/// Service de suggestions intelligentes de thèmes avec IA
library;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/features/events/page_event_theme_preview.dart';

enum ThemePersonality {
  professional,     // Professionnel et sérieux
  creative,         // Créatif et coloré
  minimal,          // Minimaliste et épuré
  elegant,          // Élégant et sophistiqué
  modern,           // Moderne et tech
  traditional,      // Traditionnel et classique
  playful,          // Ludique et amusant
  luxurious,        // Luxueux et premium
}

enum ColorHarmony {
  complementary,    // Couleurs complémentaires
  analogous,        // Couleurs analogues
  triadic,          // Triadique
  splitComplementary, // Split-complémentaire
  tetradic,         // Tétradique
  monochromatic,    // Monochromatique
}

class ThemeSuggestionService {
  static final Random _random = Random();

  /// Génère des suggestions de thèmes basées sur l'événement
  static List<EventThemeCustomization> getSuggestedThemes(EventOverlay event) {
    final suggestions = <EventThemeCustomization>[];
    final personalities = _getPersonalitiesForEvent(event);

    for (final personality in personalities) {
      suggestions.addAll(_generateThemesForPersonality(event, personality));
    }

    return suggestions;
  }

  /// Génère une palette de couleurs harmonieuse
  static List<Color> generateColorPalette(
    Color baseColor,
    ColorHarmony harmony,
  ) {
    final hsl = _rgbToHsl(baseColor);
    final colors = <Color>[];

    switch (harmony) {
      case ColorHarmony.complementary:
        colors.add(baseColor);
        colors.add(_hslToRgb(hsl['h']! + 180, hsl['s']!, hsl['l']!));
        colors.add(_hslToRgb(hsl['h']! + 180, hsl['s']! * 0.7, hsl['l']!));
        break;

      case ColorHarmony.analogous:
        colors.add(_hslToRgb(hsl['h']! - 30, hsl['s']!, hsl['l']!));
        colors.add(baseColor);
        colors.add(_hslToRgb(hsl['h']! + 30, hsl['s']!, hsl['l']!));
        break;

      case ColorHarmony.triadic:
        colors.add(baseColor);
        colors.add(_hslToRgb(hsl['h']! + 120, hsl['s']!, hsl['l']!));
        colors.add(_hslToRgb(hsl['h']! + 240, hsl['s']!, hsl['l']!));
        break;

      case ColorHarmony.splitComplementary:
        colors.add(baseColor);
        colors.add(_hslToRgb(hsl['h']! + 150, hsl['s']!, hsl['l']!));
        colors.add(_hslToRgb(hsl['h']! + 210, hsl['s']!, hsl['l']!));
        break;

      case ColorHarmony.tetradic:
        colors.add(baseColor);
        colors.add(_hslToRgb(hsl['h']! + 90, hsl['s']!, hsl['l']!));
        colors.add(_hslToRgb(hsl['h']! + 180, hsl['s']!, hsl['l']!));
        colors.add(_hslToRgb(hsl['h']! + 270, hsl['s']!, hsl['l']!));
        break;

      case ColorHarmony.monochromatic:
        colors.add(_hslToRgb(hsl['h']!, hsl['s']!, (hsl['l']! - 0.2).clamp(0.0, 1.0)));
        colors.add(baseColor);
        colors.add(_hslToRgb(hsl['h']!, hsl['s']!, (hsl['l']! + 0.2).clamp(0.0, 1.0)));
        break;
    }

    return colors;
  }

  /// Suggère des typographies appropriées
  static List<String> getFontSuggestions(ThemePersonality personality) {
    switch (personality) {
      case ThemePersonality.professional:
        return ['Roboto', 'Arial', 'Helvetica', 'Lato'];
      case ThemePersonality.creative:
        return ['Pacifico', 'Dancing Script', 'Caveat', 'Great Vibes'];
      case ThemePersonality.minimal:
        return ['Roboto Mono', 'Source Code Pro', 'Fira Code', 'IBM Plex Mono'];
      case ThemePersonality.elegant:
        return ['Playfair Display', 'Bodoni Moda', 'Cormorant Garamond', 'Merriweather'];
      case ThemePersonality.modern:
        return ['Poppins', 'Montserrat', 'Nunito', 'Quicksand'];
      case ThemePersonality.traditional:
        return ['Times New Roman', 'Georgia', 'Garamond', 'Baskerville'];
      case ThemePersonality.playful:
        return ['Comic Neue', 'Fredoka One', 'Bubblegum Sans', 'Luckiest Guy'];
      case ThemePersonality.luxurious:
        return ['Cormorant', 'Playfair Display', 'Libre Baskerville', 'Crimson Text'];
    }
  }

