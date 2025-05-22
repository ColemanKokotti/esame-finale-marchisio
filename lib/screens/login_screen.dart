import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/login_controller.dart';
import '../widget/email.dart';
import '../widget/password.dart';
import '../widget/credentials.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoginController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Benvenuto in:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ColorFiltered(
                colorFilter: const ColorFilter.mode(Color(0xFF20763A), BlendMode.srcIn),
                child: Image.asset(
                  'assets/icons/logo.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 40),
              EmailInput(controller: controller.emailController),
              const SizedBox(height: 16),
              PasswordInput(controller: controller.passwordController),
              const SizedBox(height: 16),
              CredentialsButton(
                onPressed: () => controller.signInWithCredentials(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
