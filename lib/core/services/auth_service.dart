import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service d'authentification amélioré avec persistance et état de chargement
class AuthService {
  factory AuthService() => _instance;
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  bool _isInitialized = false;
  bool _isLoading = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<User?> get idTokenChanges => _auth.idTokenChanges();

  /// Initialise le service d'authentification
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;

    try {
      // Attendre que Firebase soit initialisé
      await _auth.authStateChanges().first;

      // Récupérer les préférences locales
      final prefs = await SharedPreferences.getInstance();

      // Initialiser Google Sign-In si disponible
      if (!kIsWeb) {
        await _google.signInSilently();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de l\'auth: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Vérifie si l'utilisateur est connecté
  bool get isLoggedIn => _auth.currentUser != null;

  /// Vérifie si l'email est vérifié
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Envoie un email de vérification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Rafraîchit le token de l'utilisateur
  Future<void> refreshUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  /// Connexion avec email et mot de passe
  Future<UserCredential> signInWithEmail(String email, String password) async {
    _isLoading = true;

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Sauvegarder la préférence de connexion
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_logged_in_before', true);

      return result;
    } finally {
      _isLoading = false;
    }
  }

  /// Inscription avec email et mot de passe
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    _isLoading = true;

    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Envoyer l'email de vérification
      await result.user?.sendEmailVerification();

      // Sauvegarder la préférence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_logged_in_before', true);

      return result;
    } finally {
      _isLoading = false;
    }
  }

  /// Connexion avec Google
  Future<UserCredential> signInWithGoogle() async {
    _isLoading = true;

    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Connexion Google annulée',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      // Sauvegarder la préférence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_logged_in_before', true);

      return result;
    } finally {
      _isLoading = false;
    }
  }

  /// Réinitialisation du mot de passe
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Déconnexion
  Future<void> signOut() async {
    _isLoading = true;

    try {
      // Déconnexion de Firebase
      await _auth.signOut();

      // Déconnexion de Google si connecté
      if (!kIsWeb) {
        try {
          await _google.signOut();
        } catch (e) {
          debugPrint('Erreur lors de la déconnexion Google: $e');
        }
      }

      // Nettoyer les préférences locales si nécessaire
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('temp_user_data');

    } finally {
      _isLoading = false;
    }
  }

  /// Suppression du compte utilisateur
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Mise à jour du profil utilisateur
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
      await user.reload();
    }
  }

  /// Change le mot de passe
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  /// Récupère le token JWT actuel
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return user.getIdToken();
    }
    return null;
  }

  /// Vérifie si c'est la première connexion de l'utilisateur
  Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('has_logged_in_before') ?? false);
  }

  /// Nettoie les ressources
  void dispose() {
    _isInitialized = false;
    _isLoading = false;
  }
}