import 'package:flutter/foundation.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<Map<String, dynamic>> _notifications = [];
  String currentUserProfile = 'User';

  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);

  // Metodo per aggiungere notifica di creazione chat
  void addChatCreatedNotification(String chatName, String creatorName) {
    final notification = {
      'sender': 'Sistema',
      'message': '$creatorName ha creato la chat "$chatName"',
      'visibleToAll': true,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'chat_created',
      'chatName': chatName,
      'creatorName': creatorName
    };

    _notifications.insert(0, notification); // Inserisce all'inizio per mostrare le più recenti
    notifyListeners();

    print('Notifica creazione chat aggiunta: $chatName da $creatorName');
  }

  // Metodo per aggiungere notifica di messaggio
  void addMessageNotification(String senderName, String message, String chatName) {
    // Limita la lunghezza del messaggio per la notifica
    String truncatedMessage = message.length > 50 ?
    '${message.substring(0, 50)}...' : message;

    final notification = {
      'sender': senderName,
      'message': 'In "$chatName": $truncatedMessage',
      'visibleToAll': true,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'message',
      'chatName': chatName,
      'fullMessage': message
    };

    _notifications.insert(0, notification);
    notifyListeners();

    print('Notifica messaggio aggiunta: $senderName in $chatName');
  }

  // Metodo per aggiungere notifica generica (per compatibilità)
  void addNotification(String sender, String message, {bool visibleToAll = true}) {
    final notification = {
      'sender': sender,
      'message': message,
      'visibleToAll': visibleToAll,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'generic'
    };

    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Rimuovi notifica
  void removeNotification(Map<String, dynamic> notification) {
    _notifications.remove(notification);
    notifyListeners();
  }

  // Pulisci tutte le notifiche
  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Aggiorna il profilo utente corrente
  void updateCurrentUserProfile(String profile) {
    currentUserProfile = profile;
    notifyListeners();
  }

  // Ottieni notifiche per tipo
  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((notif) => notif['type'] == type).toList();
  }

  // Ottieni notifiche per chat specifica
  List<Map<String, dynamic>> getNotificationsForChat(String chatName) {
    return _notifications.where((notif) =>
    notif['chatName'] == chatName &&
        (notif['type'] == 'message' || notif['type'] == 'chat_created')
    ).toList();
  }
}