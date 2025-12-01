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
    String? refClient,
    required String date,
    required int deliveryDate,
    String? notePublic,
    String? notePrivate,
    required int status,
    String? contact,
    int? modeReglementId, // ⬅️ Renommé et type ajusté
    int? condReglementId, // ⬅️ Ajout de ce champ
    String? address,
    double? totalAmount,
  }) async {
    // Conversion des dates en objets DateTime
    final commandDateTime = DateTime.parse(date);

    // Conversion en timestamps Unix (secondes)
    final commandTimestamp = commandDateTime.millisecondsSinceEpoch ~/ 1000;

    final body = {
      'socid': socid,
      'ref_client': refClient ?? 'AUTO',
      'date': date,
      'delivery_date': deliveryDate.toString(),
      'note_public': notePublic ?? '',
      'note_private': notePrivate ?? '',
      'statut': status,
      'contact_id': contact,
      'mode_reglement_id': modeReglementId, // ⬅️ Utilisation du nouvel ID
      'cond_reglement_id': condReglementId, // ⬅️ Utilisation du nouvel ID
      'address': address,
      'lines': [],
    };

    if (totalAmount != null) {
      body['total_ht'] = totalAmount;
    }
    print('Envoi de la requête de création de commande client...');
    print('URL: $_baseUrl/orders');
    print('Corps de la requête: ${json.encode(body)}');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      );

      print('DEBUG: Statut de la réponse: ${response.statusCode}');
      print('DEBUG: Corps de la réponse: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // L'API Dolibarr renvoie un entier (l'ID de la commande) et non un JSON
        final int newOrderId = int.parse(response.body);
        return newOrderId;
      } else {
        throw Exception(
          'Échec de la création de la commande. Statut: ${response.statusCode}. Corps: ${response.body}',
        );
      }
    } catch (e) {
      print('DEBUG: Erreur lors de la création de la commande: $e');
      rethrow;
    }
  }

  /// Ajoute une ligne à une commande existante dans Dolibarr.
  Future<void> addCommandLine({
    required int orderId,
    required String description,
    required double quantity,
    required double unitPrice,
    required int vatRate,
  }) async {
    final url = Uri.parse('$_baseUrl/orders/$orderId/lines');

    final body = jsonEncode({
      'desc': description,
      'qty': quantity,
      'subprice': unitPrice,
      'tva_tx': vatRate,
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
        // debugPrint('Données API reçues : $jsonList');
        debugPrint('recuperation réussie!');
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

  Future<void> deleteClientCommand(int orderId) async {
    final url = Uri.parse('$_baseUrl/orders/$orderId');

    final response = await http.delete(url, headers: _jsonHeaders);

    if (response.statusCode == 200) {
      debugPrint('Commande #$orderId supprimée avec succès.');
    } else {
      debugPrint('Erreur API - Statut: ${response.statusCode}');
      debugPrint('Erreur API - Corps: ${response.body}');
      throw Exception(
        'Échec de la suppression de la commande: ${response.body}',
      );
    }
  }

  Future<void> updateCommand({
    required int orderId,
    required Map<String, dynamic> updatedData,
  }) async {
    final url = Uri.parse('$_baseUrl/orders/$orderId');
    final headers = {'Content-Type': 'application/json', 'DOLAPIKEY': _apiKey};

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        debugPrint('Commande #$orderId mise à jour avec succès.');
      } else {
        debugPrint(
          'Échec de la mise à jour de la commande #$orderId. Statut: ${response.statusCode}',
        );
        debugPrint('Erreur: ${response.body}');
        throw Exception('Échec de la mise à jour: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la commande: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<void> deleteCommandLine({
    required int orderId,
    required int lineId,
  }) async {
    final url = Uri.parse('$_baseUrl/orders/$orderId/lines/$lineId');

    final response = await http.delete(url, headers: _jsonHeaders);

    if (response.statusCode == 200 || response.statusCode == 204) {
      debugPrint('Ligne de commande #$lineId supprimée avec succès!');
    } else {
      debugPrint(
        'Erreur lors de la suppression de la ligne de commande: ${response.body}',
      );
      throw Exception(
        'Échec de la suppression de la ligne de commande. Code de statut: ${response.statusCode}',
      );
    }
  }

  /// METTRE À JOUR LA COMMANDE ENTIÈRE (y compris les lignes)
  Future<void> updateClientCommand({
    required int orderId,
    required Map<String, dynamic> updatedData,
    required List<Map<String, dynamic>> initialLines,
  }) async {
    try {
      // 1. Mise à jour des champs généraux de la commande
      final generalFields = {
        'ref_client': updatedData['ref_client'],
        'date_livraison': updatedData['date_livraison'],
        'cond_reglement_code': updatedData['cond_reglement_code'],
        'mode_reglement_code': updatedData['mode_reglement_code'],
      };
      await _updateCommandGeneralFields(
        orderId,
        generalFields,
      ); // Pass only general fields

      // 2. Mise à jour et gestion des lignes de commande
      final List<Map<String, dynamic>> newLines =
          List<Map<String, dynamic>>.from(updatedData['lines'] ?? []);

      final initialLineIds = initialLines
          .map<int?>((line) => int.tryParse(line['id']?.toString() ?? ''))
          .whereType<int>() // Filter out null IDs
          .toList();
      final newLineIds = newLines
          .map<int?>((line) => int.tryParse(line['id']?.toString() ?? ''))
          .whereType<int>()
          .toList();

      final linesToDelete = initialLineIds
          .where((id) => !newLineIds.contains(id))
          .toList();
      final linesToUpdate = newLines
          .where((line) => line['id'] != null && line['id'] != '')
          .toList();
      final linesToAdd = newLines
          .where((line) => line['id'] == null || line['id'] == '')
          .toList();

      // Suppression des lignes
      for (final lineId in linesToDelete) {
        await deleteCommandLine(orderId: orderId, lineId: lineId);
      }

      // Mise à jour des lignes existantes
      for (final line in linesToUpdate) {
        await _updateCommandLine(orderId, line);
      }

      // Ajout des nouvelles lignes
      for (final line in linesToAdd) {
        await addCommandLine(
          orderId: orderId,
          description: line['description'],
          quantity: line['qty'].toDouble(),
          unitPrice: line['subprice'].toDouble(),
          vatRate: line['tva_tx'], // Ensure vatRate is handled
        );
      }

      debugPrint(
        'Mise à jour de la commande #$orderId et de ses lignes réussie.',
      );
    } catch (e) {
      debugPrint('Échec de la mise à jour de la commande #$orderId: $e');
      throw Exception('Échec complet de la mise à jour de la commande.');
    }
  }

  /// Mettre à jour les champs généraux d'une commande
  Future<void> _updateCommandGeneralFields(
    int orderId,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$_baseUrl/orders/$orderId');
    final response = await http.put(
      url,
      headers: _jsonHeaders,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Échec de la mise à jour des champs généraux: ${response.body}',
      );
    }
  }

  /// Mettre à jour une ligne de commande spécifique
  Future<void> _updateCommandLine(
    int orderId,
    Map<String, dynamic> lineData,
  ) async {
    final lineId = int.tryParse(lineData['id'].toString());
    if (lineId == null) {
      throw Exception('ID de ligne invalide pour la mise à jour.');
    }

    final url = Uri.parse('$_baseUrl/orders/$orderId/lines/$lineId');
    final body = jsonEncode({
      'desc': lineData['description'],
      'qty': lineData['qty'],
      'subprice': lineData['subprice'],
    });

    final response = await http.put(url, headers: _jsonHeaders, body: body);

    if (response.statusCode != 200) {
      throw Exception(
        'Échec de la mise à jour de la ligne $lineId: ${response.body}',
      );
    }
  }

  Future<void> updateDeliveryDate({
    required int orderId,
    required int dateLivraisonTimestamp,
  }) async {
    final url = Uri.parse('$_baseUrl/orders/$orderId');
    final body = json.encode({'delivery_date': dateLivraisonTimestamp});

    final response = await http.put(url, headers: _jsonHeaders, body: body);

    if (response.statusCode != 200) {
      debugPrint('Erreur API - Statut: ${response.statusCode}');
      debugPrint('Erreur API - Corps: ${response.body}');
      throw Exception(
        'Échec de la mise à jour de la date de livraison: ${response.body}',
      );
    } else {
      debugPrint(
        'Date de livraison de la commande #$orderId mise à jour avec succès.',
      );
    }
  }

  Future<void> validateOrder(int orderId) async {
    final url = Uri.parse('$_baseUrl/orders/$orderId/validate');
    final headers = {'Content-Type': 'application/json', 'DOLAPIKEY': _apiKey};

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(
          {},
        ), // L'API ne requiert pas de corps pour cette requête
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Échec de la validation de la commande. Code: ${response.statusCode}, Corps: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'appel de l\'API de validation: $e');
      rethrow;
    }
  }

  // TODO: Ajoutez ici la méthode `createSupplierCommand` pour les commandes fournisseur
}