  /// Suggère des motifs d'arrière-plan
  static List<String> getPatternSuggestions(ThemePersonality personality) {
    switch (personality) {
      case ThemePersonality.professional:
      case ThemePersonality.minimal:
        return ['none', 'subtle-dots', 'fine-lines'];
      case ThemePersonality.creative:
      case ThemePersonality.playful:
        return ['geometric', 'abstract-shapes', 'colorful-dots'];
      case ThemePersonality.elegant:
      case ThemePersonality.luxurious:
        return ['elegant-lines', 'subtle-gradient', 'foil-pattern'];
      case ThemePersonality.modern:
        return ['grid', 'tech-pattern', 'circuit'];
      case ThemePersonality.traditional:
        return ['classic-pattern', 'vintage-texture', 'ornamental'];
    }
  }

  /// Analyse la saison et suggère des thèmes appropriés
  static EventThemeCustomization getSeasonalTheme(EventOverlay event) {
    final now = DateTime.now();
    final month = now.month;

    Color primaryColor;
    Color secondaryColor;
    String backgroundPattern;

    if (month >= 3 && month <= 5) { // Printemps
      primaryColor = const Color(0xFF8BC34A); // Vert printemps
      secondaryColor = const Color(0xFFFFC107); // Jaune pâle
      backgroundPattern = 'floral';
    } else if (month >= 6 && month <= 8) { // Été
      primaryColor = const Color(0xFF2196F3); // Bleu ciel
      secondaryColor = const Color(0xFFFFEB3B); // Jaune ensoleillé
      backgroundPattern = 'sun-rays';
    } else if (month >= 9 && month <= 11) { // Automne
      primaryColor = const Color(0xFFFF9800); // Orange automne
      secondaryColor = const Color(0xFF795548); // Brun
      backgroundPattern = 'falling-leaves';
    } else { // Hiver
      primaryColor = const Color(0xFF9C27B0); // Violet/bleu hiver
      secondaryColor = const Color(0xFFE1F5FE); // Blanc glacé
      backgroundPattern = 'snowflakes';
    }

    return EventThemeCustomization(
      templateId: _getTemplateForSeason(month),
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      showBackgroundPattern: true,
      backgroundPattern: backgroundPattern,
      borderRadius: 12.0,
      shadowOpacity: 0.15,
    );
  }

  /// Génère un thème basé sur l'humeur/émotion
  static EventThemeCustomization generateMoodTheme(String mood) {
    final moodLower = mood.toLowerCase();

    switch (moodLower) {
      case 'joyeux':
      case 'heureux':
        return _createJoyfulTheme();
      case 'calme':
      case 'relaxé':
        return _createCalmTheme();
      case 'énergique':
      case 'dynamique':
        return _createEnergeticTheme();
      case 'sérieux':
      case 'professionnel':
        return _createProfessionalTheme();
      case 'romantique':
        return _createRomanticTheme();
      case 'mystérieux':
        return _createMysteriousTheme();
      default:
        return _createBalancedTheme();
    }
  }

  /// Suggère des améliorations pour un thème existant
  static List<String> suggestImprovements(EventThemeCustomization theme) {
    final suggestions = <String>[];

    // Vérifier le contraste
    if (!_hasGoodContrast(theme.primaryColor, theme.backgroundColor)) {
      suggestions.add('Améliorer le contraste entre la couleur principale et le fond');
    }

    // Vérifier l'harmonie des couleurs
    if (!_colorsAreHarmonious(theme.primaryColor, theme.secondaryColor)) {
      suggestions.add('Utiliser des couleurs plus harmonieuses');
    }

    // Vérifier la lisibilité
    if (theme.bodyFontSize < 12) {
      suggestions.add('Augmenter la taille du texte pour une meilleure lisibilité');
    }

    // Vérifier les espacements
    if (theme.cardPadding < 16) {
      suggestions.add('Augmenter les marges pour un meilleur aération');
    }

    return suggestions;
  }

  // Méthodes privées

  static List<ThemePersonality> _getPersonalitiesForEvent(EventOverlay event) {
    switch (event.id) {
      case 'octobre_rose':
        return [ThemePersonality.elegant, ThemePersonality.professional];
      case 'movember':
        return [ThemePersonality.modern, ThemePersonality.professional];
      case 'noel':
        return [ThemePersonality.traditional, ThemePersonality.playful];
      case 'st_valentin':
        return [ThemePersonality.romantic, ThemePersonality.elegant];
      case 'halloween':
        return [ThemePersonality.playful, ThemePersonality.mysterious];
      default:
        return [ThemePersonality.professional, ThemePersonality.modern];
    }
  }

