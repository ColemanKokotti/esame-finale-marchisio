import 'package:flutter/foundation.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<Map<String, dynamic>> _notifications = [];
  String currentUserProfile = 'User';

  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);

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

    _notifications.insert(0, notification);
    notifyListeners();

    print('Notifica creazione chat aggiunta: $chatName da $creatorName');
  }


  void addMessageNotification(String senderName, String message, String chatName) {
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

  void removeNotification(Map<String, dynamic> notification) {
    _notifications.remove(notification);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void updateCurrentUserProfile(String profile) {
    currentUserProfile = profile;
    notifyListeners();
  }

  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((notif) => notif['type'] == type).toList();
  }

  List<Map<String, dynamic>> getNotificationsForChat(String chatName) {
    return _notifications.where((notif) =>
    notif['chatName'] == chatName &&
        (notif['type'] == 'message' || notif['type'] == 'chat_created')
    ).toList();
  }
}