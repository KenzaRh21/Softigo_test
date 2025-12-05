import 'package:flutter/material.dart';
import '../services/expense_report_api_service.dart';
import '../utils/app_styles.dart';
import 'package:intl/intl.dart';

class TicketDetailPage extends StatefulWidget {
  final int reportId;
  final ExpenseReportApiService apiService;

  const TicketDetailPage({
    super.key,
    required this.reportId,
    required this.apiService,
  });

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  ExpenseReport? _report;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReportDetails();
  }

  Future<void> _fetchReportDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final fetchedReport = await widget.apiService.fetchExpenseReportById(
        widget.reportId,
      );
      setState(() {
        _report = fetchedReport;
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

  Future<void> _editReport() async {
    if (_report == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EditReportDialog(report: _report!),
    );

    if (result != null) {
      try {
        await widget.apiService.updateExpenseReport(_report!.id, result);
        await _fetchReportDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note de frais mise à jour avec succès.'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de la mise à jour: $e')),
          );
        }
      }
    }
  }

  // J'ai laissé la fonction _mapStatus même si elle n'est plus utilisée directement
  // pour le cas où tu voudrais la réutiliser plus tard.
  String _mapStatus(dynamic status) {
    if (status is int) {
      switch (status) {
        case -2:
          return 'Brouillon';
        case 0:
          return 'Validée';
        case 1:
          return 'Payée';
        case -1:
          return 'Refusée';
        default:
          return 'Inconnu';
      }
    } else if (status is String) {
      return status;
    }
    return 'Inconnu';
  }

  Color _getStatusColor(String status) {
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

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Détails de la note',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.scaffoldBackground,
        iconTheme: const IconThemeData(color: AppColors.primaryIndigo),
        elevation: 0,
        actions: [
          if (_report != null)
            IconButton(icon: const Icon(Icons.edit), onPressed: _editReport),
        ],
      ),
      body: _isLoading
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.accentRed),
              ),
            )
          : _report == null
          ? Center(
              child: Text(
                'Note de frais non trouvée.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.neutralGrey600,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(context),
                  const SizedBox(height: 24),
                  _buildDetailList(context),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Référence: ${_report!.ref}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            // La partie qui affichait le statut a été supprimée ici
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _report!.label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailList(BuildContext context) {
    return Column(
      children: [
        _buildTotalItem(context, total: _report!.total),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          icon: Icons.description,
          title: 'Description',
          value: _report!.description,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          icon: Icons.person,
          title: 'Créée par',
          value: 'Utilisateur',
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          icon: Icons.date_range,
          title: 'Période',
          value:
              'Du ${_formatDate(_report!.dateDebut)} au ${_formatDate(_report!.dateFin)}',
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          icon: Icons.access_time,
          title: 'Date de création',
          value: _formatDate(_report!.date),
        ),
      ],
    );
  }

  Widget _buildTotalItem(BuildContext context, {required double total}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryIndigo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.euro, color: AppColors.primaryIndigo),
              const SizedBox(width: 8),
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryIndigo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            '${total.toStringAsFixed(2)} €',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.primaryIndigo,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryIndigo, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.neutralGrey700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET POUR LA BOÎTE DE DIALOGUE D'ÉDITION ---
class _EditReportDialog extends StatefulWidget {
  final ExpenseReport report;

  const _EditReportDialog({required this.report});

  @override
  State<_EditReportDialog> createState() => _EditReportDialogState();
}

class _EditReportDialogState extends State<_EditReportDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _dateDebutController;
  late final TextEditingController _dateFinController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.report.label);
    _dateDebutController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.report.dateDebut),
    );
    _dateFinController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.report.dateFin),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(controller.text),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la note de frais'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Libellé'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un libellé.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateDebutController,
                decoration: const InputDecoration(
                  labelText: 'Date de début',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(_dateDebutController),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateFinController,
                decoration: const InputDecoration(
                  labelText: 'Date de fin',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(_dateFinController),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final dateDebut = DateFormat(
                'yyyy-MM-dd',
              ).parse(_dateDebutController.text);
              final dateFin = DateFormat(
                'yyyy-MM-dd',
              ).parse(_dateFinController.text);

              final updatedData = {
                'note_public': _labelController.text,
                'date_debut': (dateDebut.millisecondsSinceEpoch ~/ 1000)
                    .toString(),
                'date_fin': (dateFin.millisecondsSinceEpoch ~/ 1000).toString(),
              };
              print(
                'Données envoyées à l\'API pour le ticket ${widget.report.id}:',
              );
              print(updatedData);
              Navigator.of(context).pop(updatedData);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
