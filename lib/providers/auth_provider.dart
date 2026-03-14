import 'package:flutter/material.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthChecked = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;
  bool get isAuthChecked => _isAuthChecked;

  // Check token exists and valid
  Future<void> xcheckAuth() async {
    if (_isAuthChecked) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hasToken = await _authService.hasToken();
      if (hasToken) {
        // Load user from sharedprefs
        final cachedUser = await Tokenmanager.getUser();
        if (cachedUser != null) {
          _currentUser = User.fromJson(cachedUser);
        } else {
          _currentUser = null;
        }
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      _isAuthChecked = true;
      notifyListeners();
    }
  }

  Future<void> checkAuth() async {
    if (_isAuthChecked) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hasToken = await _authService.hasToken();
      if (hasToken) {
        final user = await _authService.getCurrentUser();
        _currentUser = user;
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      _isAuthChecked = true;
      notifyListeners();
    }
  }

  //method logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _error = null;
      _isAuthChecked = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login method
  Future<bool> login(String login, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(login, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //get user profile
  Future<void> getCurrentUser() async {
    try {
      // await refreshUser();
      final cachedUser = await Tokenmanager.getUser();
      if (cachedUser != null) {
        _currentUser = User.fromJson(cachedUser);
        _error = null;
      } else {
        _currentUser = null;
        _error = "No cached user available";
      }
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    }
  }

  // refresh Current User
  Future<void> refreshUser() async {
    try {
      final user = await _authService.getCurrentUser();
      _currentUser = user;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // update Data Profile User
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      await _authService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        address: address,
      );

      await refreshUser();
      return true;
    } catch (e) {
      debugPrint("Update Profile error: $e");
      return false;
    }
  }

  // fungsi untuk update profil account (username, email, password)
  Future<bool> updateProfileAccount({
    required String username,
    required String email,
    String? password,
  }) async {
    try {
      final updatedUser = await _authService.updateProfileAccount(
        username: username,
        email: email,
        password: password,
      );

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error updateProfileAccount: $e");
      return false;
    }
  }

  // update Picture Profile
  Future<void> updateProfilePicture(String filePath) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateProfilePicture(filePath);
      await refreshUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
