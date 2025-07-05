import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://foodexpress-5fe0a-default-rtdb.asia-southeast1.firebasedatabase.app'
  ).ref();
  
  static bool _isOptimized = false;
  
  static List<Product>? _cachedProducts;
  static DateTime? _lastCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);


  static void optimizeFirebase() {
    if (!_isOptimized) {
      try {
        if (!kIsWeb) {
          FirebaseDatabase.instance.setPersistenceEnabled(true);
          FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10 * 1024 * 1024); //10mb
          debugPrint('Firebase optimized for mobile');
        } else {
          debugPrint('Firebase optimized for web');
        }
        _isOptimized = true;
      } catch (e) {
        debugPrint('Error optimizing Firebase: $e');
        _isOptimized = true; 
      }
    }
  }

  Future<List<Product>> fetchProducts() async {
    try {
      debugPrint('fetch database');
      
      if (_cachedProducts != null && _lastCacheTime != null) {
        final timeDiff = DateTime.now().difference(_lastCacheTime!);
        if (timeDiff < _cacheTimeout) {
          debugPrint('cache product (${_cachedProducts!.length} items)');
          return _cachedProducts!;
        }
        debugPrint('cache expired');
      }
      
      debugPrint('connecting to db');
      final snapshot = await _database.child('products').get()
        .timeout(Duration(seconds: 10)); 
      
      debugPrint('snapshot data ${snapshot.exists}');
      
      if (snapshot.exists) {
        final dynamic data = snapshot.value;
        List<Product> products = [];
        
        debugPrint('prosessing data ${data.runtimeType}');
        
        if (data is Map<dynamic, dynamic>) {
          debugPrint('mapping data ${data.length} enter');
          data.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              try {
                products.add(Product.fromJson(Map<String, dynamic>.from(value)));
              } catch (e) {
                debugPrint('error parsing produk $key: $e');
              }
            }
          });
        } else if (data is List<dynamic>) {
          debugPrint('prossesing data ${data.length}');
          for (int i = 0; i < data.length; i++) {
            if (data[i] != null && data[i] is Map<dynamic, dynamic>) {
              try {
                products.add(Product.fromJson(Map<String, dynamic>.from(data[i])));
              } catch (e) {
                debugPrint('error parsing produk $i: $e');
              }
            }
          }
        }
        
        products.sort((a, b) => a.id.compareTo(b.id));
        
        _cachedProducts = products;
        _lastCacheTime = DateTime.now();
        
        debugPrint('berhasil load ${products.length} produk');
        return products;
      }
      
      debugPrint('tidak ada data ditemukan di db');
      return [];
    } catch (e) {
      debugPrint('error fetching data $e');
      if (_cachedProducts != null) {
        debugPrint('cached data (${_cachedProducts!.length} items)');
        return _cachedProducts!;
      }
      throw Exception('gagal load produk dari firebase: $e');
    }
  }


  Future<void> addProduct(Product product) async {
    try {
      await _database.child('products').child(product.id.toString()).set({
        'id': product.id,
        'name': product.name,
        'category': product.category,
        'description': product.description,
        'image_url': product.imageUrl,
        'price': product.price,
        'rating': product.rating,
        'shop_name': product.shopName,
        'is_promos': product.isPromos,
        'is_trending': product.isTrending,
      });
    } catch (e) {
      throw Exception('gagal menambahkan product ke firebase: $e');
    }
  }


  Future<void> initializeProducts() async {
    try {
      if (_cachedProducts != null && _cachedProducts!.isNotEmpty) {
        debugPrint('Products sudah ada di cache, skip initialization');
        return;
      }

      final snapshot = await _database.child('products').get()
        .timeout(Duration(seconds: 3)); 
      if (snapshot.exists) {
        debugPrint('produk sudah ada di database');
        return;
      }


      final List<Map<String, dynamic>> productsData = [
        {
          "id": 1,
          "name": "Beef Burger Premium",
          "category": "fastfood",
          "description": "Beef patty with fresh lettuce, tomato, and cheese in a soft sesame bun.",
          "image_url": "https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=400&q=80",
          "price": 35000,
          "rating": 4.7,
          "shop_name": "Burger Bros",
          "is_promos": true,
          "is_trending": true
        },
        {
          "id": 2,
          "name": "Vegan Green Salad",
          "category": "vegan",
          "description": "Fresh mixed greens, cherry tomatoes, cucumber, and vegan dressing.",
          "image_url": "https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?q=80&w=764&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 25000,
          "rating": 4.4,
          "shop_name": "Healthy Hub",
          "is_promos": false,
          "is_trending": true
        },
        {
          "id": 3,
          "name": "Red Velvet Cake Slice",
          "category": "dessert",
          "description": "Soft and moist red velvet cake with cream cheese frosting.",
          "image_url": "https://images.unsplash.com/photo-1614707269211-474b2510b3ad?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 22000,
          "rating": 4.9,
          "shop_name": "Sweet Spot",
          "is_promos": false,
          "is_trending": false
        },
        {
          "id": 4,
          "name": "Fish and Chips",
          "category": "western",
          "description": "Classic battered fish served with crispy fries and tartar sauce.",
          "image_url": "https://images.unsplash.com/photo-1697748836791-9ddf7e616ece?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8ZmlzaCUyMGFuZCUyMGNoaXBzfGVufDB8fDB8fHww",
          "price": 40000,
          "rating": 4.3,
          "shop_name": "Western Delight",
          "is_promos": true,
          "is_trending": false
        },
        {
          "id": 5,
          "name": "Spicy Fried Chicken",
          "category": "fastfood",
          "description": "Crispy chicken pieces seasoned with a special spicy blend.",
          "image_url": "https://plus.unsplash.com/premium_photo-1683139916670-38113db90cb9?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 28000,
          "rating": 4.8,
          "shop_name": "Chicken Master",
          "is_promos": true,
          "is_trending": true
        },
        {
          "id": 6,
          "name": "Vegan Buddha Bowl",
          "category": "vegan",
          "description": "Rice, edamame, veggies, and tofu in a wholesome vegan bowl.",
          "image_url": "https://plus.unsplash.com/premium_photo-1664648005739-ce9a51e31952?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 32000,
          "rating": 4.5,
          "shop_name": "Green Eats",
          "is_promos": false,
          "is_trending": true
        },
        {
          "id": 7,
          "name": "Chocolate Lava Cake",
          "category": "dessert",
          "description": "Warm chocolate cake with a gooey melted chocolate center.",
          "image_url": "https://images.unsplash.com/photo-1617305855058-336d24456869?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 24000,
          "rating": 4.9,
          "shop_name": "Sweet Spot",
          "is_promos": false,
          "is_trending": true
        },
        {
          "id": 8,
          "name": "Chicken Katsu Curry",
          "category": "western",
          "description": "Japanese-style crispy chicken with curry sauce and rice.",
          "image_url": "https://images.unsplash.com/photo-1677743540715-d4fe04852225?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 38000,
          "rating": 4.6,
          "shop_name": "Tokyo Bites",
          "is_promos": false,
          "is_trending": false
        },
        {
          "id": 9,
          "name": "Classic Cheeseburger",
          "category": "fastfood",
          "description": "Juicy beef patty with cheddar, tomato, and house sauce.",
          "image_url": "https://plus.unsplash.com/premium_photo-1694769318070-5fbe38d744c6?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 27000,
          "rating": 4.2,
          "shop_name": "Burger Bros",
          "is_promos": false,
          "is_trending": false
        },
        {
          "id": 10,
          "name": "Avocado Toast",
          "category": "vegan",
          "description": "Whole-grain toast topped with fresh smashed avocado and seeds.",
          "image_url": "https://images.unsplash.com/photo-1704545229893-4f1bb5ef16a1?q=80&w=764&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 21000,
          "rating": 4.3,
          "shop_name": "Green Eats",
          "is_promos": false,
          "is_trending": false
        },
        {
          "id": 11,
          "name": "Blueberry Pancakes",
          "category": "dessert",
          "description": "Fluffy pancakes with fresh blueberries and maple syrup.",
          "image_url": "https://plus.unsplash.com/premium_photo-1692193552660-233948b757a4?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Ymx1YmVycnklMjBwYW5jYWtlc3xlbnwwfHwwfHx8MA%3D%3D",
          "price": 23000,
          "rating": 4.8,
          "shop_name": "Pancake House",
          "is_promos": false,
          "is_trending": true
        },
        {
          "id": 12,
          "name": "Grilled Salmon Steak",
          "category": "western",
          "description": "Grilled salmon with lemon butter sauce, served with veggies.",
          "image_url": "https://plus.unsplash.com/premium_photo-1695658518299-04b349ca9214?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 45000,
          "rating": 4.9,
          "shop_name": "Western Delight",
          "is_promos": true,
          "is_trending": false
        },
        {
          "id": 13,
          "name": "Chicken Shawarma Wrap",
          "category": "fastfood",
          "description": "Grilled chicken slices wrapped with veggies and garlic sauce.",
          "image_url": "https://images.unsplash.com/photo-1734772591537-15ac1b3b3c04?q=80&w=1169&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 26000,
          "rating": 4.1,
          "shop_name": "Middle Feast",
          "is_promos": false,
          "is_trending": false
        },
        {
          "id": 14,
          "name": "Vegan Sushi Platter",
          "category": "vegan",
          "description": "Assorted vegan sushi rolls with soy sauce and wasabi.",
          "image_url": "https://images.unsplash.com/photo-1726824863833-e88146cf0a72?q=80&w=1169&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 35000,
          "rating": 4.7,
          "shop_name": "Tokyo Bites",
          "is_promos": true,
          "is_trending": true
        },
        {
          "id": 15,
          "name": "Strawberry Shortcake",
          "category": "dessert",
          "description": "Layered sponge cake with whipped cream and strawberries.",
          "image_url": "https://images.unsplash.com/photo-1627308595171-d1b5d67129c4?q=80&w=735&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 21000,
          "rating": 4.4,
          "shop_name": "Sweet Spot",
          "is_promos": false,
          "is_trending": false
        },
        {
          "id": 16,
          "name": "BBQ Chicken Pizza",
          "category": "western",
          "description": "Pizza with BBQ chicken, red onions, and mozzarella cheese.",
          "image_url": "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=781&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 39000,
          "rating": 4.6,
          "shop_name": "Pizza Mania",
          "is_promos": true,
          "is_trending": false
        },
        {
          "id": 17,
          "name": "Cheese Fries",
          "category": "fastfood",
          "description": "Crispy fries topped with melted cheddar cheese.",
          "image_url": "https://images.unsplash.com/photo-1568226189293-77924f3f10c6?q=80&w=1331&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 15000,
          "rating": 4.0,
          "shop_name": "Burger Bros",
          "is_promos": false,
          "is_trending": true
        },
        {
          "id": 18,
          "name": "Tofu Stir Fry",
          "category": "vegan",
          "description": "Tofu cubes stir-fried with vegetables and soy sauce.",
          "image_url": "https://images.unsplash.com/photo-1609183480237-ccbb2d7c5772?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8dG9mdSUyMHN0aXIlMjBmcnl8ZW58MHx8MHx8fDA%3D",
          "price": 21000,
          "rating": 4.2,
          "shop_name": "Green Eats",
          "is_promos": false,
          "is_trending": false
        },
        {
          "id": 19,
          "name": "Chocolate Mousse",
          "category": "dessert",
          "description": "Rich and creamy chocolate mousse with whipped cream.",
          "image_url": "https://images.unsplash.com/photo-1621792907526-e69888069079?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "price": 20000,
          "rating": 4.6,
          "shop_name": "Sweet Spot",
          "is_promos": true,
          "is_trending": false
        },
        {
          "id": 20,
          "name": "Classic Carbonara",
          "category": "western",
          "description": "Pasta in creamy carbonara sauce with smoked beef.",
          "image_url": "https://images.unsplash.com/photo-1560434019-4558f9a9e2a1?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8Y2FyYm9uYXJhfGVufDB8fDB8fHww",
          "price": 32000,
          "rating": 4.3,
          "shop_name": "Western Delight",
          "is_promos": false,
          "is_trending": true
        }
      ];


      for (var productData in productsData) {
        await _database.child('products').child(productData['id'].toString()).set(productData);
      }
      
      debugPrint('berhasil initialized ${productsData.length} produck di firebase');
    } catch (e) {
      throw Exception('gagal utk initialize produk di firebase: $e');
    }
  }


  Stream<List<Product>> getProductsStream() {
    return _database.child('products').onValue.map((event) {
      if (event.snapshot.exists) {
        final dynamic data = event.snapshot.value;
        List<Product> products = [];
        
        if (data is Map<dynamic, dynamic>) {

          data.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              products.add(Product.fromJson(Map<String, dynamic>.from(value)));
            }
          });
        } else if (data is List<dynamic>) {

          for (int i = 0; i < data.length; i++) {
            if (data[i] != null && data[i] is Map<dynamic, dynamic>) {
              products.add(Product.fromJson(Map<String, dynamic>.from(data[i])));
            }
          }
        }
        
        products.sort((a, b) => a.id.compareTo(b.id));
        return products;
      }
      return <Product>[];
    });
  }

  static Future<bool> testConnection() async {
    try {
      debugPrint('testing connection to firebase');
      final testRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://foodexpress-5fe0a-default-rtdb.asia-southeast1.firebasedatabase.app'
      ).ref();
      
      await testRef.child('test').set({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'message': 'Connection test from Android'
      }).timeout(Duration(seconds: 5));
      
      final snapshot = await testRef.child('test').get()
        .timeout(Duration(seconds: 5));
      
      if (snapshot.exists) {
        debugPrint('connection berhasil');
        return true;
      } else {
        debugPrint('tidak ada data dari firebase');
        return false;
      }
    } catch (e) {
      debugPrint('connection gagal: $e');
      return false;
    }
  }

  static void clearCache() {
    _cachedProducts = null;
    _lastCacheTime = null;
    debugPrint('bersih cache produk');
  }
}
