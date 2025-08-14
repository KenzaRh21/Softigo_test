// lib/services/third_party_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:softigotest/models/third_party.dart';

class ThirdPartyApiService {
  final String _baseUrl;
  final String _apiKey;

  // Le constructeur requiert les variables d'environnement.
  ThirdPartyApiService({required String baseUrl, required String apiKey})
    : _baseUrl = baseUrl,
      _apiKey = apiKey;

  // En-têtes pour les requêtes JSON.
  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'DOLAPIKEY': _apiKey,
  };

  /// Crée un nouveau tiers dans Dolibarr.
  /// Renvoie le code du tiers créé.
  Future<String> createThirdParty(Map<String, dynamic> thirdPartyData) async {
    // --- Ligne de débogage ajoutée ici ---
    print('Envoi de la requête de création de tiers...');
    print('Corps de la requête : ${json.encode(thirdPartyData)}');
    // -------------------------------------

    final response = await http.post(
      Uri.parse('$_baseUrl/thirdparties'),
      headers: _jsonHeaders,
      body: json.encode(thirdPartyData),
    );

    if (response.statusCode == 200) {
      // L'API renvoie l'ID du tiers créé, qui est un simple nombre.
      final int newThirdPartyId = int.parse(response.body);
      return newThirdPartyId.toString();
    } else {
      print('Erreur API - Statut: ${response.statusCode}');
      print('Erreur API - Corps: ${response.body}');
      throw Exception('Erreur lors de la création du tiers: ${response.body}');
    }
  }

  /// Récupère une liste de tiers depuis Dolibarr.
  Future<List<Map<String, dynamic>>> fetchThirdParties() async {
    // Spécifiez les champs que vous voulez récupérer
    final String fields =
        't.rowid,t.name,t.address,t.phone,t.email,t.client,t.fournisseur,t.code_client';

    final response = await http.get(
      Uri.parse('$_baseUrl/thirdparties?limit=100&fields=$fields'),
      headers: _jsonHeaders,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print('Erreur API - Statut: ${response.statusCode}');
      print('Erreur API - Corps: ${response.body}');
      throw Exception(
        'Erreur lors de la récupération des tiers: ${response.body}',
      );
    }
  }

  /// Récupère un tiers unique par son ID depuis Dolibarr.
  /// La route API pour un tiers spécifique est `thirdparties/{id}`.
  Future<ThirdParty> fetchThirdPartyById(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/thirdparties/$id'),
      headers: _jsonHeaders,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('Données reçues de l\'API pour le tiers #$id: $data');
      return ThirdParty.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Tiers avec l\'ID $id non trouvé.');
    } else {
      print('Erreur API - Statut: ${response.statusCode}');
      print('Erreur API - Corps: ${response.body}');
      throw Exception(
        'Erreur lors de la récupération du tiers: ${response.body}',
      );
    }
  }

  Future<void> updateThirdParty(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/thirdparties/$id');
    final headers = {'Content-Type': 'application/json', 'DOLAPIKEY': _apiKey};
    final body = json.encode(data);

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Tiers mis à jour avec succès.');
        return;
      } else {
        // AFFICHEZ LE CORPS DE LA RÉPONSE ICI
        print('Erreur API - Statut: ${response.statusCode}');
        print('Erreur API - Corps: ${response.body}');
        final errorBody = json.decode(response.body);
        throw Exception(
          'Erreur lors de la mise à jour du tiers: ${errorBody['error']['message']}',
        );
      }
    } catch (e) {
      throw Exception(
        'Erreur de connexion lors de la mise à jour du tiers: $e',
      );
    }
  }

  Future<void> deleteThirdParty(String thirdPartyId) async {
    final uri = Uri.parse('$_baseUrl/thirdparties/$thirdPartyId');
    final headers = {'Content-Type': 'application/json', 'DOLAPIKEY': _apiKey};
    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      // 200 OK ou 204 No Content sont des codes de succès
      final responseBody = json.decode(response.body);
      final errorMessage =
          responseBody['error']['message'] ?? 'Erreur inconnue';
      throw Exception(
        'Erreur lors de la suppression du tiers: $errorMessage (Code: ${response.statusCode})',
      );
    }
  }
}
