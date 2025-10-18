/// Validateurs pour les champs de la carte de visite
class Validators {
  /// Valide un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }

    return null;
  }

  /// Valide un numéro de téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }

    // Regex plus flexible qui supporte les formats internationaux
    final phoneRegex = RegExp(r'^\+?[0-9]{1,4}?[-\s]?[(]?[0-9]{1,4}?[)]?[-\s]?[0-9]{1,4}[-\s]?[0-9]{1,4}[-\s]?[0-9]{2,9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }

    return null;
  }

  /// Valide une URL de site web
  static String? validateWebsite(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }

    final urlRegex = RegExp(r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$');
    if (!urlRegex.hasMatch(value)) {
      return 'Veuillez entrer une URL valide (ex: https://example.com)';
    }

    return null;
  }

  /// Valide un nom ou prénom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }

    if (value.length < 2) {
      return 'Doit contenir au moins 2 caractères';
    }

    if (value.length > 50) {
      return 'Doit contenir au maximum 50 caractères';
    }

    // Validation simple de caractères alphabétiques
    if (!RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value)) {
      return 'Caractères invalides détectés';
    }

    return null;
  }

  /// Valide un titre ou fonction
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }

    if (value.length < 2) {
      return 'Doit contenir au moins 2 caractères';
    }

    if (value.length > 100) {
      return 'Doit contenir au maximum 100 caractères';
    }

    return null;
  }

  /// Valide un nom d'entreprise
  static String? validateCompany(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }

    if (value.length > 100) {
      return 'Doit contenir au maximum 100 caractères';
    }

    return null;
  }

  /// Valide une adresse
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }

    if (value.length > 200) {
      return 'Doit contenir au maximum 200 caractères';
    }

    return null;
  }

  /// Valide un code postal
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }

    final postalRegex = RegExp(r'^[0-9]{5}$');
    if (!postalRegex.hasMatch(value)) {
      return 'Veuillez entrer un code postal valide';
    }

    return null;
  }

  /// Valide une ville
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }

    if (value.length > 50) {
      return 'Doit contenir au maximum 50 caractères';
    }

    return null;
  }
}