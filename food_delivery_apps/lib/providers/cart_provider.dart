import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  // Gunakan Map<Product, int> untuk menyimpan produk dan jumlahnya
  final Map<Product, int> _cart = {};

  Map<Product, int> get cart => _cart;

  void addToCart(Product product) {
    if (_cart.containsKey(product)) {
      _cart[product] = _cart[product]! + 1;
    } else {
      _cart[product] = 1;
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    if (_cart.containsKey(product)) {
      if (_cart[product]! > 1) {
        _cart[product] = _cart[product]! - 1;
      } else {
        _cart.remove(product);
      }
      notifyListeners();
    }
  }

  void deleteItem(Product product) {
    _cart.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  int getTotalPrice() {
    int total = 0;
    _cart.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  int getItemCount() {
    int count = 0;
    _cart.forEach((_, qty) {
      count += qty;
    });
    return count;
  }
}
