// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import '../models/food_item.dart';
// import provider/services untuk cart/order

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FoodItem item = ModalRoute.of(context)!.settings.arguments as FoodItem;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(item.imageUrl, height: 200, fit: BoxFit.cover),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(item.name, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Panggil fungsi tambah ke cart / CRUD order lokal/cloud
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ditambahkan ke cart/order!')));
              },
              child: Text('Pesan Sekarang'),
            ),
          )
        ],
      ),
    );
  }
}
