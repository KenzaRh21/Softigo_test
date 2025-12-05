// lib/pages/user_detail_page.dart
import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../models/user_model.dart';
import 'UserEditPage.dart'; // Assurez-vous que cette page existe

class UserDetailPage extends StatefulWidget {
  final User user;

  const UserDetailPage({super.key, required this.user});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  void _editUser() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserEditPage(user: widget.user)),
    );

    if (updatedUser != null && updatedUser is User) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Utilisateur ${updatedUser.fullName} mis à jour !'),
        ),
      );
    }
  }

  void _deleteUser() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fonctionnalité de suppression d\'utilisateur à implémenter.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          widget.user.fullName, // Utilisation du getter fullName
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
            icon: const Icon(Icons.edit),
            onPressed: _editUser,
            tooltip: 'Modifier l\'utilisateur',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _deleteUser,
            tooltip: 'Supprimer l\'utilisateur',
            color: Colors.red.shade400,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Informations de base
            _buildSectionHeader(context, 'Informations de base'),
            const SizedBox(height: 16),
            _buildInfoTile(
              context,
              'Nom complet',
              widget.user.fullName,
              Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              context,
              'Login',
              widget.user.login,
              Icons.account_circle_outlined,
            ),
            const SizedBox(height: 16),
            if (widget.user.civilityCode != null)
              _buildInfoTile(
                context,
                'Civilité',
                widget.user.civilityCode!,
                Icons.badge_outlined,
              ),
            const SizedBox(height: 16),
            if (widget.user.gender != null)
              _buildInfoTile(
                context,
                'Genre',
                widget.user.gender!,
                Icons.wc_outlined,
              ),
            const SizedBox(height: 32),

            // Section: Contact et Adresse
            _buildSectionHeader(context, 'Contact et Adresse'),
            const SizedBox(height: 16),
            if (widget.user.email != null)
              _buildInfoTile(
                context,
                'Email',
                widget.user.email!,
                Icons.email_outlined,
              ),
            const SizedBox(height: 16),
            if (widget.user.userMobile != null)
              _buildInfoTile(
                context,
                'Téléphone Mobile',
                widget.user.userMobile!,
                Icons.phone_android_outlined,
              ),
            const SizedBox(height: 16),
            if (widget.user.officePhone != null)
              _buildInfoTile(
                context,
                'Téléphone Bureau',
                widget.user.officePhone!,
                Icons.phone_outlined,
              ),
            const SizedBox(height: 16),
            if (widget.user.address != null)
              _buildInfoTile(
                context,
                'Adresse',
                '${widget.user.address}, ${widget.user.zipcode} ${widget.user.town}',
                Icons.home_outlined,
              ),
            const SizedBox(height: 32),

            // Section: Informations professionnelles
            _buildSectionHeader(context, 'Informations professionnelles'),
            const SizedBox(height: 16),
            if (widget.user.job != null)
              _buildInfoTile(
                context,
                'Poste',
                widget.user.job!,
                Icons.work_outline,
              ),
            const SizedBox(height: 16),
            if (widget.user.salary != null)
              _buildInfoTile(
                context,
                'Salaire',
                '${widget.user.salary} MAD',
                Icons.paid_outlined,
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- Widgets d'aide ---
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralGrey300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color ?? AppColors.primaryIndigo),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.neutralGrey700,
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
}
