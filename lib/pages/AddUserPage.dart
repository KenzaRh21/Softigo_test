import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../models/user_model.dart'; // Importez le modèle User

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>(); // Clé pour valider le formulaire

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // Nouveau: mot de passe
  UserRole _selectedRole = UserRole.employee; // Rôle par défaut
  bool _isActive = true; // Par défaut, un nouvel utilisateur est actif

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createUser() {
    if (_formKey.currentState!.validate()) {
      // Dans une vraie application, vous enverriez ces données à votre backend.
      // Générez un ID unique (ou laissez le backend le faire)
      final String newId = 'U${DateTime.now().millisecondsSinceEpoch}';

      final newUser = User(
        id: newId,
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole,
        isActive: _isActive,
      );

      // Ici, vous feriez un appel API pour ajouter l'utilisateur
      // Par exemple: apiService.createUser(newUser, _passwordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Utilisateur "${newUser.name}" créé avec succès !'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );

      // Optionnel: Réinitialiser le formulaire après la création
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() {
        _selectedRole = UserRole.employee;
        _isActive = true;
      });

      // Retourne à la page précédente (UserListPage) avec le nouvel utilisateur
      // pour potentiellement rafraîchir la liste.
      Navigator.pop(context, newUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Créer un Nouvel Utilisateur',
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
            icon: const Icon(Icons.person_add),
            onPressed: _createUser,
            tooltip: 'Créer l\'utilisateur',
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
              _buildSectionHeader(context, 'Informations Personnelles'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                labelText: 'Nom Complet',
                hintText: 'Entrez le nom complet du nouvel utilisateur',
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
              _buildTextField(
                controller: _passwordController,
                labelText: 'Mot de Passe',
                hintText: 'Créez un mot de passe pour l\'utilisateur',
                icon: Icons.lock_outline,
                obscureText: true, // Pour masquer le mot de passe
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le mot de passe ne peut pas être vide';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              _buildSectionHeader(context, 'Rôle et Statut'),
              const SizedBox(height: 16),

              // Sélecteur de Rôle
              _buildRoleDropdown(context),
              const SizedBox(height: 16),

              // Interrupteur de statut actif/inactif
              _buildStatusSwitch(),
              const SizedBox(height: 32),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _createUser,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Créer l\'Utilisateur'),
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

  // --- Widgets d'aide (réutilisés des pages précédentes) ---

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
    bool obscureText = false, // Ajout de obscureText
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText, // Applique obscureText
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
