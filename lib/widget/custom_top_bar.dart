import 'package:flutter/material.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showActions;
  final VoidCallback? onLogout;
  final VoidCallback? onNotification;
  final List<Widget>? actions;

  const CustomTopBar({
    super.key,
    this.showActions = false,
    this.onLogout,
    this.onNotification,
    this.actions,
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

          // Centro - Logo
          Image.asset(
            'assets/icons/logo.png',
            width: 40,
            height: 40,
            color: Colors.white,
          ),

          _buildRightSide(context),
        ],
      ),
    );
  }

  Widget _buildRightSide(BuildContext context) {
    if (actions != null && actions!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: actions!,
      );
    }

    if (showActions) {
      return Builder(
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
      );
    }

    return const SizedBox(width: 24);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}