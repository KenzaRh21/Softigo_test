// lib/pages/edit_invoice_page.dart
import 'package:flutter/material.dart';
import 'package:softigotest/models/facture_model.dart'; // Import your new Facture model
import 'package:softigotest/models/facture_line_model.dart'; // Import your new FactureLine model
import '../utils/app_styles.dart'; // Ensure this import is correct
import 'package:intl/intl.dart'; // For date formatting

class EditInvoicePage extends StatefulWidget {
  final Facture facture; // Change from Invoice to Facture

  const EditInvoicePage({
    super.key,
    required this.facture,
  }); // Change from invoice to facture

  @override
  State<EditInvoicePage> createState() => _EditInvoicePageState();
}

class _EditInvoicePageState extends State<EditInvoicePage> {
  // Controllers for invoice main details
  late TextEditingController _referenceController; // Corresponds to reference
  late TextEditingController
  _clientNameController; // No direct equivalent, assuming a client name for display
  late TextEditingController
  _invoiceDateController; // Corresponds to dateCreation
  late TextEditingController
  _dueDateController; // No direct equivalent, keeping for UI consistency
  late TextEditingController
  _notesController; // No direct equivalent in Facture, keeping for UI consistency

  // For managing invoice line items (deep copy to allow modifications)
  late List<FactureLine> _editableLineItems; // Change to FactureLine

  // Controllers for adding a new line item
  final TextEditingController _newItemDescriptionController =
      TextEditingController();
  final TextEditingController _newItemQuantityController =
      TextEditingController();
  final TextEditingController _newItemUnitPriceController =
      TextEditingController();
  final TextEditingController _newItemTaxRateController =
      TextEditingController();

  // State variables for status
  late int _currentStatus; // Corresponds to status (int)

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(
      text: widget.facture.reference,
    );
    // Assuming you might want a client name field even if not in Facture model directly
    // You might need to fetch this based on 'fournisseur' ID in a real app
    _clientNameController = TextEditingController(
      text: 'Client ID: ${widget.facture.fournisseur}', // Placeholder
    );

