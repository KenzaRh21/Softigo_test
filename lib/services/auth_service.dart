// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:softigotest/config/app_constants.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _secureStorage = const FlutterSecureStorage();
  final String _userTokenKey = 'dolibarr_user_token';

  String get _dolibarrAppApiKey => dotenv.env['DOLIBARR_API_KEY']!;

  Future<String?> login(String username, String password) async {
    // ... (Your existing login method here)
    try {
      final response = await http.post(
        Uri.parse('$kApiBaseUrl$kLoginEndpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'DOLAPIKEY': _dolibarrAppApiKey,
        },
        body: jsonEncode(<String, String>{
          'login': username,
          'password': password,
        }),
      );

      if (kDebugMode) {
        print('Login API URL: $kApiBaseUrl$kLoginEndpoint');
        print('Login Request Headers: ${response.request?.headers}');
        print(
          'Login Request Body: ${jsonEncode(<String, String>{'login': username, 'password': '***'})}',
        ); // Mask password
        print('Login Response Status Code: ${response.statusCode}');
        print('Login Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final Map<String, dynamic>? successData = responseBody['success'];
        final String? authToken = successData != null
            ? successData['token']
            : null;

        if (authToken != null && authToken.isNotEmpty) {
          await saveUserToken(authToken);
          return authToken;
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
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error during login: $e');
      }
      throw Exception('Network error during login: $e');
    }
  }

  Future<void> saveUserToken(String token) async {
    await _secureStorage.write(key: _userTokenKey, value: token);
    if (kDebugMode) {
      print('User token saved securely.');
    }
  }

  Future<String?> readUserToken() async {
    final String? token = await _secureStorage.read(key: _userTokenKey);
    if (kDebugMode) {
      print('User token read: ${token != null ? 'Exists' : 'Does not exist'}');
    }
    return token;
  }

  Future<void> deleteUserToken() async {
    await _secureStorage.delete(key: _userTokenKey);
    if (kDebugMode) {
      print('User token deleted from secure storage.');
    }
  }

  // --- THIS IS THE logout method. Keep it here as is. ---
  Future<bool> logout() async {
    final String? userToken = await readUserToken();

    if (userToken == null || userToken.isEmpty) {
      if (kDebugMode) {
        print(
          'No user token found locally. Already logged out or never logged in.',
        );
      }
      return true; // Already logged out locally
    }

    final String logoutUrl = '$kApiBaseUrl$kLogoutEndpoint';

    try {
      final response = await http.post(
        Uri.parse(logoutUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'DOLAPIKEY': userToken,
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Logout API URL: $logoutUrl');
        print('Logout Request Headers: ${response.request?.headers}');
        print('Logout Response Status Code: ${response.statusCode}');
        print('Logout Response Body: ${response.body}');
      }

      // ALWAYS clear the local token regardless of API response success/failure
      await deleteUserToken();

      return response.statusCode ==
          200; // Return true if API call was successful
    } catch (e) {
      if (kDebugMode) {
        print('Network error during logout API call: $e');
      }
      // Even on network error, ensure local token is cleared
      await deleteUserToken();
      // Rethrow the exception so the UI can catch it and display an appropriate message.
      throw Exception('Network error during logout: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final String? token = await readUserToken();
    return token != null && token.isNotEmpty;
  }
}
