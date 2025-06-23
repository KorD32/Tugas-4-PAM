import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class ApiService {
  static const baseUrl = 'https://www.themealdb.com/api/json/v1/1/search.php?s=';

  Future<List<FoodItem>> fetchMenus([String query = '']) async {
    final response = await http.get(Uri.parse('$baseUrl$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List)
            .map((item) => FoodItem.fromJson(item))
            .toList();
      }
    }
    return [];
  }
}
