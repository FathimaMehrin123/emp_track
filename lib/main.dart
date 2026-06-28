import 'package:emp_track/features/admin/viemodels/all_leave_requests_viewmodel.dart';
import 'package:emp_track/features/admin/viemodels/dashboard_viewmodel.dart';
import 'package:emp_track/features/admin/viemodels/employee_list_viewmodel.dart';

import 'package:emp_track/features/authentication/view/login_page.dart';
import 'package:emp_track/features/authentication/viewmodels/auth_viewmodel.dart';
import 'package:emp_track/features/employee/viewmodels/attendance_viewmodel.dart';
import 'package:emp_track/features/employee/viewmodels/emp_dashbaord_viewmodel.dart';
import 'package:emp_track/features/employee/viewmodels/leave_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AdminDashboardViewModel(),
        ),
          ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider(create: (_) => AllLeaveRequestsViewmodel()),
                ChangeNotifierProvider(create: (_) => EmployeeListViewModel()),
    ChangeNotifierProvider(create: (_) => EmployeeDashboardViewModel()),
    ChangeNotifierProvider(create: (_) => AttendanceViewModel()),
    ChangeNotifierProvider(create: (_) => LeaveViewModel())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoginPage(),debugShowCheckedModeBanner: false,);
  }
}