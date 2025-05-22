import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class CustomTopBarController {
  void handleLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  void handleNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifiche in arrivo...')),
    );
  }
}
