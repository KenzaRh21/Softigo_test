// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // To access .env variables
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:softigotest/config/app_constants.dart'; // Corrected import path
import 'package:http/http.dart' as http;

class AuthService {
  final _secureStorage = const FlutterSecureStorage();
  final String _userTokenKey =
      'dolibarr_user_token'; // Key for storing user session token

  // Fetch the Dolibarr Application API Key from .env
  String get _dolibarrAppApiKey => dotenv.env['DOLIBARR_API_KEY']!;

  // Method to perform user login
  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$kApiBaseUrl$kLoginEndpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'DOLAPIKEY': _dolibarrAppApiKey, // Using the app API key from .env
        },
        body: jsonEncode(<String, String>{
          'login': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final Map<String, dynamic>? successData = responseBody['success'];
        final String? authToken = successData != null
            ? successData['token']
            : null;

        if (authToken != null && authToken.isNotEmpty) {
          await saveUserToken(authToken); // Save token securely
          return authToken; // Return the token
        } else {
          throw Exception(
            'Login successful but no authentication token received.',
          );
        }
      } else {
        final errorBody = jsonDecode(response.body);
        String errorMessage = 'Login failed. Please check your credentials.';
        if (errorBody is Map && errorBody.containsKey('error')) {
          final Map<String, dynamic>? errorDetails = errorBody['error'];
          if (errorDetails != null &&
              errorDetails.containsKey('message') &&
              errorDetails['message'] is String) {
            errorMessage = errorDetails['message'];
          } else if (errorDetails != null &&
              errorDetails.containsKey('code') &&
              errorDetails['code'] is String) {
            errorMessage = 'Error: ${errorDetails['code']}';
          }
        }
        throw Exception(errorMessage); // Throw specific error message
      }
    } catch (e) {
      // General network error or parsing error
      throw Exception('Network error during login: $e');
    }
  }

  // Method to save the user session token securely
  Future<void> saveUserToken(String token) async {
    await _secureStorage.write(key: _userTokenKey, value: token);
  }

  // Method to read the user session token securely
  Future<String?> readUserToken() async {
    return await _secureStorage.read(key: _userTokenKey);
  }

  // Method to delete the user session token (for logout)
  Future<void> deleteUserToken() async {
    await _secureStorage.delete(key: _userTokenKey);
  }
}
