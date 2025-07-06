import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class OfflineCacheService {
  static SharedPreferences? _prefs;
  
  static const String _productsKey = 'cached_products';
  static const String _cartKey = 'cached_cart_';
  static const String _userProfileKey = 'cached_user_profile_';
  static const String _orderHistoryKey = 'cached_order_history_';
  static const String _lastUpdateKey = 'last_update_';
  static const String _connectivityKey = 'last_online_time';
  
  static const Duration _productsCacheExpiration = Duration(hours: 24);
  static const Duration _userDataCacheExpiration = Duration(hours: 12);
  static const Duration _orderHistoryCacheExpiration = Duration(days: 7);

  static Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      
      await clearExpiredCache();
      
      debugPrint('successfully');
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<SharedPreferences> get prefs async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  
  static Future<bool> isOnline() async {
    try {
      if (kIsWeb) {
        try {
          await Future.delayed(Duration(milliseconds: 100)); 
          await _updateLastOnlineTime();
          return true; 
        } catch (e) {
          return false;
        }
      } else {
        final result = await InternetAddress.lookup('google.com')
            .timeout(Duration(seconds: 3));
        final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        
        if (isConnected) {
          await _updateLastOnlineTime();
        }
        
        return isConnected;
      }
    } catch (e) {
      debugPrint('$e');
      return false;
    }
  }

  static Future<void> _updateLastOnlineTime() async {
    try {
      final prefsInstance = await prefs;
      await prefsInstance.setInt(_connectivityKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<DateTime?> getLastOnlineTime() async {
    try {
      final prefsInstance = await prefs;
      final timestamp = prefsInstance.getInt(_connectivityKey);
      return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }
  
  static Future<void> cacheProducts(List<Product> products) async {
    try {
      final prefsInstance = await prefs;
      final productsJson = products.map((p) => p.toJson()).toList();
      await prefsInstance.setString(_productsKey, json.encode(productsJson));
      await prefsInstance.setInt(_lastUpdateKey + 'products', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<List<Product>?> getCachedProducts() async {
    try {
      final prefsInstance = await prefs;
      final productsString = prefsInstance.getString(_productsKey);
      final lastUpdate = prefsInstance.getInt(_lastUpdateKey + 'products');
      
      if (productsString == null || lastUpdate == null) {
        return null;
      }

      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final age = DateTime.now().difference(cacheTime);
      
      
      final isOnlineStatus = await isOnline();
      final maxAge = isOnlineStatus ? _productsCacheExpiration : Duration(days: 7); 
      
      if (age > maxAge) {
        debugPrint('expired (${age.inHours}, max: ${maxAge.inHours}');
        
        if (!isOnlineStatus) {
          debugPrint('pakai expired cache karena offline');
        } else {
          return null;
        }
      }

      final List<dynamic> productsJson = json.decode(productsString);
      final products = productsJson.map((json) => Product.fromJson(json)).toList();
      return products;
    } catch (e) {
      debugPrint(' $e');
      return null;
    }
  }

  
  
  static Future<void> cacheCart(String userId, Map<int, Map<String, dynamic>> cart) async {
    try {
      final prefsInstance = await prefs;
      final cartJson = cart.map((key, value) => MapEntry(key.toString(), value));
      await prefsInstance.setString(_cartKey + userId, json.encode(cartJson));
      await prefsInstance.setInt(_lastUpdateKey + 'cart_$userId', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint(' $e');
    }
  }

  static Future<Map<int, Map<String, dynamic>>?> getCachedCart(String userId) async {
    try {
      final prefsInstance = await prefs;
      final cartString = prefsInstance.getString(_cartKey + userId);
      final lastUpdate = prefsInstance.getInt(_lastUpdateKey + 'cart_$userId');
      
      if (cartString == null || lastUpdate == null) {
        return null;
      }

      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final age = DateTime.now().difference(cacheTime);
      
      
      final isOnlineStatus = await isOnline();
      final maxAge = isOnlineStatus ? _userDataCacheExpiration : Duration(days: 7); 
      
      if (age > maxAge) {
        
        if (!isOnlineStatus) {
        } else {
          return null;
        }
      }

      final Map<String, dynamic> cartJson = json.decode(cartString);
      final cart = cartJson.map((key, value) => MapEntry(int.parse(key), Map<String, dynamic>.from(value)));
      return cart;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearCartCache(String userId) async {
    try {
      final prefsInstance = await prefs;
      await prefsInstance.remove(_cartKey + userId);
      await prefsInstance.remove(_lastUpdateKey + 'cart_$userId');
    } catch (e) {
      debugPrint(' $e');
    }
  }

  
  
  static Future<void> cacheUserProfile(String userId, Map<String, dynamic> profile) async {
    try {
      final prefsInstance = await prefs;
      await prefsInstance.setString(_userProfileKey + userId, json.encode(profile));
      await prefsInstance.setInt(_lastUpdateKey + 'profile_$userId', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('🗄️ Error caching user profile: $e');
    }
  }

  static Future<Map<String, dynamic>?> getCachedUserProfile(String userId) async {
    try {
      final prefsInstance = await prefs;
      final profileString = prefsInstance.getString(_userProfileKey + userId);
      final lastUpdate = prefsInstance.getInt(_lastUpdateKey + 'profile_$userId');
      
      if (profileString == null || lastUpdate == null) {
        return null;
      }

      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      if (DateTime.now().difference(cacheTime) > _userDataCacheExpiration) {
        return null;
      }

      final profile = Map<String, dynamic>.from(json.decode(profileString));
      return profile;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearUserProfileCache(String userId) async {
    try {
      final prefsInstance = await prefs;
      await prefsInstance.remove(_userProfileKey + userId);
      await prefsInstance.remove(_lastUpdateKey + 'profile_$userId');
    } catch (e) {
      debugPrint('$e');
    }
  }

  
  
  static Future<void> cacheOrderHistory(String userId, List<Map<String, dynamic>> orders) async {
    try {
      final prefsInstance = await prefs;
      await prefsInstance.setString(_orderHistoryKey + userId, json.encode(orders));
      await prefsInstance.setInt(_lastUpdateKey + 'orders_$userId', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<List<Map<String, dynamic>>?> getCachedOrderHistory(String userId) async {
    try {
      final prefsInstance = await prefs;
      final ordersString = prefsInstance.getString(_orderHistoryKey + userId);
      final lastUpdate = prefsInstance.getInt(_lastUpdateKey + 'orders_$userId');
      
      if (ordersString == null || lastUpdate == null) {
        return null;
      }

      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final age = DateTime.now().difference(cacheTime);
      
      
      final isOnlineStatus = await isOnline();
      final maxAge = isOnlineStatus ? _userDataCacheExpiration : Duration(days: 7); 
      
      if (age > maxAge) {
        
        if (!isOnlineStatus) {
        } else {
          return null;
        }
      }

      final List<dynamic> ordersJson = json.decode(ordersString);
      final orders = ordersJson.map((json) => Map<String, dynamic>.from(json)).toList();
      return orders;
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }

  static Future<void> clearOrderHistoryCache(String userId) async {
    try {
      final prefsInstance = await prefs;
      await prefsInstance.remove(_orderHistoryKey + userId);
      await prefsInstance.remove(_lastUpdateKey + 'orders_$userId');
    } catch (e) {
      debugPrint('$e');
    }
  }

  
  
  static Future<List<Map<String, dynamic>>?> getCachedOrderHistoryForced(String userId) async {
    try {
      final prefsInstance = await prefs;
      final ordersString = prefsInstance.getString(_orderHistoryKey + userId);
      
      if (ordersString == null) {
        return null;
      }

      final List<dynamic> ordersJson = json.decode(ordersString);
      final orders = ordersJson.map((json) => Map<String, dynamic>.from(json)).toList();
      return orders;
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }

  static Future<List<Product>?> getCachedProductsForced() async {
    try {
      final prefsInstance = await prefs;
      final productsString = prefsInstance.getString(_productsKey);
      
      if (productsString == null) {
        return null;
      }

      final List<dynamic> productsJson = json.decode(productsString);
      final products = productsJson.map((json) => Product.fromJson(json)).toList();
      return products;
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }

  static Future<Map<int, Map<String, dynamic>>?> getCachedCartForced(String userId) async {
    try {
      final prefsInstance = await prefs;
      final cartString = prefsInstance.getString(_cartKey + userId);
      
      if (cartString == null) {
        return null;
      }

      final Map<String, dynamic> cartJson = json.decode(cartString);
      final cart = cartJson.map((key, value) => MapEntry(int.parse(key), Map<String, dynamic>.from(value)));
      return cart;
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }

  
  
  static Future<void> clearAllCache() async {
    try {
      final prefsInstance = await prefs;
      final keys = prefsInstance.getKeys().toList();
      
      for (final key in keys) {
        if (key.startsWith('cached_') || key.startsWith('last_update_')) {
          await prefsInstance.remove(key);
        }
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<void> clearExpiredCache() async {
    try {
      final prefsInstance = await prefs;
      final keys = prefsInstance.getKeys().toList();
      final now = DateTime.now();
      int removedCount = 0;
      
      for (final key in keys) {
        if (key.startsWith('last_update_')) {
          final timestamp = prefsInstance.getInt(key);
          if (timestamp != null) {
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final age = now.difference(cacheTime);
            
            
            bool isExpired = false;
            if (key.contains('products')) {
              isExpired = age > _productsCacheExpiration;
            } else if (key.contains('orders')) {
              isExpired = age > _orderHistoryCacheExpiration;
            } else {
              isExpired = age > _userDataCacheExpiration;
            }
            
            if (isExpired) {
              
              final cacheKey = key.replaceFirst('last_update_', 'cached_');
              await prefsInstance.remove(key);
              await prefsInstance.remove(cacheKey);
              removedCount++;
            }
          }
        }
      }
      
      if (removedCount > 0) {
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<void> clearUserData(String userId) async {
    try {
      await clearCartCache(userId);
      await clearUserProfileCache(userId);
      await clearOrderHistoryCache(userId);
    } catch (e) {
      debugPrint('$e');
    }
  }

  
  
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefsInstance = await prefs;
      final keys = prefsInstance.getKeys().toList();
      int cacheCount = 0;
      int totalSize = 0;
      final Map<String, int> categoryCounts = {
        'products': 0,
        'cart': 0,
        'profile': 0,
        'orders': 0,
        'other': 0,
      };
      
      for (final key in keys) {
        if (key.startsWith('cached_')) {
          cacheCount++;
          final value = prefsInstance.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
          
          
          if (key.contains('products')) {
            categoryCounts['products'] = categoryCounts['products']! + 1;
          } else if (key.contains('cart')) {
            categoryCounts['cart'] = categoryCounts['cart']! + 1;
          } else if (key.contains('profile')) {
            categoryCounts['profile'] = categoryCounts['profile']! + 1;
          } else if (key.contains('orders')) {
            categoryCounts['orders'] = categoryCounts['orders']! + 1;
          } else {
            categoryCounts['other'] = categoryCounts['other']! + 1;
          }
        }
      }
      
      final lastOnline = await getLastOnlineTime();
      
      return {
        'cacheCount': cacheCount,
        'totalSizeBytes': totalSize,
        'totalSizeKB': (totalSize / 1024).toStringAsFixed(2),
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'categoryCounts': categoryCounts,
        'lastOnlineTime': lastOnline?.toIso8601String(),
        'isOnline': await isOnline(),
      };
    } catch (e) {
      debugPrint('🗄️ Error getting cache info: $e');
      return {
        'cacheCount': 0,
        'totalSizeBytes': 0,
        'totalSizeKB': '0',
        'totalSizeMB': '0',
        'categoryCounts': {},
        'lastOnlineTime': null,
        'isOnline': false,
      };
    }
  }

  
  
  static Future<bool> hasCachedData() async {
    try {
      final prefsInstance = await prefs;
      final keys = prefsInstance.getKeys();
      return keys.any((key) => key.startsWith('cached_'));
    } catch (e) {
      debugPrint('$e');
      return false;
    }
  }

  static Future<bool> isCacheValid(String cacheType, String? userId) async {
    try {
      final prefsInstance = await prefs;
      String updateKey;
      
      switch (cacheType) {
        case 'products':
          updateKey = _lastUpdateKey + 'products';
          break;
        case 'cart':
          updateKey = _lastUpdateKey + 'cart_$userId';
          break;
        case 'profile':
          updateKey = _lastUpdateKey + 'profile_$userId';
          break;
        case 'orders':
          updateKey = _lastUpdateKey + 'orders_$userId';
          break;
        default:
          return false;
      }
      
      final lastUpdate = prefsInstance.getInt(updateKey);
      if (lastUpdate == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final age = DateTime.now().difference(cacheTime);
      
      if (cacheType == 'products') {
        return age <= _productsCacheExpiration;
      } else if (cacheType == 'orders') {
        return age <= _orderHistoryCacheExpiration;
      } else {
        return age <= _userDataCacheExpiration;
      }
    } catch (e) {
      debugPrint('$e');
      return false;
    }
  }
}
