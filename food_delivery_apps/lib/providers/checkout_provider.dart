import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/checkout.dart';
import '../services/user_service.dart';
import '../services/offline_cache_service.dart';

class CheckoutProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _orderHistory = [];
  final UserService _userService = UserService();
  bool _loading = false;
  StreamSubscription<List<Map<String, dynamic>>>? _orderHistorySubscription;

  List<Map<String, dynamic>> get orderHistory => _orderHistory;
  bool get loading => _loading;

  
  Future<void> loadOrderHistory() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) {
      return;
    }
    _loading = true;
    notifyListeners();

    try {
      _orderHistory.clear();
      final orders = await _userService.getOrderHistory(userId);
      _orderHistory.addAll(orders);
    } catch (e) {
      debugPrint('$e');
      
      
      try {
        final cachedOrders = await OfflineCacheService.getCachedOrderHistory(userId);
        if (cachedOrders != null && cachedOrders.isNotEmpty) {
          _orderHistory.clear();
          _orderHistory.addAll(cachedOrders);
        } else {
          debugPrint('gadak cache');
          
          
          final forcedCachedOrders = await OfflineCacheService.getCachedOrderHistoryForced(userId);
          if (forcedCachedOrders != null && forcedCachedOrders.isNotEmpty) {
            _orderHistory.clear();
            _orderHistory.addAll(forcedCachedOrders);
          } else {
            debugPrint('gadak cache');
          }
        }
      } catch (cacheError) {
        debugPrint('$cacheError');
      }
    }

    _loading = false;
    notifyListeners();
  }

  
  void listenToOrderHistory() {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    
    _orderHistorySubscription?.cancel();

    _orderHistorySubscription = _userService.getOrderHistoryStream(userId).listen(
      (orders) {
        _orderHistory.clear();
        _orderHistory.addAll(orders);
        
        
        OfflineCacheService.cacheOrderHistory(userId, orders).then((_) {
        }).catchError((e) {
          debugPrint('$e');
        });
        
        notifyListeners();
      },
      onError: (error) {
        debugPrint('$error');
        
        
        OfflineCacheService.getCachedOrderHistory(userId).then((cachedOrders) {
          if (cachedOrders != null && cachedOrders.isNotEmpty) {
            _orderHistory.clear();
            _orderHistory.addAll(cachedOrders);
            notifyListeners();
          }
        }).catchError((cacheError) {
          debugPrint('$cacheError');
        });
      },
    );
  }

  
  Future<bool> createCheckout({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String paymentMethod,
    required int totalAmount,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return false;

    _loading = true;
    notifyListeners();

    try {
      final checkout = Checkout(
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        paymentMethod: paymentMethod,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
      );

      await _userService.createCheckout(
        userId: userId,
        checkout: checkout,
        cartItems: cartItems,
      );

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('gagal buat checkout: $e');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    try {
      await _userService.updateOrderStatus(
        userId: userId,
        orderId: orderId,
        status: status,
      );
    } catch (e) {
      debugPrint('gagal update order status: $e');
    }
  }

  
  Map<String, dynamic>? getOrderById(String orderId) {
    try {
      return _orderHistory.firstWhere((order) => order['id'] == orderId);
    } catch (e) {
      return null;
    }
  }

  
  int getTotalSpent() {
    int total = 0;
    for (var order in _orderHistory) {
      total += order['totalAmount'] as int;
    }
    return total;
  }

  
  int get orderCount => _orderHistory.length;

  Future<void> clearCheckoutData() async {
    final userId = UserService.getCurrentUserId();
    
    _orderHistory.clear();
    _loading = false;
    _orderHistorySubscription?.cancel();
    _orderHistorySubscription = null;
    
    
    if (userId != null) {
      await OfflineCacheService.clearOrderHistoryCache(userId);
    }
    
    notifyListeners();
  }
}
