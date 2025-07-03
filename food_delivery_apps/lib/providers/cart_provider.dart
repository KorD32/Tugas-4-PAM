import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/product.dart';
import '../services/user_service.dart';

class CartProvider with ChangeNotifier {
  final Map<int, Map<String, dynamic>> _cart = {};
  final Map<int, bool> _selectedItems = {};
  final UserService _userService = UserService();
  bool _loading = false;
  bool _initialized = false;
  StreamSubscription<List<Map<String, dynamic>>>? _cartSubscription;

  Map<int, Map<String, dynamic>> get cart => _cart;
  Map<int, bool> get selectedItems => _selectedItems;
  bool get loading => _loading;
  bool get isInitialized => _initialized;

  
  Future<void> loadCart() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) {
      debugPrint('gagal load ke cart, tidak ada user ID');
      return;
    }

    if (_loading || _initialized) {
      debugPrint('Cart sudah diload atau sedang loading, skip');
      return;
    }

    debugPrint('load cart user dari: $userId');
    _loading = true;
    notifyListeners();

    try {
      final cartItems = await _userService.getCartItems(userId)
        .timeout(Duration(seconds: 5));
      debugPrint('load ${cartItems.length} cart dari firebase');
      
      _cart.clear();
      _selectedItems.clear();

      for (var item in cartItems) {
        final productId = item['productId'] as int;
        _cart[productId] = item;
        _selectedItems[productId] = true;
      }
      
      _initialized = true;
      debugPrint('cart loaded berhasil: ${_cart.length} di cart');
    } catch (e) {
      debugPrint('gagal loading cart: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> refreshCart() async {
    _initialized = false;
    await loadCart();
  }

  
  void listenToCartUpdates() {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    
    _cartSubscription?.cancel();

    _cartSubscription = _userService.getCartItemsStream(userId).listen((cartItems) {
      _cart.clear();
      _selectedItems.clear();

      for (var item in cartItems) {
        final productId = item['productId'] as int;
        _cart[productId] = item;
        _selectedItems[productId] = true;
      }
      
      notifyListeners();
    });
  }

  Future<void> addToCart(Product product) async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    try {
      await _userService.addToCart(
        userId: userId,
        product: product,
        quantity: 1,
      );
      
    } catch (e) {
      debugPrint('gagal tambah ke cart: $e');
    }
  }

  Future<void> removeFromCart(Product product) async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    try {
      final productId = product.id;
      if (_cart.containsKey(productId)) {
        final currentQuantity = _cart[productId]!['quantity'] as int;
        if (currentQuantity > 1) {
          await _userService.updateCartItemQuantity(
            userId: userId,
            productId: productId,
            quantity: currentQuantity - 1,
          );
        } else {
          await _userService.removeFromCart(
            userId: userId,
            productId: productId,
          );
        }
      }
    } catch (e) {
      debugPrint('gagal remove cart: $e');
    }
  }

  Future<void> deleteItem(Product product) async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    try {
      await _userService.removeFromCart(
        userId: userId,
        productId: product.id,
      );
    } catch (e) {
      debugPrint('delete gagal: $e');
    }
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    try {
      await _userService.updateCartItemQuantity(
        userId: userId,
        productId: productId,
        quantity: quantity,
      );
    } catch (e) {
      debugPrint('gagal update quantity: $e');
    }
  }

  Future<void> clearCart() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    try {
      await _userService.clearCart(userId);
    } catch (e) {
      debugPrint('gagal clear cart: $e');
    }
  }

  void toggleSelection(int productId) {
    _selectedItems[productId] = !(_selectedItems[productId] ?? false);
    notifyListeners();
  }

  Map<int, Map<String, dynamic>> getSelectedCartItems() {
    final selected = <int, Map<String, dynamic>>{};
    _cart.forEach((productId, item) {
      if (_selectedItems[productId] ?? false) {
        selected[productId] = item;
      }
    });
    return selected;
  }

  int getTotalPrice() {
    int total = 0;
    _cart.forEach((productId, item) {
      if (_selectedItems[productId] ?? false) {
        final priceValue = item['finalPrice'];
        final quantityValue = item['quantity'];
        
        int price = 0;
        int quantity = 0;
        
        if (priceValue is int) {
          price = priceValue;
        } else if (priceValue is String) {
          price = int.tryParse(priceValue) ?? 0;
        }
        
        if (quantityValue is int) {
          quantity = quantityValue;
        } else if (quantityValue is String) {
          quantity = int.tryParse(quantityValue) ?? 0;
        }
        
        total += price * quantity;
      }
    });
    return total;
  }

  int getTotalSelectedItems() {
    int total = 0;
    _cart.forEach((productId, item) {
      if (_selectedItems[productId] ?? false) {
        final quantityValue = item['quantity'];
        int quantity = 0;
        
        if (quantityValue is int) {
          quantity = quantityValue;
        } else if (quantityValue is String) {
          quantity = int.tryParse(quantityValue) ?? 0;
        }
        
        total += quantity;
      }
    });
    return total;
  }

  Future<void> removeSelectedItems() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    try {
      final selectedProductIds = _selectedItems.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      for (int productId in selectedProductIds) {
        await _userService.removeFromCart(
          userId: userId,
          productId: productId,
        );
      }
    } catch (e) {
      debugPrint('gagal remove item yang dipilih: $e');
    }
  }

  
  List<Map<String, dynamic>> getCartItemsForCheckout() {
    final selectedItems = getSelectedCartItems();
    return selectedItems.values.toList();
  }

  
  int get cartItemCount {
    int count = 0;
    _cart.forEach((productId, item) {
      count += item['quantity'] as int;
    });
    return count;
  }

  
  bool isInCart(int productId) {
    return _cart.containsKey(productId);
  }

  
  int getProductQuantity(int productId) {
    return _cart[productId]?['quantity'] ?? 0;
  }

  Future<void> addToCartWithQuantity(Product product, int quantity) async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    try {
      
      if (_cart.containsKey(product.id)) {
        
        final currentItem = _cart[product.id]!;
        final currentQuantityValue = currentItem['quantity'];
        int currentQuantity = 0;
        
        if (currentQuantityValue is int) {
          currentQuantity = currentQuantityValue;
        } else if (currentQuantityValue is String) {
          currentQuantity = int.tryParse(currentQuantityValue) ?? 0;
        }
        
        await _userService.updateCartItemQuantity(
          userId: userId,
          productId: product.id,
          quantity: currentQuantity + quantity,
        );
      } else {
        
        await _userService.addToCart(
          userId: userId,
          product: product,
          quantity: quantity,
        );
      }
      
    } catch (e) {
      debugPrint('gagal menambahkan cart dgn quantity: $e');
    }
  }

  
  void clearCartData() {
    _cart.clear();
    _selectedItems.clear();
    _cartSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
