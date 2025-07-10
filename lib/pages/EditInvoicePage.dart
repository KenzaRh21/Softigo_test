import 'package:flutter/material.dart';
import 'package:softigotest/services/facture_api_service.dart';
import 'package:softigotest/models/facture_model.dart';
import 'package:softigotest/models/facture_line_model.dart';
import 'package:softigotest/pages/confirmation_invoice_page.dart';
import 'package:softigotest/utils/app_styles.dart';
import 'package:softigotest/models/invoice_line_create_model.dart';
import 'package:intl/intl.dart';
import 'package:softigotest/models/product_model.dart'; // Import the new Product model

final FactureApiService _factureApiService = FactureApiService();

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
  late final TextEditingController _referenceController;
  late final TextEditingController _fournisseurIdController;
  late DateTime _currentDateCreation;
  late List<FactureLine> _currentLines;

  final _formKey = GlobalKey<FormState>();

  final List<String> _invoiceSteps = ['Détails', 'Articles', 'Confirmation'];
  int _currentStepIndex = 1;

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
        // Pass the list of predefined products to the dialog
        return SimpleAddLineItemDialog(
          predefinedProducts: [
            Product(
              id: 1,
              name: 'Service de Conseil',
              priceHT: 1500.00,
              vatRate: 20,
            ),
            Product(
              id: 2,
              name: 'Développement Logiciel',
              priceHT: 5000.00,
              vatRate: 20,
            ),
            Product(
              id: 3,
              name: 'Maintenance Annuelle',
              priceHT: 800.00,
              vatRate: 10,
            ),
            Product(
              id: 4,
              name: 'Matériel Informatique',
              priceHT: 1200.00,
              vatRate: 20,
            ),
            Product(
              id: 5,
              name: 'Formation Utilisateurs',
              priceHT: 600.00,
              vatRate: 10,
            ),
          ],
        );
      },
    );

    if (newLine != null) {
      setState(() {
        _currentLines.add(newLine);
      });

      // Convert FactureLine to InvoiceLineCreate
      final invoiceLine = InvoiceLineCreate(
        libelle: newLine.description,
        qty: newLine.quantity.toDouble(),
        price: newLine.priceHTPerUnit,
        tva_tx: newLine.vatRate,
        description: newLine.description,
      );

      // Send to API (make sure facture has an ID)
      if (widget.facture.id != null) {
        try {
          bool success = await _factureApiService.addLineToFacture(
            invoiceId: int.parse(widget.facture.id!),
            line: invoiceLine,
          );

          if (success) {
            _showSnackBar('Ligne envoyée à l\'API !', AppColors.accentGreen);
          } else {
            _showSnackBar(
              'Échec d\'envoi de la ligne à l\'API.',
              AppColors.accentRed,
            );
          }
        } catch (e) {
          _showSnackBar('Erreur API: $e', AppColors.accentRed);
        }
      } else {
        _showSnackBar(
          'Facture sans ID, impossible d\'ajouter la ligne.',
          AppColors.accentRed,
        );
      }
    }
  }

  void _editLineItem(int index, FactureLine lineToEdit) async {
    final FactureLine? updatedLine = await showDialog<FactureLine>(
      context: context,
      builder: (BuildContext context) {
        return SimpleAddLineItemDialog(
          line: lineToEdit,
          predefinedProducts: [
            Product(
              id: 1,
              name: 'Service de Conseil',
              priceHT: 1500.00,
              vatRate: 20,
            ),
            Product(
              id: 2,
              name: 'Développement Logiciel',
              priceHT: 5000.00,
              vatRate: 20,
            ),
            Product(
              id: 3,
              name: 'Maintenance Annuelle',
              priceHT: 800.00,
              vatRate: 10,
            ),
            Product(
              id: 4,
              name: 'Matériel Informatique',
              priceHT: 1200.00,
              vatRate: 20,
            ),
            Product(
              id: 5,
              name: 'Formation Utilisateurs',
              priceHT: 600.00,
              vatRate: 10,
            ),
          ],
        );
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Future<void> _saveInvoice() async {
    if (_formKey.currentState!.validate()) {
      final int? fournisseurId = int.tryParse(_fournisseurIdController.text);
      if (fournisseurId == null) {
        _showSnackBar(
          'Erreur: L\'ID Fournisseur doit être un nombre entier valide.',
          AppColors.accentRed,
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

      _showSnackBar(
        widget.isNewInvoice
            ? 'Facture créée avec succès !'
            : 'Facture sauvegardée avec succès !',
        AppColors.accentGreen,
      );
      final Facture? finalFacture = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ConfirmationInvoicePage(facture: updatedFacture),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, updatedFacture);
      });
    } else {
      _showSnackBar(
        'Erreur: Veuillez corriger les champs en rouge.',
        AppColors.accentRed,
      );
    }
  }

  Widget _buildInvoiceStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_invoiceSteps.length, (index) {
          final isCompleted = index < _currentStepIndex;
          final isActive = index == _currentStepIndex;
          final isFuture = index > _currentStepIndex;

          Color circleColor = Colors.transparent;
          Color textColor = AppColors.primaryText.withOpacity(0.7);

          if (isActive) {
            circleColor = AppColors.primaryIndigo;
            textColor = AppColors.primaryText;
          } else if (isCompleted) {
            circleColor = AppColors.accentGreen;
            textColor = AppColors.primaryText.withOpacity(0.6);
          } else if (isFuture) {
            circleColor = Colors.grey[400]!;
            textColor = Colors.grey[600]!;
          }

          Widget stepWidget = Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: circleColor,
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isActive ? 16 : 14,
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                _invoiceSteps[index],
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );

          if (index < _invoiceSteps.length - 1) {
            return Expanded(
              child: Row(
                children: [
                  stepWidget,
                  Expanded(
                    child: Container(
                      height: 2.0,
                      color: isCompleted
                          ? AppColors.accentGreen
                          : Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return stepWidget;
          }
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNewInvoice ? 'Nouvelle Facture' : 'Modifier Facture',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveInvoice,
            tooltip: 'Sauvegarder les modifications',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvoiceStepper(),
          Divider(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.receipt_long),
                            filled: true,
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
                              borderRadius: BorderRadius.circular(10),
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: AppColors.neutralGrey100,
                              ),
                              controller: TextEditingController(
                                text: DateFormat(
                                  'dd/MM/yyyy',
                                ).format(_currentDateCreation),
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
                      fontWeight: FontWeight.bold,
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
                                margin: const EdgeInsets.only(bottom: 10.0),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                    color:
                                                        AppColors.primaryText,
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
                                                  color:
                                                      AppColors.primaryIndigo,
                                                ),
                                                onPressed: () => _editLineItem(
                                                  index,
                                                  lineItem,
                                                ),
                                                tooltip: 'Modifier cette ligne',
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: AppColors.accentRed,
                                                ),
                                                onPressed: () =>
                                                    _deleteLineItem(index),
                                                tooltip:
                                                    'Supprimer cette ligne',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Qté: ${lineItem.quantity} | P.U.: ${lineItem.priceHTPerUnit.toStringAsFixed(2)} MAD HT | TVA: ${lineItem.vatRate.toStringAsFixed(0)}%',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
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
                                                  color:
                                                      AppColors.neutralGrey800,
                                                ),
                                          ),
                                          Text(
                                            '${lineItem.totalHT.toStringAsFixed(2)} MAD HT',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AppColors.neutralGrey800,
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
                                                  color:
                                                      AppColors.primaryIndigo,
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: FloatingActionButton.small(
                        onPressed: _addLineItem,
                        backgroundColor: AppColors.primaryIndigo,
                        tooltip: 'Ajouter une ligne de facture',
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
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
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveInvoice,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        widget.isNewInvoice
                            ? 'Créer la Facture'
                            : 'Sauvegarder la Facture',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Added spacing at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple and modern dialog
class SimpleAddLineItemDialog extends StatefulWidget {
  final FactureLine? line;
  final List<Product> predefinedProducts; // List of predefined products

  const SimpleAddLineItemDialog({
    super.key,
    this.line,
    required this.predefinedProducts,
  });

  @override
  State<SimpleAddLineItemDialog> createState() =>
      _SimpleAddLineItemDialogState();
}

enum ProductSelectionType { custom, predefined }

class _SimpleAddLineItemDialogState extends State<SimpleAddLineItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceHTPerUnitController;
  late final TextEditingController _vatRateController;

  ProductSelectionType _selectionType = ProductSelectionType.custom;
  Product? _selectedProduct;

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

    // If editing an existing line, try to match it to a predefined product
    if (widget.line != null) {
      final matchingProduct = widget.predefinedProducts.firstWhere(
        (product) =>
            product.name == widget.line!.description &&
            product.priceHT == widget.line!.priceHTPerUnit &&
            product.vatRate == widget.line!.vatRate,
        orElse: () => Product(
          id: -1,
          name: '',
          priceHT: -1,
          vatRate: -1,
        ), // Dummy product if not found
      );

      if (matchingProduct.id != -1) {
        _selectionType = ProductSelectionType.predefined;
        _selectedProduct = matchingProduct;
      } else {
        _selectionType = ProductSelectionType.custom;
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceHTPerUnitController.dispose();
    _vatRateController.dispose();
    super.dispose();
  }

  void _updateFieldsFromSelectedProduct(Product product) {
    _descriptionController.text = product.name;
    _priceHTPerUnitController.text = product.priceHT.toStringAsFixed(2);
    _vatRateController.text = product.vatRate.toStringAsFixed(0);
    // Quantity is still user-defined, so don't update it
  }

  void _saveLineItem() {
    if (_formKey.currentState!.validate()) {
      final int quantity = int.parse(_quantityController.text);
      final double priceHTPerUnit = double.parse(
        _priceHTPerUnitController.text.replaceAll(',', '.'),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.line == null ? 'Ajouter une Ligne' : 'Modifier la Ligne',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryIndigo,
                ),
              ),
              const SizedBox(height: 24),

              // Toggle between custom and predefined
              Container(
                decoration: BoxDecoration(
                  color: AppColors.neutralGrey100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<ProductSelectionType>(
                        title: const Text('Description Libre'),
                        value: ProductSelectionType.custom,
                        groupValue: _selectionType,
                        onChanged: (ProductSelectionType? value) {
                          setState(() {
                            _selectionType = value!;
                            // Clear predefined product selection when switching to custom
                            _selectedProduct = null;
                            // Optionally clear description/price if switching from a predefined one
                            // _descriptionController.clear();
                            // _priceHTPerUnitController.clear();
                            // _vatRateController.clear();
                          });
                        },
                        activeColor: AppColors.primaryIndigo,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<ProductSelectionType>(
                        title: const Text('Produit Prédéfini'),
                        value: ProductSelectionType.predefined,
                        groupValue: _selectionType,
                        onChanged: (ProductSelectionType? value) {
                          setState(() {
                            _selectionType = value!;
                            // If there's only one predefined product, select it automatically
                            if (widget.predefinedProducts.isNotEmpty &&
                                _selectedProduct == null) {
                              _selectedProduct =
                                  widget.predefinedProducts.first;
                              _updateFieldsFromSelectedProduct(
                                _selectedProduct!,
                              );
                            }
                          });
                        },
                        activeColor: AppColors.primaryIndigo,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_selectionType == ProductSelectionType.predefined)
                DropdownButtonFormField<Product>(
                  decoration: InputDecoration(
                    labelText: 'Produit/Service',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.category),
                    filled: true,
                    fillColor: AppColors.neutralGrey100,
                    isDense: true,
                  ),
                  value: _selectedProduct,
                  onChanged: (Product? newValue) {
                    setState(() {
                      _selectedProduct = newValue;
                      if (newValue != null) {
                        _updateFieldsFromSelectedProduct(newValue);
                      }
                    });
                  },
                  items: widget.predefinedProducts
                      .map<DropdownMenuItem<Product>>((Product product) {
                        return DropdownMenuItem<Product>(
                          value: product,
                          child: Text(
                            product.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      })
                      .toList(),
                  validator: (value) {
                    if (_selectionType == ProductSelectionType.predefined &&
                        value == null) {
                      return 'Veuillez sélectionner un produit/service';
                    }
                    return null;
                  },
                )
              else
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description de l\'article',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.description),
                    filled: true,
                    fillColor: AppColors.neutralGrey100,
                    isDense: true,
                  ),
                  validator: (value) {
                    if (_selectionType == ProductSelectionType.custom &&
                        (value == null || value.isEmpty)) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                  maxLines: 3,
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
                  prefixIcon: const Icon(Icons.numbers),
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
                  labelText: 'Prix Unitaire HT (MAD)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.euro),
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
                  prefixIcon: const Icon(Icons.percent),
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
                      foregroundColor: AppColors.neutralGrey700,
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
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
