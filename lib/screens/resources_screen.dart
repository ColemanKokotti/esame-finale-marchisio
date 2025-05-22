import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widget/custom_top_bar.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  void _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Impossibile aprire il link: \$url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(),
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
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 40),
                  SizedBox(height: 8),
                  Text('Guida Introduttiva', textAlign: TextAlign.center),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _openUrl('https://drive.google.com/file/d/1-wvzY98gRuACywvks04reRGoEAnZ9Q-6/view?usp=drive_link');
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.support_agent, size: 40),
                  SizedBox(height: 8),
                  Text('Programma Settimanale', textAlign: TextAlign.center),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // No URL defined for FAQ
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.question_answer, size: 40),
                  SizedBox(height: 8),
                  Text('FAQ', textAlign: TextAlign.center),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // No URL defined for Staff
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group, size: 40),
                  SizedBox(height: 8),
                  Text('Staff', textAlign: TextAlign.center),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _openUrl('https://docs.google.com/spreadsheets/d/1esHkdR5JzPbKYxjnnFfrwXLB_nK5-ecr/edit?usp=drive_link');
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 40),
                  SizedBox(height: 8),
                  Text('Prenotazioni', textAlign: TextAlign.center),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _openUrl('https://docs.google.com/spreadsheets/d/19XUdJQiiEemIeDFCgc2PGbHQsQZCwn31/edit?usp=drive_link');
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 40),
                  SizedBox(height: 8),
                  Text('Menù', textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
