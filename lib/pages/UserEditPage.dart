import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../models/user_model.dart';

class UserEditPage extends StatefulWidget {
  final User user;

  const UserEditPage({Key? key, required this.user}) : super(key: key);

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs textuels (adaptés au nouveau modèle)
  late TextEditingController _lastnameController;
  late TextEditingController _firstnameController;
  late TextEditingController _emailController;
  late TextEditingController _loginController;

  // Champ pour le salarié, géré par une case à cocher
  late bool _isEmployee;

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs avec les données de l'utilisateur
    _lastnameController = TextEditingController(text: widget.user.lastname);
    _firstnameController = TextEditingController(text: widget.user.firstname);
    _emailController = TextEditingController(text: widget.user.email);
    _loginController = TextEditingController(text: widget.user.login);

    // Le champ 'employee' est un int dans votre modèle. On le convertit en bool.
    // 1 = Salarié, 0 = Non Salarié
    _isEmployee = widget.user.employee == 1;
  }

  @override
  void dispose() {
    _lastnameController.dispose();
    _firstnameController.dispose();
    _emailController.dispose();
    _loginController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Construction de l'objet User mis à jour
      final updatedUser = User(
        id: widget.user.id,
        lastname: _lastnameController.text,
        firstname: _firstnameController.text,
        email: _emailController.text,
        login: _loginController.text,
        employee: _isEmployee ? 1 : 0, // Conversion bool -> int
        // Note: Assurez-vous d'inclure tous les autres champs
        // (password, address, etc.) si vous souhaitez les modifier.
        // Pour cet exemple, seuls les champs affichés sont mis à jour.
        password: widget.user.password,
        civilityCode: widget.user.civilityCode,
        gender: widget.user.gender,
        address: widget.user.address,
        zipcode: widget.user.zipcode,
        town: widget.user.town,
        countryId: widget.user.countryId,
        stateId: widget.user.stateId,
        officePhone: widget.user.officePhone,
        userMobile: widget.user.userMobile,
        officeFax: widget.user.officeFax,
        accountancyCode: widget.user.accountancyCode,
        color: widget.user.color,
        usercatsMultiselect: widget.user.usercatsMultiselect,
        signature: widget.user.signature,
        notePublic: widget.user.notePublic,
        notePrivate: widget.user.notePrivate,
        job: widget.user.job,
        thm: widget.user.thm,
        tjm: widget.user.tjm,
        salary: widget.user.salary,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Utilisateur "${updatedUser.fullName}" mis à jour !'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );

      Navigator.pop(context, updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Modifier Utilisateur: ${widget.user.fullName}',
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
              _buildSectionHeader(context, 'Informations de base'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _firstnameController,
                labelText: 'Prénom',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le prénom ne peut pas être vide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastnameController,
                labelText: 'Nom de famille',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom de famille ne peut pas être vide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _loginController,
                labelText: 'Identifiant (Login)',
                icon: Icons.account_circle_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'identifiant ne peut pas être vide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
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
              const SizedBox(height: 32),

              // Case à cocher pour le statut "Salarié"
              _buildEmployeeCheckbox(),
              const SizedBox(height: 32),

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

  // Nouveau widget pour la case à cocher
  Widget _buildEmployeeCheckbox() {
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
            'Est un salarié',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          Checkbox(
            value: _isEmployee,
            onChanged: (bool? newValue) {
              if (newValue != null) {
                setState(() {
                  _isEmployee = newValue;
                });
              }
            },
            activeColor: AppColors.primaryIndigo,
          ),
        ],
      ),
    );
  }
}
