// repositories/notification_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _notificationsCollection =>
      _firestore.collection('notifications');

  // Crea notifica di benvenuto per nuovo utente
  Future<void> createWelcomeNotification(String userId) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        sender: 'Staff',
        message: "Benvenuto nell'applicazione Fondazione Oz! Esplora le risorse disponibili.",
        type: NotificationType.welcome,
        createdAt: DateTime.now(),
      );

      await _notificationsCollection.add(notification.toMap());
      print('Notifica di benvenuto creata per utente: $userId');
    } catch (e) {
      print('Errore nella creazione notifica di benvenuto: $e');
      throw Exception('Errore nella creazione notifica di benvenuto: $e');
    }
  }

  // Crea notifica per invito chat
  Future<void> createChatInviteNotification({
    required String userId,
    required String inviterName,
    required String chatTitle,
    required String chatId, required String recipientId,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        sender: inviterName,
        message: 'Ti ha invitato alla chat "$chatTitle".',
        type: NotificationType.chatInvite,
        createdAt: DateTime.now(),
        metadata: {'chatId': chatId}, // Aggiungi metadati per navigazione
      );

      await _notificationsCollection.add(notification.toMap());
      print('Notifica invito chat creata per utente: $userId');
    } catch (e) {
      print('Errore nella creazione notifica invito chat: $e');
      throw Exception('Errore nella creazione notifica invito chat: $e');
    }
  }

  // Crea notifica per nuovo messaggio in chat
  Future<void> createNewMessageNotification({
    required String userId,
    required String senderName,
    required String messageContent,
    required String chatId,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        sender: senderName,
        message: 'Nuovo messaggio da $senderName: "$messageContent"',
        type: NotificationType.newMessage,
        createdAt: DateTime.now(),
        metadata: {'chatId': chatId},
      );
      await _notificationsCollection.add(notification.toMap());
      print('Notifica nuovo messaggio creata per utente: $userId');
    } catch (e) {
      print('Errore nella creazione notifica nuovo messaggio: $e');
      throw Exception('Errore nella creazione notifica nuovo messaggio: $e');
    }
  }

  // Ottieni tutte le notifiche per un utente specifico
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    try {
      return _notificationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
    } catch (e) {
      print('Errore nel recupero notifiche utente: $e');
      throw Exception('Errore nel recupero notifiche utente: $e');
    }
  }

  // NUOVO: Ottieni solo notifiche non lette per un utente specifico
  Stream<List<NotificationModel>> getUnreadNotifications(String userId) {
    try {
      return _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false) // Filtra per non lette
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
    } catch (e) {
      print('Errore nel recupero notifiche non lette: $e');
      return Stream.value([]); // Restituisce uno stream vuoto in caso di errore
    }
  }

  // Conta le notifiche non lette per un utente
  Stream<int> getUnreadNotificationsCount(String userId) {
    try {
      return _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      print('Errore nel conteggio notifiche non lette: $e');
      return Stream.value(0);
    }
  }

  // Segna una notifica come letta
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({'isRead': true});
    } catch (e) {
      print('Errore nel marcare notifica come letta: $e');
      throw Exception('Errore nel marcare notifica come letta: $e');
    }
  }

  // Elimina una notifica
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      print('Errore nell\'eliminazione notifica: $e');
      throw Exception('Errore nell\'eliminazione notifica: $e');
    }
  }

  // Test delle notifiche per sviluppo
  Future<void> createTestNotifications(String userId) async {
    try {
      await _notificationsCollection.add(NotificationModel(
        id: '', userId: userId, sender: 'Admin', message: 'Questa è una notifica di prova.', type: NotificationType.welcome, createdAt: DateTime.now(),
      ).toMap());
      await _notificationsCollection.add(NotificationModel(
        id: '', userId: userId, sender: 'Supporto', message: 'Hai un nuovo messaggio importante!', type: NotificationType.newMessage, createdAt: DateTime.now().subtract(const Duration(minutes: 5)), isRead: false,
      ).toMap());
      await _notificationsCollection.add(NotificationModel(
        id: '', userId: userId, sender: 'Sistema', message: 'Sei stato invitato alla chat "Discussioni Generali".', type: NotificationType.chatInvite, createdAt: DateTime.now().subtract(const Duration(hours: 1)), isRead: false, metadata: {'chatId': 'test_chat_id'},
      ).toMap());
    } catch (e) {
      print('Errore nella creazione notifiche di test: $e');
      throw Exception('Errore nella creazione notifiche di test: $e');
    }
  }

  // Pulisci notifiche vecchie (da chiamare periodicamente)
  Future<void> cleanOldNotifications(String userId, {int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final snapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isLessThan: cutoffDate.millisecondsSinceEpoch)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Pulite ${snapshot.docs.length} notifiche vecchie per utente: $userId');
    } catch (e) {
      print('Errore nella pulizia notifiche vecchie: $e');
    }
  }

  // Elimina tutte le notifiche di un utente (per testing)
  Future<void> deleteAllUserNotifications(String userId) async {
    try {
      final snapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Eliminate ${snapshot.docs.length} notifiche per utente: $userId');
    } catch (e) {
      print('Errore nell\'eliminazione di tutte le notifiche dell\'utente: $e');
    }
  }
}