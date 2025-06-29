import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<Product, int> _cart = {};
  final Map<Product, bool> selectedItems = {};

  Map<Product, int> get cart => _cart;

  void addToCart(Product product) {
    if (_cart.containsKey(product)) {
      _cart[product] = _cart[product]! + 1;
    } else {
      _cart[product] = 1;
      selectedItems[product] = true;
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    if (_cart.containsKey(product)) {
      if (_cart[product]! > 1) {
        _cart[product] = _cart[product]! - 1;
      } else {
        _cart.remove(product);
        selectedItems.remove(product);
      }
      notifyListeners();
    }
  }

  void deleteItem(Product product) {
    _cart.remove(product);
    selectedItems.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    selectedItems.clear();
    notifyListeners();
  }

  void toggleSelection(Product product) {
    selectedItems[product] = !(selectedItems[product] ?? false);
    notifyListeners();
  }

  Map<Product, int> getSelectedCartItems() {
    final selected = <Product, int>{};
    _cart.forEach((product, qty) {
      if (selectedItems[product] ?? false) {
        selected[product] = qty;
      }
    });
    return selected;
  }

  int getTotalPrice() {
    int total = 0;
    _cart.forEach((product, quantity) {
      if (selectedItems[product] ?? false) {
        total += product.price * quantity;
      }
    });
    return total;
  }

  void removeSelectedItems() {
    selectedItems.keys
        .where((product) => selectedItems[product] == true)
        .toList()
        .forEach((product) => _cart.remove(product));
    selectedItems.removeWhere((key, value) => value == true);
    notifyListeners();
  }
}
