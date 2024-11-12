import 'package:flutter/material.dart';
import 'package:presensi/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/core.dart';
import '../home/pages/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          const SpaceHeight(50.0),
          Padding(
            padding: const EdgeInsets.all(85.0),
            child: Assets.images.logo.image(),
          ),
          const SpaceHeight(30.0),
          CustomTextField(
            showLabel: false,
            controller: emailController,
            label: 'Email',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Assets.icons.email.svg(),
            ),
          ),
          const SpaceHeight(18.0),
          CustomTextField(
            showLabel: false,
            controller: passwordController,
            label: 'Password',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Assets.icons.password.svg(),
            ),
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          const SpaceHeight(80.0),
          Button.filled(
            onPressed: () async {
              final email = emailController.text;
              final password = passwordController.text;

              try {
                final response = await authService.login(email, password);

                if (response['status'] == 'success') {
                  // Navigasi ke halaman utama jika login berhasil
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                } else {
                  // Tampilkan pesan kesalahan dari API jika login gagal
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Info'),
                      content: Text(response['message'] ?? 'Login failed'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                // Tangani error jaringan atau server
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error'),
                    content: const Text('Failed to connect to the server.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            label: 'Sign In',
          ),
        ],
      ),
    );
  }
}
