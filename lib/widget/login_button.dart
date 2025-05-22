import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.green),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: const Text('Accedi con Google'),
    );
  }
}
