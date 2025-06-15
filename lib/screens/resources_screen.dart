import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widget/custom_top_bar.dart';
import 'staff_screen.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  String _convertGoogleDriveUrl(String url) {

    if (url.contains('drive.google.com')) {

      RegExp regExp = RegExp(r'/d/([a-zA-Z0-9-_]+)');
      Match? match = regExp.firstMatch(url);
      if (match != null) {
        String fileId = match.group(1)!;

        if (url.contains('document')) {
          return 'https://docs.google.com/document/d/$fileId/edit';
        }

        return 'https://drive.google.com/file/d/$fileId/view';
      }
    }
    return url;
  }

  void _openUrl(String url) async {
    try {
      String convertedUrl = _convertGoogleDriveUrl(url);
      final Uri uri = Uri.parse(convertedUrl);

      debugPrint('Tentativo di aprire: $convertedUrl');

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {

        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (e) {
      debugPrint('Errore nell\'apertura del link: $e');
    }
  }

  void _openStaffScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StaffScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ElevatedButton(
              onPressed: () {
                _openUrl('https://docs.google.com/document/d/10xFoRI0zpqXBMhLK_Ots1rhlN1szigIL/edit?usp=drive_link');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0F2E9),
                foregroundColor: Colors.black,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 40, color: Color(0xFF009E3D)),
                  SizedBox(height: 8),
                  Text(
                    'Manuale di Gestione',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _openUrl('https://drive.google.com/file/d/1-wvzY98gRuACywvks04reRGoEAnZ9Q-6/view?usp=drive_link');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0F2E9),
                foregroundColor: Colors.black,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.support_agent, size: 40, color: Color(0xFF009E3D)),
                  SizedBox(height: 8),
                  Text(
                    'Programma Settimanale',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FAQ non ancora disponibili')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0F2E9),
                foregroundColor: Colors.black,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.question_answer, size: 40, color: Color(0xFF009E3D)),
                  SizedBox(height: 8),
                  Text(
                    'FAQ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _openStaffScreen(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0F2E9),
                foregroundColor: Colors.black,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group, size: 40, color: Color(0xFF009E3D)),
                  SizedBox(height: 8),
                  Text(
                    'Staff',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _openUrl('https://docs.google.com/spreadsheets/d/1esHkdR5JzPbKYxjnnFfrwXLB_nK5-ecr/edit?usp=drive_link');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0F2E9),
                foregroundColor: Colors.black,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 40, color: Color(0xFF009E3D)),
                  SizedBox(height: 8),
                  Text(
                    'Prenotazioni',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _openUrl('https://docs.google.com/spreadsheets/d/19XUdJQiiEemIeDFCgc2PGbHQsQZCwn31/edit?usp=drive_link');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0F2E9),
                foregroundColor: Colors.black,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 40, color: Color(0xFF009E3D)),
                  SizedBox(height: 8),
                  Text(
                    'Menù',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}