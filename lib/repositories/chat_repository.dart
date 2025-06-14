// repositories/chat_repository.dart - Versione completa aggiornata
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collezione chats
  CollectionReference get _chatsCollection => _firestore.collection('chats');

  // Crea una nuova chat
  Future<String> createChat(ChatModel chat) async {
    try {
      final docRef = await _chatsCollection.add(chat.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Errore durante la creazione della chat: $e');
    }
  }

  // METODO AGGIORNATO per creare chat da Map (per compatibilità con CreateChatScreen)
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

  // Ottieni tutte le chat accessibili da un utente
  Stream<List<ChatModel>> getAccessibleChats(String userId, String userRole) {
    return _chatsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .where((chat) => chat.canUserAccess(userId, userRole))
          .toList();

      // Ordina in memoria per evitare problemi con gli indici
      chats.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return chats;
    });
  }

  // Versione alternativa se preferisci mantenere l'ordinamento su Firebase
  // (richiede la creazione dell'indice composito)
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

  // Ottieni le chat create da un utente specifico
  Stream<List<ChatModel>> getChatsByCreator(String creatorId) {
    return _chatsCollection
        .where('creatorId', isEqualTo: creatorId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .toList();

      // Ordina in memoria
      chats.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return chats;
    });
  }

  // Ottieni una chat specifica
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

  // METODO AGGIORNATO per aggiornare una chat esistente
  Future<void> updateChat(String chatId, Map<String, dynamic> updates) async {
    try {
      print('Aggiornamento chat: $chatId');
      print('Dati aggiornamento: $updates');

      // Aggiungi timestamp di aggiornamento se non presente
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

  // Elimina una chat (soft delete)
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

  // Aggiorna il timestamp dell'ultimo messaggio
  Future<void> updateLastMessage(String chatId) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'lastMessageAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Errore durante l\'aggiornamento del timestamp: $e');
    }
  }

  // Ottieni statistiche delle chat
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