import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/login_controller.dart';
import '../widget/custom_top_bar.dart';
import '../widget/notification_card.dart';
import '../screens/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> notifications = List.generate(5, (index) {
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

  void _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Impossibile aprire il link: $url');
    }
  }

  Widget _buildResourceButton({required IconData icon, required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginController = Provider.of<LoginController>(context, listen: false);

    return Scaffold(
      appBar: CustomTopBar(
        showActions: true,
        onLogout: () => loginController.logout(context),
        onNotification: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        },
      ),
      body: Column(
        children: [
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
                  ),
                );
              },
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
