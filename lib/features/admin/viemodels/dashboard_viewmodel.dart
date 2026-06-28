import 'package:emp_track/sevices/admin_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AdminDashboardViewModel extends ChangeNotifier {
  final AdminApiService _adminApiService = AdminApiService();

  bool isLoading = false;
  String? errorMessage;

  int totalEmployees = 0;
  int presentToday = 0;
  int lateToday = 0;
  int pendingLeaves = 0;

 Future<void> fetchDashboardData() async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  if (token == null) {
    errorMessage = "Token not found";
    isLoading = false;
    notifyListeners();
    return;
  }

  final result = await _adminApiService.getDashboardStats(token: token);

  if (result.containsKey("error")) {
    errorMessage = result["error"];
  } else {
    totalEmployees = result["totalEmployees"] ?? 0;
    presentToday = result["presentToday"] ?? 0;
    lateToday = result["lateToday"] ?? 0;
    pendingLeaves = result["pendingLeaves"] ?? 0;
  }

  isLoading = false;
  notifyListeners();
}
}