// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
// import provider/local service untuk CRUD cart

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Misal list cart dari Provider
    // final cart = context.watch<CartProvider>().cartItems;

    return Scaffold(
      appBar: AppBar(title: Text('Cart')),      
      body: Center(
        child: Text(
          'Cart is empty', // Ganti dengan logika untuk menampilkan cart items
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
