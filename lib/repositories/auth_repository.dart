import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Stream per monitorare lo stato di autenticazione
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Utente corrente
  User? get currentUser => _firebaseAuth.currentUser;

  // Inizializza l'utente predefinito se non esiste
  Future<void> initializeDefaultUser() async {
    const String defaultEmail = 'prova@gmail.com';
    const String defaultPassword = 'prova123';

    try {
      // Verifica se l'utente esiste già
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(defaultEmail);

      if (methods.isEmpty) {
        // L'utente non esiste, crealo
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: defaultEmail,
          password: defaultPassword,
        );
        print('Utente predefinito creato con successo');
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
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Errore durante il logout: $e');
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
      default:
        return 'Errore di autenticazione: ${e.message}';
    }
  }
}