/// Utilitaires pour la manipulation des couleurs
library;
import 'package:flutter/material.dart';

class ColorUtils {
  /// Convertit une chaîne hexadécimale en Color
  static Color hexToColor(String hexString) {
    final hexCode = hexString.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  /// Convertit une Color en chaîne hexadécimale
  static String colorToHex(Color color) => '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  /// Génère une palette de couleurs à partir d'une couleur de base
  static List<Color> generateColorPalette(Color baseColor, {int count = 5}) {
    final hsl = HSLColor.fromColor(baseColor);

    return List.generate(count, (index) {
      final lightness = 0.3 + (index * 0.15); // De 30% à 90% de luminosité
      return hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
    });
  }

  /// Crée une couleur avec une opacité donnée
  static Color withOpacity(Color color, double opacity) => color.withOpacity(opacity);

  /// Mélange deux couleurs
  static Color blendColors(Color color1, Color color2, {double ratio = 0.5}) => Color.lerp(color1, color2, ratio)!;

  /// Détermine si une couleur est claire ou foncée
  static bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  /// Retourne du blanc ou du noir en fonction de la couleur de fond
  static Color getContrastColor(Color backgroundColor) => isLightColor(backgroundColor) ? Colors.black : Colors.white;

  /// Crée un MaterialColor à partir d'une couleur de base
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (var i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}