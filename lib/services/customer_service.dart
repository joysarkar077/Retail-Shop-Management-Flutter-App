import 'dart:convert';
import 'api_service.dart';
import '../config/api_config.dart';

class CustomerService {
  static Future<Map<String, dynamic>?> searchByPhone(String phone) async {
    try {
      final response = await ApiService.get('${ApiConfig.baseUrl}/customers/search?phone=$phone');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getCustomers() async {
    final response = await ApiService.get('${ApiConfig.baseUrl}/customers');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load customers');
  }

  static Future<Map<String, dynamic>> getCustomerHistory(String id) async {
    final response = await ApiService.get('${ApiConfig.baseUrl}/customers/$id/history');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load customer history');
  }
}
