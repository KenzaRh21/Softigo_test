import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour le formatage de la date
import 'package:softigotest/models/leave_request_model.dart';
import '../utils/app_styles.dart'; // Assurez-vous que ce chemin est correct

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();

  // Valeurs sélectionnées pour les dropdowns et dates
  LeaveType _selectedLeaveType = LeaveType.paid; // Valeur par défaut
  DateTime? _startDate;
  DateTime? _endDate;
  int? _numberOfDays; // Calculé ou entré si besoin

  @override
  void dispose() {
    _reasonController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  // --- Sélecteur de date ---
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2), // 2 ans dans le futur
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  AppColors.primaryIndigo, // Couleur des en-têtes et boutons
              onPrimary: AppColors
                  .neutralWhite, // Couleur du texte sur la couleur primaire
              onSurface: AppColors.primaryText, // Couleur du texte général
            ), dialogTheme: DialogThemeData(backgroundColor: AppColors.neutralWhite),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Assurer que la date de fin n'est pas avant la date de début
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // Assurer que la date de début n'est pas après la date de fin
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
        _calculateNumberOfDays(); // Recalculer le nombre de jours
      });
    }
  }

  // --- Calcul du nombre de jours de congé ---
  void _calculateNumberOfDays() {
    if (_startDate != null && _endDate != null) {
      // Calcule la différence en jours. +1 pour inclure la date de fin.
      _numberOfDays = _endDate!.difference(_startDate!).inDays + 1;
    } else {
      _numberOfDays = null;
    }
  }

  // --- Soumettre la demande de congé ---
  void _submitLeaveRequest() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ici, vous enverriez les données à votre backend ou les traiteriez
      print('Demande de congé soumise :');
      print('Type de congé: ${_selectedLeaveType.toDisplayString()}');
      print(
        'Date de début: ${_startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'N/A'}',
      );
      print(
        'Date de fin: ${_endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'N/A'}',
      );
      print('Nombre de jours: $_numberOfDays');
      print('Raison: ${_reasonController.text}');
      print('Infos contact: ${_contactInfoController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande de congé soumise avec succès!')),
      );
      Navigator.pop(context); // Revenir à la page précédente
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Demande de Congé',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type de Congé
              _buildSectionHeader(context, 'Type de Congé'),
              const SizedBox(height: 10),
              _buildDropdownField<LeaveType>(
                context,
                _selectedLeaveType,
                LeaveType.values,
                (LeaveType? newValue) {
                  setState(() {
                    _selectedLeaveType = newValue!;
                  });
                },
                'Sélectionnez le type de congé',
                Icons.beach_access_outlined,
                itemBuilder: (type) => type.toDisplayString(),
              ),
              const SizedBox(height: 16),

              // Dates de congé
              _buildSectionHeader(context, 'Période de Congé'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      context,
                      'Date de Début',
                      _startDate,
                      (date) => _selectDate(context, true),
                      Icons.calendar_month_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      context,
                      'Date de Fin',
                      _endDate,
                      (date) => _selectDate(context, false),
                      Icons.calendar_month_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nombre de jours calculé (affichage seulement)
              if (_numberOfDays != null && _numberOfDays! > 0)
                _buildInfoDisplay(
                  context,
                  'Nombre de Jours',
                  '$_numberOfDays jours',
                  Icons.calendar_today,
                  AppColors.primaryIndigo,
                ),
              const SizedBox(height: 16),

              // Raison du congé
              _buildSectionHeader(context, 'Raison du Congé'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonController,
                decoration: _buildInputDecoration(
                  'Décrivez la raison de votre congé',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez décrire la raison de votre congé.';
                  }
                  return null;
                },
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
              ),
              const SizedBox(height: 16),

              // Informations de contact pendant le congé (optionnel)
              _buildSectionHeader(
                context,
                'Informations de Contact (Optionnel)',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactInfoController,
                decoration: _buildInputDecoration(
                  'Numéro de téléphone ou email en cas d\'urgence',
                ),
                keyboardType: TextInputType.text,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
              ),
              const SizedBox(height: 24),

              // Bouton Soumettre
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitLeaveRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    foregroundColor: AppColors.neutralWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.send),
                  label: Text(
                    'Soumettre la Demande',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.w600,
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

  // --- Helper Widgets (réutilisés et adaptés des pages de ticket) ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText, {IconData? icon}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.primaryIndigo)
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
        borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
      ),
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  Widget _buildDropdownField<T>(
    BuildContext context,
    T? currentValue,
    List<T> items,
    void Function(T?) onChanged,
    String hintText,
    IconData icon, {
    String Function(T)?
    itemBuilder, // Pour convertir l'enum en String affichable
    bool canBeNull = false,
  }) {
    // Si canBeNull est vrai et qu'il n'y a pas d'itemBuilder spécifié,
    // on suppose que T est String et on peut ajouter 'Aucun'.
    // Pour les Enums, l'itemBuilder est nécessaire pour la conversion.
    List<DropdownMenuItem<T>> dropdownItems = items.map((value) {
      return DropdownMenuItem<T>(
        value: value,
        child: Text(
          itemBuilder != null ? itemBuilder(value) : value.toString(),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
        ),
      );
    }).toList();

    // Gestion de la valeur par défaut si canBeNull est vrai et currentValue est null
    T? displayValue = currentValue;
    if (canBeNull && currentValue == null && items.isNotEmpty) {
      // Si "Aucun" n'est pas un membre de l'enum, vous ne pouvez pas le définir comme valeur directe
      // Dans ce cas, il faut gérer le 'hintText' du DropdownButtonFormField
    }

    return DropdownButtonFormField<T>(
      initialValue: displayValue,
      onChanged: onChanged,
      decoration: _buildInputDecoration(hintText, icon: icon),
      items: dropdownItems,
      validator: (value) {
        if (!canBeNull && value == null) {
          return 'Veuillez sélectionner une option.';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? date,
    Function(DateTime?) onTap,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => onTap(date),
      child: InputDecorator(
        decoration: _buildInputDecoration(label, icon: icon).copyWith(
          labelText: label,
          labelStyle: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.neutralGrey700),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        child: Text(
          date != null
              ? DateFormat('dd/MM/yyyy').format(date)
              : 'Sélectionner une date',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: date != null
                ? AppColors.primaryText
                : AppColors.neutralGrey600,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoDisplay(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralGrey400),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.neutralGrey700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
