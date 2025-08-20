import 'package:flutter/material.dart';
import '../services/command_api_service.dart';
import '../utils/app_styles.dart';

class EditCommandPage extends StatefulWidget {
  final Map<String, dynamic> command;
  final CommandApiService apiService;

  const EditCommandPage({
    Key? key,
    required this.command,
    required this.apiService,
  }) : super(key: key);

  @override
  _EditCommandPageState createState() => _EditCommandPageState();
}

class _EditCommandPageState extends State<EditCommandPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _refClientController;
  late TextEditingController _dateCommandeController;
  late TextEditingController _dateLivraisonController;
  late TextEditingController _totalTTCController;
  late TextEditingController _condReglementController;
  late TextEditingController _modeLivraisonController;
  late TextEditingController _clientNameController;

  late Future<List<dynamic>> _orderLinesFuture;
  List<Map<String, dynamic>> _orderLines = [];
  List<Map<String, dynamic>> _initialOrderLines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _refClientController = TextEditingController(
      text: widget.command['ref_client'] ?? '',
    );
    _totalTTCController = TextEditingController(
      text:
          double.tryParse(
            widget.command['multicurrency_total_ttc'].toString(),
          )?.toStringAsFixed(2) ??
          '0.00',
    );
    _condReglementController = TextEditingController(
      text: widget.command['cond_reglement_code'] ?? '',
    );
    _modeLivraisonController = TextEditingController(
      text: widget.command['mode_reglement_code'] ?? '',
    );

    String formattedDateCommande = widget.command['date_commande'] != null
        ? _formatDate(widget.command['date_commande'])
        : 'Non spécifié';
    _dateCommandeController = TextEditingController(
      text: formattedDateCommande,
    );

    String formattedDateLivraison = widget.command['date_livraison'] != null
        ? _formatDate(widget.command['date_livraison'])
        : 'Non spécifié';
    _dateLivraisonController = TextEditingController(
      text: formattedDateLivraison,
    );

    String clientName = await _fetchClientName();
    _clientNameController = TextEditingController(text: clientName);

    _orderLinesFuture = widget.apiService.fetchOrderLines(
      int.parse(widget.command['id'].toString()),
    );
    _orderLinesFuture
        .then((lines) {
          setState(() {
            _orderLines = List<Map<String, dynamic>>.from(lines);
            _initialOrderLines = List<Map<String, dynamic>>.from(lines);
            _isLoading = false;
          });
        })
        .catchError((e) {
          debugPrint('Erreur lors du chargement des lignes de commande: $e');
          setState(() {
            _isLoading = false;
          });
        });
  }

  Future<String> _fetchClientName() async {
    final int? socid = int.tryParse(widget.command['socid'].toString());
    if (socid != null) {
      try {
        final thirdPartyData = await widget.apiService.fetchThirdParty(socid);
        return thirdPartyData['name'] ?? 'Nom inconnu';
      } catch (e) {
        debugPrint('Erreur lors de la récupération du nom du client: $e');
        return 'Nom inconnu';
      }
    }
    return 'Nom inconnu';
  }

  String _formatDate(dynamic dateTimestamp) {
    if (dateTimestamp == null) return 'Non spécifié';
    final date = DateTime.fromMillisecondsSinceEpoch(
      int.parse(dateTimestamp.toString()) * 1000,
    );
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _refClientController.dispose();
    _dateCommandeController.dispose();
    _dateLivraisonController.dispose();
    _totalTTCController.dispose();
    _condReglementController.dispose();
    _modeLivraisonController.dispose();
    _clientNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Modifier la Commande',
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
            icon: const Icon(Icons.save, size: 24),
            onPressed: _saveCommand,
            tooltip: 'Enregistrer les modifications',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'Informations Générales'),
              const SizedBox(height: 15),
              _buildEditableInfoCard(context),
              const SizedBox(height: 30),

              _buildSectionHeader(context, 'Dates Importantes'),
              const SizedBox(height: 15),
              _buildEditableDatesCard(context),
              const SizedBox(height: 30),

              _buildSectionHeader(context, 'Paiement & Logistique'),
              const SizedBox(height: 15),
              _buildPaymentAndLogisticsCard(context),
              const SizedBox(height: 30),

              _buildSectionHeader(context, 'Détails du Client'),
              const SizedBox(height: 15),
              _buildClientDetailsCard(context),
              const SizedBox(height: 30),

              _buildSectionHeader(context, 'Lignes de Commande'),
              const SizedBox(height: 15),
              _buildEditableOrderLinesCard(),
              const SizedBox(height: 30),
            ],
          ),
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

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
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

  Widget _buildEditableInfoCard(BuildContext context) {
    return _buildCard(
      context,
      children: [
        _buildEditableTextRow(
          context,
          label: 'Référence Client',
          controller: _refClientController,
          icon: Icons.receipt_long,
        ),
        const Divider(height: 1, color: AppColors.neutralGrey200),
        _buildEditableTextRow(
          context,
          label: 'Montant Total',
          controller: _totalTTCController,
          icon: Icons.attach_money,
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildEditableDatesCard(BuildContext context) {
    return _buildCard(
      context,
      children: [
        _buildEditableTextRow(
          context,
          label: 'Date de la commande',
          controller: _dateCommandeController,
          icon: Icons.calendar_today_outlined,
          readOnly: true,
        ),
        const Divider(height: 1, color: AppColors.neutralGrey200),
        _buildEditableTextRow(
          context,
          label: 'Date de Livraison',
          controller: _dateLivraisonController,
          icon: Icons.event_note,
          readOnly: true,
          onTap: () => _pickDate(context, _dateLivraisonController),
        ),
      ],
    );
  }

  Widget _buildPaymentAndLogisticsCard(BuildContext context) {
    return _buildCard(
      context,
      children: [
        _buildEditableTextRow(
          context,
          label: 'Conditions de Paiement',
          controller: _condReglementController,
          icon: Icons.payment,
        ),
        const Divider(height: 1, color: AppColors.neutralGrey200),
        _buildEditableTextRow(
          context,
          label: 'Mode de Livraison',
          controller: _modeLivraisonController,
          icon: Icons.local_shipping,
        ),
      ],
    );
  }

  Widget _buildClientDetailsCard(BuildContext context) {
    return _buildCard(
      context,
      children: [
        _buildEditableTextRow(
          context,
          label: 'Nom du Client',
          controller: _clientNameController,
          icon: Icons.person_outline,
          readOnly: true,
        ),
      ],
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? initialDate;
    try {
      if (controller.text.isNotEmpty && controller.text != 'Non spécifié') {
        List<String> parts = controller.text.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Widget _buildEditableTextRow(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.primaryIndigo),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.neutralGrey700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableOrderLinesCard() {
    return _buildCard(
      context,
      children: [
        if (_orderLines.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Aucune ligne de commande. Vous pouvez en ajouter une.',
              textAlign: TextAlign.center,
            ),
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _orderLines.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: AppColors.neutralGrey200),
          itemBuilder: (context, index) {
            final line = _orderLines[index];
            return _buildEditableOrderLineItem(line, index);
          },
        ),
        TextButton.icon(
          onPressed: _addNewOrderLine,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une ligne'),
        ),
      ],
    );
  }

  Widget _buildEditableOrderLineItem(Map<String, dynamic> line, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: line['description'] ?? '',
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    _orderLines[index]['description'] = value;
                  },
                ),
                TextFormField(
                  initialValue: (line['qty'] ?? 0).toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantité'),
                  onChanged: (value) {
                    _orderLines[index]['qty'] = int.tryParse(value) ?? 0;
                  },
                ),
                TextFormField(
                  initialValue: (line['subprice'] ?? 0.0).toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Prix'),
                  onChanged: (value) {
                    _orderLines[index]['subprice'] =
                        double.tryParse(value) ?? 0.0;
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: AppColors.accentRed),
            onPressed: () => _removeOrderLine(index),
          ),
        ],
      ),
    );
  }

  void _addNewOrderLine() {
    setState(() {
      _orderLines.add({'description': '', 'qty': 0, 'subprice': 0.0});
    });
  }

  void _removeOrderLine(int index) {
    setState(() {
      _orderLines.removeAt(index);
    });
  }

  Future<void> _saveCommand() async {
    if (_formKey.currentState!.validate()) {
      try {
        int? dateLivraisonTimestamp;
        if (_dateLivraisonController.text.isNotEmpty &&
            _dateLivraisonController.text != 'Non spécifié') {
          List<String> parts = _dateLivraisonController.text.split('/');
          if (parts.length == 3) {
            final date = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            dateLivraisonTimestamp = date.millisecondsSinceEpoch ~/ 1000;
          }
        }

        final updatedData = {
          'ref_client': _refClientController.text,
          'date_livraison': dateLivraisonTimestamp,
          'cond_reglement_code': _condReglementController.text,
          'mode_reglement_code': _modeLivraisonController.text,
          'lines': _orderLines,
        };

        // --- NOUVEAU DÉBOGAGE DÉTAILLÉ ---
        debugPrint('--- Débogage des champs avant envoi ---');
        debugPrint(
          'Valeur du champ "Date de Livraison" : ${_dateLivraisonController.text}',
        );
        debugPrint('Timestamp converti : $dateLivraisonTimestamp');
        debugPrint('Référence client : ${_refClientController.text}');
        debugPrint(
          'Conditions de règlement : ${_condReglementController.text}',
        );
        debugPrint('Mode de livraison : ${_modeLivraisonController.text}');
        debugPrint('--- Fin du débogage détaillé ---');
        debugPrint('Données complètes envoyées à l\'API :');
        debugPrint(updatedData.toString());
        // ---------------------------------

        // Utilisez la méthode existante 'updateClientCommand'
        await widget.apiService.updateClientCommand(
          orderId: int.parse(widget.command['id'].toString()),
          updatedData: updatedData,
          initialLines: _initialOrderLines,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande mise à jour avec succès !')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        debugPrint('Erreur lors de la mise à jour: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }
}
