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

  static Future<List<dynamic>> getLowStockAlerts() async {
    try {
      final response = await ApiService.get('${ApiConfig.baseUrl}/products/alerts/low-stock');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch low stock alerts: $e');
    }
  }

  static Future<void> adjustStock(String productId, int quantityChanged, String changeType, String note) async {
    try {
      final response = await ApiService.patch(
        '${ApiConfig.baseUrl}/products/$productId/stock',
        {
          'quantityChanged': quantityChanged,
          'changeType': changeType,
          'note': note,
        },
      );
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to adjust stock');
      }
    } catch (e) {
      throw Exception('Failed to adjust stock: $e');
    }
  }
}
