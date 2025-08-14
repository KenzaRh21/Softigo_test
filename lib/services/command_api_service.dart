// lib/services/command_api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CommandApiService {
  final String _baseUrl;
  final String _apiKey;

  CommandApiService({required String baseUrl, required String apiKey})
    : _baseUrl = baseUrl,
      _apiKey = apiKey;

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'DOLAPIKEY': _apiKey,
  };

  /// Crée une nouvelle commande client dans Dolibarr.
  ///
  /// La méthode renvoie l'ID de la nouvelle commande créée en cas de succès.
  Future<int> createClientCommand({
    required int socid,
    required String refClient,
    required String notePublic,
    required String notePrivate,
    required String dateLivraison,
  }) async {
    // Construction du corps de la requête Dolibarr.
    final body = {
      'socid': socid,
      'ref_client': refClient,
      // L'API Dolibarr attend la date au format timestamp (epoch).
      // On utilise donc le timestamp actuel.
      'date': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'date_livraison': dateLivraison,
      'note_public': notePublic,
      'note_private': notePrivate,
      // La création de la commande se fait sans les lignes
      'lines': [],
    };

    print('Envoi de la requête de création de commande client...');
    print('URL: $_baseUrl/orders');
    print('Corps de la requête: ${json.encode(body)}');

    final response = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // L'API renvoie l'ID de la commande en tant que String, on le convertit en int.
      final String responseBody = response.body;
      final int newOrderId = int.parse(responseBody);
      return newOrderId;
    } else {
      print('Erreur API - Statut: ${response.statusCode}');
      print('Erreur API - Corps: ${response.body}');
      throw Exception(
        'Erreur lors de la création de la commande client: ${response.body}',
      );
    }
  }

  /// Ajoute une ligne à une commande existante dans Dolibarr.
  Future<void> addCommandLine({
    required int orderId,
    required String description,
    required double quantity,
    required double unitPrice,
  }) async {
    final url = Uri.parse('$_baseUrl/orders/$orderId/lines');

    final body = jsonEncode({
      'desc': description,
      'qty': quantity,
      'subprice': unitPrice,
    });

    final response = await http.post(
      url,
      headers: _jsonHeaders, // Utilisation de l'en-tête global
      body: body,
    );

    if (response.statusCode == 200) {
      print('Ligne de commande ajoutée avec succès à la commande #$orderId!');
    } else {
      print(
        'Erreur lors de l\'ajout de la ligne de commande: ${response.body}',
      );
      throw Exception(
        'Échec de l\'ajout de la ligne de commande. Code de statut: ${response.statusCode}',
      );
    }
  }

  /// Récupère la liste des tiers (clients et fournisseurs) depuis Dolibarr.
  Future<List<Map<String, dynamic>>> getClients() async {
    final url = Uri.parse('$_baseUrl/thirdparties');

    final response = await http.get(url, headers: _jsonHeaders);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
        'Échec de la récupération des clients. Code de statut: ${response.statusCode}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchCommands() async {
    final url = Uri.parse('$_baseUrl/orders');

    try {
      final response = await http.get(url, headers: _jsonHeaders);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        // Si la requête a réussi, parsez le JSON
        List<dynamic> data = json.decode(response.body);
        debugPrint('Données API reçues : $jsonList');
        return List<Map<String, dynamic>>.from(data);
      } else {
        // Si la requête a échoué, lancez une exception
        throw Exception(
          'Échec du chargement des commandes : ${response.statusCode}',
        );
      }
    } catch (e) {
      // Gérer les erreurs de connexion ou autres
      throw Exception('Erreur lors de la récupération des commandes : $e');
    }
  }

  // Ajoutez cette nouvelle méthode à votre classe CommandApiService
  Future<Map<String, dynamic>> fetchThirdParty(int thirdPartyId) async {
    final url = Uri.parse(
      '$_baseUrl/thirdparties/$thirdPartyId?DOLAPIKEY=$_apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Correction ici : l'API renvoie un seul objet JSON, pas une liste.
      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception(
          'Réponse de l\'API inattendue pour l\'ID $thirdPartyId',
        );
      }
    } else {
      throw Exception('Échec du chargement du tiers: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchOrder(int orderId) async {
    // L'URL pour récupérer une commande par son ID est `api/index.php/orders/{id}`
    final url = Uri.parse('$_baseUrl/orders/$orderId?DOLAPIKEY=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // L'API renvoie un objet JSON unique, et non une liste
      final data = json.decode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception(
          'Réponse de l\'API inattendue pour la commande $orderId',
        );
      }
    } else {
      throw Exception(
        'Échec du chargement de la commande: ${response.statusCode}',
      );
    }
  }

  Future<List<dynamic>> fetchOrderLines(int orderId) async {
    final url = Uri.parse('$_baseUrl/orders/$orderId/lines?DOLAPIKEY=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data;
      } else {
        throw Exception(
          'Réponse de l\'API inattendue pour les lignes de commande $orderId',
        );
      }
    } else {
      throw Exception(
        'Échec du chargement des lignes de commande: ${response.statusCode}',
      );
    }
  }

  // TODO: Ajoutez ici la méthode `createSupplierCommand` pour les commandes fournisseur
}
