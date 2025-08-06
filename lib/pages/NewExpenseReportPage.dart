import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../services/expense_report_api_service.dart';
import '../utils/app_styles.dart';

// Modèle de données pour une ligne de dépense
class ExpenseLine {
  String label;
  double priceUnitHT;
  double priceUnitTTC;
  double tvaRate;
  DateTime date;
  String type;
  int qty;
  double totalHT;
  double totalTTC;

  ExpenseLine({
    required this.label,
    required this.priceUnitHT,
    required this.priceUnitTTC,
    required this.tvaRate,
    required this.date,
    required this.type,
    this.qty = 1,
  }) : totalHT = priceUnitHT * qty,
       totalTTC = priceUnitTTC * qty;

  Map<String, dynamic> toApiJson() {
    return {
      'comments': label,
      'description': label,
      'qty': qty,
      'vatrate': tvaRate,
      'value_unit_ht': priceUnitHT,
      'value_unit': priceUnitTTC,
      'total_ht': totalHT,
      'total_ttc': totalTTC,
      'date': date.millisecondsSinceEpoch ~/ 1000,
      'fk_c_type_fees': _getExpenseTypeId(type),
    };
  }

  int _getExpenseTypeId(String type) {
    switch (type) {
      case 'Repas':
        return 3;
      case 'Transport':
        return 2;
      case 'Frais kilométriques':
        return 4;
      case 'Autre':
        return 1;
      default:
        return 1;
    }
  }
}

class NewExpenseReportPage extends StatefulWidget {
  const NewExpenseReportPage({Key? key}) : super(key: key);

  @override
  State<NewExpenseReportPage> createState() => _NewExpenseReportPageState();
}

class _NewExpenseReportPageState extends State<NewExpenseReportPage> {
  final _formKey = GlobalKey<FormState>();
  final ExpenseReportApiService _apiService = ExpenseReportApiService(
    baseUrl: dotenv.env['API_BASE_URL']!,
    apiKey: dotenv.env['DOLIBARR_API_KEY']!,
  );

  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();

  String? _selectedFileName;
  String? _selectedFilePath;

