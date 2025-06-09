// models/chat_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatAccessType { role, specific_users }

class ChatModel {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String creatorName;
  final ChatAccessType accessType;
  final List<String> allowedRoles; // Per accesso tramite ruolo
  final List<String> allowedUserIds; // Per accesso tramite utenti specifici
  final List<String> allowedUserNames; // Nomi degli utenti per display
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final bool isActive;

  ChatModel({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.accessType,
    this.allowedRoles = const [],
    this.allowedUserIds = const [],
    this.allowedUserNames = const [],
    required this.createdAt,
    this.lastMessageAt,
    this.isActive = true,
  });

  // Converte in Map per Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'accessType': accessType.toString(),
      'allowedRoles': allowedRoles,
      'allowedUserIds': allowedUserIds,
      'allowedUserNames': allowedUserNames,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'isActive': isActive,
    };
  }

  // Crea da DocumentSnapshot di Firestore
  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      accessType: ChatAccessType.values.firstWhere(
            (e) => e.toString() == data['accessType'],
        orElse: () => ChatAccessType.role,
      ),
      allowedRoles: List<String>.from(data['allowedRoles'] ?? []),
      allowedUserIds: List<String>.from(data['allowedUserIds'] ?? []),
      allowedUserNames: List<String>.from(data['allowedUserNames'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessageAt: data['lastMessageAt'] != null
          ? (data['lastMessageAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  // Copia con modifiche
  ChatModel copyWith({
    String? title,
    String? description,
    ChatAccessType? accessType,
    List<String>? allowedRoles,
    List<String>? allowedUserIds,
    List<String>? allowedUserNames,
    DateTime? lastMessageAt,
    bool? isActive,
  }) {
    return ChatModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId,
      creatorName: creatorName,
      accessType: accessType ?? this.accessType,
      allowedRoles: allowedRoles ?? this.allowedRoles,
      allowedUserIds: allowedUserIds ?? this.allowedUserIds,
      allowedUserNames: allowedUserNames ?? this.allowedUserNames,
      createdAt: createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Verifica se un utente può accedere alla chat
  bool canUserAccess(String userId, String userRole) {
    // Il creatore può sempre accedere
    if (userId == creatorId) return true;

    switch (accessType) {
      case ChatAccessType.role:
        return allowedRoles.contains(userRole);
      case ChatAccessType.specific_users:
        return allowedUserIds.contains(userId);
    }
  }
}