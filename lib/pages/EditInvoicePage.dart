// lib/pages/EditInvoicePage.dart
import 'package:flutter/material.dart';
import 'package:softigotest/models/facture_model.dart';
import 'package:softigotest/models/facture_line_model.dart';
import 'package:softigotest/utils/app_styles.dart';

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
  late String _currentReference;
  late int _currentFournisseurId;
  late DateTime _currentDateCreation;
  late List<FactureLine> _currentLines;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _fournisseurIdController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentReference = widget.facture.reference;
    _currentFournisseurId = widget.facture.fournisseur;
    _currentDateCreation = DateTime.fromMillisecondsSinceEpoch(
      widget.facture.dateCreation * 1000,
    );
    _currentLines = List.from(widget.facture.lines);

    _referenceController.text = _currentReference;
    _fournisseurIdController.text = _currentFournisseurId.toString();
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

  void _selectDate(BuildContext context) async {
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
    }
  }

  void _deleteLineItem(int index) {
    setState(() {
      _currentLines.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ligne supprimée !'),
        backgroundColor: AppColors.accentOrange,
      ),
    );
  }

  void _saveInvoice() {
    if (_formKey.currentState!.validate()) {
      final int? fournisseurId = int.tryParse(_fournisseurIdController.text);
      if (fournisseurId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID Fournisseur doit être un nombre entier valide.'),
            backgroundColor: AppColors.accentRed,
          ),
        );
        return;
      }

      final updatedFacture = Facture(
        reference: _referenceController.text,
        fournisseur: fournisseurId,
        dateCreation: _currentDateCreation.millisecondsSinceEpoch ~/ 1000,
        total: _calculateTotal(),
        status: widget.facture.status,
        lines: _currentLines,
      );

      Navigator.pop(context, updatedFacture);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNewInvoice
              ? 'Ajouter Lignes de Facture'
              : 'Modifier la Facture',
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.receipt_long),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Veuillez entrer l\'ID du fournisseur';
                      if (int.tryParse(value) == null)
                        return 'Veuillez entrer un nombre entier valide';
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text:
                              '${_currentDateCreation.day}/${_currentDateCreation.month}/${_currentDateCreation.year}',
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
              ),
            ),
            const Divider(color: AppColors.neutralGrey300, height: 24),
            Expanded(
              child: _currentLines.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune ligne de facture ajoutée. Cliquez sur le "+" pour en ajouter une.',
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
                                const SizedBox(height: 4),
                                Text(
                                  'Qté: ${lineItem.quantity} | P.U.: ${lineItem.priceHTPerUnit.toStringAsFixed(2)} MAD HT | TVA: ${lineItem.vatRate.toStringAsFixed(0)}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.neutralGrey700,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
            const SizedBox(height: 16),
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
            ElevatedButton.icon(
              onPressed: _saveInvoice,
              icon: const Icon(Icons.check),
              label: Text(
                widget.isNewInvoice
                    ? 'Confirmer les Lignes et Sauvegarder'
                    : 'Sauvegarder la Facture',
              ),
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
                minimumSize: const Size(double.infinity, 55),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110.0), // remonté plus haut
        child: FloatingActionButton(
          onPressed: _addLineItem,
          backgroundColor: AppColors.primaryIndigo,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _priceHTPerUnitController;
  late TextEditingController _vatRateController;

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
        _priceHTPerUnitController.text,
      );
      final double vatRate = double.parse(_vatRateController.text);

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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.line == null
                      ? 'Ajouter une Ligne'
                      : 'Modifier la Ligne',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.primaryIndigo,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Veuillez entrer une description'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantité',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Veuillez entrer une quantité valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceHTPerUnitController,
                  decoration: InputDecoration(
                    labelText: 'Prix Unitaire HT',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        double.tryParse(value) == null ||
                        double.parse(value) < 0) {
                      return 'Veuillez entrer un prix unitaire HT valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _vatRateController,
                  decoration: InputDecoration(
                    labelText: 'Taux TVA (%)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        double.tryParse(value) == null ||
                        double.parse(value) < 0) {
                      return 'Veuillez entrer un taux de TVA valide';
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
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveLineItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Sauvegarder'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
