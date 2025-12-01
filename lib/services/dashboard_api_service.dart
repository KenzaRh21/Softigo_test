// lib/services/dashboard_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DashboardApiService {
  final String _baseUrl = dotenv.env['API_BASE_URL']!;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getApiKey() async {
    return await _storage.read(key: 'DOLIBARR_API_KEY');
  }

  Future<int> _fetchCount(String endpoint) async {
    final apiKey = await _getApiKey();
    if (apiKey == null) {
      throw Exception('API Key not found.');
    }

    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = {'DOLAPIKEY': apiKey, 'Content-Type': 'application/json'};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.length;
    } else {
      // You might want to handle specific status codes here (e.g., 404 for not found)
      // For now, let's just re-throw the exception
      throw Exception(
        'Failed to load data from $endpoint: ${response.statusCode}',
      );
    }
  }

  Future<int> getInvoiceCount() => _fetchCount('invoices');
  Future<int> getThirdPartyCount() => _fetchCount('thirdparties');
  Future<int> getExpenseReportCount() => _fetchCount('expensereports');
  Future<int> getOrderCount() => _fetchCount('orders');

  // The leaves and proposals functions are no longer needed here if you keep them static on the UI side.
}
