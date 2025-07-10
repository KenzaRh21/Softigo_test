// lib/pages/invoice_detail_page.dart
import 'package:flutter/material.dart';
import 'package:softigotest/pages/EditInvoicePage.dart';
import 'package:softigotest/models/facture_model.dart';
import 'package:softigotest/models/facture_line_model.dart';
import '../utils/app_styles.dart';
import 'package:intl/intl.dart';

class InvoiceDetailPage extends StatefulWidget {
  final Facture facture;

  const InvoiceDetailPage({super.key, required this.facture});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  late Facture _currentFacture;

  @override
  void initState() {
    super.initState();
    _currentFacture = widget.facture;
  }

  void _markAsFinalized() {
    if (_currentFacture.status == 0) {
      if (_currentFacture.lines.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible de valider une facture sans lignes de commande !',
            ),
            backgroundColor: AppColors.accentRed,
          ),
        );
        return;
      }
      setState(() {
        // Create a new Facture instance with updated status
        _currentFacture = Facture(
          reference: _currentFacture.reference,
          fournisseur: _currentFacture.fournisseur,
          dateCreation: _currentFacture.dateCreation,
          total: _currentFacture.total,
          status: 1, // Change status to 'Finalized' (1)
          lines: _currentFacture.lines,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Facture marquée comme validée !'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      Navigator.pop(context, _currentFacture);
    }
  }

  void _editInvoice() async {
    final updatedFacture = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditInvoicePage(facture: _currentFacture, isNewInvoice: false),
      ),
    );

    if (updatedFacture != null && updatedFacture is Facture) {
      setState(() {
        _currentFacture = updatedFacture;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Facture mise à jour avec succès !'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    }
  }

  String _formatDate(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
    ).toLocal();

    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getStatusString(int status) {
    switch (status) {
      case 0:
        return 'BROUILLON';
      case 1:
        return 'VALIDÉE';
      case 2:
        return 'PAYÉE';
      case 3:
        return 'ANNULÉE';
      default:
        return 'INCONNU';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return AppColors.accentOrange;
      case 1:
        return AppColors.accentGreen;
      default:
        return AppColors.neutralGrey500;
    }
  }

  double _calculateSubtotal() {
    return _currentFacture.lines.fold(0.0, (sum, line) => sum + line.totalHT);
  }

  double _calculateTaxAmount() {
    return _currentFacture.lines.fold(
      0.0,
      (sum, line) => sum + (line.totalTTC - line.totalHT),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDraft = _currentFacture.status == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Facture #${_currentFacture.reference}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editInvoice,
            tooltip: 'Modifier la facture',
          ),
          if (isDraft)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: _markAsFinalized,
              tooltip: 'Valider la facture',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    _currentFacture.status,
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusString(_currentFacture.status),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _getStatusColor(_currentFacture.status),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Détails Généraux',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const Divider(color: AppColors.neutralGrey300, height: 24),
            _buildDetailRow(
              'Référence:',
              _currentFacture.reference,
              icon: Icons.receipt_long,
            ),
            _buildDetailRow(
              'Fournisseur ID:',
              _currentFacture.fournisseur.toString(),
              icon: Icons.business,
            ),
            _buildDetailRow(
              'Date Création:',
              _formatDate(_currentFacture.dateCreation),
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 32),
            Text(
              'Lignes de Facture',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const Divider(color: AppColors.neutralGrey300, height: 24),
            if (_currentFacture.lines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'Aucune ligne de facture ajoutée pour cet article.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutralGrey600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: _currentFacture.lines.map((lineItem) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lineItem.description,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qté: ${lineItem.quantity} | P.U.: ${lineItem.priceHTPerUnit.toStringAsFixed(2)} MAD HT | TVA: ${lineItem.vatRate.toStringAsFixed(0)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.neutralGrey700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sous-total HT:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.neutralGrey800,
                                ),
                              ),
                              Text(
                                '${lineItem.totalHT.toStringAsFixed(2)} MAD HT',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutralGrey800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total TTC:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              Text(
                                '${lineItem.totalTTC.toStringAsFixed(2)} MAD',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryIndigo,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 32),
            Text(
              'Récapitulatif des Totaux',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const Divider(color: AppColors.neutralGrey300, height: 24),
            _buildSummaryRow('Sous-total HT:', _calculateSubtotal()),
            _buildSummaryRow('Montant TVA:', _calculateTaxAmount()),
            const Divider(color: AppColors.neutralGrey500, height: 16),
            _buildSummaryRow(
              'Montant Total (TTC):',
              _currentFacture.total,
              isTotal: true,
            ),
            const SizedBox(height: 32),
            if (isDraft)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _markAsFinalized,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Valider la Facture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(250, 55),
                    elevation: 4,
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.neutralGrey700, size: 20),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutralGrey800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  )
                : theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.neutralGrey800,
                  ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} MAD',
            style: isTotal
                ? theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryIndigo,
                  )
                : theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
          ),
        ],
      ),
    );
  }
}
