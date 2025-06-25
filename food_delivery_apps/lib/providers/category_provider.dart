import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  List<String> _categories = [
    'Fastfood',
    'Vegan',
    'Western',
    'Dessert',
  ];

  String? _selectedCategory;

  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  void setCategories(List<String> newCategories) {
    _categories = newCategories;
    notifyListeners();
  }
}
