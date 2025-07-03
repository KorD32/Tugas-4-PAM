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
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user?.updateDisplayName(username);
    await userCredential.user?.reload();

    // Create user profile in Realtime Database
    if (userCredential.user != null) {
      await _userService.createUserProfile(
        userId: userCredential.user!.uid,
        email: email,
        username: username,
        name: name,
        phone: phone,
        address: address,
      );
    }

    return _auth.currentUser;
  }

  Future<User?> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Future<void> updateDisplayName(String displayName) async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(displayName);
      
      // Also update in Realtime Database
      await _userService.updateUserProfile(
        userId: _auth.currentUser!.uid,
        username: displayName,
      );
    }
  }
}