  static List<EventThemeCustomization> _generateThemesForPersonality(
    EventOverlay event,
    ThemePersonality personality,
  ) {
    final themes = <EventThemeCustomization>[];
    final harmonies = [ColorHarmony.complementary, ColorHarmony.analogous, ColorHarmony.triadic];

    for (final harmony in harmonies) {
      final palette = generateColorPalette(event.color, harmony);
      final fonts = getFontSuggestions(personality);
      final patterns = getPatternSuggestions(personality);

      themes.add(EventThemeCustomization(
        templateId: _getTemplateForPersonality(personality),
        primaryColor: palette[0],
        secondaryColor: palette.length > 1 ? palette[1] : palette[0],
        accentColor: palette.length > 2 ? palette[2] : palette[0],
        backgroundColor: _getBackgroundForPersonality(personality),
        textColor: _getTextColorForBackground(_getBackgroundForPersonality(personality)),
        fontFamily: fonts[_random.nextInt(fonts.length)],
        titleFontSize: _getTitleSizeForPersonality(personality),
        bodyFontSize: _getBodySizeForPersonality(personality),
        showBackgroundPattern: _random.nextBool() && patterns.isNotEmpty,
        backgroundPattern: patterns.isNotEmpty ? patterns[_random.nextInt(patterns.length)] : 'none',
        borderRadius: _getBorderRadiusForPersonality(personality),
        shadowOpacity: _getShadowOpacityForPersonality(personality),
      ));
    }

    return themes;
  }

  static String _getTemplateForPersonality(ThemePersonality personality) {
    switch (personality) {
      case ThemePersonality.professional:
      case ThemePersonality.traditional:
        return 'corporate';
      case ThemePersonality.minimal:
        return 'minimal';
      case ThemePersonality.modern:
        return 'ansut_style';
      case ThemePersonality.elegant:
      case ThemePersonality.luxurious:
        return 'ansut_style';
      default:
        return 'minimal';
    }
  }

  static Color _getBackgroundForPersonality(ThemePersonality personality) {
    switch (personality) {
      case ThemePersonality.luxurious:
      case ThemePersonality.elegant:
        return const Color(0xFFFFF8F0);
      case ThemePersonality.mysterious:
        return const Color(0xFF1A1A1A);
      case ThemePersonality.modern:
        return const Color(0xFFF8F9FA);
      default:
        return Colors.white;
    }
  }

  static Color _getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  static double _getTitleSizeForPersonality(ThemePersonality personality) {
    switch (personality) {
      case ThemePersonality.elegant:
      case ThemePersonality.luxurious:
        return 24.0;
      case ThemePersonality.playful:
        return 22.0;
      default:
        return 20.0;
    }
  }

  static double _getBodySizeForPersonality(ThemePersonality personality) {
    switch (personality) {
      case ThemePersonality.elegant:
        return 16.0;
      default:
        return 14.0;
    }
  }

  static double _getBorderRadiusForPersonality(ThemePersonality personality) {
    switch (personality) {
      case ThemePersonality.modern:
        return 16.0;
      case ThemePersonality.elegant:
        return 8.0;
      case ThemePersonality.playful:
        return 20.0;
      default:
        return 12.0;
    }
  }

  static double _getShadowOpacityForPersonality(ThemePersonality personality) {
    switch (personality) {
      case ThemePersonality.luxurious:
      case ThemePersonality.elegant:
        return 0.3;
      case ThemePersonality.minimal:
        return 0.1;
      default:
        return 0.2;
    }
  }

  static String _getTemplateForSeason(int month) {
    if (month >= 3 && month <= 5) return 'minimal'; // Printemps
    if (month >= 6 && month <= 8) return 'ansut_style'; // Été
    if (month >= 9 && month <= 11) return 'corporate'; // Automne
    return 'minimal'; // Hiver
  }

  // Méthodes de création de thèmes basés sur l'humeur
  static EventThemeCustomization _createJoyfulTheme() => const EventThemeCustomization(
      primaryColor: Color(0xFFFFD600),
      secondaryColor: Color(0xFFFF6B6B),
      accentColor: Color(0xFF4ECDC4),
      backgroundColor: Color(0xFFFFF8E1),
      showBackgroundPattern: true,
      backgroundPattern: 'confetti',
      borderRadius: 20.0,
      shadowOpacity: 0.25,
    );

