import 'package:flutter/material.dart';
import '../models/ticket_model.dart'; // Import the Ticket model
import '../utils/app_styles.dart'; // Make sure this path is correct
import 'package:intl/intl.dart'; // For date formatting
import 'EditTicketPage.dart'; // <-- Import the new EditTicketPage
import 'NewTicketPage.dart'; // Make sure NewTicketPage is imported if you're reusing parts of it

class TicketDetailPage extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailPage({Key? key, required this.ticket}) : super(key: key);

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  // We need to make the ticket mutable to update it after editing
  late Ticket _currentTicket;

  @override
  void initState() {
    super.initState();
    _currentTicket = widget.ticket;
  }

  // --- Méthodes de Gestion des Actions ---

  // Gérer la modification du ticket
  Future<void> _editTicket(BuildContext context) async {
    final updatedTicket = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTicketPage(ticket: _currentTicket),
      ),
    );

    if (updatedTicket != null && updatedTicket is Ticket) {
      setState(() {
        _currentTicket = updatedTicket; // Mettre à jour le ticket affiché
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket modifié avec succès!')),
      );
      // Optionnel: Revenir à la page précédente et notifier un rafraîchissement
      // Navigator.pop(context, true); // Si vous voulez rafraîchir TicketListPage
    }
  }

  // Gérer la suppression du ticket
  Future<void> _deleteTicket(BuildContext context) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le ticket ?'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le ticket "${_currentTicket.subject}" (ID: ${_currentTicket.id}) ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Annuler
            child: Text(
              'Annuler',
              style: TextStyle(color: AppColors.primaryIndigo),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirmer
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Couleur de suppression
              foregroundColor: AppColors.neutralWhite,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      // TODO: Implémentez la logique de suppression réelle (appel API, suppression de la liste locale)
      // Pour l'exemple, nous allons juste afficher un message et revenir en arrière.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket ${_currentTicket.id} supprimé.')),
      );
      Navigator.pop(
        context,
        true,
      ); // Revenir à la liste et indiquer que quelque chose a été supprimé
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Détails du Ticket',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
        actions: [
          // Menu d'action (trois points)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editTicket(context);
              } else if (value == 'delete') {
                _deleteTicket(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.primaryText),
                    SizedBox(width: 8),
                    Text('Modifier le ticket'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Supprimer le ticket',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentTicket.id, // Use _currentTicket
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryIndigo,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _currentTicket.status.toColor().withOpacity(
                      0.15,
                    ), // Use _currentTicket
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentTicket.status
                        .toDisplayString(), // Use _currentTicket
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _currentTicket.status
                          .toColor(), // Use _currentTicket
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Subject
            _buildDetailCard(
              context,
              'Sujet',
              _currentTicket.subject, // Use _currentTicket
              Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            _buildDetailCard(
              context,
              'Description',
              _currentTicket.description, // Use _currentTicket
              Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.neutralGrey800),
            ),
            const SizedBox(height: 16),

            // Other details in a grid or row fashion
            _buildInfoRow(
              context,
              'Type de Demande',
              _currentTicket.requestType,
              Icons.notes,
            ),
            _buildInfoRow(
              context,
              'Sévérité',
              _currentTicket.severity,
              Icons.priority_high,
            ),
            _buildInfoRow(
              context,
              'Assigné à',
              _currentTicket.assignedTo,
              Icons.person,
            ),
            if (_currentTicket.thirdParty != null &&
                _currentTicket.thirdParty!.isNotEmpty)
              _buildInfoRow(
                context,
                'Tiers',
                _currentTicket.thirdParty!,
                Icons.business,
              ),
            if (_currentTicket.contactAddress != null &&
                _currentTicket.contactAddress!.isNotEmpty)
              _buildInfoRow(
                context,
                'Contact',
                _currentTicket.contactAddress!,
                Icons.contact_mail,
              ),

            // Creation Date
            const SizedBox(height: 16),
            _buildDetailCard(
              context,
              'Date de Création',
              DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(_currentTicket.creationDate), // Use _currentTicket
              Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.neutralGrey700),
              icon: Icons.calendar_today_outlined,
            ),

            // You can add more sections here for comments, attachments, etc.
          ],
        ),
      ),
    );
  }

  // Helper Widget for a detail card (like Subject, Description)
  Widget _buildDetailCard(
    BuildContext context,
    String title,
    String content,
    TextStyle? contentStyle, {
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralGrey300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Icon(icon, size: 20, color: AppColors.primaryIndigo),
              if (icon != null) const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralGrey700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: contentStyle),
        ],
      ),
    );
  }

  // Helper Widget for a single info row (like Request Type, Severity)
  Widget _buildInfoRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryIndigo),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutralGrey700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
