import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../widget/custom_top_bar.dart';
import '../widget/notification_card.dart';
import '../screens/notification_screen.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  void _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Impossibile aprire il link: $url');
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma Logout'),
          content: const Text('Sei sicuro di voler uscire?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthSignOutRequested());
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

  Widget _buildResourceButton({required IconData icon, required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE0F2E9),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF009E3D)),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.notifications;

    return Scaffold(
      appBar: CustomTopBar(
        showActions: true,
        onLogout: _handleLogout,
        onNotification: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // Carosello notifiche - mostra solo se ci sono notifiche
          if (notifications.isNotEmpty)
            SizedBox(
              height: 120,
              child: PageView.builder(
                itemCount: notifications.length,
                controller: PageController(viewportFraction: 0.95),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    child: NotificationCard(
                      sender: notif['sender']!,
                      message: notif['message']!,
                      currentUserProfile: _notificationService.currentUserProfile,
                      visibleToAll: notif['visibleToAll'] ?? true,
                    ),
                  );
                },
              ),
            ),

          // Messaggio quando non ci sono notifiche
          if (notifications.isEmpty)
            Container(
              height: 60,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Text(
                  'Nessuna notifica disponibile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildResourceButton(
                    icon: Icons.book,
                    text: 'Guida Introduttiva',
                    onPressed: () {
                      _openUrl('https://docs.google.com/document/d/10xFoRI0zpqXBMhLK_Ots1rhlN1szigIL/edit?usp=drive_link');
                    },
                  ),
                  _buildResourceButton(
                    icon: Icons.support_agent,
                    text: 'Programma Settimanale',
                    onPressed: () {
                      _openUrl('https://drive.google.com/file/d/1-wvzY98gRuACywvks04reRGoEAnZ9Q-6/view?usp=drive_link');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}