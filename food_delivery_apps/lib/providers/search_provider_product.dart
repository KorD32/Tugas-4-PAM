import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class SearchProductProvider extends ChangeNotifier {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  bool _loading = false;
  final FirebaseService _firebaseService = FirebaseService();

  List<Product> get products => _filteredProducts;
  bool get loading => _loading;

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();

    try {
      _allProducts = await _firebaseService.fetchProducts();
      _applySearch();
    } catch (e) {
      debugPrint('Error fetching products for search: $e');
    }
    
    _loading = false;
    notifyListeners();
  }

  void updateSearch(String query) {
    _searchQuery = query.toLowerCase();
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery) ||
            product.category.toLowerCase().contains(_searchQuery) ||
            (product.shopName ?? '').toLowerCase().contains(_searchQuery) ||
            product.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }
}
