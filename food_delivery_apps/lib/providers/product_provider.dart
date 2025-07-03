import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _loading = false;
  bool _initialized = false;
  final FirebaseService _firebaseService = FirebaseService();

  List<Product> get products => _products;
  bool get loading => _loading;
  bool get isInitialized => _initialized;

  Future<void> fetchProducts() async {
    if (_loading) return; 
    
    if (_products.isNotEmpty && _initialized) {
      debugPrint('Products sudah ada, skip fetch');
      return;
    }
    
    _loading = true;
    notifyListeners();
    
    try {
      _products = await _firebaseService.fetchProducts();
      _initialized = true;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      
      if (_products.isEmpty) {
        await initializeDatabase();
      }
    }
    
    _loading = false;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    _initialized = false; 
    await fetchProducts();
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