  static EventThemeCustomization _createCalmTheme() => const EventThemeCustomization(
      primaryColor: Color(0xFF81C784),
      secondaryColor: Color(0xFF64B5F6),
      accentColor: Color(0xFF9575CD),
      backgroundColor: Color(0xFFF1F8E9),
      showBackgroundPattern: true,
      backgroundPattern: 'waves',
      borderRadius: 16.0,
      shadowOpacity: 0.1,
    );

  static EventThemeCustomization _createEnergeticTheme() => const EventThemeCustomization(
      primaryColor: Color(0xFFFF5722),
      secondaryColor: Color(0xFFFFC107),
      accentColor: Color(0xFFE91E63),
      backgroundColor: Colors.white,
      showBackgroundPattern: true,
      backgroundPattern: 'dynamic-lines',
      borderRadius: 12.0,
      shadowOpacity: 0.3,
    );

  static EventThemeCustomization _createProfessionalTheme() => const EventThemeCustomization(
      primaryColor: Color(0xFF37474F),
      secondaryColor: Color(0xFF607D8B),
      accentColor: Color(0xFF1976D2),
      backgroundColor: Color(0xFFF5F5F5),
      showBackgroundPattern: false,
      borderRadius: 8.0,
      shadowOpacity: 0.15,
    );

  static EventThemeCustomization _createRomanticTheme() => const EventThemeCustomization(
      primaryColor: Color(0xFFE91E63),
      secondaryColor: Color(0xFFF48FB1),
      accentColor: Color(0xFFCE93D8),
      backgroundColor: Color(0xFFFCE4EC),
      showBackgroundPattern: true,
      backgroundPattern: 'hearts',
      borderRadius: 18.0,
      shadowOpacity: 0.2,
    );

  static EventThemeCustomization _createMysteriousTheme() => const EventThemeCustomization(
      primaryColor: Color(0xFF4A148C),
      secondaryColor: Color(0xFF1A237E),
      accentColor: Color(0xFFB71C1C),
      backgroundColor: Color(0xFF263238),
      textColor: Color(0xFFECEFF1),
      showBackgroundPattern: true,
      backgroundPattern: 'stars',
      borderRadius: 6.0,
      shadowOpacity: 0.4,
    );

  static EventThemeCustomization _createBalancedTheme() => const EventThemeCustomization(
      primaryColor: Color(0xFF2196F3),
      secondaryColor: Color(0xFF4CAF50),
      accentColor: Color(0xFFFF9800),
      backgroundColor: Colors.white,
      showBackgroundPattern: false,
      borderRadius: 12.0,
      shadowOpacity: 0.2,
    );

  // Utilitaires pour les couleurs
  static Map<String, double> _rgbToHsl(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final delta = max - min;

    double h = 0;
    double s = 0;
    final l = (max + min) / 2.0;

    if (delta != 0) {
      s = l > 0.5 ? delta / (2.0 - max - min) : delta / (max + min);

      if (max == r) {
        h = ((g - b) / delta + (g < b ? 6 : 0)) / 6.0;
      } else if (max == g) {
        h = ((b - r) / delta + 2) / 6.0;
      } else {
        h = ((r - g) / delta + 4) / 6.0;
      }
    }

    return {'h': h * 360, 's': s, 'l': l};
  }

  static Color _hslToRgb(double h, double s, double l) {
    h = h / 360.0;

    double r, g, b;

    if (s == 0) {
      r = g = b = l;
    } else {
      dynamic hue2rgb(p, q, t) {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1/6) return p + (q - p) * 6 * t;
        if (t < 1/2) return q;
        if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
        return p;
      }

      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;
      r = hue2rgb(p, q, h + 1/3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1/3);
    }

    return Color.fromARGB(255, (r * 255).round(), (g * 255).round(), (b * 255).round());
  }

  static bool _hasGoodContrast(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();
    final ratio = (luminance1 + 0.05) / (luminance2 + 0.05);
    return ratio >= 1.5 && ratio <= 6.0;
  }

  static bool _colorsAreHarmonious(Color color1, Color color2) {
    final hsl1 = _rgbToHsl(color1);
    final hsl2 = _rgbToHsl(color2);

    final hueDiff = (hsl1['h']! - hsl2['h']!).abs();
    return hueDiff <= 60 || hueDiff >= 300 || // Analogues
           (hueDiff >= 120 && hueDiff <= 240); // Triadique/complémentaire
  }
}