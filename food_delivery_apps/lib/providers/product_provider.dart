import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _loading = false;
  final FirebaseService _firebaseService = FirebaseService();

  List<Product> get products => _products;
  bool get loading => _loading;

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();
    
    try {
      _products = await _firebaseService.fetchProducts();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      // If there's an error and no products exist, initialize the database
      if (_products.isEmpty) {
        await initializeDatabase();
      }
    }
    
    _loading = false;
    notifyListeners();
  }

  Future<void> initializeDatabase() async {
    try {
      await _firebaseService.initializeProducts();
      _products = await _firebaseService.fetchProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing database: $e');
    }
  }

  // Real-time updates from Firebase
  void listenToProducts() {
    _firebaseService.getProductsStream().listen((products) {
      _products = products;
      notifyListeners();
    });
  }

  List<Product> getByCategory(String? category) {
    if (category == null || category == 'All') return _products;
    return _products
        .where((product) =>
            product.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
