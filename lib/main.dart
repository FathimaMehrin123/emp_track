import 'package:emp_track/features/admin/viemodels/dashboard_viewmodel.dart';

import 'package:emp_track/features/authentication/view/login_page.dart';
import 'package:emp_track/features/authentication/viewmodels/auth_viewmodel.dart';
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoginPage());
  }
}