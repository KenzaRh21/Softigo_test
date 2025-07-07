// lib/pages/EditInvoicePage.dart
import 'package:flutter/material.dart';
import 'package:softigotest/models/facture_model.dart';
import 'package:softigotest/models/facture_line_model.dart';
import 'package:softigotest/utils/app_styles.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class EditInvoicePage extends StatefulWidget {
  final Facture facture;
  final bool isNewInvoice;

  const EditInvoicePage({
    super.key,
    required this.facture,
    this.isNewInvoice = false,
  });

  @override
  State<EditInvoicePage> createState() => _EditInvoicePageState();
}

class _EditInvoicePageState extends State<EditInvoicePage> {
  // Using late final for controllers and initializing them directly
  // with widget.facture values for cleaner initState.
  late final TextEditingController _referenceController;
  late final TextEditingController _fournisseurIdController;
  late DateTime _currentDateCreation;
  late List<FactureLine> _currentLines;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(
      text: widget.facture.reference,
    );
    _fournisseurIdController = TextEditingController(
      text: widget.facture.fournisseur.toString(),
    );
    _currentDateCreation = DateTime.fromMillisecondsSinceEpoch(
      widget.facture.dateCreation * 1000,
    );
    // Deep copy the list to avoid modifying the original facture's lines directly
    _currentLines = List.of(widget.facture.lines);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _fournisseurIdController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    return _currentLines.fold(0.0, (sum, line) => sum + line.totalTTC);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDateCreation,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryIndigo,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryIndigo,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _currentDateCreation) {
      setState(() {
        _currentDateCreation = picked;
      });
    }
  }

  void _addLineItem() async {
    final FactureLine? newLine = await showDialog<FactureLine>(
      context: context,
      builder: (BuildContext context) {
        return const SimpleAddLineItemDialog();
      },
    );

    if (newLine != null) {
      setState(() {
        _currentLines.add(newLine);
      });
      _showSnackBar('Ligne ajoutée !', AppColors.accentGreen);
    }
  }

  void _editLineItem(int index, FactureLine lineToEdit) async {
    final FactureLine? updatedLine = await showDialog<FactureLine>(
      context: context,
      builder: (BuildContext context) {
        return SimpleAddLineItemDialog(line: lineToEdit);
      },
    );

    if (updatedLine != null) {
      setState(() {
        _currentLines[index] = updatedLine;
      });
      _showSnackBar('Ligne modifiée !', AppColors.primaryIndigo);
    }
  }

  void _deleteLineItem(int index) {
    setState(() {
      _currentLines.removeAt(index);
    });
    _showSnackBar('Ligne supprimée !', AppColors.accentRed);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Modern snackbar
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _saveInvoice() {
    if (_formKey.currentState!.validate()) {
      final int? fournisseurId = int.tryParse(_fournisseurIdController.text);
      if (fournisseurId == null) {
        _showSnackBar(
          'Erreur: L\'ID Fournisseur doit être un nombre entier valide.', // More explicit error message
          AppColors.accentRed,
        );
        return;
      }

      final updatedFacture = Facture(
        reference: _referenceController.text,
        fournisseur: fournisseurId,
        dateCreation: _currentDateCreation.millisecondsSinceEpoch ~/ 1000,
        total: _calculateTotal(),
        status: widget.facture.status, // Preserve original status
        lines: _currentLines,
      );

      // Successfully processed the invoice data
      // Show success message before navigating back
      _showSnackBar(
        widget.isNewInvoice
            ? 'Facture créée avec succès !'
            : 'Facture sauvegardée avec succès !',
        AppColors.accentGreen, // Use a success color
      );

      // Navigate back after a short delay to allow the SnackBar to be seen
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, updatedFacture);
      });
    } else {
      // If form validation fails, show a generic error message
      _showSnackBar(
        'Erreur: Veuillez corriger les champs en rouge.',
        AppColors.accentRed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNewInvoice ? 'Nouvelle Facture' : 'Modifier Facture',
          style: const TextStyle(
            fontWeight: FontWeight.bold, // Make app bar title bold
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0, // Remove shadow for a flatter, modern look
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveInvoice,
            tooltip: 'Sauvegarder les modifications',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _referenceController,
                    decoration: InputDecoration(
                      labelText: 'Référence de la Facture',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), // More rounded
                      ),
                      prefixIcon: const Icon(Icons.receipt_long),
                      filled: true, // Add fill color for better distinction
                      fillColor: AppColors.neutralGrey100,
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Veuillez entrer une référence'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fournisseurIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ID Fournisseur',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), // More rounded
                      ),
                      prefixIcon: const Icon(Icons.business),
                      filled: true,
                      fillColor: AppColors.neutralGrey100,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'ID du fournisseur';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre entier valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Date de Création',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // More rounded
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: AppColors.neutralGrey100,
                        ),
                        controller: TextEditingController(
                          text: DateFormat(
                            'dd/MM/yyyy',
                          ).format(_currentDateCreation), // Nicer date format
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Lignes de Facture',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.bold, // Make heading bold
              ),
            ),
            const Divider(color: AppColors.neutralGrey300, height: 24),
            Expanded(
              child: _currentLines.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune ligne de facture ajoutée. Appuyez sur le bouton "+" pour en ajouter une.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutralGrey600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _currentLines.length,
                      itemBuilder: (context, index) {
                        final lineItem = _currentLines[index];
                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 10.0,
                          ), // Slightly more space
                          elevation: 2, // Slightly more prominent shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // More rounded card
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              16.0,
                            ), // Increased padding
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lineItem.description,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryText,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: AppColors.primaryIndigo,
                                          ),
                                          onPressed: () =>
                                              _editLineItem(index, lineItem),
                                          tooltip: 'Modifier cette ligne',
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: AppColors.accentRed,
                                          ),
                                          onPressed: () =>
                                              _deleteLineItem(index),
                                          tooltip: 'Supprimer cette ligne',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Qté: ${lineItem.quantity} | P.U.: ${lineItem.priceHTPerUnit.toStringAsFixed(2)} MAD HT | TVA: ${lineItem.vatRate.toStringAsFixed(0)}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.neutralGrey700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total HT:',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: AppColors.neutralGrey800,
                                          ),
                                    ),
                                    Text(
                                      '${lineItem.totalHT.toStringAsFixed(2)} MAD HT',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.neutralGrey800,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total TTC:',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryText,
                                          ),
                                    ),
                                    Text(
                                      '${lineItem.totalTTC.toStringAsFixed(2)} MAD',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
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
                      },
                    ),
            ),
            // --- NEW POSITION FOR THE PLUS BUTTON ---
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0), // Added spacing
                child: FloatingActionButton.small(
                  onPressed: _addLineItem,
                  backgroundColor: AppColors.primaryIndigo,
                  tooltip: 'Ajouter une ligne de facture',
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
            // --- END NEW POSITION ---
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total de la Facture: ${_calculateTotal().toStringAsFixed(2)} MAD TTC',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryIndigo,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, // Make the button full width
              child: ElevatedButton.icon(
                onPressed: _saveInvoice,
                icon: const Icon(
                  Icons.check_circle_outline,
                ), // A more modern icon
                label: Text(
                  widget.isNewInvoice
                      ? 'Créer la Facture'
                      : 'Sauvegarder la Facture',
                  style: const TextStyle(fontSize: 16), // Slightly larger text
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18, // Increased vertical padding
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // More rounded button
                  ),
                  elevation: 5, // More prominent shadow for the main action
                ),
              ),
            ),
          ],
        ),
      ),
      // Removed floatingActionButton, floatingActionButtonLocation, and bottomNavigationBar
      // as the FAB is now part of the body's column.
    );
  }
}

