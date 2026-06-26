class ApiConstants {
  static const String baseUrl = "http://127.0.0.1:8001";

  // Authentication
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";

  // Attendance
  static const String checkIn = "$baseUrl/attendance/checkin";
  static const String attendanceHistory = "$baseUrl/attendance/history";

  // Leave
  static const String leaveRequest = "$baseUrl/leave/request";
  static const String leaveHistory = "$baseUrl/leave/history";

  // Dashboard
  static const String empdashboardStats = "$baseUrl/dashboard/stats";

  // Admin
  static const String adminDashboard = "$baseUrl/admin/dashboard";
  static const String employeeList = "$baseUrl/admin/employees";
  static const String leaveApproval = "$baseUrl/admin/leave";
  
}