// lib/pages/command_list_page.dart
import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import 'package:softigotest/pages/command_detail_page.dart';
import 'package:softigotest/pages/create_command_page.dart';

class CommandListPage extends StatefulWidget {
  const CommandListPage({Key? key}) : super(key: key);

  @override
  State<CommandListPage> createState() => _CommandListPageState();
}

enum CommandTypeFilter { all, client, fournisseur }

class _CommandListPageState extends State<CommandListPage> {
  // Dummy data for commands with expanded fields for delivery tracking
  final List<Map<String, dynamic>> _commands = [
    {
      'id': 'C001',
      'client': 'Client Alpha',
      'amount': 500.0,
      'status': 'Validée', // Overall command status
      'date': '2025-07-01',
      'description': 'Commande de services de développement logiciel.',
      'type': 'client',
      'client_email': 'alpha@example.com',
      'external_ref': 'PO-XYZ-001',
      'expected_delivery_date': '2025-07-15',
      'actual_delivery_date':
          '2025-07-12', // Added actual delivery date for a 'Livrée' status
      'logistics_status': 'Livrée', // NEW: Specific delivery/logistics status
      'tracking_number': 'TK789012345', // NEW: Tracking number
      'payment_terms': 'Net 30 jours',
      'shipping_address': '123 Rue de la Liberté, Casablanca',
      'items': [
        {
          'name': 'Développement Frontend',
          'qty': 1,
          'unit_price': 300.0,
          'total': 300.0,
        },
        {
          'name': 'Développement Backend',
          'qty': 1,
          'unit_price': 200.0,
          'total': 200.0,
        },
      ],
    },
    {
      'id': 'F001',
      'client': 'Fournisseur Beta',
      'amount': 1200.0,
      'status': 'Validée',
      'date': '2025-06-28',
      'description': 'Achat de licences logicières annuelles.',
      'type': 'fournisseur',
      'supplier_contact': 'contact@beta.com',
      'external_ref': 'INV-456-ABC',
      'expected_delivery_date': '2025-07-10',
      'actual_delivery_date': null, // Not yet received
      'logistics_status': 'En Transit', // NEW
      'tracking_number': 'SUPTK1234567', // NEW
      'payment_terms': 'Paiement à réception',
      'receiving_address': '456 Avenue du Progrès, Rabat',
      'items': [
        {
          'name': 'Licence Logiciel Pro',
          'qty': 2,
          'unit_price': 600.0,
          'total': 1200.0,
        },
      ],
    },
    {
      'id': 'C002',
      'client': 'Client Gamma',
      'amount': 300.0,
      'status': 'Livrée',
      'date': '2025-06-25',
      'description': 'Fournitures de matériel informatique.',
      'type': 'client',
      'client_email': 'gamma@example.com',
      'external_ref': null,
      'expected_delivery_date': '2025-07-01',
      'actual_delivery_date': '2025-07-01',
      'logistics_status': 'Livrée', // NEW
      'tracking_number': null, // No tracking for this one
      'payment_terms': 'Net 15 jours',
      'shipping_address': '789 Boulevard Hassan II, Marrakech',
      'items': [
        {
          'name': 'Souris Ergonomique',
          'qty': 5,
          'unit_price': 30.0,
          'total': 150.0,
        },
        {
          'name': 'Clavier Mécanique',
          'qty': 1,
          'unit_price': 150.0,
          'total': 150.0,
        },
      ],
    },
    {
      'id': 'F002',
      'client': 'Fournisseur Delta',
      'amount': 800.0,
      'status': 'Validée',
      'date': '2025-06-20',
      'description': 'Contrat de maintenance annuelle.',
      'type': 'fournisseur',
      'supplier_contact': 'delta@supplier.com',
      'external_ref': 'PO-MAINT-005',
      'expected_delivery_date': '2025-08-01',
      'actual_delivery_date': null,
      'logistics_status': 'En Attente de Réception', // NEW
      'tracking_number': null,
      'payment_terms': 'Net 60 jours',
      'receiving_address': 'Bureau principal, Fès',
      'items': [
        {
          'name': 'Service de maintenance N1',
          'qty': 1,
          'unit_price': 800.0,
          'total': 800.0,
        },
      ],
    },
    {
      'id': 'C003',
      'client': 'Client Alpha',
      'amount': 150.0,
      'status': 'Annulée',
      'date': '2025-06-15',
      'description': 'Commande de fournitures de bureau.',
      'type': 'client',
      'client_email': 'alpha@example.com',
      'external_ref': 'PO-BUR-010',
      'expected_delivery_date': '2025-06-20',
      'actual_delivery_date': null,
      'cancellation_date': '2025-06-18',
      'logistics_status': 'Annulée', // NEW
      'tracking_number': null,
      'payment_terms': 'Net 30 jours',
      'shipping_address': '123 Rue de la Liberté, Casablanca',
      'items': [
        {
          'name': 'Stylos bleus (boîte)',
          'qty': 3,
          'unit_price': 20.0,
          'total': 60.0,
        },
        {'name': 'Carnets A4', 'qty': 2, 'unit_price': 45.0, 'total': 90.0},
      ],
    },
    {
      'id': 'C004',
      'client': 'Client Beta',
      'amount': 750.0,
      'status': 'Validée',
      'date': '2025-07-15',
      'description': 'Livraison de fournitures de bureau.',
      'type': 'client',
      'client_email': 'beta@example.com',
      'logistics_status': 'En Préparation', // NEW
      'expected_delivery_date': '2025-07-22',
      'shipping_address': '456 Avenue des Roses, Fès',
      'tracking_number': null,
      'payment_terms': 'Net 30 jours',
      'items': [
        {
          'name': 'Papier A4 (ramette)',
          'qty': 10,
          'unit_price': 25.0,
          'total': 250.0,
        },
        {
          'name': 'Cartouches d\'encre',
          'qty': 3,
          'unit_price': 150.0,
          'total': 450.0,
        },
        {'name': 'Agrafeuse', 'qty': 2, 'unit_price': 25.0, 'total': 50.0},
      ],
    },
    {
      'id': 'C005',
      'client': 'Client Delta',
      'amount': 250.0,
      'status': 'Validée',
      'date': '2025-07-05',
      'description': 'Installation de logiciel antivirus.',
      'type': 'client',
      'client_email': 'delta@example.com',
      'logistics_status': 'En Préparation',
      'expected_delivery_date': '2025-07-25',
      'shipping_address': '10 Rue des Orangers, Tanger',
      'tracking_number': null,
      'payment_terms': 'Net 30 jours',
      'items': [
        {
          'name': 'Licence Antivirus',
          'qty': 1,
          'unit_price': 100.0,
          'total': 100.0,
        },
        {
          'name': 'Service Installation',
          'qty': 1,
          'unit_price': 150.0,
          'total': 150.0,
        },
      ],
    },
    {
      'id': 'F003',
      'client': 'Fournisseur Epsilon',
      'amount': 900.0,
      'status': 'Validée',
      'date': '2025-07-08',
      'description': 'Achat de serveurs pour nouveau projet.',
      'type': 'fournisseur',
      'supplier_contact': 'epsilon@example.com',
      'logistics_status': 'En Attente de Réception',
      'expected_delivery_date': '2025-07-30',
      'receiving_address': 'Data Center, Rabat',
      'tracking_number': 'SRV2025ABC',
      'payment_terms': 'Net 45 jours',
      'items': [
        {
          'name': 'Serveur Rack 1U',
          'qty': 1,
          'unit_price': 900.0,
          'total': 900.0,
        },
      ],
    },
    {
      'id': 'C006',
      'client': 'Client Zeta',
      'amount': 400.0,
      'status': 'Validée',
      'date': '2025-07-10',
      'description': 'Maintenance réseau annuelle.',
      'type': 'client',
      'client_email': 'zeta@example.com',
      'logistics_status': 'Non Concerné', // For service-based orders
      'expected_delivery_date': '2025-08-05',
      'shipping_address': '55 Av. Mohamed VI, Agadir',
      'tracking_number': null,
      'payment_terms': 'Net 30 jours',
      'items': [
        {
          'name': 'Contrat Maintenance Réseau',
          'qty': 1,
          'unit_price': 400.0,
          'total': 400.0,
        },
      ],
    },
    {
      'id': 'C007',
      'client': 'Client Eta',
      'amount': 120.0,
      'status': 'Validée',
      'date': '2025-07-12',
      'description': 'Consommables d\'impression.',
      'type': 'client',
      'client_email': 'eta@example.com',
      'logistics_status': 'Expédiée',
      'expected_delivery_date': '2025-07-19',
      'shipping_address': '99 Rue Al Maghrib, Salé',
      'tracking_number': 'CONS98765',
      'payment_terms': 'Net 15 jours',
      'items': [
        {
          'name': 'Cartouche Toner Noire',
          'qty': 2,
          'unit_price': 60.0,
          'total': 120.0,
        },
      ],
    },
    {
      'id': 'F004',
      'client': 'Fournisseur Theta',
      'amount': 1500.0,
      'status': 'Validée',
      'date': '2025-07-14',
      'description': 'Formation certifiante pour équipe.',
      'type': 'fournisseur',
      'supplier_contact': 'theta@training.com',
      'logistics_status': 'Non Concerné', // For service-based orders
      'expected_delivery_date': '2025-08-10',
      'receiving_address': 'Bureau de Formation, Casablanca',
      'tracking_number': null,
      'payment_terms': 'Net 30 jours',
      'items': [
        {
          'name': 'Formation ITIL',
          'qty': 5,
          'unit_price': 300.0,
          'total': 1500.0,
        },
      ],
    },
  ];

