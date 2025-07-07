// lib/pages/create_invoice_draft_page.dart
import 'package:flutter/material.dart';
import 'package:softigotest/models/facture_model.dart';
import 'package:softigotest/pages/EditInvoicePage.dart'; // To navigate to add lines
import 'package:softigotest/utils/app_styles.dart';

class CreateInvoiceDraftPage extends StatefulWidget {
  const CreateInvoiceDraftPage({super.key});

  @override
  State<CreateInvoiceDraftPage> createState() => _CreateInvoiceDraftPageState();
}

class _CreateInvoiceDraftPageState extends State<CreateInvoiceDraftPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _fournisseurIdController =
      TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _referenceController.dispose();
    _fournisseurIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryIndigo, // Your primary color
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryIndigo, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _createDraftInvoice() async {
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

      final newFacture = Facture(
        reference: _referenceController.text,
        fournisseur: fournisseurId,
        dateCreation:
            _selectedDate.millisecondsSinceEpoch ~/
            1000, // Convert to Unix timestamp
        total: 0.0, // Initial total is 0 for a draft
        status: 0, // 0 for Draft
        lines: [], // Start with no lines
      );

      final Facture? updatedFacture = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditInvoicePage(facture: newFacture, isNewInvoice: true),
        ),
      );

      if (updatedFacture != null) {
        Navigator.pop(
          context,
          updatedFacture,
        ); // Pop back to the list or detail page
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background, // Use a consistent background color
      appBar: AppBar(
        title: const Text(
          'Nouvelle Facture',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make title bolder
            fontSize: 22, // Slightly larger title
          ),
        ),
        centerTitle: true, // Center the title for a modern look
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 0, // Remove shadow for a flat design
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 20.0,
        ), // Increased horizontal padding
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- Section de description / illustration ---
              const SizedBox(height: 10), // Small space
              Icon(
                Icons.description, // A relevant icon
                size: 80, // Larger icon
                color: AppColors.primaryIndigo.withOpacity(
                  0.7,
                ), // Slightly faded
              ),
              const SizedBox(height: 15),
              Text(
                'Créez une nouvelle facture en quelques étapes simples.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryText.withOpacity(0.7),
                  height: 1.5, // Line height for better readability
                ),
              ),
              const SizedBox(height: 30), // More space before the form fields
              // --- Champs de formulaire ---
              _buildTextFormField(
                controller: _referenceController,
                labelText: 'Référence de la Facture',
                hintText: 'Ex: FACT-2025-001', // Add hint text
                icon: Icons.receipt_long,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une référence';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Increased spacing between fields

              _buildTextFormField(
                controller: _fournisseurIdController,
                labelText: 'ID Fournisseur',
                hintText:
                    'Entrez l\'identifiant du fournisseur (ex: 123)', // Add hint text
                keyboardType: TextInputType.number,
                icon: Icons.business,
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
              const SizedBox(height: 20), // Increased spacing
              // Date Picker Field
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date de Création',
                      hintText:
                          'Sélectionnez la date de la facture', // Add hint text
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Larger radius for a softer look
                        borderSide:
                            BorderSide.none, // No border for cleaner look
                      ),
                      filled: true,
                      fillColor: Colors.grey[50], // Light grey background
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryIndigo.withOpacity(0.8),
                      ), // Icon color
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18.0,
                        horizontal: 16.0,
                      ), // Larger padding
                    ),
                    controller: TextEditingController(
                      text:
                          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40), // More space before the button
              // --- Bouton d'action ---
              ElevatedButton.icon(
                onPressed: _createDraftInvoice,
                icon: const Icon(
                  Icons.add_shopping_cart,
                  size: 24,
                ), // More descriptive icon
                label: const Text(
                  'Créer Brouillon et Ajouter Articles', // Clearer button text
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18, // Taller button
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Consistent rounded corners
                  ),
                  minimumSize: const Size(
                    double.infinity,
                    60,
                  ), // Ensure button takes full width and is tall
                  elevation: 8, // More prominent shadow
                  shadowColor: AppColors.primaryIndigo.withOpacity(
                    0.4,
                  ), // Custom shadow color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for consistent TextFormField styling
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
          borderRadius: BorderRadius.circular(12), // Consistent larger radius
          borderSide: BorderSide.none, // No border by default
        ),
        filled: true,
        fillColor: Colors.grey[50], // Light grey background
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.primaryIndigo.withOpacity(0.8))
            : null, // Icon color
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 16.0,
        ), // Larger padding
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.accentBlue,
            width: 2,
          ), // Accent blue on focus
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.accentRed,
            width: 2,
          ), // Red for errors
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.accentRed,
            width: 2,
          ), // Red for errors
        ),
      ),
      validator: validator,
    );
  }
}
