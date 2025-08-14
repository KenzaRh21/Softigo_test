import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/command_api_service.dart';
import '../utils/app_styles.dart';
import 'edit_command_page.dart';

class CommandDetailPage extends StatefulWidget {
  final Map<String, dynamic> command;

  const CommandDetailPage({Key? key, required this.command}) : super(key: key);

  @override
  State<CommandDetailPage> createState() => _CommandDetailPageState();
}

class _CommandDetailPageState extends State<CommandDetailPage> {
  late final CommandApiService _commandApiService;
  late Future<String> _clientNameFuture;
  late Future<List<dynamic>> _orderLinesFuture;

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
    _clientNameFuture = _fetchClientName();
    _orderLinesFuture = _commandApiService.fetchOrderLines(
      int.parse(widget.command['id'].toString()),
    );
  }

  Future<String> _fetchClientName() async {
    final int? socid = int.tryParse(widget.command['socid'].toString());
    if (socid != null) {
      try {
        final thirdPartyData = await _commandApiService.fetchThirdParty(socid);
        return thirdPartyData['name'] ?? 'Nom inconnu';
      } catch (e) {
        debugPrint('Erreur lors de la récupération du nom du client: $e');
        return 'Nom inconnu';
      }
    }
    return 'Nom inconnu';
  }

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (int.tryParse(widget.command['statut'].toString())) {
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
                  builder: (context) =>
                      EditCommandPage(command: widget.command),
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
                          '${commandType} #${widget.command['ref']}',
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

            _buildSectionHeader(context, 'Informations Générales'),
            const SizedBox(height: 15),
            _buildInfoCard(
              context,
              children: [
                _buildInfoRow(
                  context,
                  label: 'Date de la commande',
                  value: widget.command['date_commande'] != null
                      ? '${DateTime.fromMillisecondsSinceEpoch(int.parse(widget.command['date_commande'].toString()) * 1000).day}/${DateTime.fromMillisecondsSinceEpoch(int.parse(widget.command['date_commande'].toString()) * 1000).month}/${DateTime.fromMillisecondsSinceEpoch(int.parse(widget.command['date_commande'].toString()) * 1000).year}'
                      : 'Non spécifié',
                  icon: Icons.calendar_today_outlined,
                ),
                if (widget.command['ref_client'] != null &&
                    widget.command['ref_client'].isNotEmpty)
                  const Divider(height: 1, color: AppColors.neutralGrey200),
                if (widget.command['ref_client'] != null &&
                    widget.command['ref_client'].isNotEmpty)
                  _buildInfoRow(
                    context,
                    label: 'Référence Client',
                    value: widget.command['ref_client'] ?? 'Non spécifié',
                    icon: Icons.receipt_long,
                  ),
                const Divider(height: 1, color: AppColors.neutralGrey200),
                _buildInfoRow(
                  context,
                  label: 'Montant Total',
                  value:
                      '${double.tryParse(widget.command['multicurrency_total_ttc'].toString())?.toStringAsFixed(2) ?? '0.00'} MAD',
                  icon: Icons.attach_money,
                  valueStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                  value: widget.command['date_livraison'] != null
                      ? '${DateTime.fromMillisecondsSinceEpoch(int.parse(widget.command['date_livraison'].toString()) * 1000).day}/${DateTime.fromMillisecondsSinceEpoch(int.parse(widget.command['date_livraison'].toString()) * 1000).month}/${DateTime.fromMillisecondsSinceEpoch(int.parse(widget.command['date_livraison'].toString()) * 1000).year}'
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
                  label: 'Conditions de Paiement',
                  value:
                      widget.command['cond_reglement_code'] ?? 'Non spécifié',
                  icon: Icons.payment,
                ),
                const Divider(height: 1, color: AppColors.neutralGrey200),
                _buildInfoRow(
                  context,
                  label: 'Mode de Livraison',
                  value:
                      widget.command['mode_reglement_code'] ?? 'Non spécifié',
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
            const SizedBox(height: 30),

            _buildSectionHeader(context, 'Détails du $clientSupplierLabel'),
            const SizedBox(height: 15),
            _buildInfoCard(
              context,
              children: [
                FutureBuilder<String>(
                  future: _clientNameFuture,
                  builder: (context, snapshot) {
                    return _buildInfoRow(
                      context,
                      label: 'Nom du $clientSupplierLabel',
                      value: snapshot.connectionState == ConnectionState.waiting
                          ? 'Chargement...'
                          : snapshot.data ?? 'Nom inconnu',
                      icon: Icons.person_outline,
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.neutralGrey200),
                _buildInfoRow(
                  context,
                  label: 'Contact',
                  value: 'Non spécifié',
                  icon: Icons.email_outlined,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Nouvelle section pour afficher les lignes de commande
            _buildSectionHeader(context, 'Lignes de Commande'),
            const SizedBox(height: 15),
            _buildOrderLinesCard(),
            const SizedBox(height: 30),
          ],
        ),
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

  Widget _buildOrderLinesCard() {
    return FutureBuilder<List<dynamic>>(
      future: _orderLinesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final List<dynamic> lines = snapshot.data!;
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
                  price: double.tryParse(line['subprice'].toString()) ?? 0.0,
                );
              },
            ),
          );
        }
        return const Text('Aucune donnée disponible.');
      },
    );
  }

  Widget _buildOrderLineItem({
    required String label,
    required int quantity,
    required double price,
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
              ],
            ),
          ),
          Text(
            '${price.toStringAsFixed(2)} MAD',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
