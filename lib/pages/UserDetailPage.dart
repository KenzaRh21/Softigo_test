import 'package:flutter/material.dart';
import 'package:softigotest/pages/UserEditPage.dart';
import '../utils/app_styles.dart';
import '../models/user_model.dart'; // Importez le modèle User

class UserDetailPage extends StatefulWidget {
  final User user; // L'utilisateur à afficher

  const UserDetailPage({Key? key, required this.user}) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  void _editUser() async {
    // We use async-await here to potentially update the UI after UserEditPage returns
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserEditPage(user: widget.user)),
    );

    // If the UserEditPage returns an updated user, you might want to refresh the state
    if (updatedUser != null && updatedUser is User) {
      // In a real app, you would typically fetch the updated user from your backend
      // and then update the widget.user. For this example, we'll just show a snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur ${updatedUser.name} mis à jour!')),
      );
      // If you were modifying widget.user directly, you'd call setState here
      // setState(() {
      //   widget.user = updatedUser; // This would require user to not be final
      // });
    }
  }

  void _toggleUserStatus() {
    String action = widget.user.isActive ? 'désactiver' : 'réactiver';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fonctionnalité de $action l\'utilisateur à implémenter.',
        ),
      ),
    );
    setState(() {
      // In a real scenario, you would update the user status via an API call
      // and then potentially refresh the user object from the backend
      // widget.user.isActive = !widget.user.isActive; // This would require isActive to be mutable
    });
  }

  void _deleteUser() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fonctionnalité de suppression d\'utilisateur à implémenter.',
        ),
      ),
    );
    // In a real scenario, after deletion, you would likely pop this page
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Détails de l\'Utilisateur', // Titre générique pour la page
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            // Smaller app bar title
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20), // Smaller icon
            onPressed: _editUser,
            tooltip: 'Modifier l\'utilisateur',
          ),
          IconButton(
            icon: Icon(
              widget.user.isActive ? Icons.person_off : Icons.person_add,
              size: 20, // Smaller icon
            ),
            onPressed: _toggleUserStatus,
            tooltip: widget.user.isActive
                ? 'Désactiver l\'utilisateur'
                : 'Activer l\'utilisateur',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, size: 20), // Smaller icon
            onPressed: _deleteUser,
            tooltip: 'Supprimer l\'utilisateur',
            color: Colors.red.shade400,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0), // Reduced overall padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte d'identité de l'utilisateur (version modifiée)
            _buildUserIdentityCard(context, widget.user),
            const SizedBox(height: 20), // Reduced spacing

            _buildSectionHeader(context, 'Informations Générales'),
            const SizedBox(height: 10), // Reduced spacing
            _buildInfoTile(
              context,
              'ID Utilisateur',
              widget.user.id,
              Icons.perm_identity,
            ),
            const SizedBox(height: 6), // Reduced spacing
            _buildInfoTile(
              context,
              'Rôle',
              widget.user.role.toDisplayString(),
              Icons.work_outline,
              color: widget.user.role.toColor(), // Couleur du rôle
            ),
            const SizedBox(height: 6), // Reduced spacing
            _buildInfoTile(
              context,
              'Statut',
              widget.user.isActive ? 'Actif' : 'Inactif',
              widget.user.isActive
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              color: widget.user.isActive
                  ? AppColors.primaryGreen
                  : Colors.red.shade700,
            ),
            const SizedBox(height: 20), // Reduced spacing
            // Nouvelle section: Coordonnées
            _buildSectionHeader(context, 'Coordonnées'),
            const SizedBox(height: 10), // Reduced spacing
            _buildInfoTile(
              context,
              'Email',
              widget.user.email,
              Icons.email_outlined,
            ),
            const SizedBox(height: 6), // Reduced spacing
            _buildInfoTile(
              context,
              'Téléphone',
              'Non spécifié', // Exemple: Vous pouvez ajouter un champ phone à votre modèle User
              Icons.phone_outlined,
            ),
            const SizedBox(height: 20), // Reduced spacing

            _buildSectionHeader(context, 'Activités Récentes'),
            const SizedBox(height: 10), // Reduced spacing
            Container(
              padding: const EdgeInsets.all(12), // Reduced padding
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(
                  10,
                ), // Slightly less rounded
                border: Border.all(color: AppColors.neutralGrey300),
              ),
              child: Text(
                'Afficher ici une liste de tickets récents ou congés soumis par ${widget.user.name}.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  // Smaller text
                  color: AppColors.neutralGrey700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets d'aide ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        // Smaller section header
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(10), // Slightly less rounded
        border: Border.all(color: AppColors.neutralGrey300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? AppColors.primaryIndigo,
          ), // Smaller icon
          const SizedBox(width: 12), // Reduced spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    // Smaller label
                    color: AppColors.neutralGrey700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2), // Reduced spacing
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    // Smaller value text
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

  // Version MODIFIÉE de _buildUserIdentityCard
  Widget _buildUserIdentityCard(BuildContext context, User user) {
    return Card(
      elevation: 2, // Less elevation for a subtler look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ), // Slightly less rounded corners
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, // Reduced padding
          vertical: 12, // Reduced padding
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryIndigo.withOpacity(
            0.08, // Lighter background color
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryIndigo.withOpacity(0.2), // Subtler border
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26, // Smaller avatar
              backgroundColor: user.role.toColor().withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 32,
                color: user.role.toColor(),
              ), // Smaller icon
            ),
            const SizedBox(width: 12), // Reduced spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      // Smaller text size
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2), // Reduced spacing
                  Text(
                    user.role.toDisplayString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      // Smaller text size
                      color: user.role.toColor(), // Role colored
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
