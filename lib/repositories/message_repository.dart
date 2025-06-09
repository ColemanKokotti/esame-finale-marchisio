// repositories/message_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Riferimento alla collezione messaggi di una chat specifica (subcollection)
  CollectionReference _getChatMessagesCollection(String chatId) =>
      _firestore.collection('chats').doc(chatId).collection('messages');

  // Invia un nuovo messaggio
  Future<void> sendMessage(MessageModel message) async {
    try {
      print('Invio messaggio: ${message.content}');

      // Usa la subcollection invece della collezione principale
      await _getChatMessagesCollection(message.chatId).add(message.toMap());

      print('Messaggio inviato con successo');
    } catch (e) {
      print('Errore nell\'invio del messaggio: $e');
      throw Exception('Errore nell\'invio del messaggio: $e');
    }
  }

  // Ottieni stream dei messaggi di una chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    try {
      print('Configurazione stream messaggi per chat: $chatId');

      return _getChatMessagesCollection(chatId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        final messages = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return MessageModel.fromMap(data, doc.id);
        }).toList();

        print('Messaggi ricevuti per chat $chatId: ${messages.length}');
        return messages;
      });
    } catch (e) {
      print('Errore nel recupero messaggi: $e');
      throw Exception('Errore nel recupero messaggi: $e');
    }
  }

  // Ottieni un singolo messaggio per ID
  Future<MessageModel?> getMessageById(String chatId, String messageId) async {
    try {
      final doc = await _getChatMessagesCollection(chatId).doc(messageId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return MessageModel.fromMap(data, doc.id);
      }

      return null;
    } catch (e) {
      print('Errore nel recupero messaggio: $e');
      throw Exception('Errore nel recupero messaggio: $e');
    }
  }

  // Elimina un messaggio (solo per admin o creatore)
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _getChatMessagesCollection(chatId).doc(messageId).delete();
      print('Messaggio eliminato: $messageId');
    } catch (e) {
      print('Errore nell\'eliminazione messaggio: $e');
      throw Exception('Errore nell\'eliminazione messaggio: $e');
    }
  }

  // Elimina tutti i messaggi di una chat (quando si elimina la chat)
  Future<void> deleteChatMessages(String chatId) async {
    try {
      final snapshot = await _getChatMessagesCollection(chatId).get();

      // Elimina tutti i messaggi in batch
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Eliminati ${snapshot.docs.length} messaggi per chat: $chatId');
    } catch (e) {
      print('Errore nell\'eliminazione messaggi chat: $e');
      throw Exception('Errore nell\'eliminazione messaggi chat: $e');
    }
  }

  // Modifica un messaggio (solo per il mittente)
  Future<void> updateMessage(String chatId, String messageId, String newContent) async {
    try {
      await _getChatMessagesCollection(chatId).doc(messageId).update({
        'content': newContent,
        'editedAt': DateTime.now().millisecondsSinceEpoch,
      });

      print('Messaggio aggiornato: $messageId');
    } catch (e) {
      print('Errore nell\'aggiornamento messaggio: $e');
      throw Exception('Errore nell\'aggiornamento messaggio: $e');
    }
  }

  // Ottieni statistiche messaggi per una chat
  Future<Map<String, int>> getChatMessageStats(String chatId) async {
    try {
      final snapshot = await _getChatMessagesCollection(chatId).get();

      final stats = <String, int>{};
      stats['totalMessages'] = snapshot.docs.length;

      // Conta messaggi per mittente
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final senderId = data['senderId'] as String? ?? 'unknown';
        stats[senderId] = (stats[senderId] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Errore nel recupero statistiche: $e');
      throw Exception('Errore nel recupero statistiche: $e');
    }
  }

  // Cerca messaggi per contenuto
  Future<List<MessageModel>> searchMessages(String chatId, String searchTerm) async {
    try {
      final snapshot = await _getChatMessagesCollection(chatId)
          .orderBy('timestamp', descending: false)
          .get();

      final messages = snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MessageModel.fromMap(data, doc.id);
      })
          .where((message) =>
          message.content.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();

      return messages;
    } catch (e) {
      print('Errore nella ricerca messaggi: $e');
      throw Exception('Errore nella ricerca messaggi: $e');
    }
  }
}