import 'package:flutter/material.dart';
import 'package:softigotest/models/third_party.dart';
import 'package:softigotest/services/third_party_service.dart';
import '../utils/app_styles.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class EditThirdPartyPage extends StatefulWidget {
  final ThirdParty thirdParty;

  const EditThirdPartyPage({super.key, required this.thirdParty});

  @override
  State<EditThirdPartyPage> createState() => _EditThirdPartyPageState();
}

class _EditThirdPartyPageState extends State<EditThirdPartyPage> {
  final _formKey = GlobalKey<FormState>();

  late final ThirdPartyApiService _thirdPartyService;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _codeClientController;
  late TextEditingController _addressController;
  late TextEditingController _zipcodeController;
  late TextEditingController _townController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _tvaIntraController;

  late bool _isClient;
  late bool _isFournisseur;

  @override
  void initState() {
    super.initState();
    final String? baseUrl = dotenv.env['API_BASE_URL'];
    final String? apiKey = dotenv.env['DOLIBARR_API_KEY'];

    if (baseUrl == null || apiKey == null) {
      throw Exception(
        'API_BASE_URL or DOLIBARR_API_KEY not defined in .env file.',
      );
    }
    _thirdPartyService = ThirdPartyApiService(baseUrl: baseUrl, apiKey: apiKey);

    _nameController = TextEditingController(text: widget.thirdParty.name);
    _codeClientController = TextEditingController(
      text: widget.thirdParty.codeClient ?? '',
    );
    _addressController = TextEditingController(
      text: widget.thirdParty.address ?? '',
    );
    _zipcodeController = TextEditingController(
      text: widget.thirdParty.zipcode ?? '',
    );
    _townController = TextEditingController(text: widget.thirdParty.town ?? '');
    _phoneController = TextEditingController(
      text: widget.thirdParty.phone ?? '',
    );
    _emailController = TextEditingController(
      text: widget.thirdParty.email ?? '',
    );
    _tvaIntraController = TextEditingController(
      text: widget.thirdParty.tvaIntra ?? '',
    );

    _isClient = widget.thirdParty.client == '1';
    _isFournisseur = widget.thirdParty.fournisseur == '1';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeClientController.dispose();
    _addressController.dispose();
    _zipcodeController.dispose();
    _townController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _tvaIntraController.dispose();
    super.dispose();
  }

  void _saveThirdParty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Start with the original data from the widget
    // The 'ThirdParty' object does not have all fields from the API.
    // So, let's build a complete map of all fields from the original 'fetch' data.
    final Map<String, dynamic> thirdPartyData = {
      'id': widget.thirdParty.id,
      'name': widget.thirdParty.name,
      'address': widget.thirdParty.address,
      'zipcode': widget.thirdParty.zipcode,
      'town': widget.thirdParty.town,
      'phone': widget.thirdParty.phone,
      'email': widget.thirdParty.email,
      'tva_intra': widget.thirdParty.tvaIntra,
      'typent_id': widget.thirdParty.typentId,
      'status': int.tryParse(widget.thirdParty.status ?? '0') ?? 0,
      'code_auto': widget.thirdParty.codeAuto,
      'country_id': widget.thirdParty.countryId,
      'state_id': widget.thirdParty.stateId,
      'assujtva_value': widget.thirdParty.assujtvaValue,
      'effectif_id': widget.thirdParty.effectifId,
      'forme_juridique_code': widget.thirdParty.formeJuridiqueCode,
      'capital': widget.thirdParty.capital,
      'cond_reglement_id': widget.thirdParty.condReglementId,
      'incoterm_id': widget.thirdParty.incotermId,
      'custcats_multiselect': widget.thirdParty.custcatsMultiselect,
      'suppcats_multiselect': widget.thirdParty.suppcatsMultiselect,
      'parent_company_id': widget.thirdParty.parentCompanyId,
      'commercial_multiselect': widget.thirdParty.commercialMultiselect,
      'commercial': widget.thirdParty.commercial,
      'client': widget.thirdParty.client,
      'fournisseur': widget.thirdParty.fournisseur,
      'code_client': widget.thirdParty.codeClient,
    };

    // Now, override with the new data from the form controllers.
    // This ensures a complete and valid payload is always sent.
    thirdPartyData['name'] = _nameController.text.trim();
    thirdPartyData['code_client'] = _codeClientController.text.trim();
    thirdPartyData['address'] = _addressController.text.trim();
    thirdPartyData['zipcode'] = _zipcodeController.text.trim();
    thirdPartyData['town'] = _townController.text.trim();
    thirdPartyData['phone'] = _phoneController.text.trim();
    thirdPartyData['email'] = _emailController.text.trim();
    thirdPartyData['tva_intra'] = _tvaIntraController.text.trim();
    thirdPartyData['client'] = _isClient ? '1' : '0';
    thirdPartyData['fournisseur'] = _isFournisseur ? '1' : '0';

    // Clean up any empty strings that should be null
    thirdPartyData.forEach((key, value) {
      if (value == '') {
        thirdPartyData[key] = null;
      }
    });

    try {
      print('Dolibarr update request payload: ${thirdPartyData}');
      await _thirdPartyService.updateThirdParty(
        widget.thirdParty.id,
        thirdPartyData,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Une erreur est survenue lors de la mise à jour du tiers: ${e.toString()}',
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
          'Modifier ${widget.thirdParty.name}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: AppColors.appBarForeground,
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.save,
                    color: AppColors.appBarForeground,
                  ),
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
                      _buildTextField(
                        context,
                        _codeClientController,
                        Icons.qr_code,
                        'Code Client',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _tvaIntraController,
                        Icons.article_outlined,
                        'Numéro de TVA Intracommunautaire',
                      ),
                      const SizedBox(height: 16),
                      _buildTypeSwitchListTile(
                        'Client',
                        Icons.person_outline,
                        _isClient,
                        (bool value) {
                          setState(() {
                            _isClient = value;
                          });
                        },
                      ),
                      _buildTypeSwitchListTile(
                        'Fournisseur',
                        Icons.local_shipping,
                        _isFournisseur,
                        (bool value) {
                          setState(() {
                            _isFournisseur = value;
                          });
                        },
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
                        'Téléphone',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _emailController,
                        Icons.email_outlined,
                        'Email',
                        keyboardType: TextInputType.emailAddress,
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
                        'Adresse',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _zipcodeController,
                        Icons.location_pin,
                        'Code Postal',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        _townController,
                        Icons.apartment,
                        'Ville',
                      ),
                    ],
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

  Widget _buildTypeSwitchListTile(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      secondary: Icon(icon, color: AppColors.primaryIndigo),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryIndigo,
      contentPadding: EdgeInsets.zero,
    );
  }

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
