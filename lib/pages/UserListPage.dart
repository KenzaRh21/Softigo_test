import 'package:flutter/material.dart';
import 'package:softigotest/pages/AddUserPage.dart';
import 'package:softigotest/pages/UserDetailPage.dart';
import '../utils/app_styles.dart';
import '../models/user_model.dart'; // Importez le modèle User

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedRoleFilter; // Filtre par rôle

  // Données d'utilisateurs fictives
  List<User> _allUsers = [
    User(
      id: 'U001',
      name: 'Alice Smith',
      email: 'alice.s@company.com',
      role: UserRole.admin,
      isActive: true,
    ),
    User(
      id: 'U002',
      name: 'Bob Johnson',
      email: 'bob.j@company.com',
      role: UserRole.manager,
      isActive: true,
    ),
    User(
      id: 'U003',
      name: 'Charlie Brown',
      email: 'charlie.b@company.com',
      role: UserRole.employee,
      isActive: true,
    ),
    User(
      id: 'U004',
      name: 'Diana Prince',
      email: 'diana.p@company.com',
      role: UserRole.employee,
      isActive: false,
    ),
    User(
      id: 'U005',
      name: 'Eve Adams',
      email: 'eve.a@company.com',
      role: UserRole.manager,
      isActive: true,
    ),
    User(
      id: 'U006',
      name: 'Frank White',
      email: 'frank.w@company.com',
      role: UserRole.employee,
      isActive: true,
    ),
    User(
      id: 'U007',
      name: 'Grace Lee',
      email: 'grace.l@company.com',
      role: UserRole.admin,
      isActive: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtrer les utilisateurs
  List<User> _getFilteredUsers() {
    List<User> filtered = _allUsers.where((user) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.id.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRole =
          _selectedRoleFilter == null ||
          _selectedRoleFilter == 'Tous' ||
          user.role.toDisplayString() == _selectedRoleFilter;

      return matchesSearch && matchesRole;
    }).toList();

    // Trier les utilisateurs par nom
    filtered.sort((a, b) => a.name.compareTo(b.name));

    return filtered;
  }

  // Fonction pour simuler le rafraîchissement des données
  void _refreshUsers() {
    setState(() {
      // Dans une vraie application, ici vous feriez un appel API pour recharger la liste des utilisateurs.
      // Pour cette démo, on simule juste un rafraîchissement.
      _allUsers = [
        User(
          id: 'U001',
          name: 'Alice Smith',
          email: 'alice.s@company.com',
          role: UserRole.admin,
          isActive: true,
        ),
        User(
          id: 'U002',
          name: 'Bob Johnson',
          email: 'bob.j@company.com',
          role: UserRole.manager,
          isActive: true,
        ),
        User(
          id: 'U003',
          name: 'Charlie Brown',
          email: 'charlie.b@company.com',
          role: UserRole.employee,
          isActive: true,
        ),
        User(
          id: 'U004',
          name: 'Diana Prince',
          email: 'diana.p@company.com',
          role: UserRole.employee,
          isActive: false,
        ),
        User(
          id: 'U005',
          name: 'Eve Adams',
          email: 'eve.a@company.com',
          role: UserRole.manager,
          isActive: true,
        ),
        User(
          id: 'U006',
          name: 'Frank White',
          email: 'frank.w@company.com',
          role: UserRole.employee,
          isActive: true,
        ),
        User(
          id: 'U007',
          name: 'Grace Lee',
          email: 'grace.l@company.com',
          role: UserRole.admin,
          isActive: true,
        ),
        // Ajoutez un nouvel utilisateur pour montrer un changement après refresh
        User(
          id: 'U008',
          name: 'Henry Ford',
          email: 'henry.f@company.com',
          role: UserRole.employee,
          isActive: true,
        ),
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Liste des utilisateurs rafraîchie!')),
    );
  }

  // Fonction pour simuler l'ajout d'un utilisateur
  void _addNewUser() async {
    final newUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddUserPage()),
    );
    if (newUser != null && newUser is User) {
      setState(() {
        _allUsers.add(newUser);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur ${newUser.name} ajouté!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Gestion des Utilisateurs',
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
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Champ de recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Rechercher un utilisateur par nom, email ou ID...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryIndigo,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.neutralGrey600,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neutralGrey400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neutralGrey400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryIndigo,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
                ),
                const SizedBox(height: 16),

                // Filtre par rôle
                _buildFilterDropdown(
                  context,
                  'Filtrer par Rôle',
                  Icons.person_outline,
                  _selectedRoleFilter,
                  [
                    'Tous',
                    ...UserRole.values.map((e) => e.toDisplayString()).toList(),
                  ],
                  (newValue) {
                    setState(() {
                      _selectedRoleFilter = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off,
                          size: 80,
                          color: AppColors.neutralGrey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun utilisateur trouvé.',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.neutralGrey600),
                        ),
                        if (_searchQuery.isNotEmpty ||
                            _selectedRoleFilter != null &&
                                _selectedRoleFilter != 'Tous')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Ajustez vos filtres de recherche.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.neutralGrey600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return UserCard(user: user);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewUser, // Appelle la fonction d'ajout
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Ajouter Utilisateur'),
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: AppColors.neutralWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Widget d'aide pour le dropdown de filtre (réutilisé)
  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    IconData icon,
    String? currentValue,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: currentValue ?? items.first, // Set default to 'Tous' or first item
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryIndigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Plus arrondi
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
          ),
        );
      }).toList(),
    );
  }
}

