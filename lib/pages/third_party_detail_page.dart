import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates in activities
import 'package:softigotest/models/third_party.dart';
import 'package:softigotest/pages/edit_thirdparty_page.dart';

import '../utils/app_styles.dart'; // Import your application styles and colors

// Dummy data needs to be accessible by both detail and edit pages for this example.
// In a real app, this would be managed via a proper state management solution (e.g., Provider, Riverpod, BLoC).
// Ensure this list is consistently used across pages that interact with dummy data.
List<ThirdParty> dummyThirdParties = [
  ThirdParty(
    id: '1', // ID is crucial for identification across pages
    name: 'Tech Solutions Inc.',
    type: 'Client',
    code: 'CLI-001',
    taxId: '123456789',
    phone: '+1-555-123-4567',
    email: 'contact@techsolutions.com',
    contactPerson: 'Alice Johnson',
    contactRole: 'Sales Manager',
    address: '123 Tech Avenue, Innovation City, 90210',
    notes:
        'Long-standing client with potential for expansion. Met at the annual tech conference.',
    activities: [
      ThirdPartyActivity(
        date: DateTime(2025, 6, 15, 10, 30),
        type: 'Appel',
        description: 'Discussion about new project requirements.',
      ),
      ThirdPartyActivity(
        date: DateTime(2025, 6, 20, 14, 0),
        type: 'Email',
        description: 'Sent proposal for phase 2 development.',
      ),
      ThirdPartyActivity(
        date: DateTime(2025, 7, 5, 9, 0),
        type: 'Note',
        description: 'Follow-up on proposal. Awaiting client feedback.',
      ),
    ],
  ),
  ThirdParty(
    id: '2', // ID is crucial for identification across pages
    name: 'Global Suppliers Ltd.',
    type: 'Fournisseur',
    code: 'FOUR-002',
    parentCompany: 'Global Holdings',
    phone: '+44-20-7946-0958',
    email: 'info@globalsuppliers.co.uk',
    address: '456 Supply Road, London, UK',
    notes:
        'Key supplier for electronic components. Good relationship. Annual contract renewal due next quarter.',
    activities: [
      ThirdPartyActivity(
        date: DateTime(2025, 5, 10, 11, 0),
        type: 'Réunion',
        description: 'Quarterly review meeting.',
      ),
      ThirdPartyActivity(
        date: DateTime(2025, 5, 25, 9, 0),
        type: 'Commande',
        description: 'Placed order #54321 for Q3 inventory.',
      ),
    ],
  ),
  ThirdParty(
    id: '3', // ID is crucial for identification across pages
    name: 'Innovate Start-up',
    type: 'Prospect',
    code: 'PROS-003',
    email: 'hello@innovate.com',
    contactPerson: 'Bob White',
    notes:
        'Initial contact made through referral. Follow-up call planned next week to discuss potential partnership.',
    activities: [
      ThirdPartyActivity(
        date: DateTime(2025, 6, 28, 16, 0),
        type: 'Email',
        description: 'Initial introduction email sent.',
      ),
    ],
  ),
];

class ThirdPartyDetailPage extends StatefulWidget {
  final ThirdParty thirdParty; // The initial third party to display

  const ThirdPartyDetailPage({super.key, required this.thirdParty});

  @override
  State<ThirdPartyDetailPage> createState() => _ThirdPartyDetailPageState();
}

class _ThirdPartyDetailPageState extends State<ThirdPartyDetailPage> {
  late ThirdParty
  _currentThirdParty; // Mutable state variable for the third party

  @override
  void initState() {
    super.initState();
    // Initialize _currentThirdParty with the value from the widget's constructor
    _currentThirdParty = widget.thirdParty;
  }

  // Helper for showing SnackBar messages
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Function to confirm deletion
  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer ce Tiers ?'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ${_currentThirdParty.name} ? Cette action est irréversible.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), // Cancel
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                // Confirm action
                Navigator.of(
                  dialogContext,
                ).pop(true); // Close the dialog with true
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Deletion logic (for this example, we remove it from dummyThirdParties)
      // In a real application, you would make an API call or database deletion.
      final exists = dummyThirdParties.any(
        (tp) => tp.id == _currentThirdParty.id,
      );
      dummyThirdParties.removeWhere((tp) => tp.id == _currentThirdParty.id);

