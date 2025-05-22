import 'package:flutter/material.dart';
import '../widget/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _AllNotificationsScreenState();
}

class _AllNotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, String>> notifications = List.generate(5, (index) {
    return {
      'sender': 'Risorsa ${index + 1}',
      'message': [
        'Consulta la guida rapida per i pulsanti personalizzati.',
        'Scopri come configurare i bottoni dinamici nei tuoi progetti.',
        'Leggi l’articolo sulle best practices per UI responsive.',
        'Nuovo aggiornamento: supporto per gesture avanzate!',
        'Aggiunta documentazione sulle animazioni nei custom button.'
      ][index],
    };
  });

  void removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutte le notifiche'),
        backgroundColor: const Color(0xFF009E3D),
      ),
      body: ListView.builder(
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
            ),
          );
        },
      ),
    );
  }
}
