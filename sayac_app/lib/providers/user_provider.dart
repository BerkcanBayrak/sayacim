import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String name;
  String email;
  String phone;
  String department;
  String? profileImagePath;

  UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.department = '',
    this.profileImagePath,
  });
}

class UserProvider extends ChangeNotifier {
  UserProfile _userProfile = UserProfile();
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  UserProfile get userProfile => _userProfile;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _userProfile = UserProfile(
      name: _prefs.getString('userName') ?? '',
      email: _prefs.getString('userEmail') ?? '',
      phone: _prefs.getString('userPhone') ?? '',
      department: _prefs.getString('userDepartment') ?? '',
      profileImagePath: _prefs.getString('userProfileImagePath'),
    );
    _isInitialized = true;
    notifyListeners();
  }

  void updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? department,
    String? profileImagePath,
  }) {
    if (name != null) _userProfile.name = name;
    if (email != null) _userProfile.email = email;
    if (phone != null) _userProfile.phone = phone;
    if (department != null) _userProfile.department = department;
    if (profileImagePath != null) _userProfile.profileImagePath = profileImagePath;
    _saveUserProfile();
    notifyListeners();
  }

  Future<void> _saveUserProfile() async {
    await _prefs.setString('userName', _userProfile.name);
    await _prefs.setString('userEmail', _userProfile.email);
    await _prefs.setString('userPhone', _userProfile.phone);
    await _prefs.setString('userDepartment', _userProfile.department);
    if (_userProfile.profileImagePath != null) {
      await _prefs.setString('userProfileImagePath', _userProfile.profileImagePath!);
    }
  }

  void resetToDefaults() {
    _userProfile = UserProfile();
    _saveUserProfile();
    notifyListeners();
  }
}
