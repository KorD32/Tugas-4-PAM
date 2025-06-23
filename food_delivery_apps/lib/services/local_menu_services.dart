// lib/services/local_menu_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';

class LocalMenuService {
  static const String _menuKey = 'local_menus';

  // READ: Get all local menus
  Future<List<FoodItem>> getLocalMenus() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_menuKey) ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => FoodItem.fromJson(item)).toList();
  }

  // CREATE: Add new menu
  Future<void> addMenu(FoodItem item) async {
    final menus = await getLocalMenus();
    menus.add(item);
    await _saveMenus(menus);
  }

  // UPDATE: Edit menu
  Future<void> updateMenu(FoodItem item) async {
    final menus = await getLocalMenus();
    final idx = menus.indexWhere((m) => m.id == item.id);
    if (idx != -1) {
      menus[idx] = item;
      await _saveMenus(menus);
    }
  }

  // DELETE: Remove menu
  Future<void> deleteMenu(String id) async {
    final menus = await getLocalMenus();
    menus.removeWhere((item) => item.id == id);
    await _saveMenus(menus);
  }

  // Helper: Save list to SharedPreferences
  Future<void> _saveMenus(List<FoodItem> menus) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(menus.map((item) => item.toJson()).toList());
    await prefs.setString(_menuKey, jsonString);
  }
}
