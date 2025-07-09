// lib/models/facture_model.dart
// Ensure you import the new FactureLine model
import 'package:softigotest/models/facture_line_model.dart'; // Renamed from invoice_line_model.dart? Please check.

class Facture {
  final String id; // ADDED: Invoice ID
  final String reference;
  final int fournisseur; // From fk_user_author (string -> int)
  final int dateCreation; // From date_validation (int, Unix timestamp)
  final double total; // From total_ttc (string -> double)
  final int status; // From statut (string -> int)
  final List<FactureLine>
  lines; // NEW: This list will hold all product lines for the invoice

  Facture({
    this.id =
        '', // ADDED: Default value for new instances before ID is assigned by backend
    required this.reference,
    required this.fournisseur,
    required this.dateCreation,
    required this.total,
    required this.status,
    required this.lines, // NEW: Required for the list of lines
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    // Helper function for safe integer parsing (can be moved to a utility if preferred)
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    // Helper function for safe double parsing (can be moved to a utility if preferred)
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Parse the 'lines' array from the JSON into a List of FactureLine objects
    List<FactureLine> parsedLines = [];
    if (json['lines'] is List) {
      // Check if the 'lines' key exists and its value is actually a List
      parsedLines =
          (json['lines'] as List) // Cast the dynamic list to a List
              .map(
                (lineJson) =>
                    FactureLine.fromJson(lineJson as Map<String, dynamic>),
              ) // For each item in the list, create a FactureLine object
              .toList(); // Convert the result back to a List
    }

    return Facture(
      id: json['id']?.toString() ?? '', // ADDED: Parse 'id' from JSON
      reference: json['ref']?.toString() ?? 'N/A',
      fournisseur: _parseInt(json['fk_user_author']),
      dateCreation: _parseInt(json['date_validation']),
      total: _parseDouble(json['total_ttc']),
      status: _parseInt(json['statut']),
      lines: parsedLines, // Assign the newly parsed list of FactureLine objects
    );
  }

  // >>> ADDED/MODIFIED toJson METHOD <<<
  Map<String, dynamic> toJson() {
    return {
      'id': id, // ADDED: Include id when converting to JSON
      'reference': reference,
      'fournisseur': fournisseur,
      'dateCreation': dateCreation,
      'total': total,
      'status': status,
      'lines': lines
          .map((line) => line.toJson())
          .toList(), // Calls toJson on each FactureLine
    };
  }

  // >>> ADDED copyWith METHOD for immutability <<<
  Facture copyWith({
    String? id,
    String? reference,
    int? fournisseur,
    int? dateCreation,
    double? total,
    int? status,
    List<FactureLine>? lines,
  }) {
    return Facture(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      fournisseur: fournisseur ?? this.fournisseur,
      dateCreation: dateCreation ?? this.dateCreation,
      total: total ?? this.total,
      status: status ?? this.status,
      lines: lines ?? this.lines,
    );
  }
}
