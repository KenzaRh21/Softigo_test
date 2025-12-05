import 'package:flutter/material.dart';
import 'package:softigotest/pages/AddUserPage.dart';
import 'package:softigotest/pages/UserDetailPage.dart';
import '../utils/app_styles.dart';
import '../models/user_model.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // Filtre par statut d'employé : 'Tous', 'Salariés', 'Non-salariés'
  String? _selectedEmployeeFilter;

  // Données d'utilisateurs fictives adaptées au nouveau modèle
  List<User> _allUsers = [
    User(
      id: 1,
      firstname: 'Alice',
      lastname: 'Smith',
      email: 'alice.s@company.com',
      login: 'alice',
      password: 'password123',
      employee: 1, // Salarié
    ),
    User(
      id: 2,
      firstname: 'Bob',
      lastname: 'Johnson',
      email: 'bob.j@company.com',
      login: 'bob',
      password: 'password123',
      employee: 0, // Non-salarié
    ),
    User(
      id: 3,
      firstname: 'Charlie',
      lastname: 'Brown',
      email: 'charlie.b@company.com',
      login: 'charlie',
      password: 'password123',
      employee: 1, // Salarié
    ),
    User(
      id: 4,
      firstname: 'Diana',
      lastname: 'Prince',
      email: 'diana.p@company.com',
      login: 'diana',
      password: 'password123',
      employee: 0, // Non-salarié
    ),
    User(
      id: 5,
      firstname: 'Eve',
      lastname: 'Adams',
      email: 'eve.a@company.com',
      login: 'eve',
      password: 'password123',
      employee: 1, // Salarié
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<User> _getFilteredUsers() {
    List<User> filtered = _allUsers.where((user) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.login.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesEmployeeStatus =
          _selectedEmployeeFilter == null ||
          _selectedEmployeeFilter == 'Tous' ||
          (_selectedEmployeeFilter == 'Salariés' && user.employee == 1) ||
          (_selectedEmployeeFilter == 'Non-salariés' && user.employee == 0);

      return matchesSearch && matchesEmployeeStatus;
    }).toList();

    filtered.sort((a, b) => a.fullName.compareTo(b.fullName));

    return filtered;
  }

  void _refreshUsers() {
    setState(() {
      _allUsers = [
        User(
          id: 1,
          firstname: 'Alice',
          lastname: 'Smith',
          email: 'alice.s@company.com',
          login: 'alice',
          password: '123',
          employee: 1,
        ),
        User(
          id: 2,
          firstname: 'Bob',
          lastname: 'Johnson',
          email: 'bob.j@company.com',
          login: 'bob',
          password: '123',
          employee: 0,
        ),
        User(
          id: 3,
          firstname: 'Charlie',
          lastname: 'Brown',
          email: 'charlie.b@company.com',
          login: 'charlie',
          password: '123',
          employee: 1,
        ),
        User(
          id: 4,
          firstname: 'Diana',
          lastname: 'Prince',
          email: 'diana.p@company.com',
          login: 'diana',
          password: '123',
          employee: 0,
        ),
        User(
          id: 5,
          firstname: 'Eve',
          lastname: 'Adams',
          email: 'eve.a@company.com',
          login: 'eve',
          password: '123',
          employee: 1,
        ),
        // Nouvel utilisateur ajouté pour la démo
        User(
          id: 6,
          firstname: 'Frank',
          lastname: 'White',
          email: 'frank.w@company.com',
          login: 'frank',
          password: '123',
          employee: 1,
        ),
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Liste des utilisateurs rafraîchie!')),
    );
  }

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
        SnackBar(content: Text('Utilisateur ${newUser.fullName} ajouté!')),
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
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un utilisateur...',
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
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neutralGrey400),
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
                ),
                const SizedBox(height: 16),
                _buildFilterDropdown(
                  context,
                  'Filtrer par statut',
                  Icons.person_outline,
                  _selectedEmployeeFilter,
                  ['Tous', 'Salariés', 'Non-salariés'],
                  (newValue) =>
                      setState(() => _selectedEmployeeFilter = newValue),
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
                            _selectedEmployeeFilter != null)
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
        onPressed: _addNewUser,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Ajouter Utilisateur'),
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: AppColors.neutralWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    IconData icon,
    String? currentValue,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: currentValue ?? items.first,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryIndigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    bool isEmployee = user.employee == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isEmployee ? AppColors.neutralGrey300 : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserDetailPage(user: user)),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isEmployee
                      ? AppColors.primaryIndigo.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEmployee ? Icons.person : Icons.work_outline,
                  size: 24,
                  color: isEmployee ? AppColors.primaryIndigo : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email ?? 'Email non spécifié',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutralGrey700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Badge de statut Salarié/Non-salarié
                    _buildStatusBadge(context, isEmployee),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppColors.neutralGrey500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isEmployee) {
    Color badgeColor = isEmployee ? AppColors.primaryGreen : Colors.orange;
    String badgeText = isEmployee ? 'Salarié' : 'Non-salarié';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        badgeText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
