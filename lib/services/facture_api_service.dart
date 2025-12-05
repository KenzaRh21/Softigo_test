// lib/services/facture_api_service.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:softigotest/models/facture_model.dart';
import 'package:softigotest/models/facture_line_model.dart';
import 'package:softigotest/models/invoice_create_model.dart';
import 'package:softigotest/models/invoice_line_create_model.dart';
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

  // method to delete a facture

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

  // ddeletin invoices
  Future<bool> deleteFacture({required invoiceId}) async {
    final response = await http.delete(
      Uri.parse('${dotenv.env['API_BASE_URL']}/invoices/$invoiceId'),
      headers: {'DOLAPIKEY': _dolApiKey},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Erreur de suppression: ${response.body}');
      return false;
    }
  }

  //delete the line
  Future<bool> deleteInvoiceLine({
    required int invoiceId,
    required int lineid,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/invoices/$invoiceId/lines/$lineid');

    final response = await http.delete(
      url,
      headers: {'DOLAPIKEY': _dolApiKey, 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Line deleted successfully.');
      return true;
    } else {
      print('Failed to delete line. Status code: ${response.statusCode}');
      print('Response: ${response.body}');
      return false;
    }
  }

  //method to add a line de facture
  Future<bool> addLineToFacture({
    required int invoiceId,
    required InvoiceLineCreate line,
  }) async {
    final url = '$_baseUrl/invoices/$invoiceId/lines';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'DOLAPIKEY': _dolApiKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(line.toJsonForApi()),
    );

    if (kDebugMode) {
      print('Add line to invoice $invoiceId => ${response.statusCode}');
      print('Body: ${response.body}');
    }

    return response.statusCode == 200;
  }

  Future<Facture?> getFactureById({required int invoiceId}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/invoices/$invoiceId'),
        headers: {'DOLAPIKEY': _dolApiKey, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Facture.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching invoice by ID: $e');
    }
  }

  Future<List<FactureLine>> getInvoiceLines(int invoiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/invoices/$invoiceId/lines'),
        headers: {'DOLAPIKEY': _dolApiKey, 'Content-Type': 'application/json'},
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Decoded lines count: ${data.length}');
        return data.map((e) => FactureLine.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load invoice lines: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getInvoiceLines: $e');
      throw Exception('Error fetching invoice lines: $e');
    }
  }

  Future<bool> setToDraft(int invoiceId) async {
    final url = '${dotenv.env['API_BASE_URL']}/invoices/$invoiceId/setdraft';

    final response = await http.post(
      Uri.parse(url),
      headers: {'DOLAPIKEY': _dolApiKey},
    );

    print('Set to draft response: ${response.statusCode}');
    print('Set to draft body: ${response.body}');

    return response.statusCode == 200;
  }

  // validate facture
  Future<bool> validateInvoice({required int invoiceId}) async {
    final Uri url = Uri.parse('$_baseUrl/invoices/$invoiceId/validate');

    final response = await http.post(
      url,
      headers: {'DOLAPIKEY': _dolApiKey, 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Invoice validated successfully.');
      return true;
    } else {
      print('Failed to validate invoice. Status code: ${response.statusCode}');
      print('Response: ${response.body}');
      return false;
    }
  }
}
