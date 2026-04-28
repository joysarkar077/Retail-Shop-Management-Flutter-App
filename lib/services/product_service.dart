import 'dart:convert';
import 'api_service.dart';
import '../config/api_config.dart';

class ProductService {
  static Future<Map<String, dynamic>?> getByBarcode(String barcode) async {
    try {
      final response = await ApiService.get('${ApiConfig.baseUrl}/products/barcode/$barcode');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product by barcode');
    }
  }

  static Future<List<dynamic>> searchProducts(String query) async {
    try {
      final queryParam = query.isNotEmpty ? '?search=$query' : '';
      final response = await ApiService.get('${ApiConfig.baseUrl}/products$queryParam');
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['products'] ?? [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}
