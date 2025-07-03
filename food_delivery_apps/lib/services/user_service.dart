import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/checkout.dart';

class UserService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String username,
    String? name,
    int? age,
    String? phone,
    String? address,
  }) async {
    try {
      await _database.child('users').child(userId).set({
        'email': email,
        'username': username,
        'name': name ?? '',
        'age': age ?? 0,
        'phone': phone ?? '',
        'address': address ?? '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('gagal buat user: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final snapshot = await _database.child('users').child(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final dynamic data = snapshot.value;
        if (data is Map<dynamic, dynamic>) {
          return Map<String, dynamic>.from(data);
        }
      }
      return null;
    } catch (e) {
      throw Exception('gagal get user: $e');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? name,
    int? age,
    String? phone,
    String? address,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (username != null) updates['username'] = username;
      if (name != null) updates['name'] = name;
      if (age != null) updates['age'] = age;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;

      await _database.child('users').child(userId).update(updates);
    } catch (e) {
      throw Exception('gagal update user: $e');
    }
  }

  
  Future<void> addToCart({
    required String userId,
    required Product product,
    required int quantity,
  }) async {
    try {
      final cartRef = _database.child('users').child(userId).child('cart');
      final productId = product.id.toString();
      
      
      final snapshot = await cartRef.child(productId).get();
      
      if (snapshot.exists) {
        
        final existingData = Map<String, dynamic>.from(snapshot.value as Map);
        final newQuantity = (existingData['quantity'] as int) + quantity;
        await cartRef.child(productId).update({
          'quantity': newQuantity,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        
        await cartRef.child(productId).set({
          'productId': product.id,
          'name': product.name,
          'price': product.price,
          'finalPrice': product.finalPrice,
          'imageUrl': product.imageUrl,
          'category': product.category,
          'shopName': product.shopName,
          'isPromos': product.isPromos,
          'quantity': quantity,
          'addedAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw Exception('gagal tambah cart: $e');
    }
  }

  Future<void> updateCartItemQuantity({
    required String userId,
    required int productId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(userId: userId, productId: productId);
        return;
      }

      await _database
          .child('users')
          .child(userId)
          .child('cart')
          .child(productId.toString())
          .update({
        'quantity': quantity,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('gagal update cart quantity: $e');
    }
  }

  Future<void> removeFromCart({
    required String userId,
    required int productId,
  }) async {
    try {
      await _database
          .child('users')
          .child(userId)
          .child('cart')
          .child(productId.toString())
          .remove();
    } catch (e) {
      throw Exception('gagal hapus cart: $e');
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      await _database.child('users').child(userId).child('cart').remove();
    } catch (e) {
      throw Exception('gagal clear cart: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    try {
      final snapshot = await _database.child('users').child(userId).child('cart').get();
      
      if (snapshot.exists && snapshot.value != null) {
        final dynamic data = snapshot.value;
        List<Map<String, dynamic>> cartItems = [];
        
        if (data is Map<dynamic, dynamic>) {
          data.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              cartItems.add(Map<String, dynamic>.from(value));
            }
          });
        }
        
        
        cartItems.sort((a, b) => (a['addedAt'] as int? ?? 0).compareTo(b['addedAt'] as int? ?? 0));
        return cartItems;
      }
      
      return [];
    } catch (e) {
      throw Exception('gagal get cart: $e');
    }
  }

  
  Stream<List<Map<String, dynamic>>> getCartItemsStream(String userId) {
    return _database.child('users').child(userId).child('cart').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final dynamic data = event.snapshot.value;
        List<Map<String, dynamic>> cartItems = [];
        
        if (data is Map<dynamic, dynamic>) {
          data.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              cartItems.add(Map<String, dynamic>.from(value));
            }
          });
        }
        
        cartItems.sort((a, b) => (a['addedAt'] as int? ?? 0).compareTo(b['addedAt'] as int? ?? 0));
        return cartItems;
      }
      return <Map<String, dynamic>>[];
    });
  }

  
  Future<void> createCheckout({
    required String userId,
    required Checkout checkout,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    try {
      final checkoutId = DateTime.now().millisecondsSinceEpoch.toString();
      
      
      await _database.child('users').child(userId).child('orders').child(checkoutId).set({
        'id': checkoutId,
        'customerName': checkout.customerName,
        'customerPhone': checkout.customerPhone,
        'customerAddress': checkout.customerAddress,
        'paymentMethod': checkout.paymentMethod,
        'totalAmount': checkout.totalAmount,
        'items': cartItems.map((item) => {
          'productId': item['productId'],
          'name': item['name'],
          'price': item['price'],
          'finalPrice': item['finalPrice'],
          'quantity': item['quantity'],
          'category': item['category'],
          'shopName': item['shopName'],
          'imageUrl': item['imageUrl'],
        }).toList(),
        'status': 'pending',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      
      await clearCart(userId);
    } catch (e) {
      throw Exception('gagal buat checkout: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOrderHistory(String userId) async {
    try {
      final snapshot = await _database.child('users').child(userId).child('orders').get();
      
      if (snapshot.exists && snapshot.value != null) {
        final dynamic data = snapshot.value;
        List<Map<String, dynamic>> orders = [];
        
        if (data is Map<dynamic, dynamic>) {
          data.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              orders.add(Map<String, dynamic>.from(value));
            }
          });
        }
        
        
        orders.sort((a, b) => (b['createdAt'] as int? ?? 0).compareTo(a['createdAt'] as int? ?? 0));
        return orders;
      }
      
      return [];
    } catch (e) {
      throw Exception('gagal buat order history: $e');
    }
  }

  
  Stream<List<Map<String, dynamic>>> getOrderHistoryStream(String userId) {
    return _database.child('users').child(userId).child('orders').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final dynamic data = event.snapshot.value;
        List<Map<String, dynamic>> orders = [];
        
        if (data is Map<dynamic, dynamic>) {
          data.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              orders.add(Map<String, dynamic>.from(value));
            }
          });
        }
        
        orders.sort((a, b) => (b['createdAt'] as int? ?? 0).compareTo(a['createdAt'] as int? ?? 0));
        return orders;
      }
      return <Map<String, dynamic>>[];
    });
  }

  Future<void> updateOrderStatus({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    try {
      await _database
          .child('users')
          .child(userId)
          .child('orders')
          .child(orderId)
          .update({
        'status': status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('gagal update order status: $e');
    }
  }

  
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  
  Stream<Map<String, dynamic>?> getUserProfileStream(String userId) {
    return _database.child('users').child(userId).onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final dynamic data = event.snapshot.value;
        if (data is Map<dynamic, dynamic>) {
          return Map<String, dynamic>.from(data);
        }
      }
      return null;
    });
  }
}
