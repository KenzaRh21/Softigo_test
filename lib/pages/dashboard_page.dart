// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';

// Importez vos styles
import '../utils/app_styles.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String _searchText = '';
  int _selectedIndex = 0;

  final List<String> _itemLabels = const [
    'Dashboard',
    'Factures',
    'Tiers',
    'Congés',
    'Paramètres',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex =
          index; // Still update index to show selected state visually
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item "${_itemLabels[index]}" cliqué !'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Helper function to show a SnackBar for InfoCards and Quick Actions
  void _showActionClickedSnackBar(String actionTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$actionTitle" cliquée !'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color unselectedColor = AppColors.neutralGrey600;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/softigologo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    _showActionClickedSnackBar('Icône de déconnexion');
                  },
                  // --- MODIFICATION HERE: Using standard Material Design logout icon ---
                  child: const Icon(
                    Icons
                        .logout, // This is the standard Material Design logout icon
                    size: 30, // Adjust size as needed
                    color: AppColors.primaryText, // Adjust color as needed
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        body: const _DashboardContent(),
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
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent({super.key});

  @override
  __DashboardContentState createState() => __DashboardContentState();
}

class __DashboardContentState extends State<_DashboardContent> {
  String _searchText = '';

  // Helper function to show a SnackBar for InfoCards and Quick Actions
  void _showActionClickedSnackBar(String actionTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$actionTitle" cliquée !'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
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
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.neutralGrey700),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
                context,
                label: 'Nouvelle facture',
                icon: Icons.add_chart,
                onTap: () {
                  _showActionClickedSnackBar('Nouvelle facture');
                },
              ),
              _buildQuickActionButton(
                context,
                label: 'Nouveau tiers',
                icon: Icons.person_add,
                onTap: () {
                  _showActionClickedSnackBar('Nouveau tiers');
                },
              ),
              _buildQuickActionButton(
                context,
                label: 'Demande de congé',
                icon: Icons.date_range,
                onTap: () {
                  _showActionClickedSnackBar('Demande de congé');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher une facture, un client, une dépense...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (val) {
              setState(() {
                _searchText = val;
              });
            },
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              InfoCard(
                title: 'Factures',
                count: 150,
                icon: Icons.receipt_long,
                color: AppColors.primaryIndigo,
                onTap: () {
                  _showActionClickedSnackBar('Factures');
                },
              ),
              InfoCard(
                title: 'Tiers',
                count: 250,
                icon: Icons.people,
                color: AppColors.accentBlue,
                onTap: () {
                  _showActionClickedSnackBar('Tiers');
                },
              ),
              InfoCard(
                title: 'Notes de frais',
                count: 12,
                icon: Icons.money,
                color: AppColors.accentOrange,
                onTap: () {
                  _showActionClickedSnackBar('Notes de frais');
                },
              ),
              InfoCard(
                title: 'Congés',
                count: 5,
                icon: Icons.calendar_today,
                color: AppColors.accentRed,
                onTap: () {
                  _showActionClickedSnackBar('Congés');
                },
              ),
              InfoCard(
                title: 'Administration',
                count: 7,
                icon: Icons.business,
                color: AppColors.accentGreen,
                onTap: () {
                  _showActionClickedSnackBar('Administration');
                },
              ),
              InfoCard(
                title: 'Devis',
                count: 25,
                icon: Icons.description,
                color: AppColors.primaryIndigo.shade300,
                onTap: () {
                  _showActionClickedSnackBar('Devis');
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
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
}

extension on Color {
  Color get shade300 =>
      (this is MaterialColor) ? (this as MaterialColor).shade300 : this;
  Color get shade800 =>
      (this is MaterialColor) ? (this as MaterialColor).shade800 : this;
}
