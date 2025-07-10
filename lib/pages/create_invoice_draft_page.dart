// lib/pages/create_invoice_draft_page.dart
import 'package:flutter/material.dart';
import 'package:softigotest/models/facture_model.dart';
import 'package:softigotest/pages/EditInvoicePage.dart';
import 'package:softigotest/utils/app_styles.dart';
import 'package:softigotest/services/facture_api_service.dart';
import 'package:softigotest/models/invoice_create_model.dart';

class CreateInvoiceDraftPage extends StatefulWidget {
  const CreateInvoiceDraftPage({super.key});

  @override
  State<CreateInvoiceDraftPage> createState() => _CreateInvoiceDraftPageState();
}

class _CreateInvoiceDraftPageState extends State<CreateInvoiceDraftPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _referenceController = TextEditingController();

  final List<Map<String, dynamic>> _fournisseurs = [
    {'id': 101, 'name': 'Fournisseur A (avec un nom un peu plus long)'},
    {'id': 102, 'name': 'Fournisseur B'},
    {'id': 103, 'name': 'Fournisseur C'},
    {
      'id': 104,
      'name':
          'Un très long nom de fournisseur qui pourrait causer des problèmes',
    },
  ];

  int? _selectedFournisseurId;
  DateTime _selectedCreationDate = DateTime.now();

  final List<String> _invoiceSteps = ['Détails', 'Articles', 'Confirmation'];
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    if (_fournisseurs.isNotEmpty) {
      _selectedFournisseurId = _fournisseurs.first['id'];
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
      if (_selectedFournisseurId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un fournisseur.'),
            backgroundColor: AppColors.accentRed,
          ),
        );
        return;
      }

      // Update step index immediately
      setState(() {
        _currentStepIndex = 1;
      });

      final now = DateTime.now();
      final DateTime dateWithTime = DateTime(
        _selectedCreationDate.year, // Corrected: Use _selectedCreationDate
        _selectedCreationDate.month, // Corrected: Use _selectedCreationDate
        _selectedCreationDate.day, // Corrected: Use _selectedCreationDate
        now.hour,
        now.minute,
        now.second,
      );

      final invoiceRequest = InvoiceCreateRequest(
        socid: _selectedFournisseurId!, // Corrected: Use _selectedFournisseurId
        date: dateWithTime.millisecondsSinceEpoch ~/ 1000,
        lines: [],
        refClient: _referenceController.text,
      );

      final factureService = FactureApiService();

      try {
        // 1. Create the invoice
        final int invoiceId = await factureService.createFacture(
          invoiceRequest,
        );

        // 3. Navigate to add lines
        final Facture draftFacture = Facture(
          id: invoiceId.toString(),
          reference: _referenceController.text,
          fournisseur:
              _selectedFournisseurId!, // Corrected: Use _selectedFournisseurId
          dateCreation:
              _selectedCreationDate.millisecondsSinceEpoch ~/
              1000, // Corrected: Use _selectedCreationDate
          total: 0.0,
          status: 0,
          lines: [],
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
          // If the user backs out of EditInvoicePage without saving/completing, revert step.
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
        // On error, revert step index
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
                      labelText: 'Référence de la Facture',
                      hintText: 'Ex: FACT-2025-001',
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
                          labelText: 'Fournisseur',
                          hintText: 'Sélectionnez un fournisseur',
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
                        value: _selectedFournisseurId,
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedFournisseurId = newValue;
                          });
                        },
                        items: _fournisseurs.map<DropdownMenuItem<int>>((
                          fournisseur,
                        ) {
                          return DropdownMenuItem<int>(
                            value: fournisseur['id'],
                            child: Text(
                              fournisseur['name']!,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner un fournisseur';
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
