import 'dart:io' show Platform;

class ApiConfig {
  static String get baseUrl {
    // For Android emulator, use 10.0.2.2. For physical devices or others, use network IP or localhost.
    if (Platform.isAndroid) {
      return 'http://192.168.0.78:5000/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }

  static String get authLogin => '$baseUrl/auth/login';
  static String get authRegister => '$baseUrl/auth/register';
  static String get authMe => '$baseUrl/auth/me';

  static String get products => '$baseUrl/products';
  static String get lowStock => '$baseUrl/products/alerts/low-stock';

  static String get categories => '$baseUrl/categories';
}
