import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importez dotenv
import 'package:softigotest/pages/add_thirdparty_page.dart';
import 'package:softigotest/services/third_party_service.dart';
import '../utils/app_styles.dart';
import 'third_party_detail_page.dart';
import '../models/third_party.dart';

class ListThirdPartiesPage extends StatefulWidget {
  const ListThirdPartiesPage({super.key});

  @override
  State<ListThirdPartiesPage> createState() => _ListThirdPartiesPageState();
}

class _ListThirdPartiesPageState extends State<ListThirdPartiesPage> {
  late final ThirdPartyApiService _thirdPartyService;
  List<ThirdParty> _allThirdParties = [];
  List<ThirdParty> _filteredThirdParties = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedFilterType = {'Tous'};

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _fetchThirdParties();
    _searchController.addListener(_applyFilters);
  }

  void _initializeApiService() {
    final String? baseUrl = dotenv.env['API_BASE_URL'];
    final String? apiKey = dotenv.env['DOLIBARR_API_KEY'];
    if (baseUrl == null || apiKey == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Les variables d'environnement ne sont pas configurées.";
      });
      return;
    }
    _thirdPartyService = ThirdPartyApiService(baseUrl: baseUrl, apiKey: apiKey);
  }

  Future<void> _fetchThirdParties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Map<String, dynamic>> rawData = await _thirdPartyService
          .fetchThirdParties();

      _allThirdParties = rawData
          .map((data) => ThirdParty.fromJson(data))
          .where((tp) => tp != null)
          .cast<ThirdParty>()
          .toList();

      _applyFilters();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la récupération des tiers: $e';
      });
      print(_errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final String searchText = _searchController.text.toLowerCase();
    final String currentFilterType = _selectedFilterType.single;

    _filteredThirdParties = _allThirdParties.where((thirdParty) {
      final bool matchesSearch =
          thirdParty.name.toLowerCase().contains(searchText) ||
          (thirdParty.codeClient?.toLowerCase().contains(searchText) ?? false);
      final bool matchesType =
          currentFilterType == 'Tous' ||
          _getThirdPartyType(thirdParty) == currentFilterType;
      return matchesSearch && matchesType;
    }).toList();
    setState(() {});
  }

  String _getThirdPartyType(ThirdParty thirdParty) {
    if (thirdParty.client == '1' && thirdParty.fournisseur == '1') {
      return 'Client & Fournisseur';
    }
    if (thirdParty.client == '1') {
      return 'Client';
    }
    if (thirdParty.fournisseur == '1') {
      return 'Fournisseur';
    }
    return 'Prospect';
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.primaryIndigo;
    final Color accentColor = AppColors.accentBlue;

    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Erreur: $_errorMessage',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: AppColors.accentRed),
          ),
        ),
      );
    } else if (_filteredThirdParties.isEmpty) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 60,
                color: AppColors.neutralGrey400,
              ),
              const SizedBox(height: 20),
              Text(
                _searchController.text.isNotEmpty
                    ? 'Aucun tiers ne correspond à votre recherche.'
                    : 'Aucun tiers n\'a été trouvé.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.neutralGrey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              if (_searchController.text.isEmpty)
                Text(
                  'Cliquez sur le bouton "+" pour ajouter un tiers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutralGrey500,
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      bodyContent = RefreshIndicator(
        onRefresh: _fetchThirdParties,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: _filteredThirdParties.length,
          itemBuilder: (context, index) {
            final thirdParty = _filteredThirdParties[index];
            final String type = _getThirdPartyType(thirdParty);
            Color typeColor = AppColors.neutralGrey700;
            Color typeBgColor = AppColors.neutralGrey200;

            if (type == 'Client') {
              typeColor = primaryColor;
              typeBgColor = primaryColor.withOpacity(0.1);
            } else if (type == 'Fournisseur') {
              typeColor = accentColor;
              typeBgColor = accentColor.withOpacity(0.1);
            } else if (type == 'Client & Fournisseur') {
              typeColor = Colors.purple;
              typeBgColor = Colors.purple.withOpacity(0.1);
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.neutralWhite,
              child: InkWell(
                onTap: () async {
                  final bool? result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ThirdPartyDetailPage(thirdPartyId: thirdParty.id),
                    ),
                  );
                  if (result == true) {
                    _fetchThirdParties();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              thirdParty.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: typeBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: typeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (thirdParty.codeClient != null &&
                          thirdParty.codeClient!.isNotEmpty)
                        Text(
                          'Code: ${thirdParty.codeClient}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.neutralGrey700,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      if (thirdParty.address != null &&
                          thirdParty.address!.isNotEmpty)
                        ..._buildInfoRow(
                          context,
                          thirdParty.address!,
                          Icons.location_on,
                        ),
                      if (thirdParty.phone != null &&
                          thirdParty.phone!.isNotEmpty)
                        ..._buildInfoRow(
                          context,
                          thirdParty.phone!,
                          Icons.phone,
                        ),
                      if (thirdParty.email != null &&
                          thirdParty.email!.isNotEmpty)
                        ..._buildInfoRow(
                          context,
                          thirdParty.email!,
                          Icons.email,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Liste des Tiers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Rechercher par nom ou code',
                    hintText: 'Ex: Dupont ou CLI-001',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.neutralGrey600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.neutralGrey300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.neutralGrey100,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // --- Début du SegmentedButton mis à jour ---
                Center(
                  child: SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'Tous',
                        label: Text('Tous', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.apps, size: 18),
                      ),
                      ButtonSegment<String>(
                        value: 'Client',
                        label: Text('Client', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.person, size: 18),
                      ),
                      ButtonSegment<String>(
                        value: 'Prospect',
                        label: Text('Prospect', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.search, size: 18),
                      ),
                      ButtonSegment<String>(
                        value: 'Fournisseur',
                        label: Text(
                          'Fournisseur',
                          style: TextStyle(fontSize: 12),
                        ),
                        icon: Icon(Icons.local_shipping, size: 18),
                      ),
                      ButtonSegment<String>(
                        value: 'Client & Fournisseur',
                        label: Text('C&F', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.groups, size: 18),
                      ),
                    ],
                    selected: _selectedFilterType,
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedFilterType = newSelection;
                        _applyFilters();
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: accentColor.withOpacity(0.1),
                      selectedForegroundColor: accentColor,
                      foregroundColor: AppColors.neutralGrey700,
                      side: BorderSide(
                        color: AppColors.neutralGrey300,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // Ajustez le padding ici pour réduire la taille globale
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ),
                    ),
                    multiSelectionEnabled: false,
                  ),
                ),
                // --- Fin du SegmentedButton mis à jour ---
              ],
            ),
          ),
          Expanded(child: bodyContent),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newThirdParty = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddThirdPartyPage()),
          );
          if (newThirdParty != null) {
            _fetchThirdParties();
          }
        },
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: AppColors.white),
        shape: const CircleBorder(),
      ),
    );
  }

  List<Widget> _buildInfoRow(BuildContext context, String text, IconData icon) {
    return [
      const SizedBox(height: 4),
      Row(
        children: [
          Icon(icon, size: 16, color: AppColors.neutralGrey600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.neutralGrey600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ];
  }
}
