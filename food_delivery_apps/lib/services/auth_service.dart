import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<User?> register(
    String email, 
    String password, 
    String username, 
    String name, 
    String phone, 
    String address
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(Duration(seconds: 10)); 

      if (userCredential.user != null) {
        userCredential.user!.updateDisplayName(username).catchError((e) {
          print('error update display name: $e');
        });
        
        _userService.createUserProfile(
          userId: userCredential.user!.uid,
          email: email,
          username: username,
          name: name,
          phone: phone,
          address: address,
        ).catchError((e) {
          print('error buat user profile: $e');
        });
      }

      return userCredential.user;
    } catch (e) {
      throw e;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(Duration(seconds: 10)); 
      return userCredential.user;
    } catch (e) {
      throw e;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Future<void> updateDisplayName(String displayName) async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(displayName);
      
      
      await _userService.updateUserProfile(
        userId: _auth.currentUser!.uid,
        username: displayName,
      );
    }
  }
}
