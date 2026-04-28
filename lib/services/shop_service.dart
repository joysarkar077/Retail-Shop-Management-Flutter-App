import 'dart:convert';
import 'api_service.dart';
import '../config/api_config.dart';

class ShopService {
  static Future<Map<String, dynamic>> getShopDetails(String shopId) async {
    final response = await ApiService.get('${ApiConfig.baseUrl}/shops/$shopId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load shop details');
  }

  static Future<Map<String, dynamic>> updateShop(String shopId, Map<String, dynamic> data) async {
    final response = await ApiService.put('${ApiConfig.baseUrl}/shops/$shopId', data);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update shop');
    }
  }
}
