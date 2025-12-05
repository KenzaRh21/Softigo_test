import 'package:flutter/material.dart';
import 'package:softigotest/models/facture_model.dart';
import 'package:softigotest/pages/create_invoice_draft_page.dart';
import 'package:softigotest/pages/invoice_detail_page.dart';
import 'package:softigotest/services/facture_api_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; // Keep if AppTheme uses it, otherwise can be removed.
import 'package:softigotest/models/facture_line_model.dart'; // Make sure this is imported
import 'package:softigotest/services/permission_service.dart';
// Enum for invoice status filters
enum InvoiceStatusFilter { all, brouillon, validate, paye, impaye }

final factureService = FactureApiService();

class FacturesPage extends StatefulWidget {
  const FacturesPage({super.key});

  @override
  State<FacturesPage> createState() => _FacturesPageState();
}

class _FacturesPageState extends State<FacturesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Facture> _allFactures = [];
  List<Facture> _filteredFactures = [];
  InvoiceStatusFilter _selectedStatusFilter = InvoiceStatusFilter.all;

  bool _isLoading = true;
  String? _errorMessage;

  int _currentPage = 1;
  final int _itemsPerPage = 7; // Number of items per page

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _searchController.addListener(_applyFiltersAndPagination);
    _permissionService = PermissionService();
    _initializePermissions();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFiltersAndPagination);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvoices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final apiService = FactureApiService();
      _allFactures = await apiService.fetchFactures();
      _applyFiltersAndPagination(); // Apply filters and pagination after fetching
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _allFactures = []; // Clear data on error
        _filteredFactures = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndPagination() {
    final query = _searchController.text.toLowerCase();

    List<Facture> searchFiltered = _allFactures.where((facture) {
      final bool matchesInvoiceDetails =
          facture.reference.toLowerCase().contains(query) ||
          facture.fournisseur.toString().toLowerCase().contains(query) ||
          _formatDate(facture.dateCreation).toLowerCase().contains(query) ||
          facture.total.toStringAsFixed(2).contains(query) ||
          _getStatusDisplayText(facture.status).toLowerCase().contains(query);

      // Check if any of the lines contain the query in their description
      final bool matchesProductDescription = facture.lines.any(
        (line) => line.description.toLowerCase().contains(query),
      );

      return matchesInvoiceDetails || matchesProductDescription;
    }).toList();

    List<Facture> statusAndSearchFiltered = searchFiltered.where((facture) {
      if (_selectedStatusFilter == InvoiceStatusFilter.all) return true;

      switch (_selectedStatusFilter) {
        case InvoiceStatusFilter.brouillon:
          return facture.status == 0;
        case InvoiceStatusFilter.validate:
          return facture.status == 1;
        case InvoiceStatusFilter.paye:
          return facture.status == 2;
        case InvoiceStatusFilter.impaye:
          return facture.status == 3;
        default:
          return false;
      }
    }).toList();

    setState(() {
      _filteredFactures = statusAndSearchFiltered;
      _currentPage = 1; // Reset page on filter change
      if (_filteredFactures.isNotEmpty && _currentPage > _totalPages) {
        _currentPage = _totalPages;
      } else if (_filteredFactures.isEmpty) {
        _currentPage = 1;
      }
    });
  }

  int get _totalPages {
    if (_filteredFactures.isEmpty) return 1;
    return (_filteredFactures.length / _itemsPerPage).ceil();
  }

  List<Facture> get _paginatedFactures {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > _filteredFactures.length) {
      endIndex = _filteredFactures.length;
    }
    if (startIndex < 0 || startIndex >= _filteredFactures.length) {
      return [];
    }
    return _filteredFactures.sublist(startIndex, endIndex);
  }

  void _goToPreviousPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
      }
    });
  }

  void _goToNextPage() {
    setState(() {
      if (_currentPage < _totalPages) {
        _currentPage++;
      }
    });
  }

  void _showStatusFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrer par statut',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Column(
                children: InvoiceStatusFilter.values.map((filter) {
                  String filterText;
                  Color dotColor;
                  switch (filter) {
                    case InvoiceStatusFilter.all:
                      filterText = 'Toutes les factures';
                      dotColor = Colors.transparent;
                      break;
                    case InvoiceStatusFilter.paye:
                      filterText = 'Payé';
                      dotColor = Colors.green[600]!;
                      break;
                    case InvoiceStatusFilter.impaye:
                      filterText = 'Impayé';
                      dotColor = Colors.red;
                      break;
                    case InvoiceStatusFilter.brouillon:
                      filterText = 'Brouillon';
                      dotColor = Colors.grey[700]!;
                      break;
                    case InvoiceStatusFilter.validate:
                      filterText = 'Validée';
                      dotColor = Colors.blue[600]!;
                      break;
                  }
                  return ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor,
                        border:
                            filter == InvoiceStatusFilter.all &&
                                dotColor == Colors.transparent
                            ? Border.all(color: Colors.grey, width: 1)
                            : null,
                      ),
                    ),
                    title: Text(
                      filterText,
                      style: TextStyle(
                        fontWeight: _selectedStatusFilter == filter
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedStatusFilter == filter
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black87,
                      ),
                    ),
                    trailing: _selectedStatusFilter == filter
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedStatusFilter = filter;
                        _applyFiltersAndPagination();
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInvoiceDetailsDialog(Facture facture) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Détails de la facture - ${facture.reference}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow(
                  'Fournisseur ID:',
                  facture.fournisseur.toString(),
                ),
                _buildDetailRow(
                  'Date Création:',
                  _formatDate(facture.dateCreation),
                ),
                _buildDetailRow(
                  'Statut:',
                  _getStatusDisplayText(facture.status),
                ),
                const Divider(),
                // Iterate through each FactureLine to display product details
                if (facture.lines.isNotEmpty) ...[
                  Text(
                    'Produits:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Use Column or ListView.builder for multiple lines
                  ...facture.lines.map((line) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Description:', line.description),
                          _buildDetailRow(
                            'Quantité:',
                            line.quantity.toString(),
                          ),
                          _buildDetailRow(
                            'Prix HT (unité):',
                            // CORRECTED: Use priceHTPerUnit from FactureLine model
                            '${line.priceHTPerUnit.toStringAsFixed(2)} MAD',
                          ),
                          _buildDetailRow(
                            'Prix TTC (unité):',
                            '${line.totalTTC.toStringAsFixed(2)} MAD',
                          ),
                          // You might want to add a subtle divider between lines if there are many
                          // const Divider(height: 16, indent: 20, endIndent: 20),
                        ],
                      ),
                    );
                  }),
                  const Divider(), // Divider before total
                ] else ...[
                  _buildDetailRow('Produits:', 'Aucun produit spécifié.'),
                  const Divider(),
                ],
                _buildDetailRow(
                  'Total Facture:',
                  '${facture.total.toStringAsFixed(2)} MAD',
                  isTotal: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Fermer',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTotal ? 16 : 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                color: isTotal
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black54,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayText(int statusId) {
    switch (statusId) {
      case 0:
        return 'Brouillon';
      case 1:
        return 'Validée';
      case 2:
        return 'Payé';
      case 3:
        return 'Impayé';
      default:
        return 'Inconnu ($statusId)';
    }
  }

  String _formatDate(int timestamp) {
    if (timestamp == 0) return 'N/A';
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  Widget _buildFactureCard(Facture facture) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (facture.status) {
      case 0: // Brouillon
        statusColor = Colors.grey[700]!;
        statusText = 'Brouillon';
        statusIcon = Icons.edit_note_outlined;
        break;
      case 1: // Validated
        statusColor = Colors.blue[600]!;
        statusText = 'Validée';
        statusIcon = Icons.check_circle_outline;
        break;
      case 2: // Paye
        statusColor = Colors.green[600]!;
        statusText = 'Payé';
        statusIcon = Icons.check_circle_outline;
        break;
      case 3: // Impaye
        statusColor = Colors.orange[600]!;
        statusText = 'Impayé';
        statusIcon = Icons.warning_amber_rounded;
        break;
      default:
        statusColor = Colors.blueGrey;
        statusText = 'Inconnu (${facture.status})';
        statusIcon = Icons.info_outline;
    }

    return Card(
      margin: const EdgeInsets.only(
        bottom: 6.0,
      ), // Espacement réduit entre les cartes
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Bords moins arrondis
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceDetailPage(facture: facture),
            ),
          );
        }, // Clique sur toute la carte
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Padding réduit
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Première ligne : Référence + Statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      facture.reference,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
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
                  ),
                ],
              ),

              // Deuxième ligne : Fournisseur
              const SizedBox(height: 4),
              Text(
                'inv id: ${facture.id}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              // Troisième ligne : Date + Montant
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(facture.dateCreation),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${facture.total.toStringAsFixed(2)} MAD',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrentFilterText() {
    switch (_selectedStatusFilter) {
      case InvoiceStatusFilter.all:
        return 'Toutes';
      case InvoiceStatusFilter.paye:
        return 'Payé';
      case InvoiceStatusFilter.impaye:
        return 'Impayé';
      case InvoiceStatusFilter.brouillon:
        return 'Brouillon';
      case InvoiceStatusFilter.validate:
        return 'Validée';
      default:
        return 'Toutes';
    }
  }


  late PermissionService _permissionService;



  Future<void> _initializePermissions() async {
    await _permissionService.loadUserData();
    
    // Si l'utilisateur n'a pas la permission de voir les factures
    if (!_permissionService.canViewInvoice()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous n\'avez pas accès à cette page'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Factures',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0), // Height for search bar
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une facture...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement: $_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchInvoices,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchInvoices,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.filter_list),
                            label: Text(
                              'Filtrer par Statut: ${_getCurrentFilterText()}',
                            ),
                            onPressed: _showStatusFilterOptions,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Text(
                            '(${_filteredFactures.length} factures)',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _paginatedFactures.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty &&
                                          _selectedStatusFilter ==
                                              InvoiceStatusFilter.all
                                      ? 'Aucune facture disponible pour le moment.'
                                      : 'Aucune facture trouvée pour "${_searchController.text}" avec le filtre "${_getCurrentFilterText()}".',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                if (_searchController.text.isNotEmpty ||
                                    _selectedStatusFilter !=
                                        InvoiceStatusFilter.all) ...[
                                  const SizedBox(height: 16),
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _selectedStatusFilter =
                                            InvoiceStatusFilter.all;
                                      });
                                    },
                                    child: const Text(
                                      'Réinitialiser les filtres',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 16.0,
                              // 👇 Augmentez le padding en bas pour laisser de l'espace pour la pagination ET le bouton flottant
                              bottom: 100.0, // Augmenté de 80 à 100
                            ),
                            itemCount: _paginatedFactures.length,
                            itemBuilder: (context, index) {
                              final facture = _paginatedFactures[index];
                              return Dismissible(
                                key: ValueKey(facture.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  alignment: Alignment.centerRight,
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        "Confirmer la suppression",
                                      ),
                                      content: Text(
                                        "Voulez-vous vraiment supprimer la facture id est ${facture.id}est le ${facture.reference} ?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("Annuler"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("Supprimer"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) async {
                                  if (facture.id == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'ID de la facture manquant.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  try {
                                    final success = await factureService
                                        .deleteFacture(invoiceId: facture.id);

                                    if (success) {
                                      setState(() {
                                        _allFactures.removeWhere(
                                          (f) =>
                                              f.id.toString() ==
                                              facture.id.toString(),
                                        );
                                        _filteredFactures.removeWhere(
                                          (f) =>
                                              f.id.toString() ==
                                              facture.id.toString(),
                                        );
                                        _applyFiltersAndPagination();
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Facture supprimée'),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'La suppression a échoué sur le serveur',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    print('Erreur API: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erreur lors de la suppression: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: _buildFactureCard(facture),
                              );
                            },
                          ),
                  ),
                  // Pagination controls
                  if (_filteredFactures.length > _itemsPerPage)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0, // Légèrement augmenté
                      ),
                      // Ajouter une marge en bas pour éviter que le FAB ne cache la pagination
                      margin: const EdgeInsets.only(bottom: 70.0),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _currentPage > 1
                                ? _goToPreviousPage
                                : null,
                            icon: const Icon(Icons.arrow_back_ios),
                            color: Theme.of(context).colorScheme.primary,
                            disabledColor: Colors.grey,
                          ),
                          Text('Page $_currentPage sur $_totalPages'),
                          IconButton(
                            onPressed: _currentPage < _totalPages
                                ? _goToNextPage
                                : null,
                            icon: const Icon(Icons.arrow_forward_ios),
                            color: Theme.of(context).colorScheme.primary,
                            disabledColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: _permissionService.canCreateInvoice()
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateInvoiceDraftPage(),
                  ),
                );
              },
        icon: const Icon(Icons.add),
        label: const Text('Créer une facture'),
          )
          : null, // Bouton masqué si pas de permission
    );
  }
}
