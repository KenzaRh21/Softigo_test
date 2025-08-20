import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_styles.dart';
import 'package:softigotest/pages/command_detail_page.dart';
import 'package:softigotest/pages/create_command_page.dart';
import '../services/command_api_service.dart';

class CommandListPage extends StatefulWidget {
  const CommandListPage({Key? key}) : super(key: key);

  @override
  State<CommandListPage> createState() => _CommandListPageState();
}

enum CommandTypeFilter { all, client, fournisseur }

class _CommandListPageState extends State<CommandListPage> {
  late final CommandApiService _commandApiService;
  late Future<List<Map<String, dynamic>>> _commandsFuture;
  // Cache pour stocker les noms de clients déjà récupérés
  final Map<int, String> _thirdPartyNames = {};

  String _searchText = '';
  CommandTypeFilter _selectedFilter = CommandTypeFilter.client;

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
    _commandsFuture = _commandApiService.fetchCommands();
  }

  Future<void> _refreshCommands() async {
    setState(() {
      _commandsFuture = _commandApiService.fetchCommands();
      _searchText = '';
      _selectedFilter = CommandTypeFilter.client;
      // Videz le cache des noms de clients lors du rafraîchissement
      _thirdPartyNames.clear();
    });
  }

  // Nouvelle méthode pour récupérer le nom du client
  Future<String> _getThirdPartyName(int thirdPartyId) async {
    // Si le nom est déjà dans le cache, le renvoyer
    if (_thirdPartyNames.containsKey(thirdPartyId)) {
      return _thirdPartyNames[thirdPartyId]!;
    }

    try {
      final thirdPartyData = await _commandApiService.fetchThirdParty(
        thirdPartyId,
      );
      final clientName = thirdPartyData['name'] ?? 'Nom inconnu';
      // Mettre en cache le nom avant de le renvoyer
      _thirdPartyNames[thirdPartyId] = clientName;
      return clientName;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du nom du client: $e');
      return 'Nom inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes Clients'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateCommandPage(),
                ),
              );
            },
            tooltip: 'Créer une commande',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCommands,
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
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher une commande...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ToggleButtons(
                  isSelected: CommandTypeFilter.values
                      .map((e) => e == _selectedFilter)
                      .toList(),
                  onPressed: (int index) {
                    setState(() {
                      _selectedFilter = CommandTypeFilter.values[index];
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  children: const <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text('Toutes'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text('Clients'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text('Fournisseurs'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _commandsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune commande trouvée.'));
                } else {
                  final allCommands = snapshot.data!;
                  final filteredCommands = allCommands.where((command) {
                    final matchesSearch =
                        (command['id']?.toString().toLowerCase().contains(
                              _searchText.toLowerCase(),
                            ) ??
                            false) ||
                        (command['ref']?.toLowerCase().contains(
                              _searchText.toLowerCase(),
                            ) ??
                            false);
                    return matchesSearch;
                  }).toList();

                  const String commandTypeLabel = 'Client';

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Total Commandes: ${filteredCommands.length}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: filteredCommands.length,
                          itemBuilder: (context, index) {
                            final command = filteredCommands[index];
                            final int? socid = int.tryParse(
                              command['socid'].toString(),
                            );
                            final String ref = command['ref'] ?? 'N/A';
                            final int? status = int.tryParse(
                              command['statut'].toString(),
                            );
                            IconData statusIcon;
                            Color statusColor;
                            String statusText;

                            switch (status) {
                              case 0:
                                statusIcon = Icons.drafts;
                                statusColor = Colors.grey;
                                statusText = 'Brouillon';
                                break;
                              case 1:
                                statusIcon = Icons.check_circle_outline;
                                statusColor = Colors.green;
                                statusText = 'Validée';
                                break;
                              case 2:
                                statusIcon = Icons.access_time;
                                statusColor = Colors.orange;
                                statusText = 'En attente';
                                break;
                              case 3:
                                statusIcon = Icons.local_shipping;
                                statusColor = Colors.blue;
                                statusText = 'Livrée';
                                break;
                              case 5:
                                statusIcon = Icons.cancel_outlined;
                                statusColor = Colors.red;
                                statusText = 'Annulée';
                                break;
                              default:
                                statusIcon = Icons.info_outline;
                                statusColor = Colors.grey;
                                statusText = 'Inconnu';
                            }

                            final double totalTTC =
                                command['multicurrency_total_ttc'] != null
                                ? double.tryParse(
                                        command['multicurrency_total_ttc']
                                            .toString(),
                                      ) ??
                                      0.0
                                : 0.0;

                            final int? dateTimestamp = int.tryParse(
                              command['date_commande'].toString(),
                            );
                            String formattedDate = 'N/A';
                            if (dateTimestamp != null) {
                              final DateTime date =
                                  DateTime.fromMillisecondsSinceEpoch(
                                    dateTimestamp * 1000,
                                  );
                              formattedDate =
                                  '${date.day}/${date.month}/${date.year}';
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommandDetailPage(
                                        orderId: int.parse(
                                          command['id'].toString(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              commandTypeLabel,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                statusIcon,
                                                size: 18,
                                                color: statusColor,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                statusText,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: statusColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Commande #$ref',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      // Utilisation d'un FutureBuilder pour afficher le nom du client
                                      FutureBuilder<String>(
                                        future: socid != null
                                            ? _getThirdPartyName(socid)
                                            : Future.value('Nom inconnu'),
                                        builder: (context, thirdPartySnapshot) {
                                          if (thirdPartySnapshot
                                                  .connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text(
                                              'Chargement du nom...',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            );
                                          } else {
                                            return Text(
                                              ' ${thirdPartySnapshot.data ?? 'Nom inconnu'}',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge,
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 5),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Date: $formattedDate',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: Colors.grey),
                                          ),
                                          Text(
                                            '${totalTTC.toStringAsFixed(2)} MAD',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
