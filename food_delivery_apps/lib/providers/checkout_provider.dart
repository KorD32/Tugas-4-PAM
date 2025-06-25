import 'package:flutter/material.dart';
import 'package:foodexpress/models/checkout.dart';

class CheckoutProvider extends ChangeNotifier {
  final List<CheckoutItem> _history = [];

  List<CheckoutItem> get history => _history;

  void checkoutItem({
    required String name,
    required int price,
    required String imagePath,
    required int quantity,
  }) {
    _history.add(CheckoutItem(
      name: name,
      price: price,
      image: imagePath,
      quantity: quantity,
      dateTime: DateTime.now(),
    ));

    notifyListeners();
  }
}
