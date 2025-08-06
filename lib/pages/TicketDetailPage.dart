// lib/pages/TicketDetailPage.dart

import 'package:flutter/material.dart';
import '../services/expense_report_api_service.dart';
import '../utils/app_styles.dart';
import 'package:intl/intl.dart';

class TicketDetailPage extends StatefulWidget {
  final int reportId;
  final ExpenseReportApiService apiService;

  const TicketDetailPage({
    Key? key,
    required this.reportId,
    required this.apiService,
  }) : super(key: key);

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
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(context),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildMainDetailsCard(context)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _buildUserCard(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAdditionalDetailsList(context),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Référence: ${_report!.ref}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(_report!.status).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _report!.status,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _getStatusColor(_report!.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainDetailsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, 'Libellé', _report!.label),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              'Total',
              '${_report!.total.toStringAsFixed(2)} €',
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Description', _report!.description),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_pin,
              size: 48,
              color: AppColors.primaryIndigo,
            ),
            const SizedBox(height: 8),
            Text(
              'Créée par',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.neutralGrey700),
            ),
            const SizedBox(height: 4),
            Text(
              'Utilisateur',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetailsList(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildListTile(
              context,
              title: 'Période',
              value:
                  'Du ${_formatDate(_report!.dateDebut)} au ${_formatDate(_report!.dateFin)}',
              icon: Icons.calendar_month,
            ),
            _buildListTile(
              context,
              title: 'Date de création',
              value: _formatDate(_report!.date),
              icon: Icons.access_time,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.neutralGrey700,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryIndigo),
      title: Text(title),
      subtitle: Text(value),
      titleTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.neutralGrey700,
      ),
      subtitleTextStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.primaryText),
    );
  }
}

// --- WIDGET POUR LA BOÎTE DE DIALOGUE D'ÉDITION ---
class _EditReportDialog extends StatefulWidget {
  final ExpenseReport report;

  const _EditReportDialog({Key? key, required this.report}) : super(key: key);

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
      // Cette ligne est la plus importante !
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
              // Champ de date de début
              TextFormField(
                controller: _dateDebutController,
                decoration: const InputDecoration(
                  labelText: 'Date de début',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true, // Empêche l'édition manuelle
                onTap: () => _selectDate(_dateDebutController),
              ),
              const SizedBox(height: 16),
              // Champ de date de fin
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
              // Convertir les chaînes de dates en objets DateTime
              final dateDebut = DateFormat(
                'yyyy-MM-dd',
              ).parse(_dateDebutController.text);
              final dateFin = DateFormat(
                'yyyy-MM-dd',
              ).parse(_dateFinController.text);

              // Créer le Map avec les timestamps Unix
              final updatedData = {
                'note_public': _labelController.text,
                'date_debut': (dateDebut.millisecondsSinceEpoch ~/ 1000)
                    .toString(), // Conversion en timestamp
                'date_fin': (dateFin.millisecondsSinceEpoch ~/ 1000)
                    .toString(), // Conversion en timestamp
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
