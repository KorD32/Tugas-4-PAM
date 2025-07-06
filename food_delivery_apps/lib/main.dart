import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_core/firebase_core.dart';
import 'package:foodexpress/providers/category_provider.dart';
import 'package:foodexpress/providers/checkout_provider.dart';
import 'package:foodexpress/providers/search_provider_product.dart';
import 'package:foodexpress/providers/user_profile_provider.dart';
import 'package:foodexpress/screens/List_product_screen.dart';
import 'package:foodexpress/screens/history_screen.dart';
import 'package:foodexpress/screens/cache_status_screen.dart';
import 'package:foodexpress/services/firebase_service.dart';
import 'package:foodexpress/services/offline_cache_service.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBD_NgwsC2zuDU1r-ciZzKo7SsTKtDe4zM",
            authDomain: "foodexpress-5fe0a.firebaseapp.com",
            databaseURL: "https://foodexpress-5fe0a-default-rtdb.asia-southeast1.firebasedatabase.app/",
            projectId: "foodexpress-5fe0a",
            storageBucket: "foodexpress-5fe0a.firebasestorage.app",
            messagingSenderId: "403992588206",
            appId: "1:403992588206:web:60f8e087c937541ccf623f",
            measurementId: "G-M9ZHLPSBME"),
      );
    } else {
      await Firebase.initializeApp();
    }
    
    FirebaseService.optimizeFirebase();
    
    await OfflineCacheService.init();
    debugPrint('cache service initialized');
    
    _initializeProductsInBackground();
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => SearchProductProvider()),
          ChangeNotifierProvider(create: (_) => CheckoutProvider()),
          ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ],
        child: MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('Error in main: $e');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => SearchProductProvider()),
          ChangeNotifierProvider(create: (_) => CheckoutProvider()),
          ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ],
        child: MyApp(),
      ),
    );
  }
}

void _initializeProductsInBackground() {
  Future.microtask(() async {
    try {
      final connected = await FirebaseService.testConnection();
      if (!connected) {
        debugPrint('gagal connect ke firebase');
        return;
      }
      
      await FirebaseService().initializeProducts();
      debugPrint('berhasil initialize produk di background');
    } catch (e) {
      debugPrint(' gagal initialize produck di background: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodExpress',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => SplashScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/home': (_) => HomeScreen(),
        '/history': (_) => HistoryScreen(),
        '/cart': (_) => CartScreen(),
        '/profile': (_) => ProfileScreen(),
        '/list': (_) => ListProductScreen(),
        '/cache-status': (_) => const CacheStatusScreen(),
      },
    );
  }
}
