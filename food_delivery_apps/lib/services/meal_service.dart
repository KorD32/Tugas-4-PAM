import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Fetch by huruf depan
  static Future<List<Meal>> fetchMealsByLetter(String letter) async {
    final url = Uri.parse('$_baseUrl/search.php?f=$letter');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List)
            .map((json) => Meal.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  /// ✅ Tambahkan ini untuk cari by nama
  static Future<List<Meal>> fetchMealsByName(String name) async {
    final url = Uri.parse('$_baseUrl/search.php?s=$name');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List)
            .map((json) => Meal.fromJson(json))
            .toList();
      }
    }
    return [];
  }
}
