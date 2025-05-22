import 'package:flutter/material.dart';
import '../widget/custom_top_bar.dart';

class ChannelsScreen extends StatelessWidget {
  const ChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(),
      body: const Center(child: Text('Channels')),
    );
  }
}
