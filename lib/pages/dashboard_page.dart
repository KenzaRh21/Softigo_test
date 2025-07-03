import 'package:flutter/material.dart';

// Import des styles personnalisés
import '../utils/app_styles.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _searchText = '';
  int _selectedIndex = 0;

  // Libellés des éléments de la BottomNavigationBar
  final List<String> _itemLabels = const [
    'Dashboard',
    'Factures',
    'Tiers',
    'Congés',
    'Paramètres',
  ];

  // Gère les clics sur la barre de navigation du bas
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Exemple de feedback utilisateur - à remplacer par navigation ou appels API
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

  // Affiche une SnackBar quand une action rapide est cliquée
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
                // Logo de l'application
                Image.asset(
                  'assets/images/softigo_logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                // Icône de déconnexion — possibilité d'intégrer une API ici
                GestureDetector(
                  onTap: () {
                    _showActionClickedSnackBar('Icône de déconnexion');
                    // TODO: Appeler API de déconnexion ici
                  },
                  child: const Icon(
                    Icons.logout,
                    size: 30,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        // Contenu principal de la page
        body: const _DashboardContent(),

        // Navigation inférieure entre les sections
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
  const _DashboardContent({Key? key}) : super(key: key);

  @override
  __DashboardContentState createState() => __DashboardContentState();
}

class __DashboardContentState extends State<_DashboardContent> {
  String _searchText = '';

  // Utilisé pour afficher un message quand une carte/action est cliquée
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
          // Texte d'accueil
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

          // Actions rapides
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
                context,
                label: 'Nouvelle facture',
                icon: Icons.add_chart,
                onTap: () {
                  _showActionClickedSnackBar('Nouvelle facture');
                  // TODO: Intégrer l’appel API pour créer une facture
                },
              ),
              _buildQuickActionButton(
                context,
                label: 'Nouveau tiers',
                icon: Icons.person_add,
                onTap: () {
                  _showActionClickedSnackBar('Nouveau tiers');
                  // TODO: Intégrer l’appel API pour créer un tiers
                },
              ),
              _buildQuickActionButton(
                context,
                label: 'Demande de congé',
                icon: Icons.date_range,
                onTap: () {
                  _showActionClickedSnackBar('Demande de congé');
                  // TODO: Intégrer l’appel API pour envoyer une demande de congé
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Champ de recherche
          TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher une facture, un client, une dépense...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (val) {
              setState(() {
                _searchText = val;
              });
              // TODO: Ajouter l’appel API de recherche ici
            },
          ),
          const SizedBox(height: 24),

          // Cartes d’informations principales (à relier avec l'API)
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
                count:
                    150, // TODO: Remplacer par une donnée dynamique depuis l'API
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

  // Construction d'un bouton d'action rapide
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

// Extension utilitaire pour accéder aux variantes de couleur si c’est un MaterialColor
extension on Color {
  Color get shade300 =>
      (this is MaterialColor) ? (this as MaterialColor).shade300 : this;
  Color get shade800 =>
      (this is MaterialColor) ? (this as MaterialColor).shade800 : this;
}