// Simple and modern dialog
class SimpleAddLineItemDialog extends StatefulWidget {
  final FactureLine? line;

  const SimpleAddLineItemDialog({super.key, this.line});

  @override
  State<SimpleAddLineItemDialog> createState() =>
      _SimpleAddLineItemDialogState();
}

class _SimpleAddLineItemDialogState extends State<SimpleAddLineItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceHTPerUnitController;
  late final TextEditingController _vatRateController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.line?.description ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.line?.quantity.toString() ?? '',
    );
    _priceHTPerUnitController = TextEditingController(
      text: widget.line?.priceHTPerUnit.toStringAsFixed(2) ?? '',
    );
    _vatRateController = TextEditingController(
      text: widget.line?.vatRate.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceHTPerUnitController.dispose();
    _vatRateController.dispose();
    super.dispose();
  }

  void _saveLineItem() {
    if (_formKey.currentState!.validate()) {
      final int quantity = int.parse(_quantityController.text);
      final double priceHTPerUnit = double.parse(
        _priceHTPerUnitController.text.replaceAll(
          ',',
          '.',
        ), // Handle comma as decimal separator
      );
      final double vatRate = double.parse(
        _vatRateController.text.replaceAll(',', '.'),
      );

      final double totalHT = quantity * priceHTPerUnit;
      final double totalTTC = totalHT * (1 + vatRate / 100);

      final newLine = FactureLine(
        description: _descriptionController.text,
        quantity: quantity,
        priceHTPerUnit: priceHTPerUnit,
        vatRate: vatRate,
        totalHT: totalHT,
        totalTTC: totalTTC,
      );
      Navigator.of(context).pop(newLine);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
      ), // Slightly reduced horizontal padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // More rounded corners
      child: SingleChildScrollView(
        // Allows scrolling for smaller screens
        padding: const EdgeInsets.all(24.0), // Increased overall padding
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.line == null ? 'Ajouter une Ligne' : 'Modifier la Ligne',
                style: theme.textTheme.headlineSmall?.copyWith(
                  // Use theme for consistency
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryIndigo,
                ),
              ),
              const SizedBox(height: 24), // Increased spacing
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText:
                      'Description de l\'article', // More descriptive label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.description), // Add icon
                  filled: true,
                  fillColor: AppColors.neutralGrey100,
                  isDense: true,
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Veuillez entrer une description'
                    : null,
                maxLines: 3, // Allow multiple lines for description
                minLines: 1,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.numbers), // Add icon
                  filled: true,
                  fillColor: AppColors.neutralGrey100,
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value.replaceAll(',', '.')) == null ||
                      double.parse(value.replaceAll(',', '.')) <= 0) {
                    return 'Veuillez entrer une quantité valide (> 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceHTPerUnitController,
                decoration: InputDecoration(
                  labelText: 'Prix Unitaire HT (MAD)', // Specify currency
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.euro), // Icon for price
                  filled: true,
                  fillColor: AppColors.neutralGrey100,
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value.replaceAll(',', '.')) == null ||
                      double.parse(value.replaceAll(',', '.')) < 0) {
                    return 'Veuillez entrer un prix unitaire HT valide (>= 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vatRateController,
                decoration: InputDecoration(
                  labelText: 'Taux TVA (%)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.percent), // Icon for percentage
                  filled: true,
                  fillColor: AppColors.neutralGrey100,
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value.replaceAll(',', '.')) == null ||
                      double.parse(value.replaceAll(',', '.')) < 0) {
                    return 'Veuillez entrer un taux de TVA valide (>= 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          AppColors.neutralGrey700, // More subtle cancel
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveLineItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Consistent rounding
                      ),
                      elevation: 3, // Add subtle elevation
                    ),
                    child: const Text(
                      'Sauvegarder',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
