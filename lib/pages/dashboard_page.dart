// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Importez vos styles et pages
import '../utils/app_styles.dart';
// Make sure this page exists
import 'factures_page.dart';

import 'create_invoice_draft_page.dart';

// Import the new pages for quick actions
import 'add_invoice_page.dart'; // Make sure this page exists

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _searchText = '';
  int _selectedIndex = 0; // For BottomNavigationBar
  String _filter = 'Today'; // For Recent Activities filter

  // Libellés des éléments de la BottomNavigationBar
  final List<String> _itemLabels = const [
    'Dashboard',
    'Factures',
    'Tiers',
    'Congés',
    'Paramètres',
  ];

  // Dummy data for Recent Activities
  final Map<String, List<Map<String, dynamic>>> _overviewData = {
    'Today': [
      {
        'type': 'invoice',
        'number': 'F101',
        'client': 'Client X',
        'amount': 300.0,
        'paid': true,
        'date': '2025-07-03',
      },
      {
        'type': 'expense',
        'number': 'NDF005',
        'description': 'Déjeuner client',
        'amount': 45.0,
        'status': 'Pending',
        'date': '2025-07-03',
      },
      {
        'type': 'invoice',
        'number': 'F102',
        'client': 'Client Y',
        'amount': 150.0,
        'paid': false,
        'date': '2025-07-02',
      },
    ],
    'Weekly': [
      {
        'type': 'invoice',
        'number': 'F103',
        'client': 'Client Z',
        'amount': 1200.0,
        'paid': true,
        'date': '2025-06-30',
      },
      {
        'type': 'leave',
        'employee': 'Sophie Martin',
        'type_conge': 'Congé Payé',
        'status': 'Pending',
        'date': '2025-06-29',
      },
      {
        'type': 'invoice',
        'number': 'F104',
        'client': 'Client W',
        'amount': 600.0,
        'paid': false,
        'date': '2025-06-28',
      },
      {
        'type': 'quote',
        'number': 'D205',
        'client': 'Client V',
        'amount': 900.0,
        'status': 'Sent',
        'date': '2025-06-27',
      },
    ],
    'Monthly': [
      {
        'type': 'invoice',
        'number': 'F106',
        'client': 'Client U',
        'amount': 2000.0,
        'paid': false,
        'date': '2025-06-20',
      },
      {
        'type': 'expense',
        'number': 'NDF004',
        'description': 'Fournitures bureau',
        'amount': 120.0,
        'status': 'Approved',
        'date': '2025-06-18',
      },
      {
        'type': 'invoice',
        'number': 'F107',
        'client': 'Client T',
        'amount': 1100.0,
        'paid': true,
        'date': '2025-06-15',
      },
      {
        'type': 'client',
        'name': 'Nouvel SARL',
        'contact': 'nouvel@example.com',
        'date': '2025-06-10',
      },
      {
        'type': 'invoice',
        'number': 'F108',
        'client': 'Client S',
        'amount': 750.0,
        'paid': false,
        'date': '2025-06-05',
      },
    ],
  };

  // Gère les clics sur la barre de navigation du bas
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on the selected index
    if (_itemLabels[index] == 'Factures') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FacturesPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Button "${_itemLabels[index]}" is clicked !'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color unselectedColor = AppColors.neutralGrey600;

    // Filter and search the overview data
    final overviewList = _overviewData[_filter]!.where((item) {
      final searchLower = _searchText.toLowerCase();
      if (item['type'] == 'invoice' || item['type'] == 'quote') {
        return item['number'].toLowerCase().contains(searchLower) ||
            item['client'].toLowerCase().contains(searchLower);
      } else if (item['type'] == 'expense') {
        return item['number'].toLowerCase().contains(searchLower) ||
            item['description'].toLowerCase().contains(searchLower);
      } else if (item['type'] == 'leave') {
        return item['employee'].toLowerCase().contains(searchLower) ||
            item['type_conge'].toLowerCase().contains(searchLower);
      } else if (item['type'] == 'client') {
        return item['name'].toLowerCase().contains(searchLower) ||
            item['contact'].toLowerCase().contains(searchLower);
      }
      return false;
    }).toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/softigo_logo.png', // Ensure this path is correct
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // Navigate to User Profile or Notifications or Logout
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile/Notifications cliquées!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150/FFDDC1/000000?text=JD', // Dummy image
                    ),
                    radius: 20,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Welcome Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Bonjour, Admin Softigo !',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              Text(
                'Bienvenue sur votre tableau de bord.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutralGrey700,
                ),
              ),
              const SizedBox(height: 16),

              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(
                    context,
                    label: 'Nouvelle facture',
                    icon: Icons.add_chart,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateInvoiceDraftPage(),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionButton(
                    context,
                    label: 'Nouveau tiers',
                    icon: Icons.person_add,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nouveau tiers clicked!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionButton(
                    context,
                    label: 'Demande de congé',
                    icon: Icons.date_range,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Demande de congé clicked!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Field
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Rechercher une facture, un client, une dépense...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none, // No border line
                  ),
                  filled: true,
                  fillColor: AppColors.neutralGrey100, // Light grey background
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ), // Adjust padding
                ),
                onChanged: (val) {
                  setState(() {
                    _searchText = val;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Info Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1, // Adjusted for better visual balance
                children: [
                  InfoCard(
                    title: 'Factures',
                    count: 150,
                    icon: Icons.receipt_long,
                    iconColor: AppColors.primaryIndigo,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FacturesPage(),
                        ),
                      );
                    },
                  ),
                  InfoCard(
                    title: 'Tiers',
                    count: 250,
                    icon: Icons.people,
                    iconColor: AppColors.accentBlue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tiers card clicked!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  InfoCard(
                    title: 'Notes de frais',
                    count: 12,
                    icon: Icons.money,
                    iconColor: AppColors.accentOrange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notes de frais card clicked!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  InfoCard(
                    title: 'Congés',
                    count: 5,
                    icon: Icons.calendar_today,
                    iconColor: AppColors.accentRed,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Congés card clicked!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  InfoCard(
                    title: 'Administration',
                    count: 7,
                    icon: Icons.business,
                    iconColor: AppColors.accentGreen,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Administration card clicked!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  InfoCard(
                    title: 'Devis',
                    count: 25,
                    icon: Icons.description,
                    iconColor: AppColors.primaryIndigo.shade300,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Devis card clicked!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => const QuotesPage()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Activities Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activités récentes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Implement navigation to a full activity log page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voir tout cliqué!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(
                      'Voir tout',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Today', 'Weekly', 'Monthly'].map((option) {
                    final isSelected = _filter == option;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _filter = option;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : AppColors.neutralGrey300,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            option,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.8)
                                      : AppColors.neutralGrey600,
                                  fontSize: 14,
                                ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // List of recent activities
              ...overviewList
                  .map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      elevation: 1, // Subtle elevation for list items
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildOverviewListItem(context, item),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Factures',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Tiers'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Congés',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for quick action buttons
  Widget _buildQuickActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutralGrey800,
          ),
        ),
      ],
    );
  }

  // Helper widget for building each item in the Recent Activities list
  Widget _buildOverviewListItem(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    IconData icon;
    Color color;
    String title;
    String subtitle;

    switch (item['type']) {
      case 'invoice':
        bool paid = item['paid'];
        icon = paid ? Icons.check_circle : Icons.warning_amber;
        color = paid ? AppColors.accentGreen : AppColors.accentRed;
        title = 'Facture ${item['number']}';
        subtitle = '${item['client']} - ${item['amount'].toStringAsFixed(2)} €';
        if (!paid) subtitle += ' (Impayée)';
        break;
      case 'expense':
        icon = Icons.money;
        color = item['status'] == 'Approved'
            ? AppColors.accentGreen
            : item['status'] == 'Pending'
            ? AppColors.accentOrange
            : AppColors.accentRed;
        title = 'Note de frais ${item['number']}';
        subtitle =
            '${item['description']} - ${item['amount'].toStringAsFixed(2)} € (${item['status']})';
        break;
      case 'leave':
        icon = Icons.calendar_today;
        color = item['status'] == 'Approved'
            ? AppColors.accentGreen
            : item['status'] == 'Pending'
            ? AppColors.accentOrange
            : AppColors.accentRed;
        title = 'Congé de ${item['employee']}';
        subtitle = '${item['type_conge']} - Statut: ${item['status']}';
        break;
      case 'quote':
        icon = Icons.description;
        color = AppColors.primaryIndigo.shade300;
        title = 'Devis ${item['number']}';
        subtitle =
            '${item['client']} - ${item['amount'].toStringAsFixed(2)} € (Statut: ${item['status']})';
        break;
      case 'client':
        icon = Icons.person_add;
        color = AppColors.accentBlue;
        title = 'Nouveau client: ${item['name']}';
        subtitle = 'Contact: ${item['contact']}';
        break;
      default:
        icon = Icons.info_outline;
        color = AppColors.neutralGrey600;
        title = 'Activité inconnue';
        subtitle = 'Détails non disponibles';
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.neutralGrey700),
      ),
      trailing: Text(
        item['date'].toString(),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.neutralGrey500),
      ),
      onTap: () {
        // Implement navigation to specific detail page based on item type
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped on ${item['type']} activity!'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
}

