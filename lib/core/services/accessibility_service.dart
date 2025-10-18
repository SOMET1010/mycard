import 'dart:math';

/// Service pour gérer l'accessibilité de l'application
class AccessibilityService {
  /// Vérifie si le contraste entre deux couleurs est suffisant (WCAG AA)
  static bool hasSufficientContrast(
    int foregroundColor,
    int backgroundColor, {
    bool largeText = false,
  }) {
    final ratio = _calculateContrastRatio(foregroundColor, backgroundColor);
    return ratio >= (largeText ? 3.0 : 4.5);
  }

  /// Calcule le ratio de contraste entre deux couleurs
  static double calculateContrastRatio(int color1, int color2) {
    final l1 = getLuminance(color1);
    final l2 = getLuminance(color2);

    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calcule la luminance relative d'une couleur
  static double getLuminance(int color) {
    final r = getLinearValue((color >> 16) & 0xFF);
    final g = getLinearValue((color >> 8) & 0xFF);
    final b = getLinearValue(color & 0xFF);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Convertit une valeur de canal de couleur en valeur linéaire
  static double getLinearValue(int channel) {
    final s = channel / 255.0;
    return s <= 0.03928 ? s / 12.92 : pow((s + 0.055) / 1.055, 2.4) as double;
  }

  /// @visibleForTesting - calcule le ratio de contraste entre deux couleurs
  static double _calculateContrastRatio(int color1, int color2) =>
      calculateContrastRatio(color1, color2);

  /// @visibleForTesting - calcule la luminance relative d'une couleur
  static double _getLuminance(int color) => getLuminance(color);

  /// Détermine la taille de texte accessible recommandée
  static double getAccessibleTextSize(
    double baseSize, {
    bool isLargeText = false,
  }) {
    if (isLargeText) {
      return baseSize >= 18.0 ? baseSize : 18.0;
    }
    return baseSize >= 14.0 ? baseSize : 14.0;
  }

  /// Vérifie si une taille de texte est suffisamment grande pour l'accessibilité
  static bool isTextSizeAccessible(double fontSize) => fontSize >= 14.0;

  /// Détermine la couleur de texte optimale pour un fond donné
  static int getOptimalTextColor(int backgroundColor) {
    final luminance = _getLuminance(backgroundColor);
    return luminance > 0.5 ? 0xFF000000 : 0xFFFFFFFF;
  }

  /// Calcule la taille minimale pour les éléments interactifs
  static double getMinimumInteractiveSize() {
    return 44.0; // Recommandation WCAG pour les éléments tactiles
  }

  /// Vérifie si un élément interactif a une taille suffisante
  static bool isInteractiveSizeAccessible(double width, double height) =>
      width >= 44.0 && height >= 44.0;

  /// Génère des suggestions pour améliorer l'accessibilité
  static List<String> getAccessibilitySuggestions({
    required int backgroundColor,
    required List<int> foregroundColors,
    required List<double> textSizes,
    required Map<String, double> interactiveSizes,
  }) {
    final suggestions = <String>[];

    // Vérifier les contrastes
    for (var i = 0; i < foregroundColors.length; i++) {
      if (!hasSufficientContrast(foregroundColors[i], backgroundColor)) {
        suggestions.add(
          'Améliorer le contraste du texte ${i + 1} avec le fond',
        );
      }
    }

    // Vérifier les tailles de texte
    for (var i = 0; i < textSizes.length; i++) {
      if (!isTextSizeAccessible(textSizes[i])) {
        suggestions.add(
          'Augmenter la taille du texte ${i + 1} à au moins 14px',
        );
      }
    }

    // Vérifier les éléments interactifs
    interactiveSizes.forEach((name, size) {
      if (size < getMinimumInteractiveSize()) {
        suggestions.add(
          'Augmenter la taille de l\'élément "$name" à au moins 44px',
        );
      }
    });

    return suggestions;
  }
}
