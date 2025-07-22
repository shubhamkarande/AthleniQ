import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _userId;
  String? _userEmail;
  String? _errorMessage;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;

  // Mock authentication methods for now
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation
      if (email.isNotEmpty && password.length >= 6) {
        _isAuthenticated = true;
        _userId = 'mock_user_${DateTime.now().millisecondsSinceEpoch}';
        _userEmail = email;
        _setLoading(false);
        return true;
      } else {
        _setError('Invalid email or password');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation
      if (email.isNotEmpty && password.length >= 6 && name.isNotEmpty) {
        _isAuthenticated = true;
        _userId = 'mock_user_${DateTime.now().millisecondsSinceEpoch}';
        _userEmail = email;
        _setLoading(false);
        return true;
      } else {
        _setError('Please fill all fields correctly');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Sign up failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  void signOut() {
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
