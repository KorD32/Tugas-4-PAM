import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/product.dart';
import '../services/user_service.dart';
import '../services/offline_cache_service.dart';

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
      debugPrint('Failed to load cart');
      return;
    }

    if (_loading) {
      return;
    }

    debugPrint('Loading cart for user: $userId');
    _loading = true;
    notifyListeners();

    try {
      final cartItems = await _userService
          .getCartItems(userId)
          .timeout(Duration(seconds: 10));

      _cart.clear();
      _selectedItems.clear();

      for (var item in cartItems) {
        final productIdValue = item['productId'];
        int? productId;

        if (productIdValue is int) {
          productId = productIdValue;
        } else if (productIdValue is String) {
          productId = int.tryParse(productIdValue);
        }

        if (productId != null) {
          _cart[productId] = item;
          _selectedItems[productId] = false;
        } else {}
      }

      _initialized = true;
      debugPrint('${_cart.length} items in cart');
    } catch (e) {
      debugPrint(' Error loading cart: $e');
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
    if (userId == null) {
      return;
    }

    _cartSubscription?.cancel();

    _cartSubscription =
        _userService.getCartItemsStream(userId).listen((cartItems) {
      _cart.clear();
      _selectedItems.clear();

      for (var item in cartItems) {
        final productIdValue = item['productId'];
        int? productId;

        if (productIdValue is int) {
          productId = productIdValue;
        } else if (productIdValue is String) {
          productId = int.tryParse(productIdValue);
        }

        if (productId != null) {
          _cart[productId] = item;
          _selectedItems[productId] = false;
        } else {
          debugPrint('invalid: $productIdValue');
        }
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
        final quantityValue = _cart[productId]!['quantity'];
        int currentQuantity = 0;

        if (quantityValue is int) {
          currentQuantity = quantityValue;
        } else if (quantityValue is String) {
          currentQuantity = int.tryParse(quantityValue) ?? 0;
        }

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
      final quantityValue = item['quantity'];
      int quantity = 0;

      if (quantityValue is int) {
        quantity = quantityValue;
      } else if (quantityValue is String) {
        quantity = int.tryParse(quantityValue) ?? 0;
      }

      count += quantity;
    });
    return count;
  }

  bool isInCart(int productId) {
    return _cart.containsKey(productId);
  }

  int getProductQuantity(int productId) {
    final item = _cart[productId];
    if (item == null) return 0;

    final quantityValue = item['quantity'];
    if (quantityValue is int) {
      return quantityValue;
    } else if (quantityValue is String) {
      return int.tryParse(quantityValue) ?? 0;
    }

    return 0;
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

  Future<void> clearCartData() async {
    final userId = UserService.getCurrentUserId();

    _cart.clear();
    _selectedItems.clear();
    _initialized = false;
    _loading = false;
    _cartSubscription?.cancel();
    _cartSubscription = null;

    if (userId != null) {
      await OfflineCacheService.clearCartCache(userId);
    }

    notifyListeners();
  }

  Future<void> incrementQuantity(int productId) async {
    final currentQuantity = getProductQuantity(productId);
    if (currentQuantity > 0) {
      await updateQuantity(productId, currentQuantity + 1);
    }
  }

  Future<void> decrementQuantity(int productId) async {
    final currentQuantity = getProductQuantity(productId);
    if (currentQuantity > 1) {
      await updateQuantity(productId, currentQuantity - 1);
    } else if (currentQuantity == 1) {
      await updateQuantity(productId, 0);
    }
  }

  Future<void> removeProductFromCart(int productId) async {
    await updateQuantity(productId, 0);
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
