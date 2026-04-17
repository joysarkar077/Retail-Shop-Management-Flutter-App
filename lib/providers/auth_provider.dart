import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  UserModel? get user => _user;
  String? get role => _user?.role;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    _token = await _storage.read(key: 'jwt_token');

    if (_token != null) {
      try {
        final response = await ApiService.get(ApiConfig.authMe);
        if (response.statusCode == 200) {
          _user = UserModel.fromJson(jsonDecode(response.body));
        } else {
          await logout();
        }
      } catch (e) {
        await logout();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(ApiConfig.authLogin, {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = UserModel.fromJson(data['user']);

        await _storage.write(key: 'jwt_token', value: _token);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }
}
