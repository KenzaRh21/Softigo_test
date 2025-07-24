// lib/models/facture_line_model.dart
import 'package:html_unescape/html_unescape.dart';

class FactureLine {
  final String description;
  final int quantity;
  final double priceHTPerUnit;
  final double totalHT;
  final double totalTTC;
  final double vatRate;

  FactureLine({
    required this.description,
    required this.quantity,
    required this.priceHTPerUnit,
    required this.totalHT,
    required this.totalTTC,
    required this.vatRate,
  });

  factory FactureLine.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    String rawDescription = json['desc']?.toString() ?? 'N/A';
    final unescape = HtmlUnescape();
    String unescapedDescription = unescape.convert(rawDescription);
    String cleanedDescription = unescapedDescription.replaceAll(
      RegExp(r'<[^>]*>'),
      '',
    );
    cleanedDescription = cleanedDescription.trim();

    return FactureLine(
      description: cleanedDescription,
      quantity: _parseInt(json['qty']),
      priceHTPerUnit: _parseDouble(json['subprice']),
      totalHT: _parseDouble(json['total_ht']),
      totalTTC: _parseDouble(json['total_ttc']),
      vatRate: _parseDouble(json['tva_tx']),
    );
  }

  // >>> THIS IS THE toJson METHOD THAT MUST BE PRESENT <<<
  Map<String, dynamic> toJsonForApi() {
    return {
      'description': description,
      'quantity': quantity,
      'priceHTPerUnit': priceHTPerUnit,
      'totalHT': totalHT,
      'totalTTC': totalTTC,
      'vatRate': vatRate,
    };
  }
}
