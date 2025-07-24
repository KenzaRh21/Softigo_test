import 'package:flutter/material.dart';
import 'package:softigotest/pages/NewTicketPage.dart';
import 'package:softigotest/pages/TicketDetailPage.dart';
import '../utils/app_styles.dart'; // Make sure this path is correct
import '../models/ticket_model.dart'; // Import the Ticket model

class TicketListPage extends StatefulWidget {
  const TicketListPage({Key? key}) : super(key: key);

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  // Example list of tickets (replace with actual data fetching from API)
  List<Ticket> _tickets = [
    Ticket(
      id: 'TS2507-0001',
      subject: 'Problème de connexion ERP',
      description:
          'Impossible de se connecter à l\'application ERP depuis ce matin.',
      requestType: 'Support',
      severity: 'Urgent',
      assignedTo: 'Taha Dev',
      status: TicketStatus.inProgress,
      creationDate: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      thirdParty: 'Tiers A',
      contactAddress: 'Contact A1',
    ),
    Ticket(
      id: 'TS2507-0002',
      subject: 'Demande de nouvelle fonctionnalité',
      description: 'Ajouter un module de rapport personnalisé pour les ventes.',
      requestType: 'Demande',
      severity: 'Normal',
      assignedTo: 'Amina Tech',
      status: TicketStatus.open,
      creationDate: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
      thirdParty: 'Tiers B',
      contactAddress: 'Contact B1',
    ),
    Ticket(
      id: 'TS2507-0003',
      subject: 'Bug affichage mobile',
      description:
          'L\'interface sur mobile est déformée pour certains utilisateurs.',
      requestType: 'Support',
      severity: 'Bloquant',
      assignedTo: 'Taha Dev',
      status: TicketStatus.pending,
      creationDate: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Ticket(
      id: 'TS2507-0004',
      subject: 'Mise à jour logiciel CRM',
      description: 'Planifier la mise à jour de la version du CRM.',
      requestType: 'Autre',
      severity: 'Normal',
      assignedTo: 'Omar Sales',
      status: TicketStatus.resolved,
      creationDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Ticket(
      id: 'TS2507-0005',
      subject: 'Problème de licence',
      description: 'La licence du logiciel X est expirée.',
      requestType: 'Support',
      severity: 'Urgent',
      assignedTo: 'Taha Dev',
      status: TicketStatus.closed,
      creationDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  String? _selectedStatusFilter;
  String? _selectedAssignedToFilter;
  String? _searchText;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.trim();
    });
  }

  // Function to filter tickets
  List<Ticket> _getFilteredTickets() {
    List<Ticket> filtered = _tickets;

    if (_selectedStatusFilter != null && _selectedStatusFilter != 'Tous') {
      filtered = filtered
          .where(
            (ticket) =>
                ticket.status.toDisplayString() == _selectedStatusFilter,
          )
          .toList();
    }

    if (_selectedAssignedToFilter != null &&
        _selectedAssignedToFilter != 'Tous') {
      filtered = filtered
          .where((ticket) => ticket.assignedTo == _selectedAssignedToFilter)
          .toList();
    }

    if (_searchText != null && _searchText!.isNotEmpty) {
      filtered = filtered
          .where(
            (ticket) =>
                ticket.subject.toLowerCase().contains(
                  _searchText!.toLowerCase(),
                ) ||
                ticket.id.toLowerCase().contains(_searchText!.toLowerCase()) ||
                ticket.description.toLowerCase().contains(
                  _searchText!.toLowerCase(),
                ),
          )
          .toList();
    }

    // Sort by creation date, newest first
    filtered.sort((a, b) => b.creationDate.compareTo(a.creationDate));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTickets = _getFilteredTickets();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Mes Tickets',
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
            onPressed: () {
              // Simulate refreshing data
              setState(() {
                // In a real app, you'd fetch data from your API here
                // For now, we just rebuild the list
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Liste des tickets rafraîchie!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterAndSearchBar(context),
          Expanded(
            child: filteredTickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: AppColors.neutralGrey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun ticket trouvé.',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.neutralGrey600),
                        ),
                        if (_selectedStatusFilter != null ||
                            _selectedAssignedToFilter != null ||
                            (_searchText != null && _searchText!.isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Ajustez vos filtres ou la recherche.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.neutralGrey600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      return TicketCard(ticket: ticket);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to NewTicketPage and wait for it to return
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewTicketPage()),
          );
          // When NewTicketPage is popped, refresh the list (in a real app, you'd re-fetch data)
          setState(() {
            // For now, we simulate adding a new ticket, but in a real app,
            // you'd typically refetch your _tickets list from an API.
            // For demo purposes, let's add a dummy ticket.
            _tickets.insert(
              0,
              Ticket(
                id: 'TS${(DateTime.now().microsecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
                subject: 'Nouveau Ticket Généré',
                description:
                    'Ceci est un ticket généré après avoir cliqué sur "Créer un Ticket".',
                requestType: 'Autre',
                severity: 'Normal',
                assignedTo: 'Taha Dev',
                status: TicketStatus.open,
                creationDate: DateTime.now(),
              ),
            );
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Ticket'),
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: AppColors.neutralWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFilterAndSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Rechercher un ticket',
              hintText: 'Par sujet, référence, description...',
              prefixIcon: Icon(Icons.search, color: AppColors.primaryIndigo),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchText = null;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.neutralGrey400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.neutralGrey400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primaryIndigo,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.inputBackground,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  context,
                  'Statut',
                  Icons.receipt_long_outlined,
                  _selectedStatusFilter,
                  [
                    'Tous',
                    ...TicketStatus.values
                        .map((e) => e.toDisplayString())
                        .toList(),
                  ],
                  (newValue) {
                    setState(() {
                      _selectedStatusFilter = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  context,
                  'Assigné à',
                  Icons.person_outline,
                  _selectedAssignedToFilter,
                  [
                    'Tous',
                    'Taha Dev',
                    'Amina Tech',
                    'Omar Sales',
                  ], // This should come from your actual assignedTo list
                  (newValue) {
                    setState(() {
                      _selectedAssignedToFilter = newValue;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
      // Set default to 'Tous' or first item
      value: currentValue ?? items.first,
      onChanged: onChanged,
      // Adjust InputDecoration for better fit
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryIndigo,
          size: 20,
        ), // Smaller icon
        // Reduce horizontal content padding
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        // Add isDense to make the input field more compact
        isDense: true,
      ),
      // Style the selected value text to be smaller if needed
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.primaryText,
        fontSize: 13, // Slightly smaller font size for selected value
      ),
      isExpanded: true, // Crucial: Allows the dropdown to expand horizontally
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
            overflow: TextOverflow.ellipsis, // Ensure overflow for long items
            maxLines: 1,
          ),
        );
      }).toList(),
    );
  }
}

// --- Ticket Card Widget --- (Kept as is from previous correct version)
class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutralGrey300, width: 1),
      ),
      child: InkWell(
        onTap: () async {
          final bool? shouldRefresh = await Navigator.push(
            // Await result
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TicketDetailPage(ticket: ticket), // Pass the selected ticket
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ticket ID
                  Flexible(
                    child: Text(
                      ticket.id,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryIndigo,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Badge - Wrapped with Flexible to prevent overflow
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ticket.status.toColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ticket.status.toDisplayString(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: ticket.status.toColor(),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // Center text in badge
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Subject
              Text(
                ticket.subject,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Description (truncated)
              Text(
                ticket.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutralGrey700,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(
                height: 24,
                thickness: 0.5,
                color: AppColors.neutralGrey300,
              ),
              // Details Row - Each child now wrapped with Expanded
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildDetailChip(
                      context,
                      Icons.notes,
                      ticket.requestType,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 1,
                    child: _buildDetailChip(
                      context,
                      Icons.person,
                      ticket.assignedTo,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 1,
                    child: _buildDetailChip(
                      context,
                      Icons.priority_high,
                      ticket.severity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Creation Date
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Créé le: ${ticket.creationDate.day.toString().padLeft(2, '0')}/${ticket.creationDate.month.toString().padLeft(2, '0')}/${ticket.creationDate.year} ${ticket.creationDate.hour.toString().padLeft(2, '0')}:${ticket.creationDate.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.neutralGrey600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.neutralGrey300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            child: Icon(icon, size: 14, color: AppColors.primaryIndigo),
          ),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 9.0,
                color: AppColors.primaryText,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
