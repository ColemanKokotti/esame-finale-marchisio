import 'package:flutter/material.dart';

class PasswordInput extends StatelessWidget {
  final TextEditingController controller;

  const PasswordInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
    );
  }
}