// InfoCard widget (moved here for completeness, or keep in a separate file if preferred)
class InfoCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const InfoCard({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center content horizontally
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Padding around the icon
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(
                    0.1,
                  ), // Light background color for the circle
                  shape: BoxShape.circle, // Makes the container circular
                ),
                child: Icon(
                  icon,
                  size: 28, // Adjust icon size
                  color: iconColor, // Use the iconColor
                ),
              ),
              const SizedBox(height: 12), // Spacing between icon and text
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500, // Slightly less bold
                  color: AppColors
                      .neutralGrey700, // Use a neutral grey for the title
                ),
              ),
              const SizedBox(height: 4), // Spacing between title and count
              Text(
                '$count',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors
                      .primaryText, // Use primary text color for the count
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder for AppColors - make sure this matches your actual AppColors file
class AppColors {
  static const Color primaryIndigo = Colors.indigo;
  static const Color accentBlue = Colors.blue;
  static const Color neutralGrey100 = Color(0xFFF5F5F5); // Very light grey
  static const Color neutralGrey300 = Color(0xFFE0E0E0); // Light grey
  static const Color neutralGrey500 = Color(0xFF9E9E9E); // Medium grey
  static const Color neutralGrey600 = Color(0xFF757575); // Example
  static const Color primaryText = Color(0xFF212121); // Example
  static const Color neutralGrey700 = Color(0xFF616161); // Example
  static const Color accentOrange = Colors.orange;
  static const Color accentRed = Colors.red;
  static const Color accentGreen = Colors.green;
  static const Color neutralGrey800 = Color(0xFF424242); // Example
}

extension on Color {
  Color get shade300 =>
      (this is MaterialColor) ? (this as MaterialColor).shade300 : this;
  Color get shade800 =>
      (this is MaterialColor) ? (this as MaterialColor).shade800 : this;
}
