import 'package:flutter/material.dart';
import 'package:softigotest/pages/add_thirdparty_page.dart';
import '../utils/app_styles.dart'; // Import your application styles and colors
import 'third_party_detail_page.dart'; // Import the new third-party detail page
import '../models/third_party.dart'; // NEW IMPORT: Import the ThirdParty model

class ListThirdPartiesPage extends StatefulWidget {
  const ListThirdPartiesPage({super.key});

  @override
  State<ListThirdPartiesPage> createState() => _ListThirdPartiesPageState();
}

class _ListThirdPartiesPageState extends State<ListThirdPartiesPage> {
  // List of all third parties (example data)
  final List<ThirdParty> _allThirdParties = [
    ThirdParty(
      id: '1',
      name: 'Alpha Solutions',
      type: 'Client',
      code: 'CLI-001234',
      address: '10 Rue de la Paix, Paris',
      phone: '01 23 45 67 89',
      email: 'contact@alpha.com',
    ),
    ThirdParty(
      id: '2',
      name: 'Beta Consulting',
      type: 'Prospect',
      code: 'PRO-005678',
      address: '25 Av. des Champs, Lyon',
      phone: '04 98 76 54 32',
      email: 'info@beta.com',
    ),
    ThirdParty(
      id: '3',
      name: 'Gamma Supplies',
      type: 'Fournisseur',
      code: 'FOU-009101',
      address: '5 Bd de la Liberté, Marseille',
      phone: '09 12 34 56 78',
      email: 'support@gamma.fr',
    ),
    ThirdParty(
      id: '4',
      name: 'Delta Innovations',
      type: 'Client',
      code: 'CLI-001122',
      address: '3 Rue du Commerce, Bordeaux',
      phone: '05 56 78 90 12',
      email: 'sales@delta.net',
    ),
    ThirdParty(
      id: '5',
      name: 'Epsilon Services',
      type: 'Prospect',
      code: 'PRO-003344',
      address: '1 Place Royale, Nantes',
      phone: '02 34 56 78 90',
      email: 'hello@epsilon.org',
    ),
  ];

  // List of third parties currently displayed after applying filters
  List<ThirdParty> _filteredThirdParties = [];

  // Controller for the name search field
  final TextEditingController _searchController = TextEditingController();

