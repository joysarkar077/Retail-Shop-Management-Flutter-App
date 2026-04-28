import 'dart:convert';
import 'api_service.dart';
import '../config/api_config.dart';

class OrderService {
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    final response = await ApiService.post('${ApiConfig.baseUrl}/orders', orderData);
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to complete checkout');
    }
  }

  static Future<List<dynamic>> getOrders({String? status}) async {
    String url = '${ApiConfig.baseUrl}/orders';
    if (status != null) {
      url += '?status=$status';
    }
    
    final response = await ApiService.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['orders'] ?? [];
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<List<dynamic>> getMyOrders({String? status}) async {
    String url = '${ApiConfig.baseUrl}/orders/my';
    if (status != null && status.isNotEmpty) {
      url += '?status=$status';
    }
    
    final response = await ApiService.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['orders'] ?? [];
    } else {
      throw Exception('Failed to load my orders');
    }
  }

  static Future<void> voidOrder(String orderId, String reason) async {
    final response = await ApiService.patch('${ApiConfig.baseUrl}/orders/$orderId/void', {
      'voidReason': reason,
    });
    
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to void order');
    }
  }
}
