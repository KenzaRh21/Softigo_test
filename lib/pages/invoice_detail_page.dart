// lib/pages/invoice_detail_page.dart
import 'package:flutter/material.dart';
import 'package:softigotest/pages/EditInvoicePage.dart'; // Make sure this path is correct if it moves
import 'package:softigotest/models/facture_model.dart'; // Import your new Facture model
import 'package:softigotest/models/facture_line_model.dart'; // Import your new FactureLine model
import '../utils/app_styles.dart'; // Ensure this import is correct

// For date formatting
import 'package:intl/intl.dart';

class InvoiceDetailPage extends StatefulWidget {
  final Facture facture; // Change from Invoice to Facture

  const InvoiceDetailPage({super.key, required this.facture});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  late Facture
  _currentFacture; // To allow local updates after editing or finalizing

  @override
  void initState() {
    super.initState();
    _currentFacture = widget.facture;
  }

  // --- Action Methods ---

  // Handles marking the invoice as finalized
  void _markAsFinalized() {
    // Assuming status 0 means 'Draft' and 1 means 'Finalized' based on common API patterns
    if (_currentFacture.status == 0) {
      // If current status is Draft (0)
      setState(() {
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
      // Return the updated facture to the previous page (FacturesPage)
      Navigator.pop(context, _currentFacture);
    }
  }

  // Handles navigation to the Edit Invoice Page
  void _editInvoice() async {
    // Navigate to EditInvoicePage and wait for a result
    // You might need to adapt EditInvoicePage to also use the new Facture model
    final updatedFacture = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInvoicePage(
          facture: _currentFacture,
        ), // Still passing as 'invoice' prop
      ),
    );

    // If EditInvoicePage returned an updated facture, refresh the UI
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
      // Optionally, if you want the FacturesPage to also refresh,
      // you could pop this page with the updatedFacture as well.
      // Navigator.pop(context, _currentFacture);
      // For now, we only update the current page.
    }
  }

  // Helper to format Unix timestamp to a readable date string
  String _formatDate(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
    ); // Unix timestamp is usually in seconds
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Helper to get status string from integer status
  String _getStatusString(int status) {
    switch (status) {
      case 0:
        return 'BROUILLON';
      case 1:
        return 'VALIDÉE';
      case 2:
        return 'PAYÉE'; // Example
      case 3:
        return 'ANNULÉE'; // Example
      default:
        return 'INCONNU';
    }
  }

  // Helper to get status color from integer status
  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return AppColors.accentOrange; // Draft
      case 1:
        return AppColors.accentGreen; // Validated/Finalized
      default:
        return AppColors.neutralGrey500; // Default for unknown/other
    }
  }

  // --- Calculation Methods ---
  double _calculateSubtotal() {
    // Summing totalHT from each FactureLine
    return _currentFacture.lines.fold(0.0, (sum, line) => sum + line.totalHT);
  }

  double _calculateTaxAmount() {
    // Summing (totalTTC - totalHT) for each FactureLine to get total tax for each line
    return _currentFacture.lines.fold(
      0.0,
      (sum, line) => sum + (line.totalTTC - line.totalHT),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDraft =
        _currentFacture.status ==
        0; // Check status against new integer representation

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Facture #${_currentFacture.reference}', // Use 'reference'
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          // Edit Button: Always available to modify invoice details
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editInvoice,
            tooltip: 'Modifier la facture',
          ),
          // Validate Button: Only visible if the invoice is a Draft
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
            // --- Invoice Status Badge ---
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
                  borderRadius: BorderRadius.circular(20), // More rounded badge
                ),
                child: Text(
                  _getStatusString(_currentFacture.status), // Use new helper
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _getStatusColor(_currentFacture.status),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8, // Slightly more spaced letters
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Section: Détails Généraux ---
            Text(
              'Détails Généraux',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const Divider(color: AppColors.neutralGrey300, height: 24),
            _buildDetailRow(
              'Référence:',
              _currentFacture.reference, // Use 'reference'
              icon: Icons.receipt_long,
            ),
            _buildDetailRow(
              'Fournisseur ID:', // Or fetch supplier name using this ID
              _currentFacture.fournisseur.toString(),
              icon: Icons.business,
            ),
            _buildDetailRow(
              'Date Création:',
              _formatDate(_currentFacture.dateCreation), // Format timestamp
              icon: Icons.calendar_today,
            ),
            // Assuming dueDate is not directly available in Facture for now based on your model.
            // If you need a due date, it would need to be added to Facture model or derived.
            // _buildDetailRow(
            //   'Date d\'échéance:',
            //   _formatDate(_currentInvoice.dueDate),
            //   icon: Icons.calendar_month,
            // ),
            const SizedBox(height: 32),

            // --- Section: Lignes de Facture ---
            Text(
              'Lignes de Facture',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const Divider(color: AppColors.neutralGrey300, height: 24),
            if (_currentFacture
                .lines
                .isEmpty) // Check against the new 'lines' list
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
              // Display line items in a more structured way, e.g., using Cards
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
                            lineItem
                                .description, // Use FactureLine's description
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Allow description to wrap if long
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

            // --- Section: Récapitulatif des Totaux ---
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
              _currentFacture.total, // Use total from Facture model
              isTotal: true,
            ),
            const SizedBox(height: 32),

            // --- Bottom Action Button (Validate if Draft) ---
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

  // --- Helper Widgets ---

  // Helper for general detail rows
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
            width: 140, // Consistent width for labels
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

  // Helper for summary total rows (reused)
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
