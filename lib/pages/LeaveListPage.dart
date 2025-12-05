import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_styles.dart';
import '../models/leave_request_model.dart'; // Importez le modèle de congé
import 'LeaveRequestPage.dart'; // Importez la page de demande de congé

class LeaveListPage extends StatefulWidget {
  const LeaveListPage({super.key});

  @override
  State<LeaveListPage> createState() => _LeaveListPageState();
}

class _LeaveListPageState extends State<LeaveListPage> {
  List<LeaveRequest> _leaveRequests = [
    LeaveRequest(
      id: 'LREQ-001',
      employeeName: 'Taha Dev',
      leaveType: LeaveType.paid,
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 10)),
      reason: 'Vacances annuelles en famille',
      requestDate: DateTime.now().subtract(const Duration(days: 5)),
      status: LeaveStatus.approved,
    ),
    LeaveRequest(
      id: 'LREQ-002',
      employeeName: 'Amina Tech',
      leaveType: LeaveType.sick,
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().subtract(const Duration(days: 1)),
      reason: 'Grippe saisonnière, fièvre et toux persistantes.',
      requestDate: DateTime.now().subtract(const Duration(days: 3)),
      status: LeaveStatus.approved,
      contactInfo: '0612345678',
    ),
    LeaveRequest(
      id: 'LREQ-003',
      employeeName: 'Omar Sales',
      leaveType: LeaveType.unpaid,
      startDate: DateTime.now().add(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 35)),
      reason: 'Voyage personnel en Asie du Sud-Est.',
      requestDate: DateTime.now().subtract(const Duration(days: 10)),
      status: LeaveStatus.pending,
    ),
    LeaveRequest(
      id: 'LREQ-004',
      employeeName: 'Taha Dev',
      leaveType: LeaveType.other,
      startDate: DateTime.now().add(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 15)),
      reason: 'Rendez-vous administratif à la préfecture.',
      requestDate: DateTime.now().subtract(const Duration(days: 2)),
      status: LeaveStatus.pending,
    ),
    LeaveRequest(
      id: 'LREQ-005',
      employeeName: 'Amina Tech',
      leaveType: LeaveType.paid,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 7)),
      reason: 'Congé familial pour événement important.',
      requestDate: DateTime.now().subtract(const Duration(days: 15)),
      status: LeaveStatus.rejected,
      rejectionReason: 'Période de forte activité et effectif réduit.',
    ),
    LeaveRequest(
      id: 'LREQ-006',
      employeeName: 'Taha Dev',
      leaveType: LeaveType.paid,
      startDate: DateTime.now().add(const Duration(days: 90)),
      endDate: DateTime.now().add(const Duration(days: 92)),
      reason: 'Pont du 1er novembre.',
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
      status: LeaveStatus.pending,
    ),
  ];

  String? _selectedStatusFilter;

  List<LeaveRequest> _getFilteredLeaveRequests() {
    List<LeaveRequest> filtered = List.from(_leaveRequests);

    if (_selectedStatusFilter != null && _selectedStatusFilter != 'Tous') {
      filtered = filtered
          .where(
            (request) =>
                request.status.toDisplayString() == _selectedStatusFilter,
          )
          .toList();
    }

    // Trier par date de début, les plus proches/actuels en premier
    filtered.sort((a, b) => a.startDate.compareTo(b.startDate));

    return filtered;
  }

  void _refreshLeaveRequests() {
    setState(() {
      // En production, vous feriez ici un appel API pour rafraîchir les données
      // Pour la démo, on re-initialise la liste fictive.
      _leaveRequests = [
        LeaveRequest(
          id: 'LREQ-001',
          employeeName: 'Taha Dev',
          leaveType: LeaveType.paid,
          startDate: DateTime.now().add(const Duration(days: 7)),
          endDate: DateTime.now().add(const Duration(days: 10)),
          reason: 'Vacances annuelles en famille',
          requestDate: DateTime.now().subtract(const Duration(days: 5)),
          status: LeaveStatus.approved,
        ),
        LeaveRequest(
          id: 'LREQ-002',
          employeeName: 'Amina Tech',
          leaveType: LeaveType.sick,
          startDate: DateTime.now().subtract(const Duration(days: 2)),
          endDate: DateTime.now().subtract(const Duration(days: 1)),
          reason: 'Grippe saisonnière, fièvre et toux persistantes.',
          requestDate: DateTime.now().subtract(const Duration(days: 3)),
          status: LeaveStatus.approved,
          contactInfo: '0612345678',
        ),
        LeaveRequest(
          id: 'LREQ-003',
          employeeName: 'Omar Sales',
          leaveType: LeaveType.unpaid,
          startDate: DateTime.now().add(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 35)),
          reason: 'Voyage personnel en Asie du Sud-Est.',
          requestDate: DateTime.now().subtract(const Duration(days: 10)),
          status: LeaveStatus.pending,
        ),
        LeaveRequest(
          id: 'LREQ-004',
          employeeName: 'Taha Dev',
          leaveType: LeaveType.other,
          startDate: DateTime.now().add(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          reason: 'Rendez-vous administratif à la préfecture.',
          requestDate: DateTime.now().subtract(const Duration(days: 2)),
          status: LeaveStatus.pending,
        ),
        LeaveRequest(
          id: 'LREQ-005',
          employeeName: 'Amina Tech',
          leaveType: LeaveType.paid,
          startDate: DateTime.now().subtract(const Duration(days: 10)),
          endDate: DateTime.now().subtract(const Duration(days: 7)),
          reason: 'Congé familial pour événement important.',
          requestDate: DateTime.now().subtract(const Duration(days: 15)),
          status: LeaveStatus.rejected,
          rejectionReason: 'Période de forte activité et effectif réduit.',
        ),
        LeaveRequest(
          id: 'LREQ-006',
          employeeName: 'Taha Dev',
          leaveType: LeaveType.paid,
          startDate: DateTime.now().add(const Duration(days: 90)),
          endDate: DateTime.now().add(const Duration(days: 92)),
          reason: 'Pont du 1er novembre.',
          requestDate: DateTime.now().subtract(const Duration(days: 1)),
          status: LeaveStatus.pending,
        ),
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Liste des congés rafraîchie!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLeaveRequests = _getFilteredLeaveRequests();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Mes Demandes de Congés',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            // Reduced from titleLarge
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
            onPressed: _refreshLeaveRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtre par statut
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0, // Reduced from 16.0
              vertical: 6.0, // Reduced from 8.0
            ),
            child: _buildFilterDropdown(
              context,
              'Statut',
              Icons.filter_list,
              _selectedStatusFilter,
              [
                'Tous',
                ...LeaveStatus.values.map((e) => e.toDisplayString()),
              ],
              (newValue) {
                setState(() {
                  _selectedStatusFilter = newValue;
                });
              },
            ),
          ),
          Expanded(
            child: filteredLeaveRequests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 60, // Reduced from 80
                          color: AppColors.neutralGrey400,
                        ),
                        const SizedBox(height: 12), // Reduced from 16
                        Text(
                          'Aucune demande de congé trouvée.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge // Reduced from titleMedium
                              ?.copyWith(color: AppColors.neutralGrey600),
                        ),
                        if (_selectedStatusFilter != null &&
                            _selectedStatusFilter != 'Tous')
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 6.0,
                            ), // Reduced from 8.0
                            child: Text(
                              'Ajustez votre filtre de statut.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall // Reduced from bodyMedium
                                  ?.copyWith(color: AppColors.neutralGrey600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, // Reduced from 16.0
                      vertical: 6.0, // Reduced from 8.0
                    ),
                    itemCount: filteredLeaveRequests.length,
                    itemBuilder: (context, index) {
                      final request = filteredLeaveRequests[index];
                      return LeaveTimelineTile(
                        request: request,
                        isFirst: index == 0,
                        isLast: index == filteredLeaveRequests.length - 1,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeaveRequestPage()),
          );
          _refreshLeaveRequests(); // Rafraîchir la liste
        },
        icon: const Icon(Icons.add_box_outlined, size: 20), // Reduced icon size
        label: const Text(
          'Nouvelle Demande',
          style: TextStyle(fontSize: 14),
        ), // Reduced font size
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: AppColors.neutralWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ), // Reduced from 16
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Widget d'aide pour le dropdown de filtre (réutilisé)
  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    IconData icon,
    String? currentValue,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: currentValue ?? items.first, // Set default to 'Tous' or first item
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryIndigo,
          size: 20,
        ), // Reduced icon size
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6), // Reduced from 8
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6), // Reduced from 8
          borderSide: BorderSide(color: AppColors.neutralGrey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6), // Reduced from 8
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10, // Reduced from 12
          horizontal: 12, // Reduced from 16
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryText,
            ), // Reduced from bodyLarge
          ),
        );
      }).toList(),
    );
  }
}

