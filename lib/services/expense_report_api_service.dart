// lib/services/expense_report_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class ExpenseReportApiService {
  final String _baseUrl;
  final String _apiKey;

  // Le constructeur requiert les variables d'environnement.
  ExpenseReportApiService({required String baseUrl, required String apiKey})
    : _baseUrl = baseUrl,
      _apiKey = apiKey;

  // En-têtes pour les requêtes JSON.
  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'DOLAPIKEY': _apiKey,
  };

  /// Crée une nouvelle note de frais dans Dolibarr.
  /// Renvoie l'ID de la note de frais créée.
  Future<int> createExpenseReport(
    Map<String, dynamic> expenseReportData,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/expensereports'),
      headers: _jsonHeaders,
      body: json.encode(expenseReportData),
    );

    if (response.statusCode == 200) {
      // L'API renvoie l'ID en tant que string, donc on le convertit en int.
      return int.parse(response.body);
    } else {
      throw Exception(
        'Erreur lors de la création de la note de frais: ${response.body}',
      );
    }
  }

  /// Joindre un fichier à un objet Dolibarr (par exemple, une note de frais).
  Future<Map<String, dynamic>> uploadFile(
    String objectType,
    int objectId,
    String filePath,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/documents/upload'),
    );

    // L'en-tête pour les requêtes multipart est différent.
    request.headers.addAll({'DOLAPIKEY': _apiKey});

    request.fields['modulepart'] = objectType; // 'expensereport' dans notre cas
    request.fields['entity'] = '1'; // L'ID de votre entité
    request.fields['subdir'] = '$objectType/$objectId';
    request.fields['tag'] = 'expensereport_attachment';

    final file = await http.MultipartFile.fromPath(
      'file',
      filePath,
      filename: path.basename(filePath),
      contentType: MediaType('application', 'octet-stream'),
    );

    request.files.add(file);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de l\'upload du fichier: ${response.body}');
    }
  }

  // --- NOUVELLE MÉTHODE POUR RÉCUPÉRER LES NOTES DE FRAIS ---
  /// Récupère la liste des notes de frais depuis l'API Dolibarr.
  Future<List<ExpenseReport>> fetchExpenseReports() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/expensereports?limit=100'),
      headers: {'DOLAPIKEY': _apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ExpenseReport.fromJson(json)).toList();
    } else {
      throw Exception(
        'Erreur lors de la récupération des notes de frais: ${response.body}',
      );
    }
  }

  Future<ExpenseReport> fetchExpenseReportById(int reportId) async {
    final url = '$_baseUrl/expensereports/$reportId';
    final response = await http.get(
      Uri.parse(url),
      headers: {'DOLAPIKEY': _apiKey},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ExpenseReport.fromJson(json);
    } else {
      throw Exception(
        'Failed to load expense report details: ${response.statusCode}',
      );
    }
  }

  // suppression
  Future<void> deleteExpenseReport(int reportId) async {
    final url = '$_baseUrl/expensereports/$reportId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'DOLAPIKEY': _apiKey},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete expense report: ${response.statusCode}',
      );
    }
  }

  // --- NOUVELLE MÉTHODE POUR METTRE À JOUR UNE NOTE DE FRAIS ---
  Future<void> updateExpenseReport(
    int reportId,
    Map<String, dynamic> updatedData,
  ) async {
    final url = '$_baseUrl/expensereports/$reportId';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'DOLAPIKEY': _apiKey},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update expense report: ${response.statusCode}',
      );
    }
  }
}

// Classe de modèle pour la note de frais (à placer dans un fichier séparé, par exemple lib/models/expense_report.dart)
class ExpenseReport {
  final int id;
  final String label;
  final String description;
  final DateTime date;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String status;
  final double total;
  final String ref;

  ExpenseReport({
    required this.id,
    required this.ref,
    required this.label,
    required this.description,
    required this.date,
    required this.dateDebut,
    required this.dateFin,
    required this.status,
    required this.total,
  });
  // AJOUTE CE BLOC DE CODE ICI
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ref': ref,
      'note_public': label,
      'note_private': description,
      'date': date.toIso8601String(),
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      'status': status,
      'total': total,
    };
  }

  // C'est aussi une bonne pratique de surcharger toString() pour le débogage.
  @override
  String toString() {
    return 'ExpenseReport(id: $id, ref: $ref, label: $label, dateDebut: $dateDebut, dateFin: $dateFin, total: $total)';
  }

  // Factory constructor pour créer un objet ExpenseReport à partir d'un JSON
  factory ExpenseReport.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic dateValue) {
      if (dateValue is String) {
        // Gère le format "JJ/MM/AAAA"
        final parts = dateValue.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            return DateTime(year, month, day);
          }
        }
      } else if (dateValue is int) {
        // Gère le format timestamp (secondes)
        return DateTime.fromMillisecondsSinceEpoch(dateValue * 1000);
      }
      return DateTime.now(); // Retourne la date du jour par défaut
    }

    final total = double.tryParse(json['total_ttc'] ?? '0.0') ?? 0.0;

    // Suppression de la conversion en chaîne de caractères française ici
    // La propriété 'status' stocke la valeur numérique brute de l'API
    final status = json['statut']?.toString() ?? '-2';

    return ExpenseReport(
      id: int.tryParse(json['id'] ?? '0') ?? 0,
      label: json['note_public'] ?? 'Pas de libellé',
      description: json['note_private'] ?? 'Pas de description',
      date: _parseDate(json['date']),
      dateDebut: _parseDate(json['date_debut']),
      dateFin: _parseDate(json['date_fin']),
      status: status,
      total: total,
      ref: json['ref'] as String? ?? 'Pas de référence',
    );
  }
}
