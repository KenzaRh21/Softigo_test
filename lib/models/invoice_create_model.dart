// lib/models/invoice_create_model.dart
import 'package:softigotest/models/invoice_line_create_model.dart'; // Make sure this path is correct

class InvoiceCreateRequest {
  final int socid; // Customer ID (fk_soc in Dolibarr API)
  final int
  date; // Invoice date as Unix timestamp (e.g., DateTime.now().millisecondsSinceEpoch ~/ 1000)
  final String
  type; // Usually '0' for customer invoices, '1' for supplier invoices
  final List<InvoiceLineCreate> lines; // List of product/service lines

  // --- Optional Fields (add or remove as per your needs) ---
  final String? refClient; // Customer's own reference number
  final String? notePrivate; // Private note on the invoice
  final String? notePublic; // Public note (visible on printed invoice)
  final String?
  modeReglementCode; // Payment method code (e.g., 'VIR' for bank transfer, 'CHQ' for check)
  final String?
  condReglementCode; // Payment condition code (e.g., 'RECEP' for "upon receipt")
  final int? fk_projet; // ID of the project linked to this invoice
  final String?
  default_warehouse_id; // Default warehouse for lines (if module enabled)
  final int? fk_user_author; // ID of the user who is creating the invoice

  InvoiceCreateRequest({
    required this.socid,
    required this.date,
    this.type = '0', // Default to '0' for customer invoices
    required this.lines,
    this.refClient,
    this.notePrivate,
    this.notePublic,
    this.modeReglementCode,
    this.condReglementCode,
    this.fk_projet,
    this.default_warehouse_id,
    this.fk_user_author,
  });

  Map<String, dynamic> toJson() {
    return {
      'socid': socid.toString(),
      // Dolibarr often expects IDs as strings
      'date': date.toString(),
      // Unix timestamp as string
      'type': type,
      'lines': lines.map((line) => line.toJson()).toList(),
      // Convert each line to JSON
      if (refClient != null) 'ref_client': refClient,
      if (notePrivate != null) 'note_private': notePrivate,
      if (notePublic != null) 'note_public': notePublic,
      if (modeReglementCode != null) 'mode_reglement_code': modeReglementCode,
      if (condReglementCode != null) 'cond_reglement_code': condReglementCode,
      if (fk_projet != null) 'fk_projet': fk_projet.toString(),
      if (default_warehouse_id != null)
        'default_warehouse_id': default_warehouse_id,
      if (fk_user_author != null) 'fk_user_author': fk_user_author.toString(),
      // You typically don't send total_ht, total_tva, total_ttc when creating
      // with lines, as Dolibarr calculates them automatically based on the lines provided.
    };
  }
}
