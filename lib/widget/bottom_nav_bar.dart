import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/bottom_nav_controller.dart';

class BottomNavBar extends StatelessWidget {
  final List<String> iconPaths = [
    'assets/icons/home.png',
    'assets/icons/resources.png',
    'assets/icons/channels.png',
    'assets/icons/profile.png',
  ];

  final List<String> labels = [
    'Home',
    'Risorse',
    'Canali',
    'Profilo',
  ];

  BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BottomNavController>(context);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: controller.selectedIndex,
      onTap: controller.changeTab,
      backgroundColor: const Color(0xFF009E3D),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: List.generate(4, (index) {
        final isSelected = controller.selectedIndex == index;
        return BottomNavigationBarItem(
          icon: Image.asset(
            iconPaths[index],
            width: 24,
            height: 24,
            color: isSelected ? Colors.white : Colors.white70,
          ),
          label: labels[index],
        );
      }),
    );
  }
}
