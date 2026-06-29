import 'package:emp_track/sevices/admin_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeListViewModel extends ChangeNotifier {
  final AdminApiService _adminApiService = AdminApiService();

  bool isLoading = false;
  String? errorMessage;
  List<dynamic> employees = [];

  Future<void> fetchEmployees({String? search}) async {
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

    final result = await _adminApiService.getEmployees(
      token: token,
      search: search,
    );

    if (result is Map && result.containsKey("error")) {
      errorMessage = result["error"];
      employees = [];
    } else {
      employees = result;
    }
    isLoading = false;
    notifyListeners();
  }
}