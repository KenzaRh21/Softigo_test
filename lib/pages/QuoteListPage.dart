import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_styles.dart';
import '../models/quote_model.dart';
import 'AddEditQuotePage.dart';
import 'QuoteDetailPage.dart'; // Importez la page de détail

class QuoteListPage extends StatefulWidget {
  const QuoteListPage({Key? key}) : super(key: key);

  @override
  State<QuoteListPage> createState() => _QuoteListPageState();
}

class _QuoteListPageState extends State<QuoteListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStatusFilter;

  List<Quote> _allQuotes = [];

  // Clients fictifs (doivent correspondre exactement à ceux de AddEditQuotePage)
  final List<String> _dummyClientNames = [
    'Alpha Corp',
    'Beta Solutions',
    'Gamma Industries',
    'Delta Innovations',
    'Epsilon Tech',
    'Zeta Solutions', // Important: Maintenir cette liste cohérente
  ];

  @override
  void initState() {
    super.initState();
    _populateInitialQuotes();
  }

  void _populateInitialQuotes() {
    _allQuotes = [
      Quote(
        id: 'D001',
        clientName: _dummyClientNames[0], // Alpha Corp
        description: 'Développement application mobile',
        amount: 15000.00,
        proposalDate: DateTime(2025, 1, 15),
        validityDurationDays: 30,
        status: QuoteStatus.accepted,
      ),
      Quote(
        id: 'D002',
        clientName: _dummyClientNames[1], // Beta Solutions
        description: 'Consulting en cybersécurité',
        amount: 8500.00,
        proposalDate: DateTime(2025, 2, 20),
        validityDurationDays: 45,
        status: QuoteStatus.pending,
      ),
      Quote(
        id: 'D003',
        clientName: _dummyClientNames[2], // Gamma Industries
        description: 'Maintenance serveur annuelle',
        amount: 3200.00,
        proposalDate: DateTime(2025, 3, 5),
        validityDurationDays: 15,
        status: QuoteStatus.rejected,
      ),
      Quote(
        id: 'D004',
        clientName: _dummyClientNames[3], // Delta Innovations
        description: 'Refonte site web e-commerce',
        amount: 12000.00,
        proposalDate: DateTime(2025, 4, 10),
        validityDurationDays: 60,
        status: QuoteStatus.invoiced,
      ),
      Quote(
        id: 'D005',
        clientName: _dummyClientNames[0], // Alpha Corp (doublon pour le test)
        description: 'Audit de sécurité initial',
        amount: 2500.00,
        proposalDate: DateTime(2025, 6, 1),
        validityDurationDays: 7,
        status: QuoteStatus.draft,
      ),
      Quote(
        id: 'D006',
        clientName: _dummyClientNames[5], // Zeta Solutions
        description: 'Formation Flutter avancée',
        amount: 5000.00,
        proposalDate: DateTime(2025, 7, 10),
        validityDurationDays: 20,
        status: QuoteStatus.pending,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Quote> _getFilteredQuotes() {
    List<Quote> filtered = _allQuotes.where((quote) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          quote.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          quote.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          quote.id.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _selectedStatusFilter == null ||
          _selectedStatusFilter == 'Tous' ||
          quote.status.toDisplayString() == _selectedStatusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    filtered.sort((a, b) => b.proposalDate.compareTo(a.proposalDate));

    return filtered;
  }

  void _refreshQuotes() {
    setState(() {
      _populateInitialQuotes();
      _searchQuery = '';
      _searchController.clear();
      _selectedStatusFilter = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Liste des devis rafraîchie!')),
    );
  }

  void _addQuote() async {
    final newQuote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditQuotePage()),
    );

    if (newQuote != null && newQuote is Quote) {
      setState(() {
        _allQuotes.add(newQuote);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Devis ${newQuote.id} créé.')));
    }
  }

  // Fonction pour éditer un devis directement depuis le PopupMenuButton de QuoteCard
  void _editQuoteFromList(Quote quoteToEdit) async {
    final updatedQuote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditQuotePage(quote: quoteToEdit),
      ),
    );

    if (updatedQuote != null && updatedQuote is Quote) {
      setState(() {
        final index = _allQuotes.indexWhere((q) => q.id == updatedQuote.id);
        if (index != -1) {
          _allQuotes[index] = updatedQuote;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Devis ${updatedQuote.id} mis à jour.')),
      );
    }
  }

  // Fonction pour voir les détails d'un devis (appelée par onTap sur QuoteCard)
  void _viewQuoteDetails(Quote quoteToView) async {
    final updatedQuote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuoteDetailPage(
          quote: quoteToView,
          onQuoteUpdated: (updated) {
            // Ce callback est appelé si le devis est mis à jour depuis QuoteDetailPage
            setState(() {
              final index = _allQuotes.indexWhere((q) => q.id == updated.id);
              if (index != -1) {
                _allQuotes[index] = updated;
              }
            });
          },
        ),
      ),
    );

    if (updatedQuote != null && updatedQuote is Quote) {
      setState(() {
        final index = _allQuotes.indexWhere((q) => q.id == updatedQuote.id);
        if (index != -1) {
          _allQuotes[index] = updatedQuote;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Devis ${updatedQuote.id} mis à jour depuis le détail/édition.',
          ),
        ),
      );
    }
  }

  void _deleteQuote(String quoteId) {
    setState(() {
      _allQuotes.removeWhere((quote) => quote.id == quoteId);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Devis $quoteId supprimé.')));
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuotes = _getFilteredQuotes();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Gestion des Devis',
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
            onPressed: _refreshQuotes,
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
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Rechercher un devis par client, description ou ID...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryIndigo,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.neutralGrey600,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neutralGrey400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neutralGrey400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
                ),
                const SizedBox(height: 16),

                _buildFilterDropdown(
                  context,
                  'Filtrer par Statut',
                  Icons.receipt_long,
                  _selectedStatusFilter,
                  [
                    'Tous',
                    ...QuoteStatus.values
                        .map((e) => e.toDisplayString())
                        .toList(),
                  ],
                  (newValue) {
                    setState(() {
                      _selectedStatusFilter = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredQuotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.request_quote_outlined,
                          size: 80,
                          color: AppColors.neutralGrey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun devis trouvé.',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.neutralGrey600),
                        ),
                        if (_searchQuery.isNotEmpty ||
                            _selectedStatusFilter != null &&
                                _selectedStatusFilter != 'Tous')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Ajustez vos filtres de recherche.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.neutralGrey600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: filteredQuotes.length,
                    itemBuilder: (context, index) {
                      final quote = filteredQuotes[index];
                      return QuoteCard(
                        quote: quote,
                        onViewDetails:
                            _viewQuoteDetails, // Tap sur la carte ouvre les détails
                        onEdit: _editQuoteFromList, // Édition via le PopupMenu
                        onDelete: _deleteQuote,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuote,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Créer Devis'),
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: AppColors.neutralWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      value: currentValue ?? items.first,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryIndigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
          ),
        );
      }).toList(),
    );
  }
}

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final Function(Quote) onEdit; // Pour l'option "Modifier" du PopupMenu
  final Function(String) onDelete;
  final Function(Quote) onViewDetails; // Pour le onTap de la carte

  const QuoteCard({
    Key? key,
    required this.quote,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Réduire la marge inférieure entre les cartes
      margin: const EdgeInsets.only(bottom: 8.0), // Réduit de 12.0 à 8.0
      elevation: 3, // Légèrement moins d'élévation pour un look plus compact
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rayon de bordure plus petit
        side: BorderSide(
          color: quote.status.toColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          onViewDetails(quote); // Appelle la fonction de vue détaillée
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          // Réduire le padding interne de la carte
          padding: const EdgeInsets.all(12.0), // Réduit de 16.0 à 12.0
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Devis #${quote.id}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        // Taille de police légèrement réduite
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    // Changer le symbole Euro (€) en MAD
                    '${quote.amount.toStringAsFixed(2)} MAD',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      // Taille de police légèrement réduite
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryIndigo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6), // Espacement réduit
              Text(
                'Client: ${quote.clientName}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  // Taille de police légèrement réduite
                  color: AppColors.neutralGrey800,
                ),
              ),
              const SizedBox(height: 3), // Espacement réduit
              Text(
                quote.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  // Taille de police plus petite pour la description
                  color: AppColors.neutralGrey700,
                ),
                maxLines: 1, // Limiter la description à une seule ligne
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10), // Espacement réduit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(context, quote.status),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(quote.proposalDate)}',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              // Taille de police légèrement réduite
                              color: AppColors.neutralGrey600,
                            ),
                      ),
                      Text(
                        'Validité: ${quote.validityDurationDays} jours',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          // Taille de police plus petite
                          color: AppColors.neutralGrey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Optionnel: Réduire ou supprimer le PopupMenuButton si l'espace est très limité
              // Pour l'instant, on le garde mais on peut le rendre moins proéminent ou le déplacer.
              Align(
                alignment: Alignment.bottomRight,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero, // Supprimer le padding du bouton
                  iconSize: 20, // Réduire la taille de l'icône
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit(quote);
                    } else if (value == 'delete') {
                      onDelete(quote.id);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Modifier'),
                            visualDensity: VisualDensity
                                .compact, // Rendre la ListTile plus compacte
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            title: Text('Supprimer'),
                            visualDensity: VisualDensity
                                .compact, // Rendre la ListTile plus compacte
                          ),
                        ),
                      ],
                  icon: const Icon(Icons.more_vert),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, QuoteStatus status) {
    return Container(
      // Réduire le padding du badge de statut
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ), // Réduit de 10/5 à 8/3
      decoration: BoxDecoration(
        color: status.toColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(6), // Rayon de bordure plus petit
        border: Border.all(color: status.toColor().withOpacity(0.3)),
      ),
      child: Text(
        status.toDisplayString(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          // Garder une petite taille de police
          color: status.toColor(),
          fontWeight: FontWeight.bold,
          fontSize: 10, // Assurer une taille de police très petite mais lisible
        ),
      ),
    );
  }
}
