import 'package:flutter/material.dart';
import 'package:softigotest/models/third_party.dart';
import '../utils/app_styles.dart'; // Make sure your AppColors are accessible

class EditThirdPartyPage extends StatefulWidget {
  final ThirdParty thirdPartyToEdit;

  const EditThirdPartyPage({super.key, required this.thirdPartyToEdit});

  @override
  State<EditThirdPartyPage> createState() => _EditThirdPartyPageState();
}

class _EditThirdPartyPageState extends State<EditThirdPartyPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all editable text fields
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _taxIdController;
  late TextEditingController _parentCompanyController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _contactPersonController;
  late TextEditingController _contactRoleController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  // For dropdown (ThirdParty type)
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.thirdPartyToEdit.name);
    _codeController = TextEditingController(text: widget.thirdPartyToEdit.code);
    _taxIdController = TextEditingController(
      text: widget.thirdPartyToEdit.taxId,
    );
    _parentCompanyController = TextEditingController(
      text: widget.thirdPartyToEdit.parentCompany,
    );
    _phoneController = TextEditingController(
      text: widget.thirdPartyToEdit.phone,
    );
    _emailController = TextEditingController(
      text: widget.thirdPartyToEdit.email,
    );
    _contactPersonController = TextEditingController(
      text: widget.thirdPartyToEdit.contactPerson,
    );
    _contactRoleController = TextEditingController(
      text: widget.thirdPartyToEdit.contactRole,
    );
    _addressController = TextEditingController(
      text: widget.thirdPartyToEdit.address,
    );
    _notesController = TextEditingController(
      text: widget.thirdPartyToEdit.notes,
    );

    _selectedType = widget.thirdPartyToEdit.type;
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _nameController.dispose();
    _codeController.dispose();
    _taxIdController.dispose();
    _parentCompanyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _contactPersonController.dispose();
    _contactRoleController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveThirdParty() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Triggers onSaved for FormFields

      // Create a new ThirdParty object with updated values
      final updatedThirdParty = ThirdParty(
        id: widget.thirdPartyToEdit.id, // Keep the original ID
        name: _nameController.text.trim(),
        type: _selectedType,
        code: _codeController.text.trim(),
        taxId: _taxIdController.text.trim().isEmpty
            ? null
            : _taxIdController.text.trim(),
        parentCompany: _parentCompanyController.text.trim().isEmpty
            ? null
            : _parentCompanyController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        contactPerson: _contactPersonController.text.trim().isEmpty
            ? null
            : _contactPersonController.text.trim(),
        contactRole: _contactRoleController.text.trim().isEmpty
            ? null
            : _contactRoleController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        activities: widget
            .thirdPartyToEdit
            .activities, // Activities are handled on the detail page
      );

      // Return the updated ThirdParty object to the previous page
      Navigator.of(context).pop(updatedThirdParty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Modifier ${widget.thirdPartyToEdit.name}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: AppColors.appBarForeground),
            tooltip: 'Enregistrer les modifications',
            onPressed: _saveThirdParty,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Informations Générales
              _buildSectionHeader(context, 'Informations Générales'),
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
                        _nameController,
                        Icons.person_outline,
                        'Nom du Tiers',
                        isRequired: true,
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
                        _codeController,
                        Icons.qr_code,
                        'Code',
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _taxIdController,
                        Icons.article_outlined,
                        'NIF / SIRET (Optionnel)',
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _parentCompanyController,
                        Icons.business_outlined,
                        'Maison Mère (Optionnel)',
                        keyboardType: TextInputType.text,
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
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _emailController,
                        Icons.email_outlined,
                        'Email (Optionnel)',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _contactPersonController,
                        Icons.person_outline,
                        'Personne de Contact (Optionnel)',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _contactRoleController,
                        Icons.badge_outlined,
                        'Rôle du Contact (Optionnel)',
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
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for text form fields
  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    IconData icon,
    String label, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int minLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
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
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            }
          : null,
    );
  }

  // Helper for dropdown form fields
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
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: onChanged,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner un type';
              }
              return null;
            }
          : null,
    );
  }

  // Helper for section headers (reused from ThirdPartyDetailPage)
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
