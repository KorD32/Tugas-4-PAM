import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartProvider extends ChangeNotifier {
  static const String _cartKey = 'cart_items';
  List<FoodItem> _cart = [];

  List<FoodItem> get cart => _cart;

  CartProvider() {
    loadCart();
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cartKey) ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);
    _cart = jsonList.map((item) => FoodItem.fromJson(item)).toList();
    notifyListeners();
  }

  Future<void> addToCart(FoodItem item) async {
    _cart.add(item);
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeFromCart(String id) async {
    _cart.removeWhere((item) => item.id == id);
    await _saveCart();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cart.clear();
    await _saveCart();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_cart.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, jsonString);
  }
}
