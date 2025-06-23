// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/food_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FoodItem> _menus = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchMenus();
  }

  void _fetchMenus() async {
    setState(() { _loading = true; });
    _menus = await ApiService().fetchMenus();
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FoodExpress'), actions: [
        IconButton(icon: Icon(Icons.person), onPressed: () {
          Navigator.pushNamed(context, '/profile');
        }),
        IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {
          Navigator.pushNamed(context, '/cart');
        }),
      ]),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _menus.length,
              itemBuilder: (_, i) => ListTile(
                leading: Image.network(_menus[i].imageUrl, width: 60, height: 60),
                title: Text(_menus[i].name),
                onTap: () => Navigator.pushNamed(context, '/detail', arguments: _menus[i]),
              ),
            ),
    );
  }
}
