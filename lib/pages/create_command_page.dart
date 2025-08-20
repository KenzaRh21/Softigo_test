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
  // final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTime? _expectedDeliveryDate;
  String? _selectedCommandType = 'client';
  String? _selectedStatus = 'Brouillon';
  String? _selectedPaymentTerm;
  String? _selectedPaymentMethod;

  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemQtyController = TextEditingController();
  final TextEditingController _itemUnitPriceController =
      TextEditingController();
  String? _selectedTVA = '20'; // Ajout du champ pour la TVA

  // Variables pour les totaux
  double _totalHT = 0.0;
  double _totalTVA = 0.0;
  double _totalTTC = 0.0;

  final List<String> _statusOptions = ['Brouillon', 'En attente', 'Validée'];
  final List<String> _tvaOptions = ['7', '10', '15', '20'];

  final List<String> _paymentTermsOptions = [
    'A réception',
    '30 jours',
    '30 jours fin de mois',
    '60 jours',
    'A commande',
    'A livraison',
    '50/50',
    '10 jours',
    '10 jours fin de mois',
    '14 jours',
  ];

  final Map<String, int> _paymentTermsIds = {
    'A réception': 1,
    '30 jours': 2,
    '30 jours fin de mois': 3,
    '60 jours': 4,
    'A commande': 5,
    'A livraison': 6,
    '50/50': 7,
    '10 jours': 8,
    '10 jours fin de mois': 9,
    '14 jours': 10,
  };

  final List<String> _paymentMethodsOptions = [
    'Carte bancaire',
    'Chèque',
    'Espèce',
    'Ordre de prélèvement',
    'Virement bancaire',
  ];

  final Map<String, int> _paymentMethodsIds = {
    'Carte bancaire': 2,
    'Chèque': 1,
    'Espèce': 4,
    'Ordre de prélèvement': 3,
    'Virement bancaire': 5,
  };

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
    // _descriptionController.dispose();
    _contactController.dispose();
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
        _itemUnitPriceController.text.isNotEmpty &&
        _selectedTVA != null) {
      final double qty = double.tryParse(_itemQtyController.text) ?? 0;
      final double unitPrice =
          double.tryParse(_itemUnitPriceController.text) ?? 0;
      final double tvaRate = double.tryParse(_selectedTVA!) ?? 0;

      final double totalHT = qty * unitPrice;
      final double totalTVA = totalHT * (tvaRate / 100);
      final double totalTTC = totalHT + totalTVA;

      setState(() {
        _items.add({
          'name': _itemNameController.text,
          'qty': qty,
          'unit_price': unitPrice,
          'tva_tx': tvaRate,
          'total_ht': totalHT,
          'total_tva': totalTVA,
          'total_ttc': totalTTC,
        });
        _calculateTotals();
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

  void _calculateTotals() {
    double newTotalHT = 0.0;
    double newTotalTVA = 0.0;
    double newTotalTTC = 0.0;

    for (final item in _items) {
      newTotalHT += item['total_ht'] as double;
      newTotalTVA += item['total_tva'] as double;
      newTotalTTC += item['total_ttc'] as double;
    }

    setState(() {
      _totalHT = newTotalHT;
      _totalTVA = newTotalTVA;
      _totalTTC = newTotalTTC;
    });
  }

  Future<void> _createOrderAndItems() async {
    if (!_formKey.currentState!.validate() ||
        _selectedClient == null ||
        _expectedDeliveryDate == null ||
        _selectedStatus == null) {
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
        final int socid = int.parse(_selectedClient!['id']);

        final Map<String, int> statusMap = {
          'Brouillon': 0,
          'En attente': 1,
          'Validée': 2,
        };
        final int statusId = statusMap[_selectedStatus]!;

        final int? paymentTermId = _selectedPaymentTerm != null
            ? _paymentTermsIds[_selectedPaymentTerm]
            : null;

        final int? paymentMethodId = _selectedPaymentMethod != null
            ? _paymentMethodsIds[_selectedPaymentMethod]
            : null;

        final int deliveryDateTimestamp =
            _expectedDeliveryDate!.millisecondsSinceEpoch ~/ 1000;

        final String currentDate = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now());

        // Commenté car _descriptionController est disposé dans la méthode dispose() mais n'est pas déclaré
        // newOrderId = await _commandApiService.createClientCommand(
        //   socid: socid,
        //   date: currentDate,
        //   deliveryDate: deliveryDateTimestamp,
        //   notePublic: _descriptionController.text,
        //   notePrivate: _descriptionController.text,
        //   status: statusId,
        //   contact: _contactController.text,
        //   modeReglementId: paymentMethodId,
        //   condReglementId: paymentTermId,
        //   address: _addressController.text,
        //   totalAmount: _totalTTC, // Utilisation du total TTC
        // );

        // Remplacer le code ci-dessus par une version qui utilise une variable déclarée
        final TextEditingController _descriptionController =
            TextEditingController();
        newOrderId = await _commandApiService.createClientCommand(
          socid: socid,
          date: currentDate,
          deliveryDate: deliveryDateTimestamp,
          notePublic: _descriptionController.text,
          notePrivate: _descriptionController.text,
          status: statusId,
          contact: _contactController.text,
          modeReglementId: paymentMethodId,
          condReglementId: paymentTermId,
          address: _addressController.text,
          totalAmount: _totalTTC, // Utilisation du total TTC
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'En-tête de la commande client créé avec succès ! ID: $newOrderId',
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );

        final fullCommandData = await _commandApiService.fetchOrder(newOrderId);
        print('DEBUG: Données de la commande complètes: $fullCommandData');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Commande ${fullCommandData['ref']} créée et les détails récupérés !',
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );

        if (_items.isNotEmpty) {
          for (final item in _items) {
            await _commandApiService.addCommandLine(
              orderId: newOrderId,
              description: item['name'],
              quantity: item['qty'],
              unitPrice: item['unit_price'],
              vatRate: item['tva_tx'],
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Articles ajoutés à la commande avec succès.'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      } catch (e, stackTrace) {
        print('DEBUG: Erreur lors de la création de la commande');
        print('Erreur: $e');
        print('Stack Trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de la commande: $e'),
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
                    _buildDateField(),
                    const SizedBox(height: 16),
                    // Dropdown pour les conditions de paiement
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentTerm,
                      decoration: InputDecoration(
                        labelText: 'Conditions de Paiement',
                        prefixIcon: const Icon(Icons.payment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.neutralWhite,
                      ),
                      hint: const Text('Sélectionner une option'),
                      items: _paymentTermsOptions.map((String term) {
                        return DropdownMenuItem<String>(
                          value: term,
                          child: Text(term),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPaymentTerm = newValue;
                        });
                      },
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // NEW: Dropdown for payment methods
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      decoration: InputDecoration(
                        labelText: 'Mode de Paiement',
                        prefixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.neutralWhite,
                      ),
                      hint: const Text('Sélectionner une option'),
                      items: _paymentMethodsOptions.map((String method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPaymentMethod = newValue;
                        });
                      },
                      validator: (value) {
                        return null;
                      },
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
                    // Comme _descriptionController est commenté, vous devez soit le décommenter et le déclarer
                    // soit le remplacer par une nouvelle instance pour éviter une erreur lors de l'appel de `dispose()`.
                    // J'ai ajouté une déclaration locale dans _createOrderAndItems pour l'exemple.
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

                    // Section Articles
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedTVA,
                                  decoration: const InputDecoration(
                                    labelText: 'TVA (%)',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: _tvaOptions.map((String tva) {
                                    return DropdownMenuItem<String>(
                                      value: tva,
                                      child: Text('$tva%'),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedTVA = newValue;
                                    });
                                  },
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
                                              const SizedBox(height: 4),
                                              Text(
                                                'Qty: ${item['qty']} | P.U.: ${item['unit_price']} | TVA: ${item['tva_rate']}%',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                              Text(
                                                'HT: ${item['total_ht'].toStringAsFixed(2)} | TVA: ${item['total_tva'].toStringAsFixed(2)}',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'TTC: ${item['total_ttc'].toStringAsFixed(2)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: AppColors.accentRed,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _items.removeAt(index);
                                              _calculateTotals();
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
                    const SizedBox(height: 24),

                    // Section Totaux
                    Card(
                      color: AppColors.neutralWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTotalRow(
                              'Total HT:',
                              _totalHT,
                              AppColors.neutralGrey700,
                            ),
                            const SizedBox(height: 8),
                            _buildTotalRow(
                              'Total TVA:',
                              _totalTVA,
                              AppColors.neutralGrey700,
                            ),
                            const Divider(
                              height: 24,
                              color: AppColors.neutralGrey300,
                            ),
                            _buildTotalRow(
                              'Total TTC:',
                              _totalTTC,
                              AppColors.primaryText,
                              isBold: true,
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _createOrderAndItems,
                        icon: const Icon(Icons.check),
                        label: const Text('Créer la Commande'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          foregroundColor: AppColors.neutralWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double value,
    Color color, {
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
        Text(
          '${value.toStringAsFixed(2)} €',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
