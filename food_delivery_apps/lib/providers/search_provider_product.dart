import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class SearchProductProvider extends ChangeNotifier {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  bool _loading = false;

  List<Product> get products => _filteredProducts;
  bool get loading => _loading;

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();

    _allProducts = await ApiService().fetchProducts();
    _applySearch();
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
