import 'package:flutter/material.dart';
import 'package:softigotest/pages/UserListPage.dart';
import 'package:softigotest/pages/ticket_list_page.dart';
import '../utils/app_styles.dart';
import 'LeaveListPage.dart'; // Pour naviguer vers la liste des congés

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Données fictives pour les statistiques. En production, elles viendraient d'une API.
  int _totalTickets = 120;
  int _openTickets = 35;
  int _pendingLeaveRequests = 15;
  int _totalUsers = 75;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Tableau de Bord Admin',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            // Reduced font size
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0), // Reduced from 16.0 to 12.0
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section des Statistiques / KPIs
            Text(
              'Statistiques Clés',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                // Reduced font size
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 12), // Reduced from 16 to 12
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10, // Reduced from 16 to 10
              mainAxisSpacing: 10, // Reduced from 16 to 10
              children: [
                _buildStatCard(
                  context,
                  'Tickets Totaux',
                  _totalTickets.toString(),
                  Icons.receipt_long,
                  AppColors.primaryIndigo,
                ),
                _buildStatCard(
                  context,
                  'Tickets Ouverts',
                  _openTickets.toString(),
                  Icons.warning_amber_outlined,
                  Colors.orange.shade700,
                ),
                _buildStatCard(
                  context,
                  'Congés en Attente',
                  _pendingLeaveRequests.toString(),
                  Icons.hourglass_empty,
                  Colors.blue.shade700,
                ),
                _buildStatCard(
                  context,
                  'Utilisateurs Actifs',
                  _totalUsers.toString(),
                  Icons.people_alt_outlined,
                  AppColors.primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 24), // Reduced from 32 to 24
            // Section de Gestion
            Text(
              'Gestion des Données',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                // Reduced font size
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 12), // Reduced from 16 to 12
            _buildManagementTile(
              context,
              'Gérer les Tickets',
              'Visualiser et administrer toutes les demandes de support.',
              Icons.list_alt,
              AppColors.primaryIndigo,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExpenseReportListPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8), // Reduced from 12 to 8
            _buildManagementTile(
              context,
              'Gérer les Congés',
              'Approuver ou rejeter les demandes de congés des employés.',
              Icons.calendar_month,
              AppColors.primaryGreen,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaveListPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8), // Reduced from 12 to 8
            _buildManagementTile(
              context,
              'Gérer les Utilisateurs',
              'Ajouter, modifier ou désactiver des comptes utilisateurs.',
              Icons.group_add,
              Colors.red.shade700,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserListPage()),
                );
              },
            ),
            const SizedBox(height: 24), // Reduced from 32 to 24
            // Autres actions administratives (optionnel)
            Text(
              'Autres Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                // Reduced font size
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 12), // Reduced from 16 to 12
            _buildActionCard(
              context,
              'Rapports et Analyses',
              Icons.bar_chart,
              Colors.purple.shade700,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Afficher les rapports et analyses.'),
                  ),
                );
              },
            ),
            const SizedBox(height: 8), // Reduced from 12 to 8
            _buildActionCard(
              context,
              'Paramètres du Système',
              Icons.settings,
              Colors.grey.shade700,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Accéder aux paramètres globaux.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets d'aide pour la mise en page ---

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4, // Reduced from 6 to 4
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Reduced from 16 to 12
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Détails pour $title')));
        },
        borderRadius: BorderRadius.circular(12), // Reduced from 16 to 12
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Reduced from 16.0 to 10.0
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 30, color: color), // Reduced from 36 to 30
              const SizedBox(height: 6), // Reduced from 8 to 6
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  // Reduced font size
                  color: AppColors.neutralGrey700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  // Reduced font size
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3, // Reduced from 4 to 3
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ), // Reduced from 12 to 10
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10), // Reduced from 12 to 10
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reduced from 16.0 to 12.0
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced from 12 to 10
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // Reduced from 10 to 8
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ), // Reduced from 28 to 24
              ),
              const SizedBox(width: 12), // Reduced from 16 to 12
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2), // Reduced from 4 to 2
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        // Reduced font size
                        color: AppColors.neutralGrey700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18, // Reduced from 20 to 18
                color: AppColors.neutralGrey500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3, // Reduced from 4 to 3
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ), // Reduced from 12 to 10
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10), // Reduced from 12 to 10
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reduced from 16.0 to 12.0
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced from 10 to 8
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6), // Reduced from 8 to 6
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ), // Reduced from 24 to 20
              ),
              const SizedBox(width: 12), // Reduced from 16 to 12
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20, // Reduced from 24 to 20
                color: AppColors.neutralGrey500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
