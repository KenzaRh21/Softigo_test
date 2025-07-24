import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../models/user_model.dart'; // Importez le modèle User

class UserEditPage extends StatefulWidget {
  final User user; // L'utilisateur à modifier

  const UserEditPage({Key? key, required this.user}) : super(key: key);

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final _formKey = GlobalKey<FormState>(); // Clé pour valider le formulaire

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late UserRole _selectedRole;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedRole = widget.user.role;
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Dans une vraie application, vous enverriez ces données à votre backend.
      // Par exemple: User updatedUser = User(id: widget.user.id, name: _nameController.text, ...);
      // apiService.updateUser(updatedUser);

      // Pour la démo, on simule la sauvegarde et on affiche un message
      final updatedUser = User(
        id: widget.user.id,
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole,
        isActive: _isActive,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Utilisateur "${updatedUser.name}" mis à jour !'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );

      // Retourne à la page précédente avec les données mises à jour
      Navigator.pop(context, updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Modifier Utilisateur: ${widget.user.name}',
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
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: 'Enregistrer les modifications',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'Informations du Compte'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                labelText: 'Nom Complet',
                hintText: 'Entrez le nom complet de l\'utilisateur',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom ne peut pas être vide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Entrez l\'adresse email de l\'utilisateur',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'email ne peut pas être vide';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Entrez une adresse email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sélecteur de Rôle
              _buildRoleDropdown(context),
              const SizedBox(height: 16),

              // Interrupteur de statut actif/inactif
              _buildStatusSwitch(),
              const SizedBox(height: 32),

              // Bouton Enregistrer (peut aussi être dans l'AppBar)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer les Modifications'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    foregroundColor: AppColors.neutralWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
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

  // --- Widgets d'aide ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.primaryIndigo)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildRoleDropdown(BuildContext context) {
    return DropdownButtonFormField<UserRole>(
      value: _selectedRole,
      onChanged: (UserRole? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedRole = newValue;
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Rôle',
        prefixIcon: Icon(Icons.work_outline, color: AppColors.primaryIndigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      items: UserRole.values.map((UserRole role) {
        return DropdownMenuItem<UserRole>(
          value: role,
          child: Text(
            role.toDisplayString(),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
          ),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner un rôle';
        }
        return null;
      },
    );
  }

  Widget _buildStatusSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralGrey300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Statut Actif',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (bool newValue) {
              setState(() {
                _isActive = newValue;
              });
            },
            activeColor: AppColors.primaryGreen,
            inactiveThumbColor: AppColors.neutralGrey500,
            inactiveTrackColor: AppColors.neutralGrey300,
          ),
        ],
      ),
    );
  }
}
