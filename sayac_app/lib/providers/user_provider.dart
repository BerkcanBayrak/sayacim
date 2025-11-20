import 'package:flutter/material.dart';

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

  UserProfile get userProfile => _userProfile;

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
    notifyListeners();
  }

  void resetToDefaults() {
    _userProfile = UserProfile();
    notifyListeners();
  }
}