// --- Nouveau Widget de Carte Utilisateur ---
class UserCard extends StatelessWidget {
  final User user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0), // Reduced margin
      elevation: 2, // Slightly reduced elevation for a flatter look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ), // Slightly less rounded corners
        side: BorderSide(
          color: user.isActive ? AppColors.neutralGrey300 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UserDetailPage(user: user), // Passe l'objet user
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ), // Reduced padding
          child: Row(
            children: [
              // Icône d'utilisateur ou Avatar
              Container(
                padding: const EdgeInsets.all(8), // Reduced padding
                decoration: BoxDecoration(
                  color: user.role.toColor().withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: user.role.toColor(),
                ), // Reduced icon size
              ),
              const SizedBox(width: 12), // Reduced spacing
              // Détails de l'utilisateur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        // Smaller font size
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1, // Ensure single line
                      overflow:
                          TextOverflow.ellipsis, // Add ellipsis for overflow
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        // Smaller font size
                        color: AppColors.neutralGrey700,
                      ),
                      maxLines: 1, // Ensure single line
                      overflow:
                          TextOverflow.ellipsis, // Add ellipsis for overflow
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    Row(
                      children: [
                        // Badge de rôle
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, // Reduced padding
                            vertical: 3, // Reduced padding
                          ),
                          decoration: BoxDecoration(
                            color: user.role.toColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              5,
                            ), // Slightly less rounded
                            border: Border.all(
                              color: user.role.toColor().withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            user.role.toDisplayString(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall // Keep labelSmall or even smaller
                                ?.copyWith(
                                  color: user.role.toColor(),
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      10, // Explicitly set a smaller font size
                                ),
                          ),
                        ),
                        const SizedBox(width: 6), // Reduced spacing
                        // Statut Actif/Inactif
                        _buildStatusBadge(context, user.isActive),
                      ],
                    ),
                  ],
                ),
              ),
              // Flèche pour indiquer la navigabilité
              Icon(
                Icons.arrow_forward_ios,
                size: 18, // Reduced icon size
                color: AppColors.neutralGrey500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryGreen.withOpacity(0.1)
            : Colors.red.shade100,
        borderRadius: BorderRadius.circular(5), // Slightly less rounded
        border: Border.all(
          color: isActive
              ? AppColors.primaryGreen.withOpacity(0.3)
              : Colors.red.shade300,
        ),
      ),
      child: Text(
        isActive ? 'Actif' : 'Inactif',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          // Keep labelSmall or even smaller
          color: isActive ? AppColors.primaryGreen : Colors.red.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 10, // Explicitly set a smaller font size
        ),
      ),
    );
  }
}
