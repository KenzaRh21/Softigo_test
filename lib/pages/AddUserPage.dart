import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:softigotest/models/user_model.dart';
import 'package:softigotest/services/user_service.dart';
import '../utils/app_styles.dart';
// Note: Le modèle User doit être mis à jour pour correspondre aux nouveaux champs

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService(
    baseUrl: dotenv.env['API_BASE_URL']!,
    apiKey: dotenv.env['DOLIBARR_API_KEY']!,
  );
  // Champs obligatoires
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Nouveaux champs non obligatoires
  final TextEditingController _civilityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _townController = TextEditingController();
  final TextEditingController _officePhoneController = TextEditingController();
  final TextEditingController _userMobileController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  @override
  void dispose() {
    _lastnameController.dispose();
    _firstnameController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _civilityController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _zipcodeController.dispose();
    _townController.dispose();
    _officePhoneController.dispose();
    _userMobileController.dispose();
    _jobController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _createUser() async {
    if (_formKey.currentState!.validate()) {
      final newUser = User(
        lastname: _lastnameController.text,
        firstname: _firstnameController.text,
        login: _loginController.text,
        password: _passwordController.text,
        civilityCode: _civilityController.text,
        email: _emailController.text,
        gender: _genderController.text,
        address: _addressController.text,
        zipcode: _zipcodeController.text,
        town: _townController.text,
        officePhone: _officePhoneController.text,
        userMobile: _userMobileController.text,
        job: _jobController.text,
        salary: _salaryController.text,
        // Vous pouvez également ajouter les autres champs ici
      );

      final bool success = await _userService.createUser(newUser);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Utilisateur créé avec succès !'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Une erreur est survenue lors de la création.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              // --- Section: Informations Obligatoires ---
              _buildSectionCard(context, 'Informations Obligatoires', [
                _buildTextField(
                  controller: _lastnameController,
                  labelText: 'Nom de famille',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Le nom de famille est obligatoire'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _firstnameController,
                  labelText: 'Prénom',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Le prénom est obligatoire'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _loginController,
                  labelText: 'Identifiant (login)',

                  icon: Icons.account_circle_outlined,
                  validator: (value) => value == null || value.isEmpty
                      ? 'L\'identifiant est obligatoire'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Mot de Passe',

                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Le mot de passe est obligatoire'
                      : null,
                ),
              ]),
              const SizedBox(height: 32),

              // --- Section: Informations Complémentaires (Facultatif) ---
              _buildSectionCard(
                context,
                'Informations Complémentaires (facultatif)',
                [
                  _buildTextField(
                    controller: _civilityController,
                    labelText: 'Civilité',
                    icon: Icons.person_pin,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _genderController,
                    labelText: 'Genre',
                    icon: Icons.wc_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Entrez une adresse email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _officePhoneController,
                    labelText: 'Téléphone bureau',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _userMobileController,
                    labelText: 'Téléphone mobile',
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    labelText: 'Adresse',
                    icon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _zipcodeController,
                    labelText: 'Code Postal',
                    icon: Icons.location_on_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _townController,
                    labelText: 'Ville',
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _jobController,
                    labelText: 'Poste',
                    icon: Icons.work_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _salaryController,
                    labelText: 'Salaire',
                    icon: Icons.paid_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
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

  // --- Widgets d'aide ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, title),
            const Divider(height: 24, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: labelText,
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
}
