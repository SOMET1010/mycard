import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Gestionnaire centralisé des erreurs d'authentification
class AuthErrorHandler {
  /// Convertit les erreurs Firebase en messages utilisateur conviviaux
  static String getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        // Erreurs de connexion
        case 'user-not-found':
          return 'Aucun compte trouvé pour cet email';
        case 'wrong-password':
          return 'Mot de passe incorrect';
        case 'invalid-email':
          return 'Format d\'email invalide';
        case 'user-disabled':
          return 'Ce compte a été désactivé';
        case 'too-many-requests':
          return 'Trop de tentatives. Veuillez réessayer plus tard';
        case 'operation-not-allowed':
          return 'Opération non autorisée';
        case 'invalid-credential':
          return 'Identifiants invalides';

        // Erreurs d'inscription
        case 'email-already-in-use':
          return 'Un compte existe déjà avec cet email';
        case 'weak-password':
          return 'Le mot de passe est trop faible';
        case 'invalid-email':
          return 'Format d\'email invalide';

        // Erreurs de réinitialisation
        case 'auth/invalid-email':
          return 'Format d\'email invalide';
        case 'auth/user-not-found':
          return 'Aucun compte trouvé pour cet email';

        // Erreurs Google Sign-In
        case 'aborted-by-user':
          return 'Connexion Google annulée';
        case 'account-exists-with-different-credential':
          return 'Un compte existe déjà avec un autre fournisseur';
        case 'invalid-credential':
          return 'Informations d\'identification Google invalides';
        case 'operation-not-allowed':
          return 'Connexion Google non activée';

        // Erreurs réseau
        case 'network-request-failed':
          return 'Erreur réseau. Vérifiez votre connexion';

        default:
          return error.message ?? 'Une erreur est survenue';
      }
    }

    return error.toString().replaceAll('Exception:', '').trim();
  }

  /// Affiche une snackbar avec une erreur formatée
  static void showErrorSnackBar(BuildContext context, Object error) {
    final message = getErrorMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Affiche une snackbar de succès
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Affiche une snackbar d'information
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
