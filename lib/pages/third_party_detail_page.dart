// lib/pages/third_party_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:softigotest/models/third_party.dart';
import 'package:softigotest/pages/edit_thirdparty_page.dart';
import 'package:softigotest/services/third_party_service.dart';
import '../utils/app_styles.dart';

class ThirdPartyDetailPage extends StatefulWidget {
  final String thirdPartyId;

  const ThirdPartyDetailPage({super.key, required this.thirdPartyId});

  @override
  State<ThirdPartyDetailPage> createState() => _ThirdPartyDetailPageState();
}

class _ThirdPartyDetailPageState extends State<ThirdPartyDetailPage> {
  late Future<ThirdParty> _thirdPartyFuture;
  late final ThirdPartyApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ThirdPartyApiService(
      baseUrl: dotenv.env['API_BASE_URL']!,
      apiKey: dotenv.env['DOLIBARR_API_KEY']!,
    );
    _thirdPartyFuture = _fetchThirdPartyData();
  }

  Future<ThirdParty> _fetchThirdPartyData() async {
    return _apiService.fetchThirdPartyById(widget.thirdPartyId);
  }

  void _refreshThirdParty() {
    setState(() {
      _thirdPartyFuture = _fetchThirdPartyData();
    });
  }

  void _showSnackBar(String message, {Color color = Colors.green}) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
    }
  }

  Future<void> _confirmDelete(String thirdPartyId) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation de suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce tiers ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _apiService.deleteThirdParty(thirdPartyId);
        if (mounted) {
          Navigator.of(
            context,
          ).pop(true); // Retourne true pour rafraîchir la liste
          _showSnackBar('Tiers supprimé avec succès !', color: Colors.red);
        }
      } catch (e) {
        _showSnackBar('Erreur lors de la suppression: $e', color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThirdParty>(
      future: _thirdPartyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: Center(
              child: Text(
                'Erreur lors du chargement des données: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Aucun tiers trouvé.')),
          );
        }

        final thirdParty = snapshot.data!;
        final primaryColor = AppColors.primaryIndigo;
        final accentColor = AppColors.accentBlue;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            title: Text(
              thirdParty.name,
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
                icon: const Icon(Icons.edit, color: AppColors.appBarForeground),
                tooltip: 'Modifier ce tiers',
                onPressed: () async {
                  final bool? wasEdited = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          EditThirdPartyPage(thirdParty: thirdParty),
                    ),
                  );
                  if (wasEdited == true) {
                    _refreshThirdParty();
                    _showSnackBar('Tiers modifié avec succès !');
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Supprimer ce tiers',
                onPressed: () => _confirmDelete(thirdParty.id),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
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
                        _buildDetailRow(
                          context,
                          Icons.person_outline,
                          'Nom',
                          thirdParty.name,
                          primaryColor,
                        ),
                        _buildDetailRow(
                          context,
                          _getIconForType(
                            thirdParty.client,
                            thirdParty.fournisseur,
                          ),
                          'Type',
                          _getThirdPartyType(
                            thirdParty.client,
                            thirdParty.fournisseur,
                          ),
                          _getColorForType(
                            thirdParty.client,
                            thirdParty.fournisseur,
                            primaryColor,
                            accentColor,
                          ),
                        ),
                        if (thirdParty.codeClient != null &&
                            thirdParty.codeClient!.isNotEmpty)
                          _buildDetailRow(
                            context,
                            Icons.qr_code,
                            'Code Client',
                            thirdParty.codeClient!,
                            AppColors.neutralGrey700,
                          ),
                        if (thirdParty.tvaIntra != null &&
                            thirdParty.tvaIntra!.isNotEmpty)
                          _buildDetailRow(
                            context,
                            Icons.article_outlined,
                            'TVA Intra',
                            thirdParty.tvaIntra!,
                            AppColors.neutralGrey700,
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
                        if (thirdParty.phone != null &&
                            thirdParty.phone!.isNotEmpty)
                          _buildDetailRow(
                            context,
                            Icons.phone,
                            'Téléphone',
                            thirdParty.phone!,
                            AppColors.neutralGrey700,
                          ),
                        if (thirdParty.email != null &&
                            thirdParty.email!.isNotEmpty)
                          _buildDetailRow(
                            context,
                            Icons.email_outlined,
                            'Email',
                            thirdParty.email!,
                            AppColors.neutralGrey700,
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
                        if (thirdParty.address != null &&
                            thirdParty.address!.isNotEmpty)
                          _buildDetailRow(
                            context,
                            Icons.location_on_outlined,
                            'Adresse',
                            thirdParty.address!,
                            AppColors.neutralGrey700,
                          ),
                        if (thirdParty.zipcode != null &&
                            thirdParty.zipcode!.isNotEmpty)
                          _buildDetailRow(
                            context,
                            Icons.location_pin,
                            'Code Postal',
                            thirdParty.zipcode!,
                            AppColors.neutralGrey700,
                          ),
                        if (thirdParty.town != null &&
                            thirdParty.town!.isNotEmpty)
                          _buildDetailRow(
                            context,
                            Icons.apartment,
                            'Ville',
                            thirdParty.town!,
                            AppColors.neutralGrey700,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getThirdPartyType(String? client, String? fournisseur) {
    bool isClient = client == '1';
    bool isFournisseur = fournisseur == '1';

    if (isClient && isFournisseur) {
      return 'Client & Fournisseur';
    } else if (isClient) {
      return 'Client';
    } else if (isFournisseur) {
      return 'Fournisseur';
    } else {
      return 'Prospect';
    }
  }

  IconData _getIconForType(String? client, String? fournisseur) {
    bool isClient = client == '1';
    bool isFournisseur = fournisseur == '1';

    if (isClient && isFournisseur) {
      return Icons.groups;
    } else if (isClient) {
      return Icons.person;
    } else if (isFournisseur) {
      return Icons.local_shipping;
    } else {
      return Icons.saved_search;
    }
  }

  Color _getColorForType(
    String? client,
    String? fournisseur,
    Color primaryColor,
    Color accentColor,
  ) {
    bool isClient = client == '1';
    bool isFournisseur = fournisseur == '1';

    if (isClient && isFournisseur) {
      return Colors.purple;
    } else if (isClient) {
      return primaryColor;
    } else if (isFournisseur) {
      return accentColor;
    } else {
      return Colors.orange;
    }
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.neutralGrey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
