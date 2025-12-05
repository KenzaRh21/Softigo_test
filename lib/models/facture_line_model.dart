import 'package:html_unescape/html_unescape.dart'; 

class FactureLine {
  final int? lineid; // Identifier for the line item
  final String description;
  final int quantity;
  final double priceHTPerUnit;
  final double totalHT;
  final double totalTTC;
  final double vatRate; // Valeur ajouter pour le taux de TVA

  FactureLine({
    this.lineid, 
    required this.description,
    required this.quantity,
    required this.priceHTPerUnit,
    required this.totalHT,
    required this.totalTTC,
    required this.vatRate,
  });
// Factory constructor to create a FactureLine from JSON
  factory FactureLine.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    double parseDouble(dynamic value) {
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
      lineid: parseInt(json['rowid']), // <-- changed to lineid here
      description: cleanedDescription,
      quantity: parseInt(json['qty']),
      priceHTPerUnit: parseDouble(json['subprice']),
      totalHT: parseDouble(json['total_ht']),
      totalTTC: parseDouble(json['total_ttc']),
      vatRate: parseDouble(json['tva_tx']),
    );
  }
// Method to convert FactureLine to JSON for API requests
  Map<String, dynamic> toJsonForApi() {
    final map = {
      'description': description,
      'quantity': quantity,
      'priceHTPerUnit': priceHTPerUnit,
      'totalHT': totalHT,
      'totalTTC': totalTTC,
      'vatRate': vatRate,
      'rowid': lineid,
    };

    return map;
  }
}
