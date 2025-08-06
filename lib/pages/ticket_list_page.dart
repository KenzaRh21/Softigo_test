// lib/pages/ExpenseReportListPage.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:softigotest/pages/NewExpenseReportPage.dart';
import 'package:softigotest/pages/TicketDetailPage.dart';
import '../utils/app_styles.dart';
import '../services/expense_report_api_service.dart';

// La page principale qui liste les notes de frais
class ExpenseReportListPage extends StatefulWidget {
  const ExpenseReportListPage({Key? key}) : super(key: key);

  @override
  State<ExpenseReportListPage> createState() => _ExpenseReportListPageState();
}

class _ExpenseReportListPageState extends State<ExpenseReportListPage> {
  List<ExpenseReport> _expenseReports = [];
  bool _isLoading = true;
  String? _error;

  String? _selectedStatusFilter;
  String? _searchText;

  final TextEditingController _searchController = TextEditingController();
  late final ExpenseReportApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ExpenseReportApiService(
      baseUrl: dotenv.env['API_BASE_URL']!,
      apiKey: dotenv.env['DOLIBARR_API_KEY']!,
    );
    _fetchExpenseReports();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchExpenseReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reports = await _apiService.fetchExpenseReports();
      print(
        'Données brutes reçues de l\'API : ${reports.map((r) => r.toJson()).toList()}',
      ); // C'est une supposition, il faut adapter à la vraie structure de `report`
      setState(() {
        _expenseReports = reports;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.trim();
    });
  }

  List<ExpenseReport> _getFilteredExpenseReports() {
    List<ExpenseReport> filtered = _expenseReports;

    if (_selectedStatusFilter != null && _selectedStatusFilter != 'Tous') {
      filtered = filtered
          .where((report) => report.status == _selectedStatusFilter)
          .toList();
    }

    if (_searchText != null && _searchText!.isNotEmpty) {
      filtered = filtered
          .where(
            (report) =>
                report.label.toLowerCase().contains(
                  _searchText!.toLowerCase(),
                ) ||
                report.description.toLowerCase().contains(
                  _searchText!.toLowerCase(),
                ) ||
                report.id.toString().contains(_searchText!.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  // --- NOUVELLE MÉTHODE POUR LA SUPPRESSION ---
  Future<void> _deleteReport(int reportId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette note de frais ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteExpenseReport(reportId);
        // Après la suppression réussie, rechargez la liste
        _fetchExpenseReports();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note de frais supprimée avec succès.'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de la suppression : $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _getFilteredExpenseReports();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Mes Notes de Frais',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchExpenseReports();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rafraîchissement en cours...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterAndSearchBar(context),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryIndigo,
                      ),
                    ),
                  )
                : _error != null
                ? Center(
                    child: Text(
                      'Erreur: $_error',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accentRed,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : filteredReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: AppColors.neutralGrey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune note de frais trouvée.',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.neutralGrey600),
                        ),
                        if (_selectedStatusFilter != null ||
                            (_searchText != null && _searchText!.isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Ajustez vos filtres ou la recherche.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.neutralGrey600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return ExpenseReportCard(
                        report: report,
                        // --- PASSEZ LE CALLBACK DE SUPPRESSION ---
                        onDelete: () => _deleteReport(report.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewExpenseReportPage(),
            ),
          );
          _fetchExpenseReports();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Note'),
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: AppColors.neutralWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFilterAndSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Rechercher une note',
              hintText: 'Par libellé ou description...',
              prefixIcon: Icon(Icons.search, color: AppColors.primaryIndigo),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchText = null;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.neutralGrey400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.neutralGrey400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primaryIndigo,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.inputBackground,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
          ),
          const SizedBox(height: 16),
          _buildFilterDropdown(
            context,
            'Statut',
            Icons.filter_alt_outlined,
            _selectedStatusFilter,
            ['Tous', 'Brouillon', 'Validée', 'Payée', 'Refusée'],
            (newValue) {
              setState(() {
                _selectedStatusFilter = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    IconData icon,
    String? currentValue,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: currentValue ?? items.first,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryIndigo, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        isDense: true,
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.primaryText,
        fontSize: 13,
      ),
      isExpanded: true,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
    );
  }
}

Color getStatusColor(String status) {
  switch (status) {
    case 'Brouillon':
      return Colors.grey.shade600;
    case 'Validée':
      return Colors.blue.shade600;
    case 'Payée':
      return Colors.green.shade600;
    case 'Refusée':
      return Colors.red.shade600;
    default:
      return Colors.grey.shade400;
  }
}

// Widget pour afficher une carte de note de frais
class ExpenseReportCard extends StatelessWidget {
  final ExpenseReport report;
  // --- NOUVELLE PROPRIÉTÉ DE CALLBACK POUR LA SUPPRESSION ---
  final VoidCallback onDelete;

  const ExpenseReportCard({
    Key? key,
    required this.report,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String titleText = report.label.isNotEmpty
        ? report.label
        : report.description;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutralGrey300, width: 1),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketDetailPage(
                reportId: report.id,
                apiService: ExpenseReportApiService(
                  baseUrl: dotenv.env['API_BASE_URL']!,
                  apiKey: dotenv.env['DOLIBARR_API_KEY']!,
                ),
              ),
            ),
          );
          // Ajoutez un rafraîchissement si vous naviguez depuis la page de détails
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Réf. #${report.ref}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryIndigo,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(report.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.status,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: getStatusColor(report.status),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // --- BOUTON DE SUPPRESSION ---
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: onDelete, // Appelle le callback
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                titleText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(
                height: 24,
                thickness: 0.5,
                color: AppColors.neutralGrey300,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailChip(
                    context,
                    Icons.calendar_today_outlined,
                    'Du ${report.dateDebut.day.toString().padLeft(2, '0')}/${report.dateDebut.month.toString().padLeft(2, '0')}',
                  ),
                  _buildDetailChip(
                    context,
                    Icons.calendar_today_outlined,
                    'Au ${report.dateFin.day.toString().padLeft(2, '0')}/${report.dateFin.month.toString().padLeft(2, '0')}',
                  ),
                  _buildDetailChip(
                    context,
                    Icons.monetization_on_outlined,
                    'Total: ${report.total.toStringAsFixed(2)} €',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Créé le: ${report.date.day.toString().padLeft(2, '0')}/${report.date.month.toString().padLeft(2, '0')}/${report.date.year}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.neutralGrey600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutralGrey300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryIndigo),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
