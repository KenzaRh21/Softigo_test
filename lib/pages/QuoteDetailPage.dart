import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour formater la date
import '../utils/app_styles.dart';
import '../models/quote_model.dart';
import 'AddEditQuotePage.dart'; // Pour la modification du devis

class QuoteDetailPage extends StatefulWidget {
  final Quote quote;
  final Function(Quote)?
  onQuoteUpdated; // Callback pour informer QuoteListPage d'une mise à jour

  const QuoteDetailPage({Key? key, required this.quote, this.onQuoteUpdated})
    : super(key: key);

  @override
  State<QuoteDetailPage> createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends State<QuoteDetailPage> {
  late Quote _currentQuote; // Pour stocker le devis et ses modifications

  @override
  void initState() {
    super.initState();
    _currentQuote = widget.quote; // Initialise avec le devis passé en paramètre
  }

  // Fonction pour naviguer vers la page de modification et gérer le retour
  void _editQuote() async {
    final updatedQuote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditQuotePage(quote: _currentQuote),
      ),
    );

    if (updatedQuote != null && updatedQuote is Quote) {
      setState(() {
        _currentQuote = updatedQuote; // Met à jour le devis affiché
      });
      // Informe la page parente (QuoteListPage) de la mise à jour
      widget.onQuoteUpdated?.call(updatedQuote);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Devis ${_currentQuote.id} mis à jour.')),
      );
    }
  }

  // Fonction pour changer le statut du devis
  void _changeStatus(QuoteStatus newStatus) {
    if (_currentQuote.status == newStatus) {
      return; // Ne fait rien si le statut est le même
    }

    setState(() {
      _currentQuote = _currentQuote.copyWith(status: newStatus);
    });
    // Informe la page parente de la mise à jour
    widget.onQuoteUpdated?.call(_currentQuote);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Statut du devis ${_currentQuote.id} changé en ${newStatus.toDisplayString()}.',
        ),
      ),
    );
    // Dans une vraie application, vous enverriez cette mise à jour à votre backend.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Détails du Devis #${_currentQuote.id}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            // Réduit la taille du titre de l'AppBar
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
            onPressed: _editQuote,
            tooltip: 'Modifier le devis',
          ),
          PopupMenuButton<QuoteStatus>(
            onSelected: _changeStatus,
            itemBuilder: (BuildContext context) => QuoteStatus.values.map((
              status,
            ) {
              return PopupMenuItem<QuoteStatus>(
                value: status,
                child: Text(
                  status.toDisplayString(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium, // Réduit la taille du texte du menu
                ),
              );
            }).toList(),
            icon: const Icon(Icons.more_vert),
            tooltip: 'Changer le statut',
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Réduire le padding général de la page
        padding: const EdgeInsets.all(12.0), // Réduit de 16.0 à 12.0
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              title: 'Informations Générales',
              children: [
                _buildDetailRow(
                  context,
                  icon: Icons.qr_code,
                  label: 'ID Devis',
                  value: _currentQuote.id,
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.business,
                  label: 'Client',
                  value: _currentQuote.clientName,
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.description,
                  label: 'Description',
                  value: _currentQuote.description,
                  isMultiline: true,
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.monetization_on, // Icône plus générique
                  label: 'Montant',
                  value:
                      '${_currentQuote.amount.toStringAsFixed(2)} MAD', // Changement ici : € en MAD
                  valueColor: AppColors.primaryIndigo,
                  valueFontWeight: FontWeight.bold,
                ),
              ],
            ),
            const SizedBox(height: 16), // Réduit de 20 à 16
            _buildInfoCard(
              context,
              title: 'Détails de Validité et Statut',
              children: [
                _buildDetailRow(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Date de Proposition',
                  value: DateFormat(
                    'dd/MM/yyyy',
                  ).format(_currentQuote.proposalDate),
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.timelapse,
                  label: 'Durée de Validité',
                  value: '${_currentQuote.validityDurationDays} jours',
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.info_outline,
                  label: 'Statut Actuel',
                  value: _currentQuote.status.toDisplayString(),
                  valueColor: _currentQuote.status.toColor(),
                  valueFontWeight: FontWeight.bold,
                ),
              ],
            ),
            const SizedBox(height: 16), // Réduit de 20 à 16
            _buildInfoCard(
              context,
              title: 'Actions Rapides',
              children: [
                _buildActionButton(
                  context,
                  label: 'Passer en En Attente',
                  icon: Icons.hourglass_empty,
                  color: QuoteStatus.pending.toColor(),
                  onPressed: () => _changeStatus(QuoteStatus.pending),
                  isActive:
                      _currentQuote.status != QuoteStatus.pending &&
                      _currentQuote.status == QuoteStatus.draft,
                ),
                _buildActionButton(
                  context,
                  label: 'Accepter le Devis',
                  icon: Icons.check_circle_outline,
                  color: QuoteStatus.accepted.toColor(),
                  onPressed: () => _changeStatus(QuoteStatus.accepted),
                  isActive: _currentQuote.status == QuoteStatus.pending,
                ),
                _buildActionButton(
                  context,
                  label: 'Rejeter le Devis',
                  icon: Icons.cancel_outlined,
                  color: QuoteStatus.rejected.toColor(),
                  onPressed: () => _changeStatus(QuoteStatus.rejected),
                  isActive: _currentQuote.status == QuoteStatus.pending,
                ),
                _buildActionButton(
                  context,
                  label: 'Marquer comme Facturé',
                  icon: Icons.paid_outlined,
                  color: QuoteStatus.invoiced.toColor(),
                  onPressed: () => _changeStatus(QuoteStatus.invoiced),
                  isActive: _currentQuote.status == QuoteStatus.accepted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets d'aide pour l'affichage des détails ---

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3, // Légèrement moins d'élévation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ), // Rayon de bordure plus petit
      child: Padding(
        // Réduire le padding interne de la carte
        padding: const EdgeInsets.all(12.0), // Réduit de 16.0 à 12.0
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                // Taille de police légèrement réduite
                fontWeight: FontWeight.bold,
                color: AppColors.primaryIndigo,
              ),
            ),
            const Divider(
              height: 16,
              thickness: 1,
            ), // Réduit la hauteur du Divider
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    FontWeight? valueFontWeight,
    bool isMultiline = false,
  }) {
    return Padding(
      // Réduire le padding vertical entre les lignes de détails
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Réduit de 8.0 à 6.0
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.primaryIndigo,
            size: 20,
          ), // Réduit la taille de l'icône
          const SizedBox(width: 10), // Réduit l'espacement
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                // Réduit la taille de la police du label
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                // Réduit la taille de la police de la valeur
                color: valueColor ?? AppColors.neutralGrey800,
                fontWeight: valueFontWeight ?? FontWeight.normal,
              ),
              overflow: isMultiline ? TextOverflow.clip : TextOverflow.ellipsis,
              maxLines: isMultiline
                  ? null
                  : 1, // Limiter à 1 ligne pour les valeurs non-multilignes
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isActive = true,
  }) {
    return Padding(
      // Réduire le padding vertical entre les boutons d'action
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Réduit de 8.0 à 6.0
      child: SizedBox(
        // Utiliser SizedBox pour contrôler la largeur du bouton
        width: double.infinity, // Rendre le bouton pleine largeur
        child: ElevatedButton.icon(
          onPressed: isActive
              ? onPressed
              : null, // Désactiver le bouton si non actif
          icon: Icon(icon, size: 20), // Réduit la taille de l'icône du bouton
          label: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              // Réduit la taille de la police du label du bouton
              color: AppColors.neutralWhite,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? color : Colors.grey.shade400,
            foregroundColor: AppColors.neutralWhite,
            // Réduire le padding interne du bouton
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ), // Réduit de 20/12 à 16/10
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                8,
              ), // Rayon de bordure plus petit
            ),
            elevation: isActive ? 2 : 0, // Légèrement moins d'ombre
          ),
        ),
      ),
    );
  }
}
