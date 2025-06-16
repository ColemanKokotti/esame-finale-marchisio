import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String sender;
  final String message;
  final bool expanded;
  final VoidCallback? onRemove;
  final String? currentUserProfile;
  final bool visibleToAll;

  const NotificationCard({
    Key? key,
    required this.sender,
    required this.message,
    this.expanded = false,
    this.onRemove,
    this.currentUserProfile,
    this.visibleToAll = true,
  }) : super(key: key);

  bool get shouldShowNotification {
    if (visibleToAll) return true;

    return currentUserProfile != 'Davide Marchisio';
  }

  @override
  Widget build(BuildContext context) {
    if (!shouldShowNotification) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Container(
          height: expanded ? null : 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getIconForSender(sender),
                color: _getColorForSender(sender),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sender,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _getColorForSender(sender),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(fontSize: 13),
                      maxLines: expanded ? null : 2,
                      overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (expanded && onRemove != null)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onRemove,
            ),
          ),
      ],
    );
  }

  IconData _getIconForSender(String sender) {
    if (sender.toLowerCase() == 'staff') {
      return Icons.admin_panel_settings;
    } else if (sender.toLowerCase().contains('davide')) {
      return Icons.person;
    } else {
      return Icons.notifications;
    }
  }

  Color _getColorForSender(String sender) {
    if (sender.toLowerCase() == 'staff') {
      return const Color(0xFF009E3D);
    } else if (sender.toLowerCase().contains('davide')) {
      return Colors.blue;
    } else {
      return const Color(0xFF009E3D);
    }
  }
}