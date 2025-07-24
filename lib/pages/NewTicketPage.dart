import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Importez le package file_picker
import '../utils/app_styles.dart';

class NewTicketPage extends StatefulWidget {
  const NewTicketPage({Key? key}) : super(key: key);

  @override
  State<NewTicketPage> createState() => _NewTicketPageState();
}

class _NewTicketPageState extends State<NewTicketPage> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Dropdown values (pre-filled with example data)
  String? _selectedRequestType = 'Autre';
  String? _selectedTicketGroup = 'Autre';
  String? _selectedSeverity = 'Normal';
  String? _selectedThirdParty; // For 'Tiers'
  String? _selectedContactAddress; // For 'Contact/Adresse'
  String? _assignedTo = 'Taha Dev';
  String? _selectedProject;
  String? _selectedContract;

  bool _notifyThirdParty = false;
  String? _selectedFileName; // To display chosen file name
  // You might also want to store the actual file path for uploading
  String? _selectedFilePath;

  // Example lists for dropdowns
  final List<String> _requestTypes = ['Autre', 'Support', 'Demande'];
  final List<String> _ticketGroups = ['Autre', 'Technique', 'Commercial'];
  final List<String> _severities = ['Normal', 'Urgent', 'Bloquant'];
  final List<String> _thirdParties = [
    'Tiers A',
    'Tiers B',
    'Tiers C',
  ]; // Replace with actual data
  final List<String> _contacts = []; // Populated based on _selectedThirdParty
  final List<String> _assignedToList = ['Taha Dev', 'Amina Tech', 'Omar Sales'];
  final List<String> _projects = [
    'Projet Alpha',
    'Projet Beta',
    'Projet Gamma',
  ];
  final List<String> _contracts = ['Contrat X', 'Contrat Y', 'Contrat Z'];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _createTicket() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Logic to save the ticket data
      // You can access _selectedFileName and _selectedFilePath here for the attachment
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ticket créé avec succès!')));
      // You can then navigate back or to a detail page
      Navigator.pop(context);
    }
  }

  void _cancelTicket() {
    // Logic to handle cancellation, e.g., pop the current page
    Navigator.pop(context);
  }

  // Modified _pickFile to use file_picker
  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // You can specify .image, .video, .audio, or .any
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'doc',
        'docx',
        'xlsx',
      ], // Example extensions
    );

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFilePath = result.files.single.path; // Store the file path
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fichier "${_selectedFileName!}" sélectionné.')),
      );
      print('Selected file path: $_selectedFilePath'); // For debugging
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélection de fichier annulée.')),
      );
      setState(() {
        _selectedFileName = null; // Clear selected file if canceled
        _selectedFilePath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Nouveau ticket',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Référence du Ticket (Read-only, generated)
              _buildInfoRow(
                context,
                'Réf.',
                'TS2507-0001',
                icon: Icons.qr_code_outlined,
              ),
              const SizedBox(height: 16.0),

              // Type de demande
              _buildDropdownField(
                context,
                'Type de demande',
                Icons.notes_outlined,
                _selectedRequestType,
                _requestTypes,
                (newValue) {
                  setState(() {
                    _selectedRequestType = newValue;
                  });
                },
                isRequired: true,
              ),
              const SizedBox(height: 16.0),

              // Groupe du ticket
              _buildDropdownField(
                context,
                'Groupe du ticket',
                Icons.group_work_outlined,
                _selectedTicketGroup,
                _ticketGroups,
                (newValue) {
                  setState(() {
                    _selectedTicketGroup = newValue;
                  });
                },
                isRequired: true,
              ),
              const SizedBox(height: 16.0),

              // Sévérité
              _buildDropdownField(
                context,
                'Sévérité',
                Icons.crisis_alert_outlined,
                _selectedSeverity,
                _severities,
                (newValue) {
                  setState(() {
                    _selectedSeverity = newValue;
                  });
                },
                isRequired: true,
              ),
              const SizedBox(height: 16.0),

              // Sujet
              _buildTextField(
                context,
                _subjectController,
                Icons.subject,
                'Sujet',
                isRequired: true,
                hintText: 'Ex: Problème de connexion à l\'ERP',
              ),
              const SizedBox(height: 16.0),

              // Message
              _buildTextField(
                context,
                _messageController,
                Icons.message_outlined,
                'Message',
                maxLines: 5,
                minLines: 3,
                hintText: 'Décrivez le problème ou la demande en détail...',
              ),
              const SizedBox(height: 24.0),

              // Section de Téléchargement de Fichier
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
                  // Changement ici : Utilisez une colonne pour empiler les éléments
                  children: [
                    Row(
                      // Gardez le bouton de sélection et le nom du fichier sur la même ligne
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            // Utilisez OutlinedButton.icon pour une icône
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
                            icon: const Icon(
                              Icons.attach_file,
                            ), // Icône pour attacher un fichier
                            label: const Text('Choisir un fichier'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _selectedFileName ?? 'Aucun fichier choisi',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _selectedFileName != null
                                  ? AppColors.primaryText
                                  : AppColors
                                        .neutralGrey600, // Couleur différente si aucun fichier
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedFileName !=
                        null) // Afficher le bouton "JOINDRE" seulement si un fichier est sélectionné
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 16.0,
                        ), // Marge au-dessus du bouton
                        child: SizedBox(
                          // Utiliser SizedBox pour contrôler la largeur du bouton
                          width:
                              double.infinity, // Bouton prend toute la largeur
                          child: ElevatedButton.icon(
                            // Utiliser ElevatedButton.icon
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
                              // Optionnel: Réinitialiser après avoir joint pour permettre de joindre un nouveau fichier
                              // setState(() {
                              //   _selectedFileName = null;
                              //   _selectedFilePath = null;
                              // });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: AppColors.neutralWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(
                              Icons.cloud_upload_outlined,
                            ), // Icône d'upload
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
              const SizedBox(height: 24.0),

              // Tiers
              _buildDropdownField(
                context,
                'Tiers',
                Icons.business_outlined,
                _selectedThirdParty,
                _thirdParties,
                (newValue) {
                  setState(() {
                    _selectedThirdParty = newValue;
                    _selectedContactAddress =
                        null; // Reset contact when third party changes
                    // In a real app, you'd fetch contacts for the selected third party here
                    _contacts.clear();
                    if (newValue == 'Tiers A')
                      _contacts.addAll(['Contact A1', 'Contact A2']);
                    if (newValue == 'Tiers B')
                      _contacts.addAll(['Contact B1', 'Contact B2']);
                    // etc.
                  });
                },
                isRequired: true,
              ),
              const SizedBox(height: 16.0),

              // Contact/Adresse (No 'Contributeur externe' suffix)
              _buildDropdownField(
                context,
                'Contact/Adresse',
                Icons.person_outline,
                _selectedContactAddress,
                _contacts, // Will be empty until a third party is selected
                (newValue) {
                  setState(() {
                    _selectedContactAddress = newValue;
                  });
                },
                // Disable if no third party selected
                enabled: _selectedThirdParty != null && _contacts.isNotEmpty,
                hintText: 'Sélectionnez d\'abord un tiers...',
              ),
              const SizedBox(height: 16.0),

              // Notifier le tiers à la création
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _notifyThirdParty,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _notifyThirdParty = newValue ?? false;
                        });
                      },
                      activeColor: AppColors.primaryIndigo,
                    ),
                    Text(
                      'Notifier le tiers à la création',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // Assigné à
              _buildDropdownField(
                context,
                'Assigné à',
                Icons.assignment_ind_outlined,
                _assignedTo,
                _assignedToList,
                (newValue) {
                  setState(() {
                    _assignedTo = newValue;
                  });
                },
                isRequired: true,
              ),
              const SizedBox(height: 16.0),

              // Projet
              _buildDropdownField(
                context,
                'Projet',
                Icons.folder_open_outlined,
                _selectedProject,
                _projects,
                (newValue) {
                  setState(() {
                    _selectedProject = newValue;
                  });
                },
                isRequired: false,
              ),
              const SizedBox(height: 16.0),

              // Contrat
              _buildDropdownField(
                context,
                'Contrat',
                Icons.sticky_note_2_outlined,
                _selectedContract,
                _contracts,
                (newValue) {
                  setState(() {
                    _selectedContract = newValue;
                  });
                },
                isRequired: false,
              ),
              const SizedBox(height: 32.0),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _createTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.neutralWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text(
                        'CRÉER TICKET',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cancelTicket,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
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
      ),
    );
  }

  // --- Helper Widgets ---

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
            width: 100, // Fixed width for label
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

  Widget _buildDropdownField(
    BuildContext context,
    String label,
    IconData icon,
    String? currentValue,
    List<String> items,
    void Function(String?) onChanged, {
    bool isRequired = false,
    bool enabled = true,
    String? hintText,
    // Removed suffixWidget parameter as "Contributeur externe" is gone
  }) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      onChanged: enabled ? onChanged : null, // Disable if not enabled
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryIndigo),
        // Removed suffixIcon as it's no longer needed
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
        fillColor: enabled
            ? AppColors.inputBackground
            : AppColors.inputBackground.withOpacity(
                0.5,
              ), // Lighter background if disabled
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        hintText: hintText,
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
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            }
          : null,
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
}
