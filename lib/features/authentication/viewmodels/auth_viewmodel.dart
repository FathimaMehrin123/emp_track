import 'package:emp_track/sevices/auth_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthApiService _authApiService = AuthApiService();

  bool isLoading = false;
  String? errorMessage;
  String? token;
  String? role;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authApiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      isLoading = false;

      if (result.containsKey("error")) {
        errorMessage = result["error"];
        notifyListeners();
        return false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = "An unexpected error occurred during registration.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authApiService.login(
        email: email,
        password: password,
      );

      isLoading = false;

      if (result.containsKey("error")) {
        errorMessage = result["error"];
        notifyListeners();
        return false;
      }

      token = result["access_token"];
      role = result["role"];

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", token!);
      await prefs.setString("role", role!);

      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = "An unexpected error occurred during login.";
      notifyListeners();
      return false;
    }
  }



Future<void> logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");
    await prefs.remove("role");

    token = null;
    role = null;

    notifyListeners();
  } catch (e) {
    errorMessage = "An unexpected error occurred during logout.";
    notifyListeners();
  }
}
}
