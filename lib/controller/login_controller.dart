import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../widget/main_page.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signInWithCredentials(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email == 'prova@gmail.com' && password == 'prova123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email o password errati')),
      );
    }
  }

  void logout(BuildContext context) {
    emailController.clear();
    passwordController.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
}
