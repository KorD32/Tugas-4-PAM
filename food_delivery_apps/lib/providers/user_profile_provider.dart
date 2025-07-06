import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import '../services/user_service.dart';

class UserProfileProvider with ChangeNotifier {
  Map<String, dynamic>? _userProfile;
  final UserService _userService = UserService();
  bool _loading = false;
  bool _initialized = false;
  StreamSubscription<Map<String, dynamic>?>? _profileSubscription;

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get loading => _loading;
  bool get isInitialized => _initialized;

  String get username => _userProfile?['username']?.toString() ?? '';
  String get name => _userProfile?['name']?.toString() ?? '';
  String get email => _userProfile?['email']?.toString() ?? '';
  int get age => (_userProfile?['age'] is int) ? _userProfile!['age'] : (int.tryParse(_userProfile?['age']?.toString() ?? '0') ?? 0);
  String get phone => _userProfile?['phone']?.toString() ?? '';
  String get address => _userProfile?['address']?.toString() ?? '';

  
  Future<void> loadUserProfile() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    if (_loading || (_initialized && _userProfile != null)) {
      debugPrint('profile sudah diload atau sedang loading, skip');
      return;
    }

    _loading = true;
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _userProfile = await _userService.getUserProfile(userId)
        .timeout(Duration(seconds: 5));
      _initialized = true;
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }

    _loading = false;
    
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> refreshProfile() async {
    _initialized = false;
    await loadUserProfile();
  }

  void clearUserData() {
    _userProfile = null;
    _initialized = false;
    _loading = false;
    _profileSubscription?.cancel();
    _profileSubscription = null;
    notifyListeners();
  }

  
  void listenToProfileUpdates() {
    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    
    _profileSubscription?.cancel();

    _profileSubscription = _userService.getUserProfileStream(userId).listen((profile) {
      _userProfile = profile;
      notifyListeners();
    });
  }

  
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

  
  bool get isProfileComplete {
    if (_userProfile == null) return false;
    return _userProfile!['name']?.toString().isNotEmpty == true &&
           _userProfile!['phone']?.toString().isNotEmpty == true &&
           _userProfile!['address']?.toString().isNotEmpty == true;
  }

  
  double get profileCompletionPercentage {
    if (_userProfile == null) return 0.0;
    
    int completedFields = 0;
    int totalFields = 5; 

    if (_userProfile!['username']?.toString().isNotEmpty == true) completedFields++;
    if (_userProfile!['name']?.toString().isNotEmpty == true) completedFields++;
    
    
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
