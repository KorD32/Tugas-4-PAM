// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        children: [
          ListTile(title: Text('Email: [user email]')), // tampilkan email user
          ListTile(
            title: Text('Logout'),
            onTap: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          // Tampilkan histori pesanan dari Firestore
        ],
      ),
    );
  }
}
