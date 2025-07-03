import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String? username;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<void> register(
      String email, String password, String usernameInput, String namaLengkap, String noHandphone, String alamatPengiriman) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      user = await _authService.register(email, password, usernameInput, namaLengkap, noHandphone, alamatPengiriman);
      username = usernameInput;

      await _firestore.collection('users').doc(user!.uid).set({
        'email': email,
        'username': usernameInput,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await user!.updateDisplayName(usernameInput);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _error = 'Email sudah terdaftar.';
          break;
        case 'invalid-email':
          _error = 'Format email tidak valid.';
          break;
        case 'weak-password':
          _error = 'Password terlalu lemah.';
          break;
        default:
          _error = 'Registrasi gagal: ${e.message}';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan tidak dikenal.';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      user = await _authService.login(email, password);

      final doc = await _firestore.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        username = doc.data()?['username'];
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _error = 'Akun dengan email ini tidak ditemukan.';
          break;
        case 'wrong-password':
          _error = 'Password salah.';
          break;
        case 'invalid-email':
          _error = 'Format email tidak valid.';
          break;
        default:
          _error = 'Login gagal: ${e.message}';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan saat login.';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    username = null;
    notifyListeners();
  }
}
