import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:softigotest/pages/list_third_parties_page.dart';
import 'package:softigotest/services/third_party_service.dart';
import '../utils/app_styles.dart';

class AddThirdPartyPage extends StatefulWidget {
  const AddThirdPartyPage({super.key});

  @override
  State<AddThirdPartyPage> createState() => _AddThirdPartyPageState();
}

class _AddThirdPartyPageState extends State<AddThirdPartyPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs du formulaire
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _townController = TextEditingController();
  final TextEditingController _tvaIntraController = TextEditingController();
  final TextEditingController _codeClientController = TextEditingController();
  final TextEditingController _codeFournisseurController =
      TextEditingController();

  // Déclaration des variables de l'état
  bool _isClient = false;
  bool _isFournisseur = false;
  bool _isProspect = false;

  String _selectedType = 'Client';
  late int _typentId; // Déclaration de la variable _typentId

  late final ThirdPartyApiService _thirdPartyService;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final String? baseUrl = dotenv.env['API_BASE_URL'];
    final String? apiKey = dotenv.env['DOLIBARR_API_KEY'];

    if (baseUrl == null || apiKey == null) {
      throw Exception(
        'Les variables d\'environnement API_BASE_URL ou DOLIBARR_API_KEY ne sont pas définies.',
      );
    }
    _thirdPartyService = ThirdPartyApiService(baseUrl: baseUrl, apiKey: apiKey);

    _updateStatusAndIdFromSelectedType(); // Appel initial pour définir _typentId
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _zipcodeController.dispose();
    _townController.dispose();
    _tvaIntraController.dispose();
    _codeClientController.dispose();
    _codeFournisseurController.dispose();
    super.dispose();
  }

  void _updateStatusAndIdFromSelectedType() {
    setState(() {
      _isClient = _selectedType == 'Client';
      _isFournisseur = _selectedType == 'Fournisseur';
      _isProspect = _selectedType == 'Prospect';
      _typentId = _isClient ? 1 : (_isFournisseur ? 3 : 2);
    });
  }

  void _showSuccessDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                'Le nouveau tiers a été enregistré avec le code :',
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
                Navigator.of(context).pop();
                _clearForm();
              },
              child: Text(
                'Ajouter un autre Tiers',
                style: TextStyle(color: colorScheme.secondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListThirdPartiesPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Voir les Tiers'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _emailController.clear();
    _zipcodeController.clear();
    _townController.clear();
    _tvaIntraController.clear();
    _codeClientController.clear();
    _codeFournisseurController.clear();
    setState(() {
      _selectedType = 'Client';
      _updateStatusAndIdFromSelectedType();
    });
  }

  void _addThirdParty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _updateStatusAndIdFromSelectedType();

    final Map<String, dynamic> thirdPartyData = {
      'name': _nameController.text,
      'address': _addressController.text,
      'zipcode': _zipcodeController.text,
      'town': _townController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'tva_intra': _tvaIntraController.text,
      'typent_id': _typentId,
      'status': 1,
      'code_auto': 1, // Assurez-vous que cette valeur est bien à 1
      'country_id': 12,
      'state_id': 0,
      'assujtva_value': 1,
      'effectif_id': 0,
      'forme_juridique_code': 0,
      'capital': 0,
      'cond_reglement_id': 0,
      'incoterm_id': 0,
      'custcats_multiselect': 1,
      'suppcats_multiselect': 1,
      'parent_company_id': -1,
      'commercial_multiselect': 1,
      'commercial': [2],
      'client': _isClient ? 1 : 0,
      'fournisseur': _isFournisseur ? 1 : 0,
      'prospect': _isProspect ? 1 : 0,
      // La valeur doit être une chaîne vide, pas null.
      // Cela indique à Dolibarr de générer un code client.
      'code_client': _isClient ? '' : null,
      // Idem pour le fournisseur, pour éviter des problèmes futurs.
      'code_fournisseur': _isFournisseur ? '' : null,
    };
    print('Données envoyées à l\'API: $thirdPartyData');

    try {
      final generatedCode = await _thirdPartyService.createThirdParty(
        thirdPartyData,
      );
      if (mounted) {
        _showSuccessDialog(generatedCode);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Une erreur est survenue lors de l\'ajout du tiers: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Ajouter un Tiers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                            _updateStatusAndIdFromSelectedType();
                          });
                        },
                        isRequired: true,
                      ),

                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _tvaIntraController,
                        Icons.article_outlined,
                        'N° TVA Intra (Optionnel)',
                        keyboardType: TextInputType.text,
                        hintText: 'Ex: FR12345678901',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                        hintText: 'Ex: 123 Rue de la Paix',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _zipcodeController,
                        Icons.local_post_office_outlined,
                        'Code Postal (Optionnel)',
                        keyboardType: TextInputType.number,
                        hintText: 'Ex: 75001',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _townController,
                        Icons.location_city_outlined,
                        'Ville (Optionnel)',
                        hintText: 'Ex: Paris',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.neutralWhite,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 40,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _addThirdParty,
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.neutralWhite,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Les fonctions _buildTextField, _buildDropdownField, etc. sont inchangées.
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
                return validator(value);
              }
              return null;
            }
          : validator,
    );
  }

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
      initialValue: currentValue,
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
