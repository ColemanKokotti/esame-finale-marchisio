import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String sender;
  final String message;
  final bool expanded;
  final VoidCallback? onRemove;

  const NotificationCard({
    Key? key,
    required this.sender,
    required this.message,
    this.expanded = false,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.notifications, color: Color(0xFF009E3D), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sender,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
}
