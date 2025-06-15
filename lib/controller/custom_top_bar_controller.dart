import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../screens/notification_screen.dart';

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

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Conferma Logout'),
          content: const Text('Sei sicuro di voler uscire?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(AuthSignOutRequested());
                onLogout?.call();
              },
              child: const Text(
                'Esci',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleNotification(BuildContext context) {
    if (onNotification != null) {
      onNotification!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF009E3D),
      elevation: 2,
      shadowColor: Colors.black26,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showActions)
            const SizedBox(width: 48)
          else
            const SizedBox(width: 24),

          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              'assets/icons/logo.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 40,
                );
              },
            ),
          ),

          if (showActions)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _handleNotification(context),
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 24,
                  ),
                  tooltip: 'Notifiche',
                ),
                IconButton(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 24,
                  ),
                  tooltip: 'Logout',
                ),
              ],
            )
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}