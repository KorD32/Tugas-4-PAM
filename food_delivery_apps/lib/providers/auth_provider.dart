import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? user;

  bool _loading = false;
  String? _error;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> register(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      user = await _authService.register(email, password);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      user = await _authService.login(email, password);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    notifyListeners();
  }
}