  final List<ExpenseLine> _expenseLines = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addNewExpenseLine() async {
    final _lineFormKey = GlobalKey<FormState>();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(
      text: '1',
    );
    final TextEditingController labelController = TextEditingController();
    DateTime selectedLineDate = DateTime.now();
    String? selectedExpenseType;
    double? selectedTvaRate;

    final List<String> expenseTypes = [
      'Autre',
      'Transport',
      'Repas',
      'Frais kilométriques',
    ];
    final List<double> tvaRates = [0.0, 7.0, 10.0, 14.0, 20.0];

    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: const Text('Ajouter une ligne de dépense'),
              content: SingleChildScrollView(
                child: Form(
                  key: _lineFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: labelController,
                        decoration: const InputDecoration(labelText: 'Libellé'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ce champ est requis'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: amountController,
                        decoration: const InputDecoration(
                          labelText: 'Prix Unitaire TTC',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) =>
                            value == null || double.tryParse(value) == null
                            ? 'Veuillez entrer un montant valide'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantité',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || int.tryParse(value) == null
                            ? 'Veuillez entrer une quantité valide'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Type de dépense',
                        ),
                        value: selectedExpenseType,
                        items: expenseTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          dialogSetState(() {
                            selectedExpenseType = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Ce champ est requis' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<double>(
                        decoration: const InputDecoration(
                          labelText: 'Taux de TVA',
                        ),
                        value: selectedTvaRate,
                        items: tvaRates.map((double rate) {
                          return DropdownMenuItem<double>(
                            value: rate,
                            child: Text('$rate %'),
                          );
                        }).toList(),
                        onChanged: (double? newValue) {
                          dialogSetState(() {
                            selectedTvaRate = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Ce champ est requis' : null,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedLineDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            dialogSetState(() {
                              selectedLineDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date de la dépense',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(selectedLineDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ANNULER'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_lineFormKey.currentState!.validate()) {
                      final double priceUnitTTC =
                          double.tryParse(amountController.text) ?? 0.0;
                      final int quantity =
                          int.tryParse(quantityController.text) ?? 1;
                      final double tvaRate = selectedTvaRate!;

                      final double priceUnitHT =
                          priceUnitTTC / (1 + (tvaRate / 100));

                      final newLine = ExpenseLine(
                        label: labelController.text,
                        priceUnitHT: priceUnitHT,
                        priceUnitTTC: priceUnitTTC,
                        tvaRate: tvaRate,
                        date: selectedLineDate,
                        type: selectedExpenseType!,
                        qty: quantity,
                      );

                      Navigator.of(context).pop(newLine);
                    }
                  },
                  child: const Text('AJOUTER'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _expenseLines.add(result);
      });
    }
  }

  void _createExpenseReport() async {
    if (_formKey.currentState!.validate() && _expenseLines.isNotEmpty) {
      if (_selectedEndDate.isBefore(_selectedStartDate)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'La date de fin ne peut pas être antérieure à la date de début.',
              ),
            ),
          );
        }
        return;
      }

      final int startDateTimestamp =
          _selectedStartDate.millisecondsSinceEpoch ~/ 1000;
      final int endDateTimestamp =
          _selectedEndDate.millisecondsSinceEpoch ~/ 1000;
      final List<Map<String, dynamic>> apiExpenseLines = _expenseLines
          .map((line) => line.toApiJson())
          .toList();

      final expenseReportData = {
        'label': _labelController.text,
        'date': startDateTimestamp,
        'date_debut': startDateTimestamp,
        'date_fin': endDateTimestamp,
        'fk_user_author': 1,
        'note_public': _descriptionController.text,
        'note_private': _descriptionController.text,
        'lines': apiExpenseLines,
      };

      print('Données envoyées à l\'API : $expenseReportData');

      try {
        // Définir l'état de chargement
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        await _apiService.createExpenseReport(expenseReportData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note de frais créée avec succès!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la création de la note: $e'),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une ligne de dépense.'),
        ),
      );
    }
  }

  void _cancelExpenseReport() {
    Navigator.pop(context);
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFilePath = result.files.single.path;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fichier "${_selectedFileName!}" sélectionné.'),
          ),
        );
      }
    } else {
      setState(() {
        _selectedFileName = null;
        _selectedFilePath = null;
      });
    }
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final initialDate = isStartDate ? _selectedStartDate : _selectedEndDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
          if (_selectedEndDate.isBefore(_selectedStartDate)) {
            _selectedEndDate = _selectedStartDate;
          }
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Nouvelle note de frais',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: const IconThemeData(color: AppColors.appBarForeground),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context,
                    'Réf.',
                    'Générée automatiquement',
                    icon: Icons.qr_code_outlined,
                  ),
                  const SizedBox(height: 16.0),
                  _buildDateField(
                    context,
                    label: 'Date de début',
                    selectedDate: _selectedStartDate,
                    onTap: () => _selectDate(context, isStartDate: true),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDateField(
                    context,
                    label: 'Date de fin',
                    selectedDate: _selectedEndDate,
                    onTap: () => _selectDate(context, isStartDate: false),
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextField(
                    context,
                    _labelController,
                    Icons.label_outline,
                    'Libellé de la note',
                    isRequired: true,
                    hintText: 'Ex: Déplacement pour le projet X',
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextField(
                    context,
                    _descriptionController,
                    Icons.message_outlined,
                    'Description de la note',
                    maxLines: 5,
                    minLines: 3,
                    hintText: 'Ajoutez une description détaillée de la note...',
                  ),
                  const SizedBox(height: 24.0),
                  _buildSectionHeader(context, 'Lignes de dépense'),
                  const SizedBox(height: 10),
                  ..._expenseLines.asMap().entries.map((entry) {
                    int index = entry.key;
                    ExpenseLine line = entry.value;
                    return Dismissible(
                      key: Key(line.label + index.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          _expenseLines.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ligne "${line.label}" supprimée.'),
                          ),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(line.label),
                          subtitle: Text(
                            '${line.type} - ${line.qty} x ${line.priceUnitTTC.toStringAsFixed(2)} € (TVA: ${line.tvaRate}%)',
                          ),
                          trailing: Text(
                            'Total: ${line.totalTTC.toStringAsFixed(2)} €',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _addNewExpenseLine,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter une ligne'),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  _buildSectionHeader(context, 'Justificatif (Optionnel)'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.neutralWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.neutralGrey400),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickFile,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryIndigo,
                                  side: const BorderSide(
                                    color: AppColors.primaryIndigo,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                icon: const Icon(Icons.attach_file),
                                label: const Text('Choisir un fichier'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _selectedFileName ?? 'Aucun fichier choisi',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: _selectedFileName != null
                                          ? AppColors.primaryText
                                          : AppColors.neutralGrey600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _createExpenseReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.neutralWhite,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: Text(
                            _isLoading ? 'CRÉATION...' : 'CRÉER LA NOTE',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _cancelExpenseReport,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text(
                            'ANNULER',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.primaryIndigo, size: 24),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    IconData icon,
    String label, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int minLines = 1,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primaryIndigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutralGrey400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutralGrey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primaryIndigo,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
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
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              if (validator != null) {
                return validator(value);
              }
              return null;
            }
          : validator,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime selectedDate,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.primaryIndigo,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.neutralGrey400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.neutralGrey400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
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
        child: Text(
          DateFormat('dd/MM/yyyy').format(selectedDate),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
        ),
      ),
    );
  }
}
