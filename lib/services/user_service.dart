// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  final String _baseUrl;
  final String _apiKey;

  // Ajout du constructeur qui initialise _baseUrl et _apiKey
  UserService({required String baseUrl, required String apiKey})
    : _baseUrl = baseUrl,
      _apiKey = apiKey;

  // Getter pour les en-têtes de requête, en réutilisant la clé d'API
  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json; charset=UTF-8',
    'DOLAPIKEY': _apiKey,
  };

  /// Crée un nouvel utilisateur en envoyant une requête POST à l'API.
  Future<bool> createUser(User user) async {
    try {
      final response = await http.post(
        // Construction de l'URI complète avec le chemin de l'API pour les utilisateurs
        Uri.parse('$_baseUrl/users'),
        headers: _jsonHeaders,
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        // Dans Dolibarr, une réponse 200 avec l'ID de l'utilisateur est souvent utilisée
        print('Utilisateur créé avec succès ! ID: ${response.body}');
        return true;
      } else {
        print(
          'Échec de la création de l\'utilisateur. Statut : ${response.statusCode}',
        );
        print('Corps de la réponse : ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur réseau lors de la création de l\'utilisateur : $e');
      return false;
    }
  }
}
