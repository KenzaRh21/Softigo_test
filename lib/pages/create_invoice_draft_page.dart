import 'package:flutter/material.dart';
import 'package:softigotest/models/facture_model.dart';
import 'package:softigotest/pages/EditInvoicePage.dart';
import 'package:softigotest/utils/app_styles.dart';
import 'package:softigotest/services/facture_api_service.dart';
import 'package:softigotest/models/invoice_create_model.dart';

// 1. Introduce an Enum for Invoice Type
enum InvoiceType { client, supplier }

class CreateInvoiceDraftPage extends StatefulWidget {
  const CreateInvoiceDraftPage({super.key});

  @override
  State<CreateInvoiceDraftPage> createState() => _CreateInvoiceDraftPageState();
}

class _CreateInvoiceDraftPageState extends State<CreateInvoiceDraftPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _referenceController = TextEditingController();

  // Separate lists for clients and suppliers
  final List<Map<String, dynamic>> _fournisseurs = [
    {'id': 9, 'name': 'ARM'},
    {'id': 3, 'name': 'ALLIANZE '},
    {'id': 6, 'name': 'ENSA '},
    {'id': 1, 'name': 'Oulmes'},
  ];

  final List<Map<String, dynamic>> _clients = [
    {'id': 101, 'name': 'Client A Corp'},
    {'id': 102, 'name': 'Client B SARL'},
    {'id': 103, 'name': 'Client C Inc.'},
  ];

  // 2. State variable for the selected invoice type
  InvoiceType _selectedInvoiceType =
      InvoiceType.supplier; // Default to supplier

  int? _selectedEntityId; // This will hold either client_id or fournisseur_id
  DateTime _selectedCreationDate = DateTime.now();

  final List<String> _invoiceSteps = ['Détails', 'Articles', 'Confirmation'];
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize _selectedEntityId based on the default invoice type
    _initializeSelectedEntityId();
  }

  void _initializeSelectedEntityId() {
    if (_selectedInvoiceType == InvoiceType.supplier &&
        _fournisseurs.isNotEmpty) {
      _selectedEntityId = _fournisseurs.first['id'];
    } else if (_selectedInvoiceType == InvoiceType.client &&
        _clients.isNotEmpty) {
      _selectedEntityId = _clients.first['id'];
    } else {
      _selectedEntityId = null;
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _selectCreationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedCreationDate,
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
    if (picked != null && picked != _selectedCreationDate) {
      setState(() {
        _selectedCreationDate = picked;
      });
    }
  }

  void _createDraftInvoice() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedEntityId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veuillez sélectionner un ${_selectedInvoiceType == InvoiceType.supplier ? 'fournisseur' : 'client'}.',
            ),
            backgroundColor: AppColors.accentRed,
          ),
        );
        return;
      }

      setState(() {
        _currentStepIndex = 1;
      });

      final now = DateTime.now();
      final DateTime dateWithTime = DateTime(
        _selectedCreationDate.year,
        _selectedCreationDate.month,
        _selectedCreationDate.day,
        now.hour,
        now.minute,
        now.second,
      );

      // Construct InvoiceCreateRequest based on selected type
      final invoiceRequest = InvoiceCreateRequest(
        socid: _selectedEntityId!,
        date: dateWithTime.millisecondsSinceEpoch ~/ 1000,
        lines: [],
        refClient: _referenceController
            .text, // This field name might need to be dynamic on backend too
      );

      final factureService = FactureApiService();

      try {
        final int invoiceId = await factureService.createFacture(
          invoiceRequest,
          // Remove or comment out this line to avoid passing invoiceType to the API service for now
          // invoiceType: _selectedInvoiceType,
        );

        final Facture draftFacture = Facture(
          id: invoiceId,
          reference: _referenceController.text,
          // Depending on your Facture model, you might need to adjust this.
          // If 'fournisseur' means 'entity ID', then it's fine.
          fournisseur: _selectedEntityId!,
          dateCreation: _selectedCreationDate.millisecondsSinceEpoch ~/ 1000,
          total: 0.0,
          status: 0,
          lines: [],
          // Add type to Facture model if necessary for EditInvoicePage
          // type: _selectedInvoiceType.name,
        );

        final Facture? updatedFacture = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EditInvoicePage(facture: draftFacture, isNewInvoice: true),
          ),
        );

        if (updatedFacture != null) {
          Navigator.pop(context, updatedFacture);
        } else {
          setState(() {
            _currentStepIndex = 0;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la création de la facture: ${e.toString()}',
            ),
            backgroundColor: AppColors.accentRed,
          ),
        );
        setState(() {
          _currentStepIndex = 0;
        });
      }
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

          Color circleColor = Colors.transparent;
          Color textColor = AppColors.primaryText.withOpacity(0.7);

          if (isActive) {
            circleColor = AppColors.primaryIndigo;
            textColor = AppColors.primaryText;
          } else if (isCompleted) {
            circleColor = AppColors.accentGreen;
            textColor = AppColors.primaryText.withOpacity(0.6);
          } else {
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
    // Determine the list of entities (clients or suppliers) to display
    final List<Map<String, dynamic>> currentEntities =
        _selectedInvoiceType == InvoiceType.supplier ? _fournisseurs : _clients;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Nouvelle Facture',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildInvoiceStepper(),
          Divider(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10.0,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    // 3. Invoice Type Selection (modern button group)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedInvoiceType = InvoiceType.client;
                                _initializeSelectedEntityId(); // Reset entity selection
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _selectedInvoiceType == InvoiceType.client
                                  ? AppColors
                                        .primaryIndigo // Active color
                                  : AppColors.inputBackground, // Inactive color
                              foregroundColor:
                                  _selectedInvoiceType == InvoiceType.client
                                  ? AppColors.neutralWhite
                                  : AppColors.primaryText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      _selectedInvoiceType == InvoiceType.client
                                      ? AppColors.primaryIndigo
                                      : AppColors.neutralGrey400,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text('Facture Client'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedInvoiceType = InvoiceType.supplier;
                                _initializeSelectedEntityId(); // Reset entity selection
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _selectedInvoiceType == InvoiceType.supplier
                                  ? AppColors.primaryIndigo
                                  : AppColors.inputBackground,
                              foregroundColor:
                                  _selectedInvoiceType == InvoiceType.supplier
                                  ? AppColors.neutralWhite
                                  : AppColors.primaryText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      _selectedInvoiceType ==
                                          InvoiceType.supplier
                                      ? AppColors.primaryIndigo
                                      : AppColors.neutralGrey400,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text('Facture Fournisseur'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    Icon(
                      Icons.description,
                      size: 80,
                      color: AppColors.primaryIndigo.withOpacity(0.7),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Créez une nouvelle facture en quelques étapes simples.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryText.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextFormField(
                      controller: _referenceController,
                      labelText: _selectedInvoiceType == InvoiceType.client
                          ? 'Référence Client'
                          : 'Référence Fournisseur', // Dynamic label
                      hintText: _selectedInvoiceType == InvoiceType.client
                          ? 'Ex: REF-CLIENT-001'
                          : 'Ex: REF-FOURN-001', // Dynamic hint
                      icon: Icons.receipt_long,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une référence';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<int>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _selectedInvoiceType == InvoiceType.client
                              ? 'Client'
                              : 'Fournisseur', // Dynamic label
                          hintText: _selectedInvoiceType == InvoiceType.client
                              ? 'Sélectionnez un client'
                              : 'Sélectionnez un fournisseur', // Dynamic hint
                          prefixIcon: Icon(
                            Icons.business,
                            color: AppColors.primaryIndigo.withOpacity(0.8),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 16.0,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.accentBlue,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.accentRed,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.accentRed,
                              width: 2,
                            ),
                          ),
                        ),
                        value: _selectedEntityId,
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedEntityId = newValue;
                          });
                        },
                        items: currentEntities.map<DropdownMenuItem<int>>((
                          entity, // Changed from 'fournisseur' to 'entity'
                        ) {
                          return DropdownMenuItem<int>(
                            value: entity['id'],
                            child: Text(
                              entity['name']!,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner un ${_selectedInvoiceType == InvoiceType.supplier ? 'fournisseur' : 'client'}';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _selectCreationDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Date de Création',
                            hintText: 'Sélectionnez la date de la facture',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: AppColors.primaryIndigo.withOpacity(0.8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18.0,
                              horizontal: 16.0,
                            ),
                          ),
                          controller: TextEditingController(
                            text:
                                '${_selectedCreationDate.day.toString().padLeft(2, '0')}/${_selectedCreationDate.month.toString().padLeft(2, '0')}/${_selectedCreationDate.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _createDraftInvoice,
                      icon: const Icon(Icons.add_shopping_cart, size: 24),
                      label: const Text(
                        'Créer Brouillon et Ajouter Articles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 60),
                        elevation: 8,
                        shadowColor: AppColors.primaryIndigo.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType? keyboardType,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.primaryIndigo.withOpacity(0.8))
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 16.0,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
