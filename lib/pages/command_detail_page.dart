// lib/pages/command_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/command_api_service.dart';
import '../utils/app_styles.dart';
import 'package:intl/intl.dart';
import 'edit_command_page.dart';

class CommandDetailPage extends StatefulWidget {
  final int orderId;

  const CommandDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<CommandDetailPage> createState() => _CommandDetailPageState();
}

class _CommandDetailPageState extends State<CommandDetailPage> {
  late final CommandApiService _commandApiService;
  late Future<Map<String, dynamic>> _orderFuture;

  @override
  void initState() {
    super.initState();
    final String? baseUrl = dotenv.env['API_BASE_URL'];
    final String? apiKey = dotenv.env['DOLIBARR_API_KEY'];

    if (baseUrl == null || apiKey == null) {
      throw Exception(
        'Erreur: Les variables d\'environnement API_BASE_URL ou DOLIBARR_API_KEY ne sont pas définies.',
      );
    }

    _commandApiService = CommandApiService(baseUrl: baseUrl, apiKey: apiKey);
    _orderFuture = _commandApiService.fetchOrder(widget.orderId);

    // DÉBUGAGE : Affiche les données de la commande une fois qu'elles sont reçues
    _orderFuture
        .then((data) {
          debugPrint('--- Données de la commande reçues ---');
          data.forEach((key, value) {
            debugPrint('$key: $value');
          });
          debugPrint('------------------------------------');
        })
        .catchError((error) {
          debugPrint(
            'Erreur lors de la récupération des données de la commande: $error',
          );
        });
  }

  Future<Map<String, dynamic>> _fetchClientData(int? socid) async {
    if (socid != null) {
      try {
        final clientData = await _commandApiService.fetchThirdParty(socid);
        // Renvoie l'objet entier, pas seulement le nom
        return clientData;
      } catch (e) {
        debugPrint('Erreur lors de la récupération des données du client: $e');
        // Renvoie un objet vide ou avec un message d'erreur
        return {'name': 'Nom inconnu', 'code_client': 'Code inconnu'};
      }
    }
    return {'name': 'Nom inconnu', 'code_client': 'Code inconnu'};
  }

