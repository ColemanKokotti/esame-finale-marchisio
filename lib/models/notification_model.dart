// models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  welcome,
  chatInvite, // User invited to a specific chat (e.g. by direct add, or new chat created with role)
  newMessage, // New message in a chat
  chatCreation, // A new chat has been created (for specific roles)
}

class NotificationModel {
  final String id;
  final String userId; // The recipient of the notification
  final String sender; // Who sent the notification (e.g., 'System', 'Admin', or a user's name)
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata; // For additional data like chatId, messageId, etc.

  NotificationModel({
    required this.id,
    required this.userId,
    required this.sender,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'sender': sender,
      'message': message,
      'type': type.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'metadata': metadata ?? {},
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      sender: map['sender'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => NotificationType.welcome,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isRead: map['isRead'] ?? false,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? sender,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}