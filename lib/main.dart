import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/bottom_nav_controller.dart';
import 'controller/login_controller.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavController()),
        ChangeNotifierProvider(create: (_) => LoginController()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