  @override
  Widget build(BuildContext context) {
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
              // Vous devez passer l'objet de la commande à la page d'édition
              // après qu'il a été récupéré par le FutureBuilder.
              // Le plus simple est de mettre ce bouton dans le FutureBuilder
              // pour qu'il ne soit pas disponible pendant le chargement.
              // Dans ce code, il faudrait ajuster le `onPressed` pour passer `snapshot.data`.
            },
            tooltip: 'Modifier la commande',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, size: 24),
            onPressed: () => _confirmAndDeleteCommand(context, widget.orderId),
            tooltip: 'Supprimer la commande',
            color: Colors.red.shade400,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final command = snapshot.data!;

            // DÉBUGAGE : Affiche les données de la commande telles qu'elles sont utilisées dans l'UI
            debugPrint('--- Données de la commande affichées ---');
            command.forEach((key, value) {
              debugPrint('$key: $value');
            });
            debugPrint('----------------------------------');

            IconData statusIcon;
            Color statusColor;
            String statusText;

            switch (int.tryParse(command['statut'].toString())) {
              case 0:
                statusIcon = Icons.drafts;
                statusColor = AppColors.neutralGrey600;
                statusText = 'Brouillon';
                break;
              case 1:
                statusIcon = Icons.check_circle_outline;
                statusColor = AppColors.primaryGreen;
                statusText = 'Validée';
                break;
              case 2:
                statusIcon = Icons.access_time;
                statusColor = AppColors.accentOrange;
                statusText = 'En Attente';
                break;
              case 3:
                statusIcon = Icons.local_shipping;
                statusColor = AppColors.accentBlue;
                statusText = 'Livrée';
                break;
              case 5:
                statusIcon = Icons.cancel_outlined;
                statusColor = AppColors.accentRed;
                statusText = 'Annulée';
                break;
              default:
                statusIcon = Icons.info_outline;
                statusColor = AppColors.neutralGrey600;
                statusText = 'Inconnu';
            }

            String commandType = 'client';
            IconData typeIcon = Icons.shopping_cart;
            Color typeColor = AppColors.primaryGreen;
            String clientSupplierLabel = 'Client';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                '${commandType} #${command['ref']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryText,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    statusIcon,
                                    size: 20,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    statusText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
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
                  _buildSectionHeader(context, 'Informations Générales'),
                  const SizedBox(height: 15),
                  _buildInfoCard(
                    context,
                    children: [
                      _buildInfoRow(
                        context,
                        label: 'Date de la commande',
                        value: command['date_commande'] != null
                            ? '${DateTime.fromMillisecondsSinceEpoch(int.parse(command['date_commande'].toString()) * 1000).day}/${DateTime.fromMillisecondsSinceEpoch(int.parse(command['date_commande'].toString()) * 1000).month}/${DateTime.fromMillisecondsSinceEpoch(int.parse(command['date_commande'].toString()) * 1000).year}'
                            : 'Non spécifié',
                        icon: Icons.calendar_today_outlined,
                      ),
                      if (command['ref_client'] != null &&
                          command['ref_client'].isNotEmpty)
                        const Divider(
                          height: 1,
                          color: AppColors.neutralGrey200,
                        ),
                      if (command['ref_client'] != null &&
                          command['ref_client'].isNotEmpty)
                        _buildInfoRow(
                          context,
                          label: 'Référence Client',
                          value: command['ref_client'] ?? 'Non spécifié',
                          icon: Icons.receipt_long,
                        ),
                      const Divider(height: 1, color: AppColors.neutralGrey200),
                      _buildInfoRow(
                        context,
                        label: 'Montant Total',
                        value:
                            '${double.tryParse(command['multicurrency_total_ttc'].toString())?.toStringAsFixed(2) ?? '0.00'} MAD',
                        icon: Icons.attach_money,
                        valueStyle: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, 'Dates Importantes'),
                  const SizedBox(height: 15),
                  _buildInfoCard(
                    context,
                    children: [
                      _buildInfoRow(
                        context,
                        label: 'Date de Livraison Prévue',
                        value: command['delivery_date'] != null
                            ? DateFormat('dd/MM/yyyy').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  (int.tryParse(
                                            command['delivery_date'].toString(),
                                          ) ??
                                          0) *
                                      1000,
                                ),
                              )
                            : 'Non spécifié',
                        icon: Icons.event_note,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, 'Paiement & Logistique'),
                  const SizedBox(height: 15),
                  _buildInfoCard(
                    context,
                    children: [
                      _buildInfoRow(
                        context,
                        label: 'mode de reglement',
                        value: command['mode_reglement_code'] ?? 'Non spécifié',
                        icon: Icons.payment,
                      ),
                      const Divider(height: 1, color: AppColors.neutralGrey200),
                      _buildInfoRow(
                        context,
                        label: 'Condition de reglement',
                        value: command['cond_reglement_doc'] ?? 'Non spécifié',
                        icon: Icons.location_on_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSectionHeader(
                    context,
                    'Détails du $clientSupplierLabel',
                  ),
                  const SizedBox(height: 15),
                  _buildInfoCard(
                    context,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: _fetchClientData(
                          int.tryParse(command['socid'].toString()),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                              children: [
                                _buildInfoRow(
                                  context,
                                  label: 'Nom du Client',
                                  value: 'Chargement...',
                                  icon: Icons.person_outline,
                                ),
                                const Divider(
                                  height: 1,
                                  color: AppColors.neutralGrey200,
                                ),
                                _buildInfoRow(
                                  context,
                                  label: 'Code Client',
                                  value: 'Chargement...',
                                  icon: Icons.qr_code_2_outlined,
                                ),
                              ],
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            final clientData = snapshot.data!;
                            return Column(
                              children: [
                                _buildInfoRow(
                                  context,
                                  label: 'Nom du Client',
                                  value: clientData['name'] ?? 'Nom inconnu',
                                  icon: Icons.person_outline,
                                ),
                                const Divider(
                                  height: 1,
                                  color: AppColors.neutralGrey200,
                                ),
                                _buildInfoRow(
                                  context,
                                  label: 'Code Client',
                                  value:
                                      clientData['code_client'] ??
                                      'Code inconnu', // ✨ ACCÈS AU CODE CLIENT ICI
                                  icon: Icons.qr_code_2_outlined,
                                ),
                              ],
                            );
                          } else {
                            return _buildInfoRow(
                              context,
                              label: 'Client',
                              value: 'Non spécifié',
                              icon: Icons.person_outline,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, 'Lignes de Commande'),
                  const SizedBox(height: 15),
                  _buildOrderLinesCard(command['lines']),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
          return const Center(
            child: Text('Aucune donnée de commande trouvée.'),
          );
        },
      ),
    );
  }

  // Méthodes utilitaires
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

  Widget _buildOrderLinesCard(List<dynamic> lines) {
    if (lines.isEmpty) {
      return const Text('Aucune ligne de commande trouvée.');
    }

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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: lines.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: AppColors.neutralGrey200),
        itemBuilder: (context, index) {
          final line = lines[index];
          return _buildOrderLineItem(
            label: line['description'] ?? 'Produit sans description',
            quantity: int.tryParse(line['qty'].toString()) ?? 0,
            // Ajouter le prix HT ici
            priceTTC: double.tryParse(line['total_ttc'].toString()) ?? 0.0,
            priceHT: double.tryParse(line['total_ht'].toString()) ?? 0.0,
          );
        },
      ),
    );
  }

  Widget _buildOrderLineItem({
    required String label,
    required int quantity,
    required double priceTTC,
    required double priceHT, // Nouveau paramètre pour le prix HT
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantité: $quantity',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutralGrey700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prix HT: ${priceHT.toStringAsFixed(2)} MAD', // Affichage du prix HT
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutralGrey600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${priceTTC.toStringAsFixed(2)} MAD',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Prix TTC',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDeleteCommand(
    BuildContext context,
    int orderId,
  ) async {
    final bool confirmDelete =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette commande ? Cette action est irréversible.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      try {
        await _commandApiService.deleteClientCommand(orderId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La commande a été supprimée avec succès !'),
          ),
        );
        ;

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
