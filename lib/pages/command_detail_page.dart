// lib/pages/command_detail_page.dart
import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import 'package:softigotest/pages/edit_command_page.dart';

class CommandDetailPage extends StatelessWidget {
  final Map<String, dynamic> command;

  const CommandDetailPage({Key? key, required this.command}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (command['status']) {
      case 'Validée':
        statusIcon = Icons.check_circle_outline;
        statusColor = AppColors.primaryGreen;
        statusText = 'Validée';
        break;
      case 'En attente':
        statusIcon = Icons.access_time;
        statusColor = AppColors.accentOrange;
        statusText = 'En Attente';
        break;
      case 'Livrée':
        statusIcon = Icons.local_shipping;
        statusColor = AppColors.accentBlue;
        statusText = 'Livrée';
        break;
      case 'Annulée':
        statusIcon = Icons.cancel_outlined;
        statusColor = AppColors.accentRed;
        statusText = 'Annulée';
        break;
      default:
        statusIcon = Icons.info_outline;
        statusColor = AppColors.neutralGrey600;
        statusText = 'Inconnu';
    }

    String commandType = command['type'] == 'client' ? 'Client' : 'Fournisseur';
    IconData typeIcon = command['type'] == 'client'
        ? Icons.shopping_cart
        : Icons.local_shipping;
    Color typeColor = command['type'] == 'client'
        ? AppColors.primaryGreen
        : AppColors.accentBlue;
    String clientSupplierLabel = command['type'] == 'client'
        ? 'Client'
        : 'Fournisseur';
    String contactInfo = command['type'] == 'client'
        ? (command['client_email'] ?? 'Non spécifié')
        : (command['supplier_contact'] ?? 'Non spécifié');
    IconData contactIcon = command['type'] == 'client'
        ? Icons.email_outlined
        : Icons
              .phone_outlined; // Changed icon for supplier contact to be more general

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Détails de la Commande',
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
            icon: const Icon(Icons.edit, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCommandPage(command: command),
                ),
              );
            },
            tooltip: 'Modifier la commande',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Supprimer la commande (à implémenter)'),
                ),
              );
            },
            tooltip: 'Supprimer la commande',
            color: Colors.red.shade400,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section: Command ID, Type and Status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: typeColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: typeColor.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: typeColor.withOpacity(0.2),
                    child: Icon(typeIcon, size: 40, color: typeColor),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${commandType} #${command['id']}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(statusIcon, size: 20, color: statusColor),
                            const SizedBox(width: 8),
                            Text(
                              statusText,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // General Information Section
            _buildSectionHeader(context, 'Informations Générales'),
            const SizedBox(height: 15),
            _buildInfoCard(
              context,
              children: [
                _buildInfoRow(
                  context,
                  label: 'Date de la commande',
                  value: command['date'],
                  icon: Icons.calendar_today_outlined,
                ),
                if (command['external_ref'] != null &&
                    command['external_ref'].isNotEmpty)
                  const Divider(height: 1, color: AppColors.neutralGrey200),
                if (command['external_ref'] != null &&
                    command['external_ref'].isNotEmpty)
                  _buildInfoRow(
                    context,
                    label: 'Référence Externe',
                    value: command['external_ref'],
                    icon: Icons.receipt_long,
                  ),
                const Divider(height: 1, color: AppColors.neutralGrey200),
                _buildInfoRow(
                  context,
                  label: 'Montant Total',
                  value: '${command['amount'].toStringAsFixed(2)} MAD',
                  icon: Icons.attach_money,
                  valueStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Dates Section
            _buildSectionHeader(context, 'Dates Importantes'),
            const SizedBox(height: 15),
            _buildInfoCard(
              context,
              children: [
                _buildInfoRow(
                  context,
                  label: command['type'] == 'client'
                      ? 'Date de Livraison Prévue'
                      : 'Date de Réception Prévue',
                  value: command['expected_delivery_date'] ?? 'Non spécifié',
                  icon: Icons.event_note,
                ),
                if (command['actual_delivery_date'] != null &&
                    command['actual_delivery_date'].isNotEmpty)
                  const Divider(height: 1, color: AppColors.neutralGrey200),
                if (command['actual_delivery_date'] != null &&
                    command['actual_delivery_date'].isNotEmpty)
                  _buildInfoRow(
                    context,
                    label: command['type'] == 'client'
                        ? 'Date de Livraison Réelle'
                        : 'Date de Réception Réelle',
                    value: command['actual_delivery_date'],
                    icon: Icons.done_all,
                    iconColor: AppColors.primaryGreen,
                  ),
                if (command['cancellation_date'] != null &&
                    command['cancellation_date'].isNotEmpty)
                  const Divider(height: 1, color: AppColors.neutralGrey200),
                if (command['cancellation_date'] != null &&
                    command['cancellation_date'].isNotEmpty)
                  _buildInfoRow(
                    context,
                    label: 'Date d\'Annulation',
                    value: command['cancellation_date'],
                    icon: Icons.close_outlined,
                    iconColor: AppColors.accentRed,
                  ),
              ],
            ),
            const SizedBox(height: 30),

            // Payment & Shipping Section
            _buildSectionHeader(context, 'Paiement & Logistique'),
            const SizedBox(height: 15),
            _buildInfoCard(
              context,
              children: [
                _buildInfoRow(
                  context,
                  label: 'Conditions de Paiement',
                  value: command['payment_terms'] ?? 'Non spécifié',
                  icon: Icons.payment,
                ),
                const Divider(height: 1, color: AppColors.neutralGrey200),
                _buildInfoRow(
                  context,
                  label: command['type'] == 'client'
                      ? 'Adresse de Livraison'
                      : 'Adresse de Réception',
                  value: command['type'] == 'client'
                      ? (command['shipping_address'] ?? 'Non spécifié')
                      : (command['receiving_address'] ?? 'Non spécifié'),
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Client/Supplier Information Section (remains the same)
            _buildSectionHeader(context, 'Détails du $clientSupplierLabel'),
            const SizedBox(height: 15),
            _buildInfoCard(
              context,
              children: [
                _buildInfoRow(
                  context,
                  label: 'Nom du $clientSupplierLabel',
                  value: command['client'],
                  icon: Icons.person_outline,
                ),
                const Divider(height: 1, color: AppColors.neutralGrey200),
                _buildInfoRow(
                  context,
                  label: 'Contact',
                  value: contactInfo,
                  icon: contactIcon,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Description Section (remains the same)
            _buildSectionHeader(context, 'Description de la Commande'),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutralGrey300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                command['description'] ??
                    'Aucune description détaillée disponible pour cette commande.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutralGrey700,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 30),

            // NEW: Articles Commandés Section
            _buildSectionHeader(context, 'Articles Commandés'),
            const SizedBox(height: 15),
            _buildInfoCard(
              context,
              children: [
                if (command['items'] == null ||
                    (command['items'] as List).isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      'Aucun article détaillé pour cette commande.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutralGrey600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      // Header Row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Article',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Qté',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'P. Unitaire',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Total',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.neutralGrey300),
                      // Item Rows
                      ListView.separated(
                        shrinkWrap: true, // Important for nested listviews
                        physics:
                            const NeverScrollableScrollPhysics(), // Important for nested listviews
                        itemCount: (command['items'] as List).length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          color: AppColors.neutralGrey200,
                          indent: 18,
                          endIndent: 18,
                        ),
                        itemBuilder: (context, index) {
                          final item = command['items'][index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    item['name'],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${item['qty']}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${item['unit_price'].toStringAsFixed(2)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${item['total'].toStringAsFixed(2)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutralGrey300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: iconColor ?? AppColors.primaryIndigo),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.neutralGrey700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style:
                      valueStyle ??
                      Theme.of(context).textTheme.titleMedium?.copyWith(
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
