import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../utils/app_styles.dart'; // Assuming AppColors is defined here
import '../models/facture_model.dart'; // Import your Facture model
import '../models/facture_line_model.dart'; // Import your FactureLine model

class AddInvoicePage extends StatefulWidget {
  const AddInvoicePage({super.key});

  @override
  State<AddInvoicePage> createState() => _AddInvoicePageState();
}

class _AddInvoicePageState extends State<AddInvoicePage> {
  final _formKey = GlobalKey<FormState>();

  // Invoice main details controllers
  // Removed _invoiceNumberController
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _supplierNumberController =
      TextEditingController(); // Added for supplier number

  // For managing invoice line items, now using FactureLine directly
  final List<FactureLine> _lineItems = [];

  // Controllers for adding a new line item
  final TextEditingController _itemDescriptionController =
      TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();
  final TextEditingController _itemUnitPriceController =
      TextEditingController();
  final TextEditingController _itemTaxRateController = TextEditingController(
    text: '20.0',
  ); // Default tax rate

  @override
  void initState() {
    super.initState();
    // Pre-fill invoice date with today's date for convenience
    _invoiceDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());
    // Set due date to 30 days from now as a common default
    _dueDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().add(const Duration(days: 30)));
  }

  @override
  void dispose() {
    // Removed _invoiceNumberController.dispose();
    _clientNameController.dispose();
    _invoiceDateController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    _supplierNumberController.dispose(); // Dispose the new controller
    _itemDescriptionController.dispose();
    _itemQuantityController.dispose();
    _itemUnitPriceController.dispose();
    _itemTaxRateController.dispose();
    super.dispose();
  }

  // --- Date Picker Helpers ---
  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(
                context,
              ).colorScheme.primary, // AppBar background color
              onPrimary: Colors.white, // Text color on primary
              onSurface:
                  AppColors.primaryText, // Text color on calendar surface
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    AppColors.primaryText, // Color of action buttons
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // --- Line Item Management ---
  void _addInvoiceLineItem() {
    final String description = _itemDescriptionController.text.trim();
    final int? quantity = int.tryParse(
      _itemQuantityController.text,
    ); // Changed to int
    final double? unitPrice = double.tryParse(_itemUnitPriceController.text);
    final double? taxRate = double.tryParse(_itemTaxRateController.text);

    if (description.isEmpty ||
        quantity == null ||
        unitPrice == null ||
        taxRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs de l\'article.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (quantity <= 0 || unitPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La quantité et le prix unitaire doivent être supérieurs à zéro.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculate totalHT and totalTTC for the new FactureLine
    final double totalHT = quantity * unitPrice;
    final double totalTTC = totalHT * (1 + taxRate / 100);

    setState(() {
      _lineItems.add(
        FactureLine(
          description: description,
          quantity: quantity,
          priceHTPerUnit: unitPrice,
          totalHT: totalHT,
          totalTTC: totalTTC,
          vatRate: taxRate,
        ),
      );
      // Clear the input fields for the next item
      _itemDescriptionController.clear();
      _itemQuantityController.clear();
      _itemUnitPriceController.clear();
      _itemTaxRateController.text = '20.0'; // Reset to default
    });
  }

  void _removeInvoiceLineItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
    });
  }

  // --- Calculation Methods ---
  double _calculateSubtotal() {
    return _lineItems.fold(
      0.0,
      (sum, item) => sum + item.totalHT, // Use totalHT from FactureLine
    );
  }

  double _calculateTaxAmount() {
    return _lineItems.fold(0.0, (sum, item) {
      final itemTotal = item.quantity * item.priceHTPerUnit;
      return sum +
          (itemTotal * (item.vatRate / 100)); // Use vatRate from FactureLine
    });
  }

  double _calculateTotal() {
    return _lineItems.fold(
      0.0,
      (sum, item) => sum + item.totalTTC, // Use totalTTC from FactureLine
    );
  }

  // Helper to convert yyyy-MM-dd string to Unix timestamp (seconds since epoch)
  int _dateToUnixTimestamp(String dateString) {
    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(dateString);
      return dateTime.millisecondsSinceEpoch ~/ 1000;
    } catch (e) {
      print('Error parsing date: $e');
      return 0; // Return 0 or handle error appropriately
    }
  }

  // --- Invoice Actions ---
  void _saveFacture(int status) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs dans le formulaire.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une ligne de facture.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // FactureLine list is already in the correct format (_lineItems)
    final String reference = _supplierNumberController.text.isNotEmpty
        ? 'FOURNISSEUR_${_supplierNumberController.text}_${DateTime.now().millisecondsSinceEpoch}'
        : 'AUTO_GEN_${DateTime.now().millisecondsSinceEpoch}';

    final Facture newFacture = Facture(
      reference: reference,
      fournisseur:
          1, // Placeholder: In a real app, this would come from client selection
      dateCreation: _dateToUnixTimestamp(_invoiceDateController.text),
      total: _calculateTotal(),
      status: status, // 0 for Draft, 1 for Finalized
      lines:
          _lineItems, // Directly use _lineItems as they are FactureLine objects
    );

    print('Facture to save: ${newFacture.toJson()}'); // For debugging

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 0
              ? 'Facture enregistrée en brouillon !'
              : 'Facture finalisée !',
        ),
        backgroundColor: status == 0
            ? AppColors.accentBlue
            : AppColors.accentGreen,
      ),
    );
    Navigator.pop(context); // Go back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une Facture'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // --- Invoice Details Section ---
            _buildSectionHeader(context, 'Détails de la Facture'),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Removed TextFormField for _invoiceNumberController
                    TextFormField(
                      controller: _clientNameController,
                      decoration: _inputDecoration(
                        'Nom du Client / Fournisseur',
                        'Ex: SARL Dupont & Fils',
                        Icons.business,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom du client.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _invoiceDateController,
                      decoration:
                          _inputDecoration(
                            'Date de la Facture',
                            'AAAA-MM-JJ',
                            Icons.calendar_today,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit_calendar),
                              onPressed: () =>
                                  _selectDate(_invoiceDateController),
                            ),
                          ),
                      readOnly: true,
                      onTap: () => _selectDate(_invoiceDateController),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une date de facture.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dueDateController,
                      decoration:
                          _inputDecoration(
                            'Date d\'échéance (Pour vos archives)',
                            'AAAA-MM-JJ',
                            Icons.calendar_month,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit_calendar),
                              onPressed: () => _selectDate(_dueDateController),
                            ),
                          ),
                      readOnly: true,
                      onTap: () => _selectDate(_dueDateController),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une date d\'échéance.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Added TextFormField for supplier number BEFORE notes
                    TextFormField(
                      controller: _supplierNumberController,
                      decoration: _inputDecoration(
                        'Numéro Fournisseur (Optionnel)',
                        'Ex: F001',
                        Icons.person_outline,
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: _inputDecoration(
                        'Notes / Conditions de paiement (Pour vos archives)',
                        'Ex: Merci pour votre confiance !',
                        Icons.notes,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Add Line Item Section ---
            _buildSectionHeader(context, 'Ajouter un Article'),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _itemDescriptionController,
                      decoration: _inputDecoration(
                        'Description de l\'article',
                        'Ex: Développement de site web',
                        Icons.description,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _itemQuantityController,
                            decoration: _inputDecoration(
                              'Quantité',
                              '1',
                              Icons.numbers,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _itemUnitPriceController,
                            decoration: _inputDecoration(
                              'Prix Unitaire (MAD)',
                              '100.00',
                              Icons.euro,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _itemTaxRateController,
                            decoration: _inputDecoration(
                              'TVA (%)',
                              '20',
                              Icons.percent,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _addInvoiceLineItem,
                      icon: const Icon(Icons.add_shopping_cart, size: 24),
                      label: const Text(
                        'Ajouter l\'article',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Invoice Lines Preview Section ---
            _buildSectionHeader(context, 'Articles de la Facture'),
            const SizedBox(height: 16),
            if (_lineItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'Aucun article ajouté. Ajoutez des articles ci-dessus.',
                    style: TextStyle(
                      color: AppColors.neutralGrey600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _lineItems.length,
                  itemBuilder: (context, index) {
                    final item = _lineItems[index];
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          title: Text(
                            item.description,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                          ),
                          subtitle: Text(
                            '${item.quantity.toString()} x ${item.priceHTPerUnit.toStringAsFixed(2)} MAD HT (TVA ${item.vatRate.toStringAsFixed(0)}%)',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.neutralGrey700),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.totalTTC.toStringAsFixed(2)} MAD TTC',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentGreen,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.redAccent,
                                  size: 24,
                                ),
                                onPressed: () => _removeInvoiceLineItem(index),
                                tooltip: 'Supprimer cet article',
                              ),
                            ],
                          ),
                        ),
                        if (index < _lineItems.length - 1)
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: AppColors.neutralGrey300,
                          ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),

            // --- Summary Totals Section ---
            _buildSectionHeader(context, 'Résumé de la Facture'),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSummaryRow('Sous-total HT:', _calculateSubtotal()),
                    _buildSummaryRow('Montant TVA:', _calculateTaxAmount()),
                    Divider(color: AppColors.neutralGrey500, height: 24),
                    _buildSummaryRow(
                      'Total TTC:',
                      _calculateTotal(),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Action Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _saveFacture(0), // 0 for Draft
                    icon: const Icon(Icons.drafts),
                    label: const Text('Enregistrer Brouillon'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryText,
                      side: BorderSide(
                        color: AppColors.primaryText,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveFacture(1), // 1 for Finalized
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Finaliser Facture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders for Reusability ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: AppColors.neutralGrey400, thickness: 1),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.neutralGrey400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.neutralGrey400, width: 1),
      ),
      prefixIcon: Icon(icon, color: AppColors.neutralGrey700),
      labelStyle: TextStyle(color: AppColors.neutralGrey700),
      hintStyle: TextStyle(color: AppColors.neutralGrey500),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.primaryText : AppColors.neutralGrey800,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} MAD', // Changed € to MAD
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.accentGreen : AppColors.neutralGrey800,
            ),
          ),
        ],
      ),
    );
  }
}
