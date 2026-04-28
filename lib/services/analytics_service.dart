import 'dart:convert';
import 'api_service.dart';
import '../config/api_config.dart';

class AnalyticsService {
  static Future<Map<String, dynamic>> getSummary({String period = 'today', String? shopId}) async {
    String url = '${ApiConfig.baseUrl}/analytics/summary?period=$period';
    if (shopId != null) url += '&shopId=$shopId';
    final response = await ApiService.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load summary');
    }
  }

  static Future<List<dynamic>> getRevenueSeries({String period = 'week', String? shopId}) async {
    String url = '${ApiConfig.baseUrl}/analytics/revenue?period=$period';
    if (shopId != null) url += '&shopId=$shopId';
    final response = await ApiService.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load revenue series');
    }
  }

  static Future<List<dynamic>> getTopProducts({int limit = 5, String? shopId}) async {
    String url = '${ApiConfig.baseUrl}/analytics/top-products?limit=$limit';
    if (shopId != null) url += '&shopId=$shopId';
    final response = await ApiService.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load top products');
    }
  }
}
