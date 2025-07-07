import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

class MealProvider with ChangeNotifier {
  List<Meal> _meals = [];
  bool _loading = false;

  List<Meal> get meals => _meals;
  bool get loading => _loading;

  Future<void> fetchMealsByLetter(String letter) async {
    if (letter.isEmpty) return;
    _loading = true;
    notifyListeners();
    try {
      _meals = await MealService.fetchMealsByLetter(letter);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMealsByName(String name) async {
    if (name.isEmpty) return;
    _loading = true;
    notifyListeners();
    try {
      _meals = await MealService.fetchMealsByName(name);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearMeals() {
    _meals = [];
    notifyListeners();
  }
}
