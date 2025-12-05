import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_styles.dart';
import '../models/quote_model.dart';

class AddEditQuotePage extends StatefulWidget {
  final Quote? quote;

  const AddEditQuotePage({super.key, this.quote});

  @override
  State<AddEditQuotePage> createState() => _AddEditQuotePageState();
}

class _AddEditQuotePageState extends State<AddEditQuotePage> {
  final _formKey = GlobalKey<FormState>();

  late String? _selectedClientName;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _proposalDateController;
  late TextEditingController _validityDurationController;
  late QuoteStatus _selectedStatus;

  final List<String> _dummyClientNames = [
    'Alpha Corp',
    'Beta Solutions',
    'Gamma Industries',
    'Delta Innovations',
    'Epsilon Tech',
    'Zeta Solutions', // Assurez-vous que cette liste est cohérente avec QuoteListPage
  ];

  @override
  void initState() {
    super.initState();
    if (widget.quote != null) {
      // FIX POUR L'ERREUR D'ASSERTION DU DROPDOWN :
      // S'assurer que le clientName du devis existant est parmi les options _dummyClientNames.
      // Si ce n'est pas le cas, le définir sur null pour que le hint soit affiché.
      if (_dummyClientNames.contains(widget.quote!.clientName)) {
        _selectedClientName = widget.quote!.clientName;
      } else {
        _selectedClientName =
            null; // Important: Si la valeur n'existe pas, la mettre à null
        // Optionnel: Afficher un message d'avertissement à l'utilisateur ou logguer
        debugPrint(
          'AVERTISSEMENT: Le client "${widget.quote!.clientName}" n\'existe pas dans la liste des clients disponibles.',
        );
      }

      _descriptionController = TextEditingController(
        text: widget.quote!.description,
      );
      _amountController = TextEditingController(
        text: widget.quote!.amount.toString(),
      );
      _proposalDateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(widget.quote!.proposalDate),
      );
      _validityDurationController = TextEditingController(
        text: widget.quote!.validityDurationDays.toString(),
      );
      _selectedStatus = widget.quote!.status;
    } else {
      _selectedClientName =
          null; // Un nouveau devis commence sans client sélectionné
      _descriptionController = TextEditingController();
      _amountController = TextEditingController();
      _proposalDateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      );
      _validityDurationController = TextEditingController(text: '30');
      _selectedStatus = QuoteStatus.draft;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _proposalDateController.dispose();
    _validityDurationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _proposalDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _saveQuote() {
    if (_formKey.currentState!.validate()) {
      // La validation du client se fait maintenant dans le validator du Dropdown,
      // mais on ajoute une vérification finale ici aussi si le statut n'est pas brouillon.
      if ((_selectedClientName == null || _selectedClientName!.isEmpty) &&
          _selectedStatus != QuoteStatus.draft) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez sélectionner un client pour un devis non-brouillon.',
            ),
          ),
        );
        return;
      }

      final String newId =
          widget.quote?.id ?? 'Q${DateTime.now().millisecondsSinceEpoch}';
      final newAmount = double.parse(_amountController.text);
      final newProposalDate = DateFormat(
        'dd/MM/yyyy',
      ).parse(_proposalDateController.text);
      final newValidityDuration = int.parse(_validityDurationController.text);

      final savedQuote = Quote(
        id: newId,
        clientName:
            _selectedClientName ??
            'Client Inconnu (Brouillon)', // Valeur par défaut si null
        description: _descriptionController.text,
        amount: newAmount,
        proposalDate: newProposalDate,
        validityDurationDays: newValidityDuration,
        status: _selectedStatus,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.quote == null
                ? 'Devis "${savedQuote.id}" créé !'
                : 'Devis "${savedQuote.id}" mis à jour !',
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );

      Navigator.pop(context, savedQuote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          widget.quote == null
              ? 'Créer un Devis'
              : 'Modifier Devis: ${widget.quote!.id}',
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
            icon: const Icon(Icons.save),
            onPressed: _saveQuote,
            tooltip: 'Enregistrer le devis',
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
              _buildSectionHeader(context, 'Informations du Devis'),
              const SizedBox(height: 16),

              _buildClientDropdown(context),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _descriptionController,
                labelText: 'Description du Devis',
                hintText:
                    'Ex: Développement application mobile, Maintenance annuelle',
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La description ne peut pas être vide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _amountController,
                labelText: 'Montant (€)',
                hintText: 'Ex: 15000.00',
                icon: Icons.euro,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le montant ne peut pas être vide';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Entrez un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildDateField(context),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _validityDurationController,
                labelText: 'Durée de Validité (jours)',
                hintText: 'Ex: 30',
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La durée de validité ne peut pas être vide';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Entrez un nombre de jours valide (> 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              _buildSectionHeader(context, 'Statut du Devis'),
              const SizedBox(height: 16),

              _buildStatusDropdown(context),
              const SizedBox(height: 32),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveQuote,
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.quote == null
                        ? 'Créer le Devis'
                        : 'Mettre à Jour le Devis',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    foregroundColor: AppColors.neutralWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets d'aide ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.primaryIndigo)
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
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildClientDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      // La valeur doit être null si rien n'est sélectionné, sinon elle doit être dans les items.
      initialValue: _selectedClientName,
      hint: Text(
        'Sélectionner un client',
        style: TextStyle(color: AppColors.neutralGrey600),
      ),
      onChanged: (String? newValue) {
        setState(() {
          _selectedClientName = newValue;
        });
      },
      decoration: InputDecoration(
        labelText: 'Client',
        prefixIcon: Icon(
          Icons.business_center_outlined,
          color: AppColors.primaryIndigo,
        ),
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
      items: _dummyClientNames.map((String clientName) {
        return DropdownMenuItem<String>(
          value: clientName,
          child: Text(
            clientName,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
          ),
        );
      }).toList(),
      validator: (value) {
        // Le client est obligatoire sauf si le devis est un brouillon
        if ((value == null || value.isEmpty) &&
            _selectedStatus != QuoteStatus.draft) {
          return 'Veuillez sélectionner un client';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: _proposalDateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date de Proposition',
        prefixIcon: Icon(
          Icons.calendar_month_outlined,
          color: AppColors.primaryIndigo,
        ),
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
        suffixIcon: IconButton(
          icon: Icon(
            Icons.edit_calendar_outlined,
            color: AppColors.primaryIndigo,
          ),
          onPressed: () => _selectDate(context),
        ),
      ),
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'La date de proposition ne peut pas être vide';
        }
        try {
          DateFormat('dd/MM/yyyy').parse(value);
          return null;
        } catch (e) {
          return 'Format de date invalide (JJ/MM/AAAA)';
        }
      },
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    final List<QuoteStatus> availableStatuses = QuoteStatus.values;

    return DropdownButtonFormField<QuoteStatus>(
      initialValue: _selectedStatus,
      onChanged: (QuoteStatus? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedStatus = newValue;
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Statut du Devis',
        prefixIcon: Icon(Icons.info_outline, color: AppColors.primaryIndigo),
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
      items: availableStatuses.map((QuoteStatus status) {
        return DropdownMenuItem<QuoteStatus>(
          value: status,
          child: Text(
            status.toDisplayString(),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: status.toColor()),
          ),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner un statut';
        }
        return null;
      },
    );
  }
}
