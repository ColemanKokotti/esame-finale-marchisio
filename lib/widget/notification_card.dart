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

  // Metodo per determinare se la notifica deve essere visibile
  bool get shouldShowNotification {
    // Se la notifica è visibile a tutti, mostrala sempre
    if (visibleToAll) return true;

    // Se non è visibile a tutti, mostrala solo se l'utente corrente non è Davide Marchisio
    return currentUserProfile != 'Davide Marchisio';
  }

  @override
  Widget build(BuildContext context) {
    // Se la notifica non deve essere mostrata, restituisce un widget vuoto
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
              // Icona personalizzata in base al mittente
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

  // Metodo per ottenere l'icona appropriata in base al mittente
  IconData _getIconForSender(String sender) {
    if (sender.toLowerCase() == 'staff') {
      return Icons.admin_panel_settings;
    } else if (sender.toLowerCase().contains('davide')) {
      return Icons.person;
    } else {
      return Icons.notifications;
    }
  }

  // Metodo per ottenere il colore appropriato in base al mittente
  Color _getColorForSender(String sender) {
    if (sender.toLowerCase() == 'staff') {
      return const Color(0xFF009E3D); // Verde per lo staff
    } else if (sender.toLowerCase().contains('davide')) {
      return Colors.blue; // Blu per Davide Marchisio
    } else {
      return const Color(0xFF009E3D); // Verde di default
    }
  }
}