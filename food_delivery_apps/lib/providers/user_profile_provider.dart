import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/user_service.dart';

class UserProfileProvider with ChangeNotifier {
  Map<String, dynamic>? _userProfile;
  final UserService _userService = UserService();
  bool _loading = false;
  StreamSubscription<Map<String, dynamic>?>? _profileSubscription;

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get loading => _loading;

  String get username => _userProfile?['username']?.toString() ?? '';
  String get name => _userProfile?['name']?.toString() ?? '';
  String get email => _userProfile?['email']?.toString() ?? '';
  int get age => (_userProfile?['age'] is int) ? _userProfile!['age'] : (int.tryParse(_userProfile?['age']?.toString() ?? '0') ?? 0);
  String get phone => _userProfile?['phone']?.toString() ?? '';
  String get address => _userProfile?['address']?.toString() ?? '';

  // Load user profile from Firebase
  Future<void> loadUserProfile() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    _loading = true;
    notifyListeners();

    try {
      _userProfile = await _userService.getUserProfile(userId);
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }

    _loading = false;
    notifyListeners();
  }

  // Listen to real-time profile updates
  void listenToProfileUpdates() {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    // Cancel previous subscription to prevent duplicates
    _profileSubscription?.cancel();

    _profileSubscription = _userService.getUserProfileStream(userId).listen((profile) {
      _userProfile = profile;
      notifyListeners();
    });
  }

  // Update user profile
  Future<bool> updateProfile({
    String? username,
    String? name,
    int? age,
    String? phone,
    String? address,
  }) async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return false;

    _loading = true;
    notifyListeners();

    try {
      await _userService.updateUserProfile(
        userId: userId,
        username: username,
        name: name,
        age: age,
        phone: phone,
        address: address,
      );

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear profile data (for logout)
  void clearProfile() {
    _userProfile = null;
    _profileSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  // Check if profile is complete
  bool get isProfileComplete {
    if (_userProfile == null) return false;
    return _userProfile!['name']?.toString().isNotEmpty == true &&
           _userProfile!['phone']?.toString().isNotEmpty == true &&
           _userProfile!['address']?.toString().isNotEmpty == true;
  }

  // Get profile completion percentage
  double get profileCompletionPercentage {
    if (_userProfile == null) return 0.0;
    
    int completedFields = 0;
    int totalFields = 5; // username, name, age, phone, address

    if (_userProfile!['username']?.toString().isNotEmpty == true) completedFields++;
    if (_userProfile!['name']?.toString().isNotEmpty == true) completedFields++;
    
    // Safe age checking
    final ageValue = _userProfile!['age'];
    int ageInt = 0;
    if (ageValue is int) {
      ageInt = ageValue;
    } else if (ageValue is String) {
      ageInt = int.tryParse(ageValue) ?? 0;
    }
    if (ageInt > 0) completedFields++;
    
    if (_userProfile!['phone']?.toString().isNotEmpty == true) completedFields++;
    if (_userProfile!['address']?.toString().isNotEmpty == true) completedFields++;

    return completedFields / totalFields;
  }
}
