import 'package:flutter/material.dart';

class CredentialsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CredentialsButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Accedi con credenziali'),
    );
  }
}
