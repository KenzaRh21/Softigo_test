import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/ticket_model.dart'; // Make sure to import Ticket model
import '../utils/app_styles.dart'; // Make sure this path is correct

class EditTicketPage extends StatefulWidget {
  final Ticket ticket; // The ticket to be edited

  const EditTicketPage({Key? key, required this.ticket}) : super(key: key);

  @override
  State<EditTicketPage> createState() => _EditTicketPageState();
}

class _EditTicketPageState extends State<EditTicketPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields, initialized with existing ticket data
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;
  late TextEditingController _contactAddressController;

  // Selected values for dropdowns, initialized with existing ticket data
  late String _selectedRequestType;
  late String _selectedSeverity;
  late String _selectedAssignedTo;
  String? _selectedThirdParty;

  // For file attachment
  String? _selectedFileName;
  String? _selectedFilePath;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.ticket.subject);
    _descriptionController = TextEditingController(
      text: widget.ticket.description,
    );
    _contactAddressController = TextEditingController(
      text: widget.ticket.contactAddress,
    );

    _selectedRequestType = widget.ticket.requestType;
    _selectedSeverity = widget.ticket.severity;
    _selectedAssignedTo = widget.ticket.assignedTo;
    _selectedThirdParty = widget.ticket.thirdParty;

    // If there was an attached file in the original ticket, you'd initialize
    // _selectedFileName and _selectedFilePath here if you store them in Ticket model.
    // For now, assuming attachments are not part of the initial Ticket model for simplicity.
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _contactAddressController.dispose();
    super.dispose();
  }

  // --- File Picker Logic (similar to NewTicketPage) ---
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.first.name;
        _selectedFilePath = result.files.first.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fichier sélectionné : $_selectedFileName')),
      );
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélection de fichier annulée.')),
      );
    }
  }

  // --- Save Ticket Logic ---
  void _saveTicket() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create an updated Ticket object
      final updatedTicket = Ticket(
        id: widget.ticket.id, // Keep original ID
        subject: _subjectController.text,
        description: _descriptionController.text,
        requestType: _selectedRequestType,
        severity: _selectedSeverity,
        assignedTo: _selectedAssignedTo,
        status: widget
            .ticket
            .status, // Status might be changed elsewhere, or in a separate action
        creationDate: widget.ticket.creationDate, // Keep original creation date
        thirdParty: _selectedThirdParty,
        contactAddress: _contactAddressController.text.isEmpty
            ? null
            : _contactAddressController.text,
        // attachmentPath: _selectedFilePath, // If you add this to Ticket model
      );

      // Return the updated ticket to the previous page (TicketDetailPage)
      Navigator.pop(context, updatedTicket);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Modifier le Ticket',
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
              // Ticket ID Display
              _buildInfoDisplay(
                context,
                'ID du Ticket',
                widget.ticket.id,
                Icons.tag,
                AppColors.primaryIndigo,
              ),
              const SizedBox(height: 16),

              // Subject
              _buildSectionHeader(context, 'Sujet du Ticket'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _subjectController,
                decoration: _buildInputDecoration('Sujet du ticket'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le sujet du ticket.';
                  }
                  return null;
                },
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
              ),
              const SizedBox(height: 16),

              // Description
              _buildSectionHeader(context, 'Description du Ticket'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration('Description détaillée'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description.';
                  }
                  return null;
                },
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
              ),
              const SizedBox(height: 16),

              // Request Type Dropdown
              _buildSectionHeader(context, 'Type de Demande'),
              const SizedBox(height: 10),
              _buildDropdownField(
                context,
                _selectedRequestType,
                [
                  'Support',
                  'Demande',
                  'Incident',
                  'Problème',
                  'Changement',
                  'Autre',
                ],
                (String? newValue) {
                  setState(() {
                    _selectedRequestType = newValue!;
                  });
                },
                'Type de demande',
                Icons.category_outlined,
              ),
              const SizedBox(height: 16),

              // Severity Dropdown
              _buildSectionHeader(context, 'Sévérité'),
              const SizedBox(height: 10),
              _buildDropdownField(
                context,
                _selectedSeverity,
                ['Faible', 'Normal', 'Urgent', 'Bloquant'],
                (String? newValue) {
                  setState(() {
                    _selectedSeverity = newValue!;
                  });
                },
                'Niveau de sévérité',
                Icons.error_outline,
              ),
              const SizedBox(height: 16),

              // Assigned To Dropdown
              _buildSectionHeader(context, 'Assigné à'),
              const SizedBox(height: 10),
              _buildDropdownField(
                context,
                _selectedAssignedTo,
                ['Taha Dev', 'Amina Tech', 'Omar Sales', 'Non assigné'],
                (String? newValue) {
                  setState(() {
                    _selectedAssignedTo = newValue!;
                  });
                },
                'Assigné à',
                Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Third Party (Optional)
              _buildSectionHeader(context, 'Tiers (Optionnel)'),
              const SizedBox(height: 10),
              _buildDropdownField(
                context,
                _selectedThirdParty,
                ['Tiers A', 'Tiers B', 'Tiers C', 'Aucun'],
                (String? newValue) {
                  setState(() {
                    _selectedThirdParty = newValue == 'Aucun' ? null : newValue;
                  });
                },
                'Sélectionner un tiers',
                Icons.business_outlined,
                canBeNull: true,
              ),
              const SizedBox(height: 16),

              // Contact Address (Optional)
              _buildSectionHeader(context, 'Adresse de Contact (Optionnel)'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactAddressController,
                decoration: _buildInputDecoration(
                  'Email ou numéro de téléphone',
                ),
                keyboardType: TextInputType.emailAddress,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
              ),
              const SizedBox(height: 16),

              // File Attachment Section (Copy from NewTicketPage)
              _buildSectionHeader(context, 'Joindre un fichier (Optionnel)'),
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                    if (_selectedFileName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Fichier "${_selectedFileName!}" joint.',
                                  ),
                                ),
                              );
                              print(
                                'Attempting to "join" file from path: $_selectedFilePath',
                              );
                              // This is where you'd handle the actual file upload
                              // You might want to clear the selected file after "joining" it.
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: AppColors.neutralWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text(
                              'JOINDRE CE FICHIER',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    foregroundColor: AppColors.neutralWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.save),
                  label: Text(
                    'Enregistrer les Modifications',
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

  // --- Helper Widgets (from NewTicketPage, adapted) ---
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

  Widget _buildDropdownField(
    BuildContext context,
    String? currentValue,
    List<String> items,
    void Function(String?) onChanged,
    String hintText,
    IconData icon, {
    bool canBeNull = false,
  }) {
    List<String> effectiveItems = List.from(items); // Create a mutable copy

    if (canBeNull && !effectiveItems.contains('Aucun')) {
      effectiveItems.insert(
        0,
        'Aucun',
      ); // Add 'Aucun' only if it's not already there and canBeNull is true
    }

    String? displayValue = currentValue;
    if (canBeNull && currentValue == null) {
      displayValue =
          'Aucun'; // Display 'Aucun' if the value is null and it's allowed
    } else if (!effectiveItems.contains(currentValue) && !canBeNull) {
      // Fallback: If currentValue isn't in the list and nulls aren't allowed, default to the first item
      displayValue = effectiveItems.first;
    }

    return DropdownButtonFormField<String>(
      value: displayValue,
      onChanged: onChanged,
      decoration: _buildInputDecoration(hintText, icon: icon),
      items: effectiveItems.map((String value) {
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
      validator: (value) {
        if (!canBeNull &&
            (value == null || value.isEmpty || value == 'Aucun')) {
          return 'Veuillez sélectionner une option.';
        }
        return null;
      },
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
