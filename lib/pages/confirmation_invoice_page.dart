// lib/pages/confirmation_invoice_page.dart
import 'package:flutter/material.dart';
import 'package:softigotest/models/facture_model.dart';
import 'package:softigotest/utils/app_styles.dart';
import 'package:intl/intl.dart';

class ConfirmationInvoicePage extends StatefulWidget {
  final Facture facture;

  const ConfirmationInvoicePage({super.key, required this.facture});

  @override
  State<ConfirmationInvoicePage> createState() =>
      _ConfirmationInvoicePageState();
}

class _ConfirmationInvoicePageState extends State<ConfirmationInvoicePage> {
  final List<String> _invoiceSteps = [
    'Détails', // Étape 1
    'Articles', // Étape 2
    'Confirmation', // Étape 3
  ];
  int _currentStepIndex = 2; // Cette page est l'étape "Confirmation" (index 2)

  Widget _buildInvoiceStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_invoiceSteps.length, (index) {
          final isCompleted = index < _currentStepIndex;
          final isActive = index == _currentStepIndex;
          final isFuture = index > _currentStepIndex;

          Color circleColor = Colors.transparent;
          Color textColor = AppColors.primaryText.withOpacity(0.7);

          if (isActive) {
            circleColor = AppColors.primaryIndigo;
            textColor = AppColors.primaryText;
          } else if (isCompleted) {
            circleColor = AppColors.accentGreen;
            textColor = AppColors.primaryText.withOpacity(0.6);
          } else if (isFuture) {
            circleColor = Colors.grey[400]!;
            textColor = Colors.grey[600]!;
          }

          Widget stepWidget = Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: circleColor,
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isActive ? 16 : 14,
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                _invoiceSteps[index],
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );

          if (index < _invoiceSteps.length - 1) {
            return Expanded(
              child: Row(
                children: [
                  stepWidget,
                  Expanded(
                    child: Container(
                      height: 2.0,
                      color: isCompleted
                          ? AppColors.accentGreen
                          : Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return stepWidget;
          }
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final facture = widget.facture;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Confirmation Facture',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Timeline Steps en haut
          _buildInvoiceStepper(),
          Divider(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: AppColors.accentGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Récapitulatif de la Facture',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const Divider(color: AppColors.neutralGrey300, height: 24),
                  _buildInfoRow(
                    context,
                    'Référence:',
                    facture.reference,
                    icon: Icons.receipt_long,
                  ),
                  _buildInfoRow(
                    context,
                    'Fournisseur ID:',
                    facture.fournisseur.toString(),
                    icon: Icons.business,
                  ),
                  _buildInfoRow(
                    context,
                    'Date de Création:',
                    DateFormat('dd/MM/yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(
                        facture.dateCreation * 1000,
                      ),
                    ),
                    icon: Icons.calendar_today,
                  ),
                  _buildInfoRow(
                    context,
                    'Statut:',
                    facture.status == 0 ? 'Brouillon' : 'Confirmée',
                    icon: Icons.info_outline,
                    valueColor: facture.status == 0
                        ? AppColors.accentRed
                        : AppColors.accentGreen,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Lignes de Facture (${facture.lines.length})',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const Divider(color: AppColors.neutralGrey300, height: 24),
                  if (facture.lines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'Aucune ligne d\'article dans cette facture.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutralGrey600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
                    ...facture.lines.asMap().entries.map((entry) {
                      int index = entry.key;
                      var lineItem = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${lineItem.description}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildLineInfoRow(
                                context,
                                'Quantité:',
                                lineItem.quantity.toString(),
                              ),
                              _buildLineInfoRow(
                                context,
                                'Prix Unitaire HT:',
                                '${lineItem.priceHTPerUnit.toStringAsFixed(2)} MAD',
                              ),
                              _buildLineInfoRow(
                                context,
                                'Taux TVA:',
                                '${lineItem.vatRate.toStringAsFixed(0)}%',
                              ),
                              Divider(height: 16, color: Colors.grey[200]),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total HT:',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.neutralGrey800,
                                    ),
                                  ),
                                  Text(
                                    '${lineItem.totalHT.toStringAsFixed(2)} MAD',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.neutralGrey800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total TTC:',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  Text(
                                    '${lineItem.totalTTC.toStringAsFixed(2)} MAD',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryIndigo,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Grand Total de la Facture: ${facture.total.toStringAsFixed(2)} MAD TTC',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryIndigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Action à effectuer lorsque la facture est "confirmée"
                        // Par exemple, sauvegarder en base de données finale,
                        // afficher un message de succès et revenir à l'écran d'accueil.
                        // Pour cet exemple, nous allons simplement revenir à la page précédente
                        // et potentiellement passer la facture finale.
                        Navigator.pop(
                          context,
                          facture,
                        ); // Retourne la facture confirmée
                      },
                      icon: const Icon(Icons.check_circle, size: 24),
                      label: const Text(
                        'Confirmer la Facture',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.accentGreen.withOpacity(0.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        ); // Revient à la page précédente (EditInvoicePage)
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Modifier les Articles'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryIndigo,
                        side: const BorderSide(color: AppColors.primaryIndigo),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(icon, color: AppColors.neutralGrey700, size: 20),
            ),
          SizedBox(
            width: 120, // Alignement des labels
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutralGrey800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: valueColor ?? AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutralGrey700,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.neutralGrey800,
            ),
          ),
        ],
      ),
    );
  }
}
