// repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'user_repository.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    UserRepository? userRepository,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _userRepository = userRepository ?? UserRepository();

  // Stream per monitorare lo stato di autenticazione
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Utente corrente
  User? get currentUser => _firebaseAuth.currentUser;

  // Inizializza l'utente predefinito se non esiste
  Future<void> initializeDefaultUser() async {
    const String defaultEmail = 'prova@gmail.com';
    const String defaultPassword = 'prova123';
    const String defaultName = 'Mario Rossi';

    try {
      // Verifica se l'utente esiste già
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(defaultEmail);

      if (methods.isEmpty) {
        // L'utente non esiste, crealo
        final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: defaultEmail,
          password: defaultPassword,
        );

        // Crea il profilo utente su Firestore
        if (credential.user != null) {
          final userModel = UserModel(
            uid: credential.user!.uid,
            name: defaultName,
            email: defaultEmail,
            role: 'Ospite',
            isOnline: false,
            createdAt: DateTime.now(),
          );

          await _userRepository.createOrUpdateUser(userModel);
          print('Utente predefinito creato con successo');
        }
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        // L'utente esiste già, va bene
        print('Utente predefinito già esistente');
      } else {
        print('Errore durante l\'inizializzazione dell\'utente predefinito: $e');
      }
    }
  }

  // Accesso con email e password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Aggiorna lo stato online dell'utente
      if (credential.user != null) {
        await _userRepository.updateUserOnlineStatus(credential.user!.uid, true);
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registrazione con email e password
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String role = 'Ospite',
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crea il profilo utente su Firestore
      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
          role: role,
          isOnline: true,
          createdAt: DateTime.now(),
        );

        await _userRepository.createOrUpdateUser(userModel);
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      // Aggiorna lo stato offline prima del logout
      if (currentUser != null) {
        await _userRepository.updateUserOnlineStatus(currentUser!.uid, false);
      }

      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Errore durante il logout: $e');
    }
  }

  // Ottieni il profilo utente corrente
  Future<UserModel?> getCurrentUserProfile() async {
    if (currentUser != null) {
      return await _userRepository.getUserById(currentUser!.uid);
    }
    return null;
  }

  // Aggiorna il profilo utente corrente
  Future<void> updateCurrentUserProfile({
    String? name,
    String? role,
    bool? isOnline,
  }) async {
    if (currentUser != null) {
      final currentProfile = await _userRepository.getUserById(currentUser!.uid);

      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          name: name,
          role: role,
          isOnline: isOnline,
        );

        await _userRepository.createOrUpdateUser(updatedProfile);
      }
    }
  }

  // Gestione delle eccezioni Firebase
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Nessun utente trovato con questa email.';
      case 'wrong-password':
        return 'Password errata.';
      case 'invalid-email':
        return 'Email non valida.';
      case 'user-disabled':
        return 'Questo account è stato disabilitato.';
      case 'too-many-requests':
        return 'Troppi tentativi di accesso. Riprova più tardi.';
      case 'operation-not-allowed':
        return 'Operazione non consentita.';
      case 'email-already-in-use':
        return 'Questa email è già registrata.';
      case 'weak-password':
        return 'La password è troppo debole.';
      default:
        return 'Errore di autenticazione: ${e.message}';
    }
  }
}