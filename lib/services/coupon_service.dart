import 'dart:convert';
import 'api_service.dart';
import '../config/api_config.dart';

class CouponService {
  static Future<Map<String, dynamic>?> applyCoupon(String code) async {
    final response = await ApiService.post('${ApiConfig.baseUrl}/coupons/apply', {'code': code});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to apply coupon');
    }
  }

  static Future<List<dynamic>> getCoupons() async {
    final response = await ApiService.get('${ApiConfig.baseUrl}/coupons');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load coupons');
  }

  static Future<void> createCoupon(String code, double percentage) async {
    final response = await ApiService.post('${ApiConfig.baseUrl}/coupons', {
      'code': code,
      'discountPercentage': percentage,
    });
    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to create coupon');
    }
  }

  static Future<void> deleteCoupon(String id) async {
    final response = await ApiService.delete('${ApiConfig.baseUrl}/coupons/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete coupon');
    }
  }
}
