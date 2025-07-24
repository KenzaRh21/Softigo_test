// lib/pages/create_command_page.dart
import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class CreateCommandPage extends StatefulWidget {
  const CreateCommandPage({Key? key}) : super(key: key);

  @override
  State<CreateCommandPage> createState() => _CreateCommandPageState();
}

class _CreateCommandPageState extends State<CreateCommandPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientOrSupplierNameController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _externalRefController =
      TextEditingController(); // New
  final TextEditingController _expectedDeliveryDateController =
      TextEditingController(); // New
  final TextEditingController _paymentTermsController =
      TextEditingController(); // New
  final TextEditingController _addressController =
      TextEditingController(); // New: For shipping/receiving address

  String? _selectedCommandType = 'client'; // Default to client
  String? _selectedStatus = 'Brouillon';

  // For items list
  final List<Map<String, dynamic>> _items = []; // New: List to hold items
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemQtyController = TextEditingController();
  final TextEditingController _itemUnitPriceController =
      TextEditingController();

  final List<String> _statusOptions = [
    'Brouillon',
    'En attente',
    'Validée',
    // 'Livrée', 'Annulée' are typically set after creation
  ];

  @override
  void dispose() {
    _clientOrSupplierNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _externalRefController.dispose(); // Dispose new controllers
    _expectedDeliveryDateController.dispose(); // Dispose new controllers
    _paymentTermsController.dispose(); // Dispose new controllers
    _addressController.dispose(); // Dispose new controllers
    _itemNameController.dispose(); // Dispose item controllers
    _itemQtyController.dispose();
    _itemUnitPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'), // Ensure French locale
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _addItem() {
    if (_itemNameController.text.isNotEmpty &&
        _itemQtyController.text.isNotEmpty &&
        _itemUnitPriceController.text.isNotEmpty) {
      final double qty = double.tryParse(_itemQtyController.text) ?? 0;
      final double unitPrice =
          double.tryParse(_itemUnitPriceController.text) ?? 0;
      final double total = qty * unitPrice;

      setState(() {
        _items.add({
          'name': _itemNameController.text,
          'qty': qty,
          'unit_price': unitPrice,
          'total': total,
        });
      });

      _itemNameController.clear();
      _itemQtyController.clear();
      _itemUnitPriceController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs de l\'article.'),
        ),
      );
    }
  }

  void _createCommand() {
    if (_formKey.currentState!.validate()) {
      // In a real application, you would send this data to your API
      final newCommandData = {
        'id': 'NEW${DateTime.now().millisecondsSinceEpoch}', // Dummy ID
        'client': _clientOrSupplierNameController.text,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'description': _descriptionController.text,
        'status': _selectedStatus ?? 'Brouillon',
        'date': DateTime.now().toIso8601String().substring(
          0,
          10,
        ), // Current date
        'type': _selectedCommandType,
        'external_ref': _externalRefController.text.isEmpty
            ? null
            : _externalRefController.text, // New
        'expected_delivery_date': _expectedDeliveryDateController.text.isEmpty
            ? null
            : _expectedDeliveryDateController.text, // New
        'payment_terms': _paymentTermsController.text.isEmpty
            ? null
            : _paymentTermsController.text, // New
        'items': _items, // New: Add items list
        // Conditional contact/address based on type
        if (_selectedCommandType == 'client')
          'client_email': _contactController.text
        else
          'supplier_contact': _contactController.text,
        if (_selectedCommandType == 'client')
          'shipping_address': _addressController.text
        else
          'receiving_address': _addressController.text,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Commande créée avec succès! ID: ${newCommandData['id']}',
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );

      Navigator.pop(context); // Go back to CommandListPage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Créer une Nouvelle Commande',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remplissez les informations pour créer une nouvelle commande.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutralGrey700,
                ),
              ),
              const SizedBox(height: 24),

              // Command Type Selection
              Text(
                'Type de Commande',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutralGrey300),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Commande Client'),
                      value: 'client',
                      groupValue: _selectedCommandType,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCommandType = value;
                          _contactController.clear();
                          _addressController
                              .clear(); // Clear address on type change
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    RadioListTile<String>(
                      title: const Text('Commande Fournisseur'),
                      value: 'fournisseur',
                      groupValue: _selectedCommandType,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCommandType = value;
                          _contactController.clear();
                          _addressController
                              .clear(); // Clear address on type change
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Client/Supplier Name
              TextFormField(
                controller: _clientOrSupplierNameController,
                decoration: InputDecoration(
                  labelText: _selectedCommandType == 'client'
                      ? 'Nom du Client'
                      : 'Nom du Fournisseur',
                  hintText: _selectedCommandType == 'client'
                      ? 'Ex: Société ABC'
                      : 'Ex: Fournisseur XYZ',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.neutralWhite,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du ${_selectedCommandType == 'client' ? 'client' : 'fournisseur'}.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contact Info
              TextFormField(
                controller: _contactController,
                keyboardType: _selectedCommandType == 'client'
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                decoration: InputDecoration(
                  labelText: _selectedCommandType == 'client'
                      ? 'Email du Client'
                      : 'Contact Fournisseur',
                  hintText: _selectedCommandType == 'client'
                      ? 'client@example.com'
                      : 'Numéro de téléphone ou email',
                  prefixIcon: _selectedCommandType == 'client'
                      ? const Icon(Icons.email_outlined)
                      : const Icon(Icons.contact_mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.neutralWhite,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer les informations de contact.';
                  }
                  if (_selectedCommandType == 'client' &&
                      !value.contains('@')) {
                    return 'Veuillez entrer un email valide.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // NEW: External Reference
              TextFormField(
                controller: _externalRefController,
                decoration: InputDecoration(
                  labelText: 'Référence Externe (Optionnel)',
                  hintText: _selectedCommandType == 'client'
                      ? 'PO Client (Ex: PO-12345)'
                      : 'Réf. Fournisseur (Ex: INV-9876)',
                  prefixIcon: const Icon(Icons.receipt_long),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.neutralWhite,
                ),
              ),
              const SizedBox(height: 16),

              // NEW: Expected Delivery/Receiving Date
              TextFormField(
                controller: _expectedDeliveryDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: _selectedCommandType == 'client'
                      ? 'Date de Livraison Prévue'
                      : 'Date de Réception Prévue',
                  hintText: 'Sélectionner une date',
                  prefixIcon: const Icon(Icons.event_note),
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.neutralWhite,
                ),
                onTap: () =>
                    _selectDate(context, _expectedDeliveryDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une date.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // NEW: Payment Terms
              TextFormField(
                controller: _paymentTermsController,
                decoration: InputDecoration(
                  labelText: 'Conditions de Paiement',
                  hintText: 'Ex: Net 30 jours, Paiement à réception',
                  prefixIcon: const Icon(Icons.payment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.neutralWhite,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez spécifier les conditions de paiement.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // NEW: Shipping/Receiving Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: _selectedCommandType == 'client'
                      ? 'Adresse de Livraison'
                      : 'Adresse de Réception',
                  hintText: 'Ex: 123 Rue Principale, Ville, Pays',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.neutralWhite,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez spécifier l\'adresse.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount (remains the same)
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant Total (MAD)',
                  hintText: 'Ex: 1250.75',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.neutralWhite,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description (remains the same)
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description de la Commande',
                  hintText: 'Détails des produits ou services commandés...',
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.neutralWhite,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status Dropdown (remains the same)
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Statut de la Commande',
                  prefixIcon: const Icon(Icons.checklist),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.neutralWhite,
                ),
                hint: const Text('Sélectionner le statut'),
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un statut.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // NEW: Articles Section
              Text(
                'Articles de la Commande',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutralGrey300),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _itemNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'article',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _itemQtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantité',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _itemUnitPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Prix Unitaire',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter Article'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.neutralWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_items.isEmpty)
                      Text(
                        'Aucun article ajouté.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutralGrey600,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: AppColors.neutralGrey100,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                        ),
                                        Text(
                                          '${item['qty']} x ${item['unit_price'].toStringAsFixed(2)} MAD',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.neutralGrey700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${item['total'].toStringAsFixed(2)} MAD',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.accentRed,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _items.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Create Command Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _createCommand,
                  icon: const Icon(Icons.add),
                  label: const Text('Créer la Commande'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: AppColors.neutralWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
