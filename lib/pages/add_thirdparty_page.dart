import 'package:flutter/material.dart';
import 'dart:math';

import 'package:softigotest/pages/list_third_parties_page.dart'; // Assurez-vous que ce chemin est correct
import '../utils/app_styles.dart'; // Importez votre fichier AppColors

class AddThirdPartyPage extends StatefulWidget {
  const AddThirdPartyPage({super.key});

  @override
  State<AddThirdPartyPage> createState() => _AddThirdPartyPageState();
}

class _AddThirdPartyPageState extends State<AddThirdPartyPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _contactRoleController = TextEditingController();
  final TextEditingController _parentCompanyController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedType =
      'Client'; // Utilisation d'une seule valeur pour le type
  String _generatedCode = '';
  bool _isLoading = false; // Nouvelle variable pour gérer l'état de chargement

  @override
  void initState() {
    super.initState();
  }

  String _generateUniqueCode(String typePrefix) {
    final random = Random();
    final uniqueId = random.nextInt(999999).toString().padLeft(6, '0');
    return '${typePrefix.toUpperCase()}-$uniqueId';
  }

  // Fonction pour afficher le dialogue de succès
  void _showSuccessDialog(String type, String code) {
    showDialog(
      context: context,
      barrierDismissible: false, // L'utilisateur doit choisir une action
      builder: (BuildContext context) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(
            'Tiers Ajouté avec Succès !',
            style: TextStyle(color: colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Le nouveau $type a été enregistré avec le code :',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: SelectableText(
                  // Rendre le code sélectionnable
                  code,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Que souhaitez-vous faire ensuite ?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                _clearForm(); // Efface les champs
                setState(() {
                  _generatedCode = ''; // Réinitialise le code affiché en bas
                });
              },
              child: Text(
                'Ajouter un autre Tiers',
                style: TextStyle(color: colorScheme.secondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                // Redirige vers la page des tiers
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListThirdPartiesPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    colorScheme.primary, // Couleur du bouton principal
                foregroundColor: colorScheme.onPrimary, // Couleur du texte
              ),
              child: const Text('Voir les Tiers'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour effacer les champs du formulaire
  void _clearForm() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _emailController.clear();
    _taxIdController.clear();
    _contactPersonController.clear();
    _contactRoleController.clear();
    _parentCompanyController.clear();
    _notesController.clear();
    setState(() {
      _selectedType = 'Client'; // Réinitialise le type à 'Client'
    });
  }

  void _addThirdParty() async {
    if (!_formKey.currentState!.validate()) {
      return; // Ne fait rien si la validation échoue
    }

    setState(() {
      _isLoading = true; // Active l'indicateur de chargement
    });

    String prefix;
    final type = _selectedType;

    switch (type) {
      case 'Client':
        prefix = 'CLI';
        break;
      case 'Prospect':
        prefix = 'PRO';
        break;
      case 'Fournisseur':
        prefix = 'FOU';
        break;
      default:
        prefix = 'GEN';
    }

    // Simuler une opération réseau/base de données
    await Future.delayed(const Duration(seconds: 1)); // Attente d'1 seconde

    final generatedCode = _generateUniqueCode(prefix);

    if (mounted) {
      setState(() {
        _generatedCode = generatedCode;
        _isLoading = false; // Désactive l'indicateur de chargement
      });

      _showSuccessDialog(type, generatedCode);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _taxIdController.dispose();
    _contactPersonController.dispose();
    _contactRoleController.dispose();
    _parentCompanyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground, // Utiliser AppColors
      appBar: AppBar(
        title: Text(
          'Ajouter un Tiers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground, // Utiliser AppColors
        iconTheme: const IconThemeData(
          color: AppColors.appBarForeground,
        ), // Utiliser AppColors
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Section Informations Générales
              _buildSectionHeader(context, 'Informations Générales'),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.neutralWhite, // Utiliser AppColors
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        context,
                        _nameController,
                        Icons.person_outline,
                        'Nom du Tiers',
                        isRequired: true,
                        hintText: 'Ex: Dupont S.A.',
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        context,
                        'Type de Tiers',
                        Icons.category_outlined,
                        _selectedType,
                        ['Client', 'Prospect', 'Fournisseur'],
                        (newValue) {
                          setState(() {
                            _selectedType = newValue!;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _taxIdController,
                        Icons.article_outlined,
                        'NIF / SIRET (Optionnel)',
                        keyboardType: TextInputType.text,
                        hintText: 'Ex: 123 456 789 00012',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _parentCompanyController,
                        Icons.business_outlined,
                        'Maison Mère (Optionnel)',
                        keyboardType: TextInputType.text,
                        hintText: 'Ex: Groupe Alpha',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section Contact
              _buildSectionHeader(context, 'Contact'),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.neutralWhite,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        context,
                        _phoneController,
                        Icons.phone,
                        'Téléphone (Optionnel)',
                        keyboardType: TextInputType.phone,
                        hintText: 'Ex: +33 6 12 34 56 78',
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^\+?[0-9\s-]{8,}$').hasMatch(value)) {
                              return 'Veuillez entrer un numéro de téléphone valide.';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _emailController,
                        Icons.email_outlined,
                        'Email (Optionnel)',
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Ex: contact@dupont.com',
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              !value.contains('@')) {
                            return 'Veuillez entrer une adresse email valide.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _contactPersonController,
                        Icons.person_outline,
                        'Personne de Contact (Optionnel)',
                        hintText: 'Ex: Jean Martin',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _contactRoleController,
                        Icons.badge_outlined,
                        'Rôle du Contact (Optionnel)',
                        hintText: 'Ex: Responsable Commercial',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section Adresse
              _buildSectionHeader(context, 'Adresse'),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.neutralWhite,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        context,
                        _addressController,
                        Icons.location_on_outlined,
                        'Adresse (Optionnel)',
                        maxLines: 3,
                        hintText: 'Ex: 123 Rue de la Paix, 75001 Paris',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section Notes
              _buildSectionHeader(context, 'Notes'),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.neutralWhite,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildTextField(
                    context,
                    _notesController,
                    Icons.note_alt_outlined,
                    'Notes (Optionnel)',
                    maxLines: 5,
                    minLines: 3,
                    hintText: 'Informations supplémentaires...',
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryGreen, // Utiliser AppColors
                    foregroundColor:
                        AppColors.neutralWhite, // Utiliser AppColors
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 40,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _isLoading
                      ? null
                      : _addThirdParty, // Désactiver le bouton pendant le chargement
                  child:
                      _isLoading // Afficher l'indicateur de chargement ou le texte
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors
                                .neutralWhite, // Couleur de l'indicateur
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Ajouter le Tiers',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20), // Espace après le bouton
            ],
          ),
        ),
      ),
    );
  }

  // Helper for text form fields (adapté de la page de modification)
  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    IconData icon,
    String label, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int minLines = 1,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primaryIndigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              if (validator != null) {
                return validator(
                  value,
                ); // Appliquer la validation personnalisée en plus
              }
              return null;
            }
          : validator, // Utiliser directement le validator passé
    );
  }

  // Helper for dropdown form fields (adapté de la page de modification)
  Widget _buildDropdownField(
    BuildContext context,
    String label,
    IconData icon,
    String? currentValue,
    List<String> items,
    void Function(String?) onChanged, {
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryIndigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            }
          : null,
    );
  }

  // Helper for section headers (adapté de la page de modification)
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