  String _searchText = '';
  CommandTypeFilter _selectedFilter = CommandTypeFilter.all;

  int _currentPage = 0;
  final int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final filteredCommands = _commands.where((command) {
      final matchesSearch =
          command['id'].toLowerCase().contains(_searchText.toLowerCase()) ||
          command['client'].toLowerCase().contains(_searchText.toLowerCase()) ||
          command['description'].toLowerCase().contains(
            _searchText.toLowerCase(),
          );

      final matchesFilter =
          _selectedFilter == CommandTypeFilter.all ||
          (_selectedFilter == CommandTypeFilter.client &&
              command['type'] == 'client') ||
          (_selectedFilter == CommandTypeFilter.fournisseur &&
              command['type'] == 'fournisseur');

      return matchesSearch && matchesFilter;
    }).toList();

    final int totalPages = (_itemsPerPage == 0)
        ? 1
        : (filteredCommands.length / _itemsPerPage).ceil();
    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      filteredCommands.length,
    );
    final List<Map<String, dynamic>> commandsOnCurrentPage = filteredCommands
        .sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Commandes (${_selectedFilter == CommandTypeFilter.client
              ? 'Clients'
              : _selectedFilter == CommandTypeFilter.fournisseur
              ? 'Fournisseurs'
              : 'Toutes'})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
        actions: [
          // REMOVED: IconButton for Delivery Tracking Page
          /*
          IconButton(
            icon: const Icon(Icons.local_shipping_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeliveryTrackingPage()),
              );
            },
            tooltip: 'Suivi des Livraisons',
          ),
          */
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
                      _currentPage = 0; // Reset to first page on search
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher une commande...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.neutralGrey600,
                    ),
                    filled: true,
                    fillColor: AppColors.neutralWhite,
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
                      _currentPage = 0; // Reset to first page on filter change
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: AppColors.neutralWhite,
                  fillColor: Theme.of(context).colorScheme.primary,
                  color: AppColors.neutralGrey700,
                  borderColor: AppColors.neutralGrey300,
                  selectedBorderColor: Theme.of(context).colorScheme.primary,
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
          // Display total count of filtered commands
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total Commandes: ${filteredCommands.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: commandsOnCurrentPage.length, // Use paginated list
              itemBuilder: (context, index) {
                final command =
                    commandsOnCurrentPage[index]; // Use paginated list
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

                String commandTypeLabel = command['type'] == 'client'
                    ? 'Client'
                    : 'Fournisseur';

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
                          builder: (context) =>
                              CommandDetailPage(command: command),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: command['type'] == 'client'
                                      ? AppColors.primaryGreen.withOpacity(0.1)
                                      : AppColors.accentBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  commandTypeLabel,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: command['type'] == 'client'
                                            ? AppColors.primaryGreen
                                            : AppColors.accentBlue,
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
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Commande #${command['id']}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            command['client'],
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.neutralGrey800),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            command['description'],
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.neutralGrey600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date: ${command['date']}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.neutralGrey600),
                              ),
                              Text(
                                '${command['amount'].toStringAsFixed(2)} MAD',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
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
          // Pagination Controls
          if (totalPages > 1)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                border: Border(
                  top: BorderSide(color: AppColors.neutralGrey300, width: 1.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: _currentPage > 0
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        : null,
                    color: AppColors.primaryIndigo,
                    disabledColor: AppColors.neutralGrey400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Page ${_currentPage + 1} sur $totalPages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: _currentPage < totalPages - 1
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                          }
                        : null,
                    color: AppColors.primaryIndigo,
                    disabledColor: AppColors.neutralGrey400,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
