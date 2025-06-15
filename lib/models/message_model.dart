class MessageModel {
  final String id;
  final String chatId;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      chatId: map['chatId'] ?? '',
      content: map['content'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? content,
    String? senderId,
    String? senderName,
    DateTime? timestamp,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, chatId: $chatId, content: $content, senderId: $senderId, senderName: $senderName, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageModel &&
        other.id == id &&
        other.chatId == chatId &&
        other.content == content &&
        other.senderId == senderId &&
        other.senderName == senderName &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    chatId.hashCode ^
    content.hashCode ^
    senderId.hashCode ^
    senderName.hashCode ^
    timestamp.hashCode;
  }
}