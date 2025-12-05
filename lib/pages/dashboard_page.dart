// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:softigotest/pages/AdminPage.dart';
import 'package:softigotest/pages/LeaveListPage.dart';
import 'package:softigotest/pages/LeaveRequestPage.dart';
import 'package:softigotest/pages/QuoteListPage.dart';
import 'package:softigotest/pages/add_thirdparty_page.dart';
import 'package:softigotest/pages/list_third_parties_page.dart';
import 'package:softigotest/pages/ticket_list_page.dart';
import 'package:softigotest/services/permission_service.dart';

// Import the new page
import 'package:softigotest/pages/command_list_page.dart';

// Import your styles and pages
import '../utils/app_styles.dart';
import 'factures_page.dart';
import 'create_invoice_draft_page.dart';
import 'package:softigotest/pages/NewExpenseReportPage.dart';

// IMPORT AUTH SERVICE AND LOGIN PAGE
import 'package:softigotest/services/auth_service.dart';
import 'package:softigotest/pages/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _searchText = '';
  int _selectedIndex = 0;
  String _filter = 'Today';

  final AuthService _authService = AuthService();

  final List<String> _itemLabels = const [
    'Dashboard',
    'Factures',
    'Tiers',
    'Congés',
    'Paramètres',
  ];

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_itemLabels[index] == 'Factures') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FacturesPage()),
      );
    } else if (_itemLabels[index] == 'Tiers') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ListThirdPartiesPage()),
      );
    } else if (_itemLabels[index] == 'Congés') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LeaveListPage()),
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

  Future<void> _handleLogout() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Déconnexion en cours...')));

    try {
      final bool apiCallSuccessful = await _authService.logout();

      if (apiCallSuccessful) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déconnexion réussie !'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Échec API de déconnexion, mais session locale effacée.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  late PermissionService _permissionService;
  
  @override
  void initState() {
    super.initState();
    _permissionService = PermissionService();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    await _permissionService.loadUserData();
    setState(() {}); // Rafraîchir l'interface
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color unselectedColor = AppColors.neutralGrey600;

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
            padding: const EdgeInsets.only(top: 10), // Reduced top padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/softigo_logo.png',
                  height: 30, // Reduced logo size
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _handleLogout,
                  child: CircleAvatar(
                    radius: 16, // Reduced avatar radius
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16, // Reduced icon size
                    ),
                  ),
                ),
                const SizedBox(width: 6), // Reduced space
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ), // Reduced horizontal padding
          child: ListView(
            children: [
              // Welcome Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                ), // Reduced vertical padding
                child: Text(
                  'Bonjour, Admin Softigo !',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              Text(
                'Bienvenue sur votre tableau de bord.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  // Reduced font size
                  color: AppColors.neutralGrey700,
                ),
              ),
              const SizedBox(height: 12), // Reduced space
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddThirdPartyPage(),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionButton(
                    context,
                    label: 'Demande de congé',
                    icon: Icons.date_range,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaveRequestPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18), // Reduced space
              // Search Field
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher une facture, un client...',
                  prefixIcon: Icon(Icons.search, size: 18), // Reduced icon size
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ), // Reduced border radius
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.neutralGrey100,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, // Reduced vertical padding
                    horizontal: 12, // Reduced horizontal padding
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchText = val;
                  });
                },
              ),
              const SizedBox(height: 18), // Reduced space
              // Info Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12, // Reduced spacing
                crossAxisSpacing: 12, // Reduced spacing
                childAspectRatio: 1.2,
                children: [
                  if (_permissionService.canViewInvoice())
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
                  if (_permissionService.canViewThirdParty())
                  InfoCard(
                    title: 'Tiers',
                    count: 250,
                    icon: Icons.people,
                    iconColor: AppColors.accentBlue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListThirdPartiesPage(),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExpenseReportListPage(),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaveListPage(),
                        ),
                      );
                    },
                  ),
                  if (_permissionService.isAdmin())
                  InfoCard(
                    title: 'Administration',
                    count: 7,
                    icon: Icons.business,
                    iconColor: AppColors.accentGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminPage(),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuoteListPage(),
                        ),
                      );
                    },
                  ),
                  if (_permissionService.canViewCommand())
                  InfoCard(
                    title: 'Commandes',
                    count: 50,
                    icon: Icons.shopping_cart,
                    iconColor: AppColors.accentBlue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CommandListPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24), // Reduced space
              // Recent Activities Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activités récentes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voir tout cliqué!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(
                      'Voir tout',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        // Reduced font size
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Reduced space
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Today', 'Weekly', 'Monthly'].map((option) {
                    final isSelected = _filter == option;
                    return Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                      ), // Reduced padding
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _filter = option;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            vertical: 6, // Reduced vertical padding
                            horizontal: 16, // Reduced horizontal padding
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // Reduced border radius
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : AppColors.neutralGrey300,
                              width: 1, // Reduced border width
                            ),
                          ),
                          child: Text(
                            option,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  // Reduced font size
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.8)
                                      : AppColors.neutralGrey600,
                                ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12), // Reduced space
              ...overviewList
                  .map(
                    (item) => Card(
                      margin: const EdgeInsets.only(
                        bottom: 6.0,
                      ), // Reduced bottom margin
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildOverviewListItem(context, item),
                    ),
                  )
                  ,
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 12), // Reduced font size
          unselectedLabelStyle: TextStyle(fontSize: 12), // Reduced font size
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, size: 20), // Reduced icon size
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long, size: 20), // Reduced icon size
              label: 'Factures',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group, size: 20), // Reduced icon size
              label: 'Tiers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: 20), // Reduced icon size
              label: 'Congés',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 20), // Reduced icon size
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }

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
          borderRadius: BorderRadius.circular(8), // Reduced border radius
          child: Container(
            padding: const EdgeInsets.all(10), // Reduced padding
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8), // Reduced border radius
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24, // Reduced icon size
            ),
          ),
        ),
        const SizedBox(height: 6), // Reduced space
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            // Reduced font size
            fontWeight: FontWeight.w600,
            color: AppColors.neutralGrey800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

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
        subtitle =
            '${item['client']} - ${item['amount'].toStringAsFixed(2)} MAD';
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
            '${item['description']} - ${item['amount'].toStringAsFixed(2)} MAD (${item['status']})';
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
            '${item['client']} - ${item['amount'].toStringAsFixed(2)} MAD (Statut: ${item['status']})';
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
      dense: true, // Makes the list tile more compact
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ), // Reduced padding
      leading: CircleAvatar(
        radius: 18, // Reduced avatar radius
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 18), // Reduced icon size
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ), // Reduced font size
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.neutralGrey700,
        ), // Reduced font size
      ),
      trailing: Text(
        item['date'].toString(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.neutralGrey500,
        ), // Reduced font size
      ),
      onTap: () {
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
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5, // Reduced elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ), // Reduced border radius
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced padding
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24, // Reduced icon size
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  // Reduced font size
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutralGrey700,
                ),
              ),
              const SizedBox(height: 2), // Reduced spacing
              Text(
                '$count',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  // Adjusted font size
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on Color {
  Color get shade300 =>
      (this is MaterialColor) ? (this as MaterialColor).shade300 : this;
  Color get shade800 =>
      (this is MaterialColor) ? (this as MaterialColor).shade800 : this;
}
