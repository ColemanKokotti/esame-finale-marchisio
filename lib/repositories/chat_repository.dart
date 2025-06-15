import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _chatsCollection => _firestore.collection('chats');

  Future<String> createChat(ChatModel chat) async {
    try {
      final docRef = await _chatsCollection.add(chat.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Errore durante la creazione della chat: $e');
    }
  }

  Future<String> createChatFromMap(Map<String, dynamic> chatData) async {
    try {
      print('Creazione chat con dati: $chatData');
      final docRef = await _chatsCollection.add(chatData);
      print('Chat creata con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Errore nella creazione della chat: $e');
      throw Exception('Errore nella creazione della chat: $e');
    }
  }

  Stream<List<ChatModel>> getAccessibleChats(String userId, String userRole) {
    return _chatsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .where((chat) => chat.canUserAccess(userId, userRole))
          .toList();

      chats.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return chats;
    });
  }

  Stream<List<ChatModel>> getAccessibleChatsWithServerSort(String userId, String userRole) {
    return _chatsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .where((chat) => chat.canUserAccess(userId, userRole))
          .toList();
    });
  }

  Stream<List<ChatModel>> getChatsByCreator(String creatorId) {
    return _chatsCollection
        .where('creatorId', isEqualTo: creatorId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .toList();

      chats.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return chats;
    });
  }

  Future<ChatModel?> getChatById(String chatId) async {
    try {
      final doc = await _chatsCollection.doc(chatId).get();
      if (doc.exists) {
        return ChatModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Errore durante il recupero della chat: $e');
    }
  }

  Future<void> updateChat(String chatId, Map<String, dynamic> updates) async {
    try {
      print('Aggiornamento chat: $chatId');
      print('Dati aggiornamento: $updates');

      if (!updates.containsKey('updatedAt')) {
        updates['updatedAt'] = Timestamp.now();
      }

      await _chatsCollection.doc(chatId).update(updates);
      print('Chat aggiornata con successo');
    } catch (e) {
      print('Errore nell\'aggiornamento della chat: $e');
      throw Exception('Errore durante l\'aggiornamento della chat: $e');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'isActive': false,
        'deletedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Errore durante l\'eliminazione della chat: $e');
    }
  }

  Future<void> updateLastMessage(String chatId) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'lastMessageAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Errore durante l\'aggiornamento del timestamp: $e');
    }
  }

  Future<Map<String, int>> getChatStats() async {
    try {
      final snapshot = await _chatsCollection
          .where('isActive', isEqualTo: true)
          .get();

      return {
        'total': snapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Errore durante il recupero delle statistiche: $e');
    }
  }
}