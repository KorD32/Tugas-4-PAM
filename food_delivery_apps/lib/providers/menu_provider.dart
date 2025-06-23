import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';

class MenuProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  List<FoodItem> _menus = [];
  bool _loading = false;
  String? _error;

  List<FoodItem> get menus => _menus;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchMenus([String query = '']) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _menus = await apiService.fetchMenus(query);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
}