      if (exists) {
        _showSnackBar(
          context,
          '${_currentThirdParty.name} a été supprimé avec succès.',
        );
        Navigator.of(context).pop(true);
      } else {
        _showSnackBar(
          context,
          'Erreur lors de la suppression de ${_currentThirdParty.name}.',
          isError: true,
        );
      }
    }
  }

  Future<void> _addActivity(BuildContext context) async {
    final TextEditingController activityController = TextEditingController();
    String? selectedActivityType = 'Note'; // Default type

    final bool? shouldAdd = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ajouter une nouvelle activité'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedActivityType,
                  decoration: const InputDecoration(
                    labelText: 'Type d\'activité',
                  ),
                  items:
                      <String>[
                        'Appel',
                        'Email',
                        'Réunion',
                        'Commande',
                        'Note',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    // Update the local variable, which will be used when adding the activity
                    selectedActivityType = newValue;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: activityController,
                  decoration: const InputDecoration(
                    labelText: 'Description de l\'activité',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              // THIS IS THE CORRECTED PART (LINE 130 IN YOUR PROVIDED CODE)
              onPressed: () {
                if (activityController.text.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop(
                    true,
                  ); // Just pop, don't assign or await in this context
                } else {
                  _showSnackBar(
                    dialogContext,
                    'La description de l\'activité ne peut pas être vide.',
                    isError: true,
                  );
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    if (shouldAdd == true) {
      final newActivity = ThirdPartyActivity(
        date: DateTime.now(),
        type: selectedActivityType ?? 'Note', // Use selected type or default
        description: activityController.text.trim(),
      );

      setState(() {
        // Ensure activities list is not null before adding
        _currentThirdParty.activities ??= [];
        _currentThirdParty.activities!.add(newActivity);
        // Sort activities by date, most recent first
        _currentThirdParty.activities!.sort((a, b) => b.date.compareTo(a.date));
      });

      _showSnackBar(context, 'Activité ajoutée avec succès.');
      // IMPORTANT: Update the dummy data list to reflect the change globally.
      // This ensures that when returning to ListThirdPartiesPage, it has the updated data.
      final index = dummyThirdParties.indexWhere(
        (tp) => tp.id == _currentThirdParty.id,
      );
      if (index != -1) {
        dummyThirdParties[index] = _currentThirdParty;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using colors defined in AppColors
    final Color primaryColor = AppColors.primaryIndigo;
    final Color accentColor = AppColors.accentBlue;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          _currentThirdParty.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.appBarForeground),
            tooltip: 'Modifier ce tiers',
            onPressed: () async {
              // Navigate to EditThirdPartyPage, passing the current third party
              // and waiting for a result (the updated ThirdParty object)
              final updatedThirdParty = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditThirdPartyPage(
                    thirdPartyToEdit:
                        _currentThirdParty, // Pass the existing object from state
                  ),
                ),
              );

              // If EditThirdPartyPage returns an updated object, update the state
              if (updatedThirdParty != null &&
                  updatedThirdParty is ThirdParty) {
                setState(() {
                  _currentThirdParty =
                      updatedThirdParty; // Update the local state
                });
                _showSnackBar(
                  context,
                  '${updatedThirdParty.name} a été mis à jour avec succès.',
                );

                // IMPORTANT: For your dummy data, you need to update the global list too.
                // In a real app, this would be handled by your data layer (e.g., API call, database update).
                final index = dummyThirdParties.indexWhere(
                  (tp) => tp.id == updatedThirdParty.id,
                );
                if (index != -1) {
                  dummyThirdParties[index] = updatedThirdParty;
                }
              }
            },
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Supprimer ce tiers',
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Information Section
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
                      _currentThirdParty.name,
                      primaryColor,
                    ),
                    _buildDetailRow(
                      context,
                      _getIconForType(_currentThirdParty.type),
                      'Type',
                      _currentThirdParty.type,
                      _getColorForType(
                        _currentThirdParty.type,
                        primaryColor,
                        accentColor,
                      ),
                    ),
                    _buildDetailRow(
                      context,
                      Icons.qr_code,
                      'Code',
                      _currentThirdParty.code,
                      AppColors.neutralGrey700,
                    ),
                    if (_currentThirdParty.taxId != null &&
                        _currentThirdParty.taxId!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        Icons.article_outlined,
                        'NIF / SIRET',
                        _currentThirdParty.taxId!,
                        AppColors.neutralGrey700,
                      ),
                    if (_currentThirdParty.parentCompany != null &&
                        _currentThirdParty.parentCompany!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        Icons.business_outlined,
                        'Maison Mère',
                        _currentThirdParty.parentCompany!,
                        AppColors.neutralGrey700,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Contact Section
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
                    if (_currentThirdParty.phone != null &&
                        _currentThirdParty.phone!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        Icons.phone,
                        'Téléphone',
                        _currentThirdParty.phone!,
                        AppColors.neutralGrey700,
                      ),
                    if (_currentThirdParty.email != null &&
                        _currentThirdParty.email!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        Icons.email_outlined,
                        'Email',
                        _currentThirdParty.email!,
                        AppColors.neutralGrey700,
                      ),
                    if (_currentThirdParty.contactPerson != null &&
                        _currentThirdParty.contactPerson!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        Icons.person_outline,
                        'Personne de Contact',
                        _currentThirdParty.contactPerson!,
                        AppColors.neutralGrey700,
                      ),
                    if (_currentThirdParty.contactRole != null &&
                        _currentThirdParty.contactRole!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        Icons.badge_outlined,
                        'Rôle du Contact',
                        _currentThirdParty.contactRole!,
                        AppColors.neutralGrey700,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Address Section
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
                    if (_currentThirdParty.address != null &&
                        _currentThirdParty.address!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        Icons.location_on_outlined,
                        'Adresse',
                        _currentThirdParty.address!,
                        AppColors.neutralGrey700,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notes Section
            if (_currentThirdParty.notes != null &&
                _currentThirdParty.notes!.isNotEmpty) ...[
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
                  child: Text(
                    _currentThirdParty.notes!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Activity History Section
            _buildSectionHeader(context, 'Historique des Activités'),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.neutralWhite,
              child: Column(
                children: [
                  if (_currentThirdParty.activities != null &&
                      _currentThirdParty.activities!.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _currentThirdParty.activities!.length,
                      itemBuilder: (context, index) {
                        final activity = _currentThirdParty.activities![index];
                        return _buildActivityTile(context, activity);
                      },
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Aucune activité enregistrée pour le moment.',
                        style: TextStyle(color: AppColors.neutralGrey600),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _addActivity(context),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Ajouter une activité'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper for building detail rows
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

  // Helper for section headers
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

  // Helper to get icon based on third-party type
  IconData _getIconForType(String type) {
    switch (type) {
      case 'Client':
        return Icons.person;
      case 'Prospect':
        return Icons.saved_search;
      case 'Fournisseur':
        return Icons.local_shipping;
      default:
        return Icons.info_outline;
    }
  }

  // Helper to get color based on third-party type
  Color _getColorForType(String type, Color primaryColor, Color accentColor) {
    switch (type) {
      case 'Client':
        return primaryColor;
      case 'Prospect':
        return Colors.orange;
      case 'Fournisseur':
        return accentColor;
      default:
        return AppColors.neutralGrey500;
    }
  }

  // Helper for building an activity tile
  Widget _buildActivityTile(BuildContext context, ThirdPartyActivity activity) {
    IconData icon;
    Color iconColor;
    switch (activity.type) {
      case 'Appel':
        icon = Icons.call;
        iconColor = Colors.green;
        break;
      case 'Email':
        icon = Icons.mail;
        iconColor = Colors.blue;
        break;
      case 'Réunion':
        icon = Icons.people;
        iconColor = Colors.purple;
        break;
      case 'Commande':
        icon = Icons.shopping_cart;
        iconColor = Colors.teal;
        break;
      case 'Note':
      default:
        icon = Icons.note;
        iconColor = Colors.grey;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'dd MMMM yyyy, HH:mm',
                  ).format(activity.date), // Date formatting
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutralGrey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
