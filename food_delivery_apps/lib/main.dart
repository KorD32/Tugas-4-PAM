import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
  apiKey: "AIzaSyBD_NgwsC2zuDU1r-ciZzKo7SsTKtDe4zM",

  authDomain: "foodexpress-5fe0a.firebaseapp.com",

  projectId: "foodexpress-5fe0a",

  storageBucket: "foodexpress-5fe0a.firebasestorage.app",

  messagingSenderId: "403992588206",

  appId: "1:403992588206:web:60f8e087c937541ccf623f",

  measurementId: "G-M9ZHLPSBME"

      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodExpress',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
          '/login': (_) => LoginScreen(),
          '/register': (_) => RegisterScreen(),
          '/home': (_) => HomeScreen(),
          '/cart': (_) => CartScreen(),
          '/profile': (_) => ProfileScreen(),
      },
    );
  }
}