  // Selected third-party type for filtering (initialized to 'Tous')
  // Using a Set for SegmentedButton
  Set<String> _selectedFilterType = {'Tous'};
  // This list is defined but not directly used in the SegmentedButton segments,
  // as the segments are hardcoded. It's fine for clarity.
  final List<String> _filterTypes = [
    'Tous',
    'Client',
    'Prospect',
    'Fournisseur',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with all third parties
    _filteredThirdParties = List.from(_allThirdParties);
    // Listen for changes in the search field
    _searchController.addListener(_applyFilters);
    // Apply initial filters in case _selectedFilterType is not 'Tous' initially
    // (though in this code, it is)
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  // Function to apply filters (search by name/code and by type)
  void _applyFilters() {
    final String searchText = _searchController.text.toLowerCase();
    // Retrieve the single value from the Set
    final String currentFilterType = _selectedFilterType.single;

    _filteredThirdParties = _allThirdParties.where((thirdParty) {
      final bool matchesSearch =
          thirdParty.name.toLowerCase().contains(searchText) ||
          thirdParty.code.toLowerCase().contains(searchText);
      final bool matchesType =
          currentFilterType == 'Tous' || thirdParty.type == currentFilterType;
      return matchesSearch && matchesType;
    }).toList();
    setState(() {}); // Update the UI
  }

  @override
  Widget build(BuildContext context) {
    // Using colors defined in AppColors
    final Color primaryColor =
        AppColors.primaryIndigo; // Main color (indigo blue)
    final Color accentColor = AppColors.accentBlue; // Accent color (blue)

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground, // Scaffold background
      appBar: AppBar(
        title: Text(
          'Liste des Tiers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground, // App bar text color
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground, // App bar background color
        iconTheme: const IconThemeData(
          color: AppColors.appBarForeground,
        ), // Back icon color
        elevation: 0, // No shadow for a flat, modern look
      ),
      body: Stack(
        // Using a Stack for the background message
        children: [
          // Background message (always visible)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .people_alt_outlined, // Icon to represent third parties
                    size: 100, // Larger icon
                    color: AppColors
                        .neutralGrey200, // Very light color for background
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Vos tiers s\'afficheront ici.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color:
                          AppColors.neutralGrey300, // Light text for background
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Utilisez les filtres pour affiner votre recherche.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.neutralGrey300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main content (filters and list)
          Column(
            children: [
              // Filters area
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search field
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
                          borderSide: BorderSide.none, // No default border
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
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 2,
                          ), // Primary color on focus
                        ),
                        filled: true,
                        fillColor:
                            AppColors.neutralGrey100, // Field background color
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Filter by type (SegmentedButton)
                    Center(
                      child: SegmentedButton<String>(
                        segments: const <ButtonSegment<String>>[
                          ButtonSegment<String>(
                            value: 'Tous',
                            label: Text('Tous'),
                            icon: Icon(Icons.apps),
                          ),
                          ButtonSegment<String>(
                            value: 'Client',
                            label: Text('Client'),
                            icon: Icon(Icons.person),
                          ),
                          ButtonSegment<String>(
                            value: 'Prospect',
                            label: Text('Prospect'),
                            icon: Icon(Icons.search),
                          ),
                          ButtonSegment<String>(
                            value: 'Fournisseur',
                            label: Text('Fournisseur'),
                            icon: Icon(Icons.local_shipping),
                          ),
                        ],
                        selected: _selectedFilterType,
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedFilterType = newSelection;
                            _applyFilters(); // Apply filters on each change
                          });
                        },
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: accentColor.withOpacity(
                            0.1,
                          ), // Subtle background for selection
                          selectedForegroundColor:
                              accentColor, // Selected text/icon color
                          foregroundColor:
                              AppColors.neutralGrey700, // Default color
                          side: BorderSide(
                            color: AppColors.neutralGrey300,
                            width: 1,
                          ), // Light border
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        multiSelectionEnabled: false,
                      ),
                    ),
                  ],
                ),
              ),

              // List of third parties
              Expanded(
                child:
                    _filteredThirdParties.isEmpty &&
                        _searchController.text.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline, // Icon for "no results"
                                size: 60,
                                color: AppColors
                                    .neutralGrey400, // Gray color for the icon
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Aucun tiers ne correspond à votre recherche.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors
                                      .neutralGrey600, // Gray color for the text
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Veuillez ajuster vos filtres ou le terme de recherche.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.neutralGrey500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        itemCount: _filteredThirdParties.length,
                        itemBuilder: (context, index) {
                          final thirdParty = _filteredThirdParties[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: AppColors.neutralWhite, // Card color
                            child: InkWell(
                              // Makes the card clickable
                              onTap: () {
                                // NAVIGATE TO THE THIRD PARTY DETAIL PAGE
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ThirdPartyDetailPage(
                                      thirdParty: thirdParty,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          // Use Expanded to prevent overflow
                                          child: Text(
                                            thirdParty.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors
                                                      .primaryText, // Dark primary text
                                                ),
                                            overflow: TextOverflow
                                                .ellipsis, // Handle long names
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: thirdParty.type == 'Client'
                                                ? primaryColor.withOpacity(
                                                    0.1,
                                                  ) // Client: primary color tint
                                                : thirdParty.type == 'Prospect'
                                                ? AppColors
                                                      .neutralGrey200 // Prospect: neutral gray
                                                : accentColor.withOpacity(
                                                    0.1,
                                                  ), // Fournisseur: accent color tint
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            thirdParty.type,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: thirdParty.type == 'Client'
                                                  ? primaryColor // Client: primary color
                                                  : thirdParty.type ==
                                                        'Prospect'
                                                  ? AppColors
                                                        .neutralGrey700 // Prospect: dark gray
                                                  : accentColor, // Fournisseur: accent color
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Code: ${thirdParty.code}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.neutralGrey700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    if (thirdParty.address != null &&
                                        thirdParty.address!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        thirdParty.address!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.neutralGrey600,
                                            ),
                                      ),
                                    ],
                                    if (thirdParty.phone != null &&
                                        thirdParty.phone!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tel: ${thirdParty.phone!}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.neutralGrey600,
                                            ),
                                      ),
                                    ],
                                    if (thirdParty.email != null &&
                                        thirdParty.email!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Email: ${thirdParty.email!}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.neutralGrey600,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the add third party page and wait for a result
          final newThirdParty = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddThirdPartyPage()),
          );

          // If a new third party was returned, add it to the list and refresh
          if (newThirdParty != null && newThirdParty is ThirdParty) {
            setState(() {
              _allThirdParties.add(newThirdParty);
              _applyFilters(); // Re-apply filters to include the new third party
            });
          }
        },
        backgroundColor:
            accentColor, // Accent color for the floating action button
        child: const Icon(Icons.add, color: AppColors.white), // Add icon
        shape: const CircleBorder(), // Circular floating button
      ),
    );
  }
}
