import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(Duration(seconds: 2));
    
    User? user = FirebaseAuth.instance.currentUser;
    
    if (mounted) {
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9038FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.restaurant,
                size: 60,
                color: Color(0xFF9038FF)
              ),
            ),
            SizedBox(height: 30),
            
            Text(
              'FoodExpress',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            
            Text(
              'Makan enak murah',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 50),
            
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