// --- Nouveau Widget pour la "Timeline Tile" ---
class LeaveTimelineTile extends StatefulWidget {
  final LeaveRequest request;
  final bool isFirst;
  final bool isLast;

  const LeaveTimelineTile({
    super.key,
    required this.request,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<LeaveTimelineTile> createState() => _LeaveTimelineTileState();
}

class _LeaveTimelineTileState extends State<LeaveTimelineTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.request.status.toColor();
    final typeColor = widget.request.leaveType.toColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0), // Reduced from 4.0
      child: IntrinsicHeight(
        // Permet aux colonnes d'avoir la même hauteur
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Rend les colonnes extensibles
          children: [
            // Colonne de la Timeline (ligne verticale et cercle)
            Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2, // Reduced from 3
                    color: widget.isFirst
                        ? Colors.transparent
                        : AppColors.neutralGrey300,
                  ),
                ),
                Container(
                  width: 20, // Reduced from 24
                  height: 20, // Reduced from 24
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor, // Couleur du cercle basée sur le statut
                    border: Border.all(
                      color: AppColors.neutralWhite,
                      width: 1.5,
                    ), // Reduced border width
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3), // Reduced opacity
                        blurRadius: 3, // Reduced blur radius
                      ),
                    ],
                  ),
                  child: Icon(
                    _getStatusIcon(widget.request.status),
                    color: AppColors.neutralWhite,
                    size: 12, // Reduced from 14
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2, // Reduced from 3
                    color: widget.isLast
                        ? Colors.transparent
                        : AppColors.neutralGrey300,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10), // Reduced from 12
            // Contenu de la Demande de Congé
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(12.0), // Reduced from 16.0
                  margin: const EdgeInsets.only(
                    bottom: 6.0,
                  ), // Reduced from 8.0
                  decoration: BoxDecoration(
                    color: AppColors.neutralWhite,
                    borderRadius: BorderRadius.circular(10), // Reduced from 12
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neutralGrey300.withOpacity(
                          0.4,
                        ), // Reduced opacity
                        blurRadius: 6, // Reduced from 8
                        offset: const Offset(0, 3), // Reduced offset
                      ),
                    ],
                    border: Border.all(
                      color: statusColor.withOpacity(0.2), // Reduced opacity
                      width: 1.0, // Reduced from 1.5
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête : Type de congé et ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              widget.request.leaveType.toDisplayString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge // Reduced from titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: typeColor,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            widget.request.id,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.neutralGrey600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6), // Reduced from 8
                      // Nom de l'employé
                      Text(
                        widget.request.employeeName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium // Reduced from headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                      ),
                      const SizedBox(height: 8), // Reduced from 12
                      // Dates et nombre de jours
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 16, // Reduced from 18
                            color: AppColors.neutralGrey700,
                          ),
                          const SizedBox(width: 6), // Reduced from 8
                          Expanded(
                            child: Text(
                              '${DateFormat('dd/MM').format(widget.request.startDate)} - ${DateFormat('dd/MM/yyyy').format(widget.request.endDate)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium // Reduced from bodyLarge
                                  ?.copyWith(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, // Reduced from 8
                              vertical: 3, // Reduced from 4
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryIndigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                6,
                              ), // Reduced from 8
                            ),
                            child: Text(
                              '${widget.request.numberOfDays}j',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall // Reduced from labelMedium
                                  ?.copyWith(
                                    color: AppColors.primaryIndigo,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8), // Reduced from 12
                      // Statut
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16, // Reduced from 18
                            color: statusColor,
                          ),
                          const SizedBox(width: 6), // Reduced from 8
                          Text(
                            'Statut: ${widget.request.status.toDisplayString()}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium // Reduced from bodyLarge
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),

                      // Détails expandables
                      if (_isExpanded) ...[
                        const Divider(height: 20), // Reduced from 24
                        Text(
                          'Raison:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.neutralGrey700,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 3), // Reduced from 4
                        Text(
                          widget.request.reason,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall // Reduced from bodyMedium
                              ?.copyWith(color: AppColors.neutralGrey800),
                        ),
                        if (widget.request.contactInfo != null &&
                            widget.request.contactInfo!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                            ), // Reduced from 10.0
                            child: Text(
                              'Contact en cas d\'urgence: ${widget.request.contactInfo}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.neutralGrey700),
                            ),
                          ),
                        if (widget.request.status == LeaveStatus.rejected &&
                            widget.request.rejectionReason != null &&
                            widget.request.rejectionReason!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                            ), // Reduced from 10.0
                            child: Text(
                              'Raison du rejet: ${widget.request.rejectionReason}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.red.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return Icons.hourglass_empty;
      case LeaveStatus.approved:
        return Icons.check_circle_outline;
      case LeaveStatus.rejected:
        return Icons.cancel_outlined;
      case LeaveStatus.cancelled:
        return Icons.block;
    }
  }
}
