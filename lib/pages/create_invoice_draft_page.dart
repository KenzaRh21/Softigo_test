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
      // Validate fournisseur ID as integer
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

      // Create a new Facture as a draft with empty lines
      // Assumes Facture constructor takes these parameters
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

      // Navigate to the EditInvoicePage to add lines
      final Facture? updatedFacture = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditInvoicePage(facture: newFacture, isNewInvoice: true),
        ),
      );

      if (updatedFacture != null) {
        // If lines were added and saved, navigate back with the updated facture
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
      appBar: AppBar(
        title: const Text('Créer une Nouvelle Facture (Brouillon)'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une référence';
                  }
                  return null;
                },
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text:
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _createDraftInvoice,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Créer Brouillon et Ajouter Lignes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
