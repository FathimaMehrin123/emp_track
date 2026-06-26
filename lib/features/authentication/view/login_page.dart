import 'package:emp_track/features/authentication/view/register_page.dart';
import 'package:emp_track/features/authentication/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../admin/view/admin_dashbaord.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            if (authViewModel.errorMessage != null)
              Text(
                authViewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 10),

            authViewModel.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      final success = await authViewModel.login(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      if (success && mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminDashboardPage(
                              token: authViewModel.token!,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("Login"),
                  ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterPage(),
                  ),
                );
              },
              child: const Text("Create account"),
            ),
          ],
        ),
      ),
    );
  }
}