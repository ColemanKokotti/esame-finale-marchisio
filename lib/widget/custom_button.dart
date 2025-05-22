import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE0F2E9),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 40,
            height: 40,
          ),
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
}