    // Convert Unix timestamp to human-readable date string
    _invoiceDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(
        DateTime.fromMillisecondsSinceEpoch(widget.facture.dateCreation * 1000),
      ), // Convert to milliseconds
    );
    _dueDateController = TextEditingController(
      text: DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().add(const Duration(days: 30))),
    ); // Placeholder for due date

    _notesController = TextEditingController(
      text: '', // No direct notes field in Facture model
    );
    _currentStatus = widget.facture.status;

    // Deep copy line items to allow modification without affecting the original object
    _editableLineItems = List<FactureLine>.from(
      widget.facture.lines.map(
        (item) => FactureLine(
          description: item.description,
          quantity: item.quantity,
          priceHTPerUnit: item.priceHTPerUnit,
          totalHT: item.totalHT,
          totalTTC: item.totalTTC,
          vatRate: item.vatRate,
        ),
      ),
    );

    // Set default tax rate for new items. Consider moving this default into a constant.
    _newItemTaxRateController.text = '20.0';
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _clientNameController.dispose();
    _invoiceDateController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    _newItemDescriptionController.dispose();
    _newItemQuantityController.dispose();
    _newItemUnitPriceController.dispose();
    _newItemTaxRateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        // Apply theme to date picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(
                context,
              ).colorScheme.primary, // Primary color for selected date, header
              onPrimary: Theme.of(
                context,
              ).colorScheme.onPrimary, // Text on primary
              onSurface: AppColors.primaryText, // Text on surface
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.primary, // Color for buttons like "CANCEL", "OK"
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked); // Format date for display
      });
    }
  }

  // Helper functions for calculations
  double _calculateSubtotal() {
    return _editableLineItems.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.priceHTPerUnit),
    );
  }

  double _calculateTaxAmount() {
    return _editableLineItems.fold(0.0, (sum, item) {
      final itemTotal = item.quantity * item.priceHTPerUnit;
      return sum + (itemTotal * (item.vatRate / 100));
    });
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateTaxAmount();
  }

  void _addInvoiceLineItem() {
    final String description = _newItemDescriptionController.text.trim();
    final int? quantity = int.tryParse(_newItemQuantityController.text);
    final double? unitPrice = double.tryParse(_newItemUnitPriceController.text);
    final double? taxRate = double.tryParse(_newItemTaxRateController.text);

    if (description.isEmpty ||
        quantity == null ||
        unitPrice == null ||
        taxRate == null ||
        quantity <= 0 ||
        unitPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir correctement tous les champs pour ajouter la ligne.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      final newTotalHT = quantity * unitPrice;
      final newTotalTTC = newTotalHT * (1 + taxRate / 100);

      _editableLineItems.add(
        FactureLine(
          description: description,
          quantity: quantity,
          priceHTPerUnit: unitPrice,
          totalHT: newTotalHT,
          totalTTC: newTotalTTC,
          vatRate: taxRate,
        ),
      );
      // Clear input fields for next item
      _newItemDescriptionController.clear();
      _newItemQuantityController.clear();
      _newItemUnitPriceController.clear();
      _newItemTaxRateController.text =
          '20.0'; // Reset to default, ensures consistency
    });
    // Give immediate feedback for addition
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ligne "$description" ajoutée !'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  void _removeInvoiceLineItem(int index) {
    // Show a confirmation dialog for better UX
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette ligne de facture ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _editableLineItems.removeAt(index);
                });
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ligne de facture supprimée !'),
                    backgroundColor: AppColors.accentOrange,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    // Basic validation
    if (_referenceController.text.trim().isEmpty ||
        _clientNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Numéro de facture et nom du client sont obligatoires.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convert formatted date back to Unix timestamp for the Facture model
    final int updatedDateCreation =
        DateTime.parse(_invoiceDateController.text).millisecondsSinceEpoch ~/
        1000;

    final updatedFacture = Facture(
      reference: _referenceController.text.trim(),
      fournisseur: widget
          .facture
          .fournisseur, // Keep original supplier ID or allow editing
      dateCreation: updatedDateCreation,
      total: _calculateTotal(), // Recalculate total based on edited lines
      status: _currentStatus,
      lines: _editableLineItems,
    );

    // In a real app, you'd send this `updatedFacture` object to your backend API
    // For now, we'll just print it and pop the page.
    print('Updating Facture: ${updatedFacture.reference}');
    print('New Status: ${updatedFacture.status}');
    print('New Line Items: ${updatedFacture.lines.length} lines');
    print('New Total: ${updatedFacture.total}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Facture mise à jour avec succès !'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
    Navigator.pop(context, updatedFacture); // Return the updated facture
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme for consistent styling

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifier la Facture',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: 'Enregistrer les modifications',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section: Détails Généraux de la Facture ---
            Text(
              'Détails Généraux',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const Divider(color: AppColors.neutralGrey300, height: 24),
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Numéro de Facture (Référence)',
                hintText: 'Ex: F2025-001',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clientNameController,
              decoration: const InputDecoration(
                labelText: 'Nom du Client (Fournisseur)',
                hintText: 'Ex: SARL Alpha Solutions',
              ),
              readOnly:
                  true, // Assuming client name is derived from fournisseur
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _invoiceDateController,
                    decoration: const InputDecoration(
                      labelText: 'Date de la Facture',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _pickDate(_invoiceDateController),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dueDateController,
                    decoration: const InputDecoration(
                      labelText: 'Date d\'échéance',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    readOnly: true,
                    onTap: () => _pickDate(_dueDateController),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _currentStatus,
              decoration: const InputDecoration(
                labelText: 'Statut de la Facture',
              ),
              items: [
                // Map integer status to meaningful string and color
                DropdownMenuItem<int>(
                  value: 0, // Assuming 0 is Draft
                  child: Text(
                    'Brouillon',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DropdownMenuItem<int>(
                  value: 1, // Assuming 1 is Finalized
                  child: Text(
                    'Validée',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              onChanged: (int? newValue) {
                setState(() {
                  _currentStatus = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (facultatif)',
                hintText: 'Ajoutez des informations supplémentaires ici...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // --- Section: Ajout de Lignes de Facture ---
            Text(
              'Ajouter une Ligne de Produit/Service',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const Divider(color: AppColors.neutralGrey300, height: 24),
            TextFormField(
              controller: _newItemDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Ex: Conception logo',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _newItemQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantité',
                      hintText: '1, 2, etc.',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _newItemUnitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix Unitaire HT (MAD)',
                      hintText: '100.00',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _newItemTaxRateController,
                    decoration: const InputDecoration(
                      labelText: 'TVA (%)',
                      hintText: '20',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addInvoiceLineItem,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Ajouter cette ligne'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    theme.colorScheme.secondary, // Uses accent green
                foregroundColor: theme.colorScheme.onSecondary, // White text
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Section: Lignes de Facture Actuelles ---
            Text(
              'Lignes Existantes',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const Divider(color: AppColors.neutralGrey300, height: 24),
            if (_editableLineItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'Aucune ligne de facture ajoutée pour le moment.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutralGrey600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              // Use a Column of Cards for better visual separation and click targets
              Column(
                children: _editableLineItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  FactureLine item = entry.value; // Change type to FactureLine

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    elevation: 1, // Lighter elevation for individual items
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.description,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeInvoiceLineItem(index),
                                tooltip: 'Supprimer cette ligne',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qté: ${item.quantity} | P.U. HT: ${item.priceHTPerUnit.toStringAsFixed(2)} MAD | TVA: ${item.vatRate.toStringAsFixed(0)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.neutralGrey700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sous-total:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.neutralGrey800,
                                ),
                              ),
                              Text(
                                '${item.totalHT.toStringAsFixed(2)} MAD HT',
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
                                '${item.totalTTC.toStringAsFixed(2)} MAD',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors
                                      .primaryIndigo, // Highlight individual item total
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
            const SizedBox(height: 24),

            // --- Section: Totaux de la Facture ---
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
              _calculateTotal(),
              isTotal: true,
            ),
            const SizedBox(height: 32),

            // Save button at the bottom (repeated for easy access)
            Center(
              // Center the save button
              child: ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer toutes les modifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(250, 55), // Give it a minimum size
                  elevation: 4, // More prominent elevation
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper for summary rows (retained, but now using theme text styles)
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
