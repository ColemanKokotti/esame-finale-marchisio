import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/auth_repository.dart';
import '../../services/notification_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final NotificationService _notificationService = NotificationService();
  late StreamSubscription<User?> _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {

    on<AuthInitializeRequested>(_onAuthInitializeRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);

    // Inizializza il monitoraggio dello stato di autenticazione
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        // Imposta il profilo utente nel NotificationService
        _setUserProfileFromFirebaseUser(user);
        emit(AuthAuthenticated(user: user));
      } else {
        // Pulisci il profilo utente quando l'utente non è autenticato
        _notificationService.updateCurrentUserProfile('');
        emit(AuthUnauthenticated());
      }
    });
  }

  // Metodo helper per impostare il profilo utente dal Firebase User
  void _setUserProfileFromFirebaseUser(User user) {
    // Usa displayName se disponibile, altrimenti usa email
    final userProfile = user.displayName ?? user.email ?? 'Utente Sconosciuto';
    _notificationService.updateCurrentUserProfile(userProfile);
  }

  Future<void> _onAuthInitializeRequested(
      AuthInitializeRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      emit(AuthLoading());

      // Inizializza l'utente predefinito
      await _authRepository.initializeDefaultUser();

      // Controlla se c'è un utente già autenticato
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        // Imposta il profilo utente nel NotificationService
        _setUserProfileFromFirebaseUser(currentUser);
        emit(AuthAuthenticated(user: currentUser));
      } else {
        // Assicurati che il profilo sia vuoto se non c'è utente
        _notificationService.updateCurrentUserProfile('');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Errore durante l\'inizializzazione: $e'));
    }
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        // Imposta il profilo utente nel NotificationService
        _setUserProfileFromFirebaseUser(currentUser);
        emit(AuthAuthenticated(user: currentUser));
      } else {
        // Pulisci il profilo utente
        _notificationService.updateCurrentUserProfile('');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Errore durante il controllo dell\'autenticazione: $e'));
    }
  }

  Future<void> _onAuthSignInRequested(
      AuthSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      emit(AuthLoading());

      final user = await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );

      if (user != null) {
        // Imposta il profilo utente nel NotificationService
        _setUserProfileFromFirebaseUser(user);
        emit(AuthAuthenticated(user: user));
      } else {
        // Assicurati che il profilo sia vuoto in caso di errore
        _notificationService.updateCurrentUserProfile('');
        emit(const AuthError(message: 'Errore durante l\'accesso'));
      }
    } catch (e) {
      // Pulisci il profilo in caso di errore
      _notificationService.updateCurrentUserProfile('');
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthSignOutRequested(
      AuthSignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      emit(AuthLoading());
      await _authRepository.signOut();

      // Pulisci il profilo utente dal NotificationService
      _notificationService.updateCurrentUserProfile('');

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Errore durante il logout: $e'));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}