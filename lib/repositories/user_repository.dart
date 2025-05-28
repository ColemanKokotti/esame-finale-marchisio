// repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collezione users
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Crea o aggiorna un utente
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(
        user.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Errore durante il salvataggio dell\'utente: $e');
    }
  }

  // Ottieni un utente tramite UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Errore durante il recupero dell\'utente: $e');
    }
  }

  // Stream di tutti gli utenti
  Stream<List<UserModel>> getAllUsers() {
    return _usersCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList());
  }

  // Stream di tutti gli utenti online
  Stream<List<UserModel>> getOnlineUsers() {
    return _usersCollection
        .where('isOnline', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList());
  }

  // NUOVO: Stream di utenti filtrati per ruolo
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _usersCollection
        .where('role', isEqualTo: role)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList());
  }

  // NUOVO: Stream di utenti con filtro dinamico
  Stream<List<UserModel>> getUsersWithFilter({
    String? role,
    bool? isOnline,
  }) {
    Query query = _usersCollection.orderBy('name');

    if (role != null) {
      query = query.where('role', isEqualTo: role);
    }

    if (isOnline != null) {
      query = query.where('isOnline', isEqualTo: isOnline);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // Aggiorna il ruolo di un utente
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _usersCollection.doc(uid).update({
        'role': newRole,
      });
    } catch (e) {
      throw Exception('Errore durante l\'aggiornamento del ruolo: $e');
    }
  }

  // Aggiorna lo stato online/offline di un utente
  Future<void> updateUserOnlineStatus(String uid, bool isOnline) async {
    try {
      await _usersCollection.doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': isOnline ? null : Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Errore durante l\'aggiornamento dello stato: $e');
    }
  }

  // Aggiorna il nome dell'utente
  Future<void> updateUserName(String uid, String newName) async {
    try {
      await _usersCollection.doc(uid).update({
        'name': newName,
      });
    } catch (e) {
      throw Exception('Errore durante l\'aggiornamento del nome: $e');
    }
  }

  // Elimina un utente
  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      throw Exception('Errore durante l\'eliminazione dell\'utente: $e');
    }
  }

  // Ottieni statistiche utenti
  Future<Map<String, int>> getUserStats() async {
    try {
      final allUsersSnapshot = await _usersCollection.get();
      final onlineUsersSnapshot = await _usersCollection
          .where('isOnline', isEqualTo: true)
          .get();

      return {
        'total': allUsersSnapshot.docs.length,
        'online': onlineUsersSnapshot.docs.length,
        'offline': allUsersSnapshot.docs.length - onlineUsersSnapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Errore durante il recupero delle statistiche: $e');
    }
  }

  // NUOVO: Ottieni statistiche per ruolo
  Future<Map<String, int>> getStatsPerRole() async {
    try {
      final allUsersSnapshot = await _usersCollection.get();
      final Map<String, int> roleStats = {};

      for (var doc in allUsersSnapshot.docs) {
        final user = UserModel.fromFirestore(doc);
        roleStats[user.role] = (roleStats[user.role] ?? 0) + 1;
      }

      return roleStats;
    } catch (e) {
      throw Exception('Errore durante il recupero delle statistiche per ruolo: $e');
    }
  }
}