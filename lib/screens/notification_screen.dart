import 'package:flutter/material.dart';
import '../widget/notification_card.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _AllNotificationsScreenState();
}

class _AllNotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    setState(() {});
  }

  void removeNotification(int index) {
    final notifications = _notificationService.notifications;
    if (index < notifications.length) {
      final notificationToRemove = notifications[index];
      _notificationService.removeNotification(notificationToRemove);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutte le notifiche'),
        backgroundColor: const Color(0xFF009E3D),
      ),
      body: Column(
        children: [
          // Info profilo corrente (senza pulsanti debug)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Text(
              'Profilo corrente: ${_notificationService.currentUserProfile}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(
              child: Text(
                'Nessuna notifica disponibile',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: NotificationCard(
                    sender: notif['sender']!,
                    message: notif['message']!,
                    expanded: true,
                    onRemove: () => removeNotification(index),
                    currentUserProfile: _notificationService.currentUserProfile,
                    visibleToAll: notif['visibleToAll'] ?? true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}