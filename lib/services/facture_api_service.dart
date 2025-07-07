// lib/services/facture_api_service.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:softigotest/models/facture_model.dart';
import 'package:softigotest/models/invoice_create_model.dart';
import 'package:http/http.dart' as http;

class FactureApiService {
  final String _baseUrl = dotenv.env['API_BASE_URL']!;
  final String _dolApiKey = dotenv.env['DOLIBARR_API_KEY']!;

  Future<List<Facture>> fetchFactures() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/invoices'),
        headers: {'DOLAPIKEY': _dolApiKey, 'Content-Type': 'application/json'},
      );

      if (kDebugMode) {
        print('API URL: $_baseUrl/invoices');
        print('Request Headers: ${response.request?.headers}');
        print('API Response Status Code: ${response.statusCode}');
        print('API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Facture.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load invoices: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // UPDATED: Method to create an invoice
  // Changed return type to Future<int> and adjusted success parsing
  Future<int> createFacture(InvoiceCreateRequest invoiceRequest) async {
    // <-- Changed return type
    final String createUrl = '$_baseUrl/invoices';

    final Map<String, String> headers = {
      'DOLAPIKEY': _dolApiKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final String requestBody = json.encode(invoiceRequest.toJson());

    if (kDebugMode) {
      print('Sending invoice creation request to: $createUrl');
      print('Headers: $headers');
      print('Request Body: $requestBody');
    }

    try {
      final response = await http.post(
        Uri.parse(createUrl),
        headers: headers,
        body: requestBody,
      );

      if (kDebugMode) {
        print('Invoice creation response Status Code: ${response.statusCode}');
        print('Invoice creation response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Dolibarr returns the created ID as a simple integer in the body
        try {
          final int invoiceId = int.parse(
            response.body,
          ); // <-- Parse body as int
          print('Invoice creation successful. New Invoice ID: $invoiceId');
          return invoiceId; // <-- Return the integer ID
        } catch (e) {
          throw Exception(
            'Failed to parse invoice ID from response: ${response.body} - $e',
          );
        }
      } else {
        // Handle API-specific errors from Dolibarr
        String errorMessage =
            'Failed to create invoice: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map &&
              errorBody.containsKey('error') &&
              errorBody['error'] is Map &&
              errorBody['error'].containsKey('message')) {
            errorMessage += ' - ${errorBody['error']['message']}';
          } else {
            errorMessage += ' - ${response.body}';
          }
        } catch (_) {
          errorMessage += ' - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server or unknown error during invoice creation: $e',
      );
    }
  }
}
