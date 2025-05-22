import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/bottom_nav_controller.dart';
import '../widget/bottom_nav_bar.dart';
import '../screens/home_screen.dart';
import '../screens/resources_screen.dart';
import '../screens/channels_screen.dart';
import '../screens/profile_screen.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BottomNavController>(context);
    final screens = const [
      HomeScreen(),
      ResourcesScreen(),
      ChannelsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: screens[controller.selectedIndex],
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
