import 'package:flutter/material.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showActions;
  final VoidCallback? onLogout;
  final VoidCallback? onNotification;

  const CustomTopBar({
    super.key,
    this.showActions = false,
    this.onLogout,
    this.onNotification,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF009E3D),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showActions
              ? GestureDetector(
            onTap: onLogout,
            child: Image.asset(
              'assets/icons/logout.png',
              width: 24,
              height: 24,
            ),
          )
              : const SizedBox(width: 24),

          Image.asset(
            'assets/icons/logo.png',
            width: 40,
            height: 40,
            color: Colors.white,
          ),
          showActions
              ? Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                if (onNotification != null) {
                  onNotification!();
                } else {
                  Scaffold.of(context).openEndDrawer();
                }
              },
              child: Image.asset(
                'assets/icons/notification.png',
                width: 24,
                height: 24,
              ),
            ),
          )
              : const SizedBox(width: 24),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
