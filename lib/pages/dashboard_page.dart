// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';

// Import custom application styles for consistent theming.
import '../utils/app_styles.dart';

/// The main dashboard page of the application.
/// This is a StatefulWidget to manage mutable state such as selected navigation item.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Although _searchText is defined, it's not currently used in this widget.
  // Consider moving it to _DashboardContent if it's solely for the search bar there,
  // or removing it if it's not intended for use here.
  final String _searchText = '';
  // Tracks the currently selected item in the bottom navigation bar.
  int _selectedIndex = 0;

  // Defines the labels for the bottom navigation bar items.
  final List<String> _itemLabels = const [
    'Dashboard',
    'Factures',
    'Tiers',
    'Congés',
    'Paramètres',
  ];

  /// Handles the tap event for items in the bottom navigation bar.
  /// Updates the selected index and shows a SnackBar notification.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the index to visually highlight the selected item.
    });

    // Display a SnackBar to confirm the item selection.
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
    // TODO: Integrate API calls here based on the selected index.
    // For example:
    // if (index == 0) {
    //   // Call API for Dashboard data
    // } else if (index == 1) {
    //   // Call API for Factures data
    // }
    // This is where you'd navigate to different pages or update the content
    // based on the selected navigation item.
  }

  /// A utility function to display a SnackBar for various actions.
  /// This can be used for actions like tapping on Quick Actions or InfoCards.
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
    // TODO: When integrating actual API calls, this SnackBar might be replaced
    // with more specific feedback (e.g., "Loading data...", "Data saved!").
  }

  @override
  Widget build(BuildContext context) {
    // Define colors for selected and unselected bottom navigation bar items.
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color unselectedColor = AppColors.neutralGrey600;

    return SafeArea(
      child: Scaffold(
        // Application bar at the top of the screen.
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the application logo.
                Image.asset(
                  'assets/images/softigo_logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const Spacer(), // Pushes the logout icon to the right.
                // Logout icon, tappable to show a SnackBar.
                GestureDetector(
                  onTap: () {
                    _showActionClickedSnackBar('Icône de déconnexion');
                    // TODO: Implement actual logout functionality here.
                    // This would typically involve clearing user session data
                    // and navigating to the login screen.
                    // Example: AuthService().logout(); Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Icon(
                    Icons.logout, // Standard Material Design logout icon.
                    size: 30,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        // The main content area of the dashboard, managed by a separate widget.
        body: const _DashboardContent(),
        // Bottom navigation bar for primary navigation.
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          type: BottomNavigationBarType.fixed, // Ensures all items are visible.
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

/// A private StatefulWidget to manage the dynamic content of the dashboard.
/// This separation helps keep the main DashboardPage cleaner and focuses on layout.
class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  __DashboardContentState createState() => __DashboardContentState();
}

class __DashboardContentState extends State<_DashboardContent> {
  // State variable to hold the current search text from the TextField.
  String _searchText = '';

  /// A utility function to display a SnackBar for various actions within the content area.
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
    // TODO: Similar to the DashboardPage, this SnackBar should be replaced
    // with actual API calls or navigation logic when integrating backend services.
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Greeting text for the user.
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
          // Welcome message.
          Text(
            'Bienvenue sur votre tableau de bord.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.neutralGrey700),
          ),
          const SizedBox(height: 16),

          // Row of quick action buttons.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
                context,
                label: 'Nouvelle facture',
                icon: Icons.add_chart,
                onTap: () {
                  _showActionClickedSnackBar('Nouvelle facture');
                  // TODO: Call API to initiate a new invoice creation or navigate to the invoice creation page.
                  // Example: Navigator.pushNamed(context, '/new-invoice');
                },
              ),
              _buildQuickActionButton(
                context,
                label: 'Nouveau tiers',
                icon: Icons.person_add,
                onTap: () {
                  _showActionClickedSnackBar('Nouveau tiers');
                  // TODO: Call API to add a new third party or navigate to the new third party creation page.
                  // Example: Navigator.pushNamed(context, '/new-contact');
                },
              ),
              _buildQuickActionButton(
                context,
                label: 'Demande de congé',
                icon: Icons.date_range,
                onTap: () {
                  _showActionClickedSnackBar('Demande de congé');
                  // TODO: Call API to submit a leave request or navigate to the leave request form.
                  // Example: Navigator.pushNamed(context, '/leave-request');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search input field.
          TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher une facture, un client, une dépense...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (val) {
              setState(() {
                _searchText = val;
              });
              // TODO: Implement search API call or local filtering based on `_searchText`.
              // You might want to debounce this call to avoid excessive API requests.
            },
          ),
          const SizedBox(height: 24),
          // Grid of information cards.
          GridView.count(
            shrinkWrap: true, // Prevents the GridView from expanding infinitely.
            physics:
                const NeverScrollableScrollPhysics(), // Disables GridView's own scrolling.
            crossAxisCount: 2, // Two cards per row.
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4, // Aspect ratio of each card.
            children: [
              InfoCard(
                title: 'Factures',
                count: 150, // TODO: Replace with dynamic data from API.
                icon: Icons.receipt_long,
                color: AppColors.primaryIndigo,
                onTap: () {
                  _showActionClickedSnackBar('Factures');
                  // TODO: Navigate to the invoices list page.
                  // Example: Navigator.pushNamed(context, '/invoices');
                },
              ),
              InfoCard(
                title: 'Tiers',
                count: 250, // TODO: Replace with dynamic data from API.
                icon: Icons.people,
                color: AppColors.accentBlue,
                onTap: () {
                  _showActionClickedSnackBar('Tiers');
                  // TODO: Navigate to the third parties list page.
                  // Example: Navigator.pushNamed(context, '/third-parties');
                },
              ),
              InfoCard(
                title: 'Notes de frais',
                count: 12, // TODO: Replace with dynamic data from API.
                icon: Icons.money,
                color: AppColors.accentOrange,
                onTap: () {
                  _showActionClickedSnackBar('Notes de frais');
                  // TODO: Navigate to the expense reports page.
                  // Example: Navigator.pushNamed(context, '/expense-reports');
                },
              ),
              InfoCard(
                title: 'Congés',
                count: 5, // TODO: Replace with dynamic data from API.
                icon: Icons.calendar_today,
                color: AppColors.accentRed,
                onTap: () {
                  _showActionClickedSnackBar('Congés');
                  // TODO: Navigate to the leave requests page.
                  // Example: Navigator.pushNamed(context, '/leaves');
                },
              ),
              InfoCard(
                title: 'Administration',
                count: 7, // TODO: Replace with dynamic data from API.
                icon: Icons.business,
                color: AppColors.accentGreen,
                onTap: () {
                  _showActionClickedSnackBar('Administration');
                  // TODO: Navigate to the administration section.
                  // Example: Navigator.pushNamed(context, '/admin');
                },
              ),
              InfoCard(
                title: 'Devis',
                count: 25, // TODO: Replace with dynamic data from API.
                icon: Icons.description,
                color: AppColors.primaryIndigo.shade300,
                onTap: () {
                  _showActionClickedSnackBar('Devis');
                  // TODO: Navigate to the quotes list page.
                  // Example: Navigator.pushNamed(context, '/quotes');
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Builds a reusable quick action button with an icon and label.
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

/// A simple widget to display information in a card format.
/// This would typically show a count and an icon related to a specific category.
class InfoCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color.withOpacity(0.1), // Slightly transparent background.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
        elevation: 0, // No shadow for a flat design.
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 36, color: color), // Category icon.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                  ),
                  Text(
                    '$count', // Display the count.
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension methods for the `Color` class to easily access shades.
/// This simplifies accessing specific shades like `shade300` or `shade800`
/// from MaterialColor instances.
extension on Color {
  Color get shade300 =>
      (this is MaterialColor) ? (this as MaterialColor).shade300 : this;
  Color get shade800 =>
      (this is MaterialColor) ? (this as MaterialColor).shade800 : this;
}
