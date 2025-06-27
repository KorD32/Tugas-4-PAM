import 'package:flutter/material.dart';

class CheckoutItem {
  final String name;
  final String image;
  final int quantity;
  final int price;
  final DateTime dateTime;

  CheckoutItem({
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
    required this.dateTime,
  });
}

class CheckoutProvider with ChangeNotifier {
  final List<CheckoutItem> _history = [];

  List<CheckoutItem> get history => _history;

  void checkoutItem({
    required String name,
    required String image,
    required int quantity,
    required int price,
  }) {
    _history.add(
      CheckoutItem(
        name: name,
        image: image,
        quantity: quantity,
        price: price,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
