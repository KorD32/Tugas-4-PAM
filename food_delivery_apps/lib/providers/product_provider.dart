import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _loading = false;

  List<Product> get products => _products;
  bool get loading => _loading;

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();
    _products = await ApiService().fetchProducts();
    _loading = false;
    notifyListeners();
  }

  List<Product> getByCategory(String? category) {
    if (category == null || category == 'All') return _products;
    return _products
        .where((product) =>
            product.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
