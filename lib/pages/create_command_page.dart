// lib/pages/create_command_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../services/command_api_service.dart';
import '../utils/app_styles.dart';

class CreateCommandPage extends StatefulWidget {
  const CreateCommandPage({Key? key}) : super(key: key);

  @override
  State<CreateCommandPage> createState() => _CreateCommandPageState();
}

class _CreateCommandPageState extends State<CreateCommandPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs et variables d'état
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _externalRefController = TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DateTime? _expectedDeliveryDate;

  String? _selectedCommandType = 'client';
  String? _selectedStatus = 'Brouillon';

  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemQtyController = TextEditingController();
  final TextEditingController _itemUnitPriceController =
      TextEditingController();

  final List<String> _statusOptions = ['Brouillon', 'En attente', 'Validée'];

  // Variables pour la liste déroulante des clients
  List<Map<String, dynamic>> _clients = [];
  Map<String, dynamic>? _selectedClient;
  bool _isLoadingClients = true;

  late final CommandApiService _commandApiService;

  @override
  void initState() {
    super.initState();
    final String? baseUrl = dotenv.env['API_BASE_URL'];
    final String? apiKey = dotenv.env['DOLIBARR_API_KEY'];

    if (baseUrl == null || apiKey == null) {
      throw Exception(
        'Les variables d\'environnement DOLIBARR_BASE_URL ou DOLIBARR_API_KEY ne sont pas définies.',
      );
    }
    _commandApiService = CommandApiService(baseUrl: baseUrl, apiKey: apiKey);

    _fetchClients();
  }

  Future<void> _fetchClients() async {
    try {
      final clients = await _commandApiService.getClients();
      setState(() {
        _clients = clients;
        _isLoadingClients = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des clients: $e');
      setState(() {
        _isLoadingClients = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de charger la liste des clients.'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _externalRefController.dispose();
    _paymentTermsController.dispose();
    _addressController.dispose();
    _itemNameController.dispose();
    _itemQtyController.dispose();
    _itemUnitPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedDeliveryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _expectedDeliveryDate) {
      setState(() {
        _expectedDeliveryDate = picked;
      });
    }
  }

  Widget _buildDateField() {
    return FormField<DateTime?>(
      validator: (value) {
        if (_expectedDeliveryDate == null) {
          return 'Veuillez sélectionner une date de livraison.';
        }
        return null;
      },
      builder: (FormFieldState<DateTime?> state) {
        return InkWell(
          onTap: () async {
            await _selectDate(context);
            state.didChange(_expectedDeliveryDate);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: _selectedCommandType == 'client'
                  ? 'Date de Livraison Prévue *'
                  : 'Date de Réception Prévue *',
              hintText: 'Sélectionner une date',
              prefixIcon: const Icon(Icons.event_note),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.neutralWhite,
              errorText: state.errorText,
            ),
            child: Text(
              _expectedDeliveryDate == null
                  ? ''
                  : DateFormat('dd/MM/yyyy').format(_expectedDeliveryDate!),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
      },
    );
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

  Future<void> _createOrderAndItems() async {
    if (!_formKey.currentState!.validate() || _selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires (*).'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    int? newOrderId;
    if (_selectedCommandType == 'client') {
      try {
        final int socid = int.parse(
          _selectedClient!['id'],
        ); // Log des valeurs envoyées pour la création de l'en-tête
        print(
          'DEBUG: Tentative de création de l\'en-tête de la commande avec les données suivantes:',
        );
        print('socid: $socid');
        print('refClient: ${_externalRefController.text}');
        print('notePublic: ${_descriptionController.text}');
        print('notePrivate: ${_descriptionController.text}');
        print(
          'dateLivraison: ${DateFormat('yyyy-MM-dd').format(_expectedDeliveryDate!)}',
        );

        newOrderId = await _commandApiService.createClientCommand(
          socid: socid,
          refClient: _externalRefController.text.isNotEmpty
              ? _externalRefController.text
              : 'REF_CLIENT_AUTO',
          notePublic: _descriptionController.text,
          notePrivate: _descriptionController.text,
          dateLivraison: DateFormat(
            'yyyy-MM-dd',
          ).format(_expectedDeliveryDate!),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'En-tête de la commande client créé avec succès ! ID: $newOrderId',
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } catch (e, stackTrace) {
        print('DEBUG: Erreur lors de la création de l\'en-tête de la commande');
        print('Erreur: $e');
        print('Stack Trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la création de l\'en-tête de la commande: $e',
            ),
            backgroundColor: AppColors.accentRed,
          ),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La création de commandes fournisseur n\'est pas encore implémentée.',
          ),
          backgroundColor: AppColors.accentBlue,
        ),
      );
      return;
    }

    if (newOrderId != null && _items.isNotEmpty) {
      try {
        for (final item in _items) {
          await _commandApiService.addCommandLine(
            orderId: newOrderId,
            description: item['name'],
            quantity: item['qty'],
            unitPrice: item['unit_price'],
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Articles ajoutés à la commande avec succès.'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout des articles: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }

    Navigator.pop(context);
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
      body: _isLoadingClients
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remplissez les informations pour créer une nouvelle commande. Les champs avec (*) sont obligatoires.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.neutralGrey700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Command Type Selection (Reste inchangé)
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
                                _addressController.clear();
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
                                _addressController.clear();
                              });
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dropdown pour sélectionner le client
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedClient,
                      decoration: InputDecoration(
                        labelText: _selectedCommandType == 'client'
                            ? 'Nom du Client *'
                            : 'Nom du Fournisseur *',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.neutralWhite,
                      ),
                      hint: const Text('Sélectionner un client'),
                      items: _clients.map((client) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: client,
                          child: Text(client['name']),
                        );
                      }).toList(),
                      onChanged: (Map<String, dynamic>? newValue) {
                        setState(() {
                          _selectedClient = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un client.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactController,
                      keyboardType: _selectedCommandType == 'client'
                          ? TextInputType.emailAddress
                          : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: _selectedCommandType == 'client'
                            ? 'Email du Client (Optionnel)'
                            : 'Contact Fournisseur (Optionnel)',
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
                    ),
                    const SizedBox(height: 16),
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
                    _buildDateField(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _paymentTermsController,
                      decoration: InputDecoration(
                        labelText: 'Conditions de Paiement (Optionnel)',
                        hintText: 'Ex: Net 30 jours, Paiement à réception',
                        prefixIcon: const Icon(Icons.payment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.neutralWhite,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: _selectedCommandType == 'client'
                            ? 'Adresse de Livraison (Optionnel)'
                            : 'Adresse de Réception (Optionnel)',
                        hintText: 'Ex: 123 Rue Principale, Ville, Pays',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.neutralWhite,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Montant Total (MAD) (Optionnel)',
                        hintText: 'Ex: 1250.75',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.neutralWhite,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description de la Commande (Optionnel)',
                        hintText:
                            'Détails des produits ou services commandés...',
                        prefixIcon: const Icon(Icons.description),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.neutralWhite,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Statut de la Commande *',
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
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
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
                                                      color: AppColors
                                                          .neutralGrey700,
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
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
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
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _createOrderAndItems,
                        icon: const Icon(Icons.add),
                        label: const Text('Créer la Commande'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
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
