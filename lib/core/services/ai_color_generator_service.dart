/// Service de génération de couleurs avec IA et algorithmes avancés
library;

import 'dart:math';
import 'package:flutter/material.dart';

enum ColorGenerationMethod {
  complementary, // Couleurs complémentaires
  analogous, // Couleurs analogues
  triadic, // Triadique
  tetradic, // Tétradique
  splitComplementary, // Split-complémentaire
  monochromatic, // Monochromatique
  aiHarmony, // Harmonie IA
  moodBased, // Basé sur l'humeur
  brandBased, // Basé sur la marque
  seasonal, // Saisonnier
  random, // Aléatoire
  gradientBased, // Basé sur dégradé
  imageExtracted, // Extrait d'image
  accessibility, // Accessibilité WCAG
}

enum ColorMood {
  energetic, // Énergique
  calm, // Calme
  professional, // Professionnel
  creative, // Créatif
  romantic, // Romantique
  mysterious, // Mystérieux
  playful, // Ludique
  luxurious, // Luxueux
  natural, // Naturel
  futuristic, // Futuriste
}

class AIColorPalette {
  const AIColorPalette({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
    this.additionalColors = const [],
    required this.generationMethod,
    this.mood,
    this.metadata = const {},
    required this.createdAt,
    this.harmonyScore = 0.0,
    this.accessibilityScore = 0.0,
  });

  factory AIColorPalette.fromJson(Map<String, dynamic> json) => AIColorPalette(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    primaryColor: Color(
      int.parse(json['primaryColor'].substring(1), radix: 16) + 0xFF000000,
    ),
    secondaryColor: Color(
      int.parse(json['secondaryColor'].substring(1), radix: 16) + 0xFF000000,
    ),
    accentColor: Color(
      int.parse(json['accentColor'].substring(1), radix: 16) + 0xFF000000,
    ),
    backgroundColor: Color(
      int.parse(json['backgroundColor'].substring(1), radix: 16) + 0xFF000000,
    ),
    textColor: Color(
      int.parse(json['textColor'].substring(1), radix: 16) + 0xFF000000,
    ),
    additionalColors: (json['additionalColors'] as List)
        .map(
          (color) =>
              Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
        )
        .toList(),
    generationMethod: ColorGenerationMethod.values.firstWhere(
      (e) => e.name == json['generationMethod'],
      orElse: () => ColorGenerationMethod.random,
    ),
    mood: json['mood'] != null
        ? ColorMood.values.firstWhere(
            (e) => e.name == json['mood'],
            orElse: () => ColorMood.energetic,
          )
        : null,
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    createdAt: DateTime.parse(json['createdAt']),
    harmonyScore: (json['harmonyScore'] ?? 0.0).toDouble(),
    accessibilityScore: (json['accessibilityScore'] ?? 0.0).toDouble(),
  );
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color textColor;
  final List<Color> additionalColors;
  final ColorGenerationMethod generationMethod;
  final ColorMood? mood;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final double harmonyScore;
  final double accessibilityScore;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'primaryColor': '#${primaryColor.value.toRadixString(16).substring(2)}',
    'secondaryColor': '#${secondaryColor.value.toRadixString(16).substring(2)}',
    'accentColor': '#${accentColor.value.toRadixString(16).substring(2)}',
    'backgroundColor':
        '#${backgroundColor.value.toRadixString(16).substring(2)}',
    'textColor': '#${textColor.value.toRadixString(16).substring(2)}',
    'additionalColors': additionalColors
        .map((color) => '#${color.value.toRadixString(16).substring(2)}')
        .toList(),
    'generationMethod': generationMethod.name,
    'mood': mood?.name,
    'metadata': metadata,
    'createdAt': createdAt.toIso8601String(),
    'harmonyScore': harmonyScore,
    'accessibilityScore': accessibilityScore,
  };

  AIColorPalette copyWith({
    String? id,
    String? name,
    String? description,
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    Color? backgroundColor,
    Color? textColor,
    List<Color>? additionalColors,
    ColorGenerationMethod? generationMethod,
    ColorMood? mood,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    double? harmonyScore,
    double? accessibilityScore,
  }) => AIColorPalette(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    primaryColor: primaryColor ?? this.primaryColor,
    secondaryColor: secondaryColor ?? this.secondaryColor,
    accentColor: accentColor ?? this.accentColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    textColor: textColor ?? this.textColor,
    additionalColors: additionalColors ?? this.additionalColors,
    generationMethod: generationMethod ?? this.generationMethod,
    mood: mood ?? this.mood,
    metadata: metadata ?? this.metadata,
    createdAt: createdAt ?? this.createdAt,
    harmonyScore: harmonyScore ?? this.harmonyScore,
    accessibilityScore: accessibilityScore ?? this.accessibilityScore,
  );
}

class AIColorGeneratorService {
  static final Random _random = Random();

  /// Génère une palette de couleurs complète
  static AIColorPalette generatePalette({
    required ColorGenerationMethod method,
    Color? baseColor,
    ColorMood? mood,
    String? brandName,
    Map<String, dynamic>? constraints,
  }) {
    switch (method) {
      case ColorGenerationMethod.complementary:
        return _generateComplementaryPalette(baseColor ?? _getRandomColor());
      case ColorGenerationMethod.analogous:
        return _generateAnalogousPalette(baseColor ?? _getRandomColor());
      case ColorGenerationMethod.triadic:
        return _generateTriadicPalette(baseColor ?? _getRandomColor());
      case ColorGenerationMethod.tetradic:
        return _generateTetradicPalette(baseColor ?? _getRandomColor());
      case ColorGenerationMethod.splitComplementary:
        return _generateSplitComplementaryPalette(
          baseColor ?? _getRandomColor(),
        );
      case ColorGenerationMethod.monochromatic:
        return _generateMonochromaticPalette(baseColor ?? _getRandomColor());
      case ColorGenerationMethod.aiHarmony:
        return _generateAIHarmonyPalette(baseColor ?? _getRandomColor());
      case ColorGenerationMethod.moodBased:
        return _generateMoodBasedPalette(mood ?? ColorMood.energetic);
      case ColorGenerationMethod.brandBased:
        return _generateBrandBasedPalette(brandName ?? '');
      case ColorGenerationMethod.seasonal:
        return _generateSeasonalPalette();
      case ColorGenerationMethod.random:
        return _generateRandomPalette();
      case ColorGenerationMethod.gradientBased:
        return _generateGradientPalette(baseColor ?? _getRandomColor());
      case ColorGenerationMethod.accessibility:
        return _generateAccessibilityPalette(baseColor ?? _getRandomColor());
      case ColorGenerationMethod.imageExtracted:
        return _generateImageExtractedPalette(); // Simulation
    }
  }

  /// Génère une palette basée sur les couleurs complémentaires
  static AIColorPalette _generateComplementaryPalette(Color baseColor) {
    final hsl = _rgbToHsl(baseColor);
    final complementaryHue = (hsl['h']! + 180) % 360;

    final complementaryColor = _hslToRgb(
      complementaryHue,
      hsl['s']!,
      hsl['l']!,
    );
    final backgroundColor = _getOptimalBackgroundColor(
      baseColor,
      complementaryColor,
    );
    final textColor = _getOptimalTextColor(backgroundColor);
    final accentColor = _generateAccentColor(baseColor, complementaryColor);

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette Complémentaire',
      description: 'Couleurs opposées sur la roue chromatique',
      primaryColor: baseColor,
      secondaryColor: complementaryColor,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [
        _adjustBrightness(baseColor, 0.2),
        _adjustBrightness(complementaryColor, 0.2),
        _adjustSaturation(baseColor, 0.8),
        _adjustSaturation(complementaryColor, 0.8),
      ],
      generationMethod: ColorGenerationMethod.complementary,
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(baseColor, complementaryColor),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette basée sur les couleurs analogues
  static AIColorPalette _generateAnalogousPalette(Color baseColor) {
    final hsl = _rgbToHsl(baseColor);
    final analogousHue1 = (hsl['h']! - 30) % 360;
    final analogousHue2 = (hsl['h']! + 30) % 360;

    final analogousColor1 = _hslToRgb(analogousHue1, hsl['s']!, hsl['l']!);
    final analogousColor2 = _hslToRgb(analogousHue2, hsl['s']!, hsl['l']!);
    final backgroundColor = _getOptimalBackgroundColor(
      baseColor,
      analogousColor1,
    );
    final textColor = _getOptimalTextColor(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette Analogue',
      description: 'Couleurs voisines sur la roue chromatique',
      primaryColor: baseColor,
      secondaryColor: analogousColor1,
      accentColor: analogousColor2,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [
        _adjustBrightness(baseColor, 0.3),
        _adjustBrightness(analogousColor1, 0.3),
        _adjustBrightness(analogousColor2, 0.3),
      ],
      generationMethod: ColorGenerationMethod.analogous,
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(baseColor, analogousColor1),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette triadique
  static AIColorPalette _generateTriadicPalette(Color baseColor) {
    final hsl = _rgbToHsl(baseColor);
    final triadicHue1 = (hsl['h']! + 120) % 360;
    final triadicHue2 = (hsl['h']! + 240) % 360;

    final triadicColor1 = _hslToRgb(triadicHue1, hsl['s']!, hsl['l']!);
    final triadicColor2 = _hslToRgb(triadicHue2, hsl['s']!, hsl['l']!);
    final backgroundColor = _getOptimalBackgroundColor(
      baseColor,
      triadicColor1,
    );
    final textColor = _getOptimalTextColor(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette Triadique',
      description: 'Trois couleurs espacées de 120°',
      primaryColor: baseColor,
      secondaryColor: triadicColor1,
      accentColor: triadicColor2,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [
        _adjustBrightness(baseColor, 0.2),
        _adjustBrightness(triadicColor1, 0.2),
        _adjustBrightness(triadicColor2, 0.2),
      ],
      generationMethod: ColorGenerationMethod.triadic,
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(baseColor, triadicColor1),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette tétradique
  static AIColorPalette _generateTetradicPalette(Color baseColor) {
    final hsl = _rgbToHsl(baseColor);
    final tetradicHue1 = (hsl['h']! + 90) % 360;
    final tetradicHue2 = (hsl['h']! + 180) % 360;
    final tetradicHue3 = (hsl['h']! + 270) % 360;

    final tetradicColor1 = _hslToRgb(tetradicHue1, hsl['s']!, hsl['l']!);
    final tetradicColor2 = _hslToRgb(tetradicHue2, hsl['s']!, hsl['l']!);
    final tetradicColor3 = _hslToRgb(tetradicHue3, hsl['s']!, hsl['l']!);
    final backgroundColor = _getOptimalBackgroundColor(
      baseColor,
      tetradicColor1,
    );
    final textColor = _getOptimalTextColor(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette Tétradique',
      description: 'Quatre couleurs espacées de 90°',
      primaryColor: baseColor,
      secondaryColor: tetradicColor1,
      accentColor: tetradicColor2,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [tetradicColor3],
      generationMethod: ColorGenerationMethod.tetradic,
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(baseColor, tetradicColor1),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette split-complémentaire
  static AIColorPalette _generateSplitComplementaryPalette(Color baseColor) {
    final hsl = _rgbToHsl(baseColor);
    final splitHue1 = (hsl['h']! + 150) % 360;
    final splitHue2 = (hsl['h']! + 210) % 360;

    final splitColor1 = _hslToRgb(splitHue1, hsl['s']!, hsl['l']!);
    final splitColor2 = _hslToRgb(splitHue2, hsl['s']!, hsl['l']!);
    final backgroundColor = _getOptimalBackgroundColor(baseColor, splitColor1);
    final textColor = _getOptimalTextColor(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette Split-Complémentaire',
      description: 'Variante de la palette complémentaire',
      primaryColor: baseColor,
      secondaryColor: splitColor1,
      accentColor: splitColor2,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [
        _adjustBrightness(baseColor, 0.2),
        _adjustBrightness(splitColor1, 0.2),
        _adjustBrightness(splitColor2, 0.2),
      ],
      generationMethod: ColorGenerationMethod.splitComplementary,
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(baseColor, splitColor1),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette monochromatique
  static AIColorPalette _generateMonochromaticPalette(Color baseColor) {
    final hsl = _rgbToHsl(baseColor);

    final lightColor = _hslToRgb(
      hsl['h']!,
      hsl['s']!,
      (hsl['l']! + 0.3).clamp(0.0, 1.0),
    );
    final darkColor = _hslToRgb(
      hsl['h']!,
      hsl['s']!,
      (hsl['l']! - 0.3).clamp(0.0, 1.0),
    );
    final backgroundColor = _getOptimalBackgroundColor(baseColor, lightColor);
    final textColor = _getOptimalTextColor(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette Monochromatique',
      description: 'Différentes nuances d\'une même couleur',
      primaryColor: baseColor,
      secondaryColor: lightColor,
      accentColor: darkColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [
        _adjustBrightness(baseColor, 0.1),
        _adjustBrightness(baseColor, 0.2),
        _adjustBrightness(baseColor, 0.3),
      ],
      generationMethod: ColorGenerationMethod.monochromatic,
      createdAt: DateTime.now(),
      harmonyScore: 1.0, // Parfaitement harmonieux
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette avec harmonie IA
  static AIColorPalette _generateAIHarmonyPalette(Color baseColor) {
    // Simulation d'algorithme IA complexe
    final hsl = _rgbToHsl(baseColor);

    // Analyse de la couleur dominante
    final dominantHue = hsl['h']!;
    final saturation = hsl['s']!;
    final lightness = hsl['l']!;

    // Génération basée sur des règles psychologiques et esthétiques
    final harmonyShift = _calculateOptimalHarmonyShift(dominantHue, saturation);
    final secondaryHue = (dominantHue + harmonyShift) % 360;
    final accentHue = (dominantHue + harmonyShift * 2) % 360;

    final secondaryColor = _hslToRgb(secondaryHue, saturation * 0.8, lightness);
    final accentColor = _hslToRgb(accentHue, saturation * 0.6, lightness);

    // Optimisation pour l'accessibilité
    final backgroundColor = _calculateOptimalBackground(
      baseColor,
      secondaryColor,
    );
    final textColor = _calculateOptimalText(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette IA-Harmony',
      description: 'Palette optimisée par intelligence artificielle',
      primaryColor: baseColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [
        _generateAIAdditionalColor(dominantHue, saturation, lightness, 0.1),
        _generateAIAdditionalColor(dominantHue, saturation, lightness, 0.2),
        _generateAIAdditionalColor(dominantHue, saturation, lightness, 0.3),
      ],
      generationMethod: ColorGenerationMethod.aiHarmony,
      metadata: {
        'harmonyShift': harmonyShift,
        'optimization': 'ai_enhanced',
        'version': '2.0',
      },
      createdAt: DateTime.now(),
      harmonyScore: _calculateAdvancedHarmonyScore(
        baseColor,
        secondaryColor,
        accentColor,
      ),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette basée sur l'humeur
  static AIColorPalette _generateMoodBasedPalette(ColorMood mood) {
    Color primaryColor;
    Color secondaryColor;
    Color accentColor;
    Color backgroundColor;
    String name;
    String description;

    switch (mood) {
      case ColorMood.energetic:
        primaryColor = const Color(0xFFFF5722); // Orange rouge
        secondaryColor = const Color(0xFFFFC107); // Jaune
        accentColor = const Color(0xFF4CAF50); // Vert
        backgroundColor = const Color(0xFFFFF8E1);
        name = 'Palette Énergique';
        description = 'Couleurs vives et stimulantes';
        break;
      case ColorMood.calm:
        primaryColor = const Color(0xFF81C784); // Vert doux
        secondaryColor = const Color(0xFF64B5F6); // Bleu clair
        accentColor = const Color(0xFF9575CD); // Lavande
        backgroundColor = const Color(0xFFF1F8E9);
        name = 'Palette Apaisante';
        description = 'Couleurs relaxantes et harmonieuses';
        break;
      case ColorMood.professional:
        primaryColor = const Color(0xFF37474F); // Gris foncé
        secondaryColor = const Color(0xFF607D8B); // Bleu gris
        accentColor = const Color(0xFF1976D2); // Bleu professionnel
        backgroundColor = const Color(0xFFF5F5F5);
        name = 'Palette Professionnelle';
        description = 'Couleurs sérieuses et corporate';
        break;
      case ColorMood.creative:
        primaryColor = const Color(0xFFE91E63); // Rose vif
        secondaryColor = const Color(0xFF9C27B0); // Violet
        accentColor = const Color(0xFF673AB7); // Violet profond
        backgroundColor = const Color(0xFFFCE4EC);
        name = 'Palette Créative';
        description = 'Couleurs inspirantes et originales';
        break;
      case ColorMood.romantic:
        primaryColor = const Color(0xFFE91E63); // Rose
        secondaryColor = const Color(0xFFF48FB1); // Rose clair
        accentColor = const Color(0xFFCE93D8); // Lavande
        backgroundColor = const Color(0xFFFCE4EC);
        name = 'Palette Romantique';
        description = 'Couleurs douces et tendres';
        break;
      case ColorMood.mysterious:
        primaryColor = const Color(0xFF4A148C); // Violet foncé
        secondaryColor = const Color(0xFF1A237E); // Bleu nuit
        accentColor = const Color(0xFFB71C1C); // Rouge vin
        backgroundColor = const Color(0xFF263238);
        name = 'Palette Mystérieuse';
        description = 'Couleurs sombres et énigmatiques';
        break;
      case ColorMood.playful:
        primaryColor = const Color(0xFFFF6B6B); // Rouge vif
        secondaryColor = const Color(0xFF4ECDC4); // Turquoise
        accentColor = const Color(0xFFFFD93D); // Jaune vif
        backgroundColor = const Color(0xFFFFF8E1);
        name = 'Palette Ludique';
        description = 'Couleurs amusantes et joyeuses';
        break;
      case ColorMood.luxurious:
        primaryColor = const Color(0xFF795548); // Brun
        secondaryColor = const Color(0xFFD4AF37); // Or
        accentColor = const Color(0xFF8D6E63); // Brun clair
        backgroundColor = const Color(0xFFFFF8E1);
        name = 'Palette Luxueuse';
        description = 'Couleurs riches et élégantes';
        break;
      case ColorMood.natural:
        primaryColor = const Color(0xFF795548); // Terre
        secondaryColor = const Color(0xFF8BC34A); // Vert nature
        accentColor = const Color(0xFF689F38); // Vert forêt
        backgroundColor = const Color(0xFFF1F8E9);
        name = 'Palette Naturelle';
        description = 'Couleurs organiques et terreuses';
        break;
      case ColorMood.futuristic:
        primaryColor = const Color(0xFF00BCD4); // Cyan
        secondaryColor = const Color(0xFF3F51B5); // Indigo
        accentColor = const Color(0xFFE91E63); // Rose néon
        backgroundColor = const Color(0xFFE3F2FD);
        name = 'Palette Futuriste';
        description = 'Couleurs technologiques et modernes';
        break;
    }

    final textColor = _getOptimalTextColor(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: name,
      description: description,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [
        _adjustBrightness(primaryColor, 0.2),
        _adjustBrightness(secondaryColor, 0.2),
        _adjustBrightness(accentColor, 0.2),
      ],
      generationMethod: ColorGenerationMethod.moodBased,
      mood: mood,
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(primaryColor, secondaryColor),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette basée sur une marque (simulation)
  static AIColorPalette _generateBrandBasedPalette(String brandName) {
    // Simulation d'analyse de marque
    final hashCode = brandName.hashCode.abs();
    final baseHue = (hashCode % 360).toDouble();

    final baseColor = _hslToRgb(baseHue, 0.7, 0.5);
    final hsl = _rgbToHsl(baseColor);

    final secondaryColor = _hslToRgb((baseHue + 120) % 360, 0.6, 0.6);
    final accentColor = _hslToRgb((baseHue + 240) % 360, 0.8, 0.4);
    final backgroundColor = _getOptimalBackgroundColor(
      baseColor,
      secondaryColor,
    );
    final textColor = _getOptimalTextColor(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette de $brandName',
      description: 'Palette générée pour la marque $brandName',
      primaryColor: baseColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [
        _adjustBrightness(baseColor, 0.2),
        _adjustBrightness(secondaryColor, 0.2),
        _adjustBrightness(accentColor, 0.2),
      ],
      generationMethod: ColorGenerationMethod.brandBased,
      metadata: {'brandName': brandName, 'brandHash': hashCode},
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(baseColor, secondaryColor),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette saisonnière
  static AIColorPalette _generateSeasonalPalette() {
    final month = DateTime.now().month;
    Color primaryColor;
    Color secondaryColor;
    Color accentColor;
    Color backgroundColor;
    String name;
    String description;

    if (month >= 3 && month <= 5) {
      // Printemps
      primaryColor = const Color(0xFF8BC34A); // Vert printemps
      secondaryColor = const Color(0xFFFFC107); // Jaune pâle
      accentColor = const Color(0xFFE91E63); // Rose printemps
      backgroundColor = const Color(0xFFF1F8E9);
      name = 'Palette Printemps';
      description = 'Fraîcheur et renouveau';
    } else if (month >= 6 && month <= 8) {
      // Été
      primaryColor = const Color(0xFF2196F3); // Bleu ciel
      secondaryColor = const Color(0xFFFFEB3B); // Jaune ensoleillé
      accentColor = const Color(0xFFFF5722); // Orange été
      backgroundColor = const Color(0xFFE3F2FD);
      name = 'Palette Été';
      description = 'Chaleur et énergie';
    } else if (month >= 9 && month <= 11) {
      // Automne
      primaryColor = const Color(0xFFFF9800); // Orange automne
      secondaryColor = const Color(0xFF795548); // Brun
      accentColor = const Color(0xFFF44336); // Rouge feuille
      backgroundColor = const Color(0xFFFFF3E0);
      name = 'Palette Automne';
      description = 'Chaleur terreuse';
    } else {
      // Hiver
      primaryColor = const Color(0xFF9C27B0); // Violet/bleu hiver
      secondaryColor = const Color(0xFFE1F5FE); // Blanc glacé
      accentColor = const Color(0xFF0277BD); // Bleu glacier
      backgroundColor = const Color(0xFFFAFAFA);
      name = 'Palette Hiver';
      description = 'Froideur et élégance';
    }

    final textColor = _getOptimalTextColor(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: name,
      description: description,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [
        _adjustBrightness(primaryColor, 0.2),
        _adjustBrightness(secondaryColor, 0.2),
        _adjustBrightness(accentColor, 0.2),
      ],
      generationMethod: ColorGenerationMethod.seasonal,
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(primaryColor, secondaryColor),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette aléatoire
  static AIColorPalette _generateRandomPalette() {
    final primaryColor = _getRandomColor();
    final hsl = _rgbToHsl(primaryColor);

    final secondaryHue = (hsl['h']! + _random.nextInt(180) - 90) % 360;
    final secondaryColor = _hslToRgb(secondaryHue, hsl['s']!, hsl['l']!);

    final accentHue = (hsl['h']! + _random.nextInt(180) - 90) % 360;
    final accentColor = _hslToRgb(accentHue, hsl['s']!, hsl['l']!);

    final backgroundColor = _getOptimalBackgroundColor(
      primaryColor,
      secondaryColor,
    );
    final textColor = _getOptimalTextColor(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette Aléatoire',
      description: 'Générée aléatoirement',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [
        _getRandomColor(),
        _getRandomColor(),
        _getRandomColor(),
      ],
      generationMethod: ColorGenerationMethod.random,
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(primaryColor, secondaryColor),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette basée sur dégradé
  static AIColorPalette _generateGradientPalette(Color baseColor) {
    final hsl = _rgbToHsl(baseColor);

    final gradientColors = [
      baseColor,
      _hslToRgb((hsl['h']! + 30) % 360, hsl['s']!, hsl['l']!),
      _hslToRgb((hsl['h']! + 60) % 360, hsl['s']!, hsl['l']!),
      _hslToRgb((hsl['h']! + 90) % 360, hsl['s']!, hsl['l']!),
    ];

    final backgroundColor = _getOptimalBackgroundColor(
      gradientColors[0],
      gradientColors[1],
    );
    final textColor = _getOptimalTextColor(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette Dégradé',
      description: 'Basée sur un dégradé harmonieux',
      primaryColor: gradientColors[0],
      secondaryColor: gradientColors[1],
      accentColor: gradientColors[2],
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [gradientColors[3]],
      generationMethod: ColorGenerationMethod.gradientBased,
      metadata: {'gradientType': 'linear', 'gradientAngle': 45.0},
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(
        gradientColors[0],
        gradientColors[1],
      ),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  /// Génère une palette optimisée pour l'accessibilité
  static AIColorPalette _generateAccessibilityPalette(Color baseColor) {
    // Garantir un contraste WCAG AA minimum
    final backgroundColor = _chooseAccessibleBackground(baseColor);
    final textColor = _chooseAccessibleTextColor(backgroundColor);

    final hsl = _rgbToHsl(baseColor);
    final accessibleSecondary = _ensureAccessibility(
      baseColor,
      backgroundColor,
    );
    final accessibleAccent = _ensureAccessibility(
      _hslToRgb((hsl['h']! + 120) % 360, hsl['s']!, hsl['l']!),
      backgroundColor,
    );

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette Accessibilité',
      description: 'Conforme aux normes WCAG AA',
      primaryColor: baseColor,
      secondaryColor: accessibleSecondary,
      accentColor: accessibleAccent,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [
        _ensureAccessibility(
          _adjustBrightness(baseColor, 0.2),
          backgroundColor,
        ),
        _ensureAccessibility(
          _adjustBrightness(accessibleSecondary, 0.2),
          backgroundColor,
        ),
      ],
      generationMethod: ColorGenerationMethod.accessibility,
      metadata: {
        'wcagCompliant': true,
        'contrastRatio': _calculateContrastRatio(textColor, backgroundColor),
      },
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(baseColor, accessibleSecondary),
      accessibilityScore: 1.0, // Maximum accessibilité
    );
  }

  /// Génère une palette extraite d'image (simulation)
  static AIColorPalette _generateImageExtractedPalette() {
    // Simulation d'extraction de couleurs d'image
    final extractedColors = [
      const Color(0xFF2196F3), // Bleu dominant
      const Color(0xFFFF9800), // Orange secondaire
      const Color(0xFF4CAF50), // Vert accent
      const Color(0xFF9E9E9E), // Gris neutre
      const Color(0xFFFFFFFF), // Blanc
    ];

    final primaryColor = extractedColors[0];
    final secondaryColor = extractedColors[1];
    final accentColor = extractedColors[2];
    final backgroundColor = extractedColors[4];
    final textColor = _getOptimalTextColor(backgroundColor);

    return AIColorPalette(
      id: _generateId(),
      name: 'Palette Extraite',
      description: 'Extraite d\'une image',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      additionalColors: [extractedColors[3]],
      generationMethod: ColorGenerationMethod.imageExtracted,
      metadata: {
        'source': 'image_analysis',
        'extractionMethod': 'kmeans_clustering',
        'dominance': [
          0.35, // 35% bleu
          0.25, // 25% orange
          0.20, // 20% vert
          0.15, // 15% gris
          0.05, // 5% blanc
        ],
      },
      createdAt: DateTime.now(),
      harmonyScore: _calculateHarmonyScore(primaryColor, secondaryColor),
      accessibilityScore: _calculateAccessibilityScore(
        textColor,
        backgroundColor,
      ),
    );
  }

  // Méthodes utilitaires

  static Color _getRandomColor() =>
      Color(_random.nextInt(0xFFFFFFFF) | 0xFF000000);

  static String _generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';

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
        if (t < 1 / 6) return p + (q - p) * 6 * t;
        if (t < 1 / 2) return q;
        if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
        return p;
      }

      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;
      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }

    return Color.fromARGB(
      255,
      (r * 255).round(),
      (g * 255).round(),
      (b * 255).round(),
    );
  }

  static Color _adjustBrightness(Color color, double factor) {
    final hsl = _rgbToHsl(color);
    return _hslToRgb(
      hsl['h']!,
      hsl['s']!,
      (hsl['l']! + factor).clamp(0.0, 1.0),
    );
  }

  static Color _adjustSaturation(Color color, double factor) {
    final hsl = _rgbToHsl(color);
    return _hslToRgb(
      hsl['h']!,
      (hsl['s']! * factor).clamp(0.0, 1.0),
      hsl['l']!,
    );
  }

  static Color _getOptimalBackgroundColor(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();

    if (luminance1 > 0.7 && luminance2 > 0.7) {
      return Colors.grey[800]!; // Fond sombre pour couleurs claires
    } else if (luminance1 < 0.3 && luminance2 < 0.3) {
      return Colors.grey[100]!; // Fond clair pour couleurs sombres
    } else {
      return Colors.white; // Fond blanc par défaut
    }
  }

  static Color _getOptimalTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  static Color _generateAccentColor(Color color1, Color color2) {
    final hsl1 = _rgbToHsl(color1);
    final hsl2 = _rgbToHsl(color2);

    final accentHue = (hsl1['h']! + hsl2['h']!) / 2;
    final accentSaturation = (hsl1['s']! + hsl2['s']!) / 2;
    final accentLightness = (hsl1['l']! + hsl2['l']!) / 2;

    return _hslToRgb(accentHue, accentSaturation, accentLightness);
  }

  static double _calculateHarmonyScore(Color color1, Color color2) {
    final hsl1 = _rgbToHsl(color1);
    final hsl2 = _rgbToHsl(color2);

    final hueDiff = (hsl1['h']! - hsl2['h']!).abs();
    final satDiff = (hsl1['s']! - hsl2['s']!).abs();
    final lightDiff = (hsl1['l']! - hsl2['l']!).abs();

    // Score basé sur les règles d'harmonie des couleurs
    var score = 0.0;

    // Complémentaire (180°)
    if (hueDiff >= 170 && hueDiff <= 190) {
      score += 0.3;
    } else if (hueDiff >= 20 && hueDiff <= 40)
      score += 0.25;
    // Triadique (120°)
    else if (hueDiff >= 110 && hueDiff <= 130)
      score += 0.2;
    // Tétradique (90°)
    else if (hueDiff >= 80 && hueDiff <= 100)
      score += 0.15;

    // Bonus pour la similarité de saturation
    score += (1.0 - satDiff) * 0.2;

    // Bonus pour la différence de luminosité modérée
    if (lightDiff >= 0.2 && lightDiff <= 0.6) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  static double _calculateAdvancedHarmonyScore(
    Color primary,
    Color secondary,
    Color accent,
  ) {
    final score1 = _calculateHarmonyScore(primary, secondary);
    final score2 = _calculateHarmonyScore(primary, accent);
    final score3 = _calculateHarmonyScore(secondary, accent);

    return (score1 + score2 + score3) / 3.0;
  }

  static double _calculateAccessibilityScore(Color text, Color background) {
    final ratio = _calculateContrastRatio(text, background);

    // WCAG AA: 4.5:1 pour texte normal, 3:1 pour texte large
    if (ratio >= 7.0) return 1.0; // AAA
    if (ratio >= 4.5) return 0.8; // AA
    if (ratio >= 3.0) return 0.6; // AA pour texte large
    return ratio / 3.0; // En dessous des normes
  }

  static double _calculateContrastRatio(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();

    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _calculateOptimalHarmonyShift(double hue, double saturation) {
    // Algorithme d'IA pour trouver le meilleur décalage de teinte
    // Basé sur la psychologie des couleurs et les préférences humaines

    if (saturation < 0.3) {
      // Pour les couleurs désaturées, utiliser des décalages plus grands
      return 120.0 + (hue % 60.0);
    } else if (hue >= 0 && hue < 60) {
      // Rouges: complémentaire ou analogue
      return 180.0;
    } else if (hue >= 60 && hue < 120) {
      // Jaunes/verts: split-complémentaire
      return 150.0;
    } else if (hue >= 120 && hue < 180) {
      // Verts: triadique
      return 120.0;
    } else if (hue >= 180 && hue < 240) {
      // Cyans/bleus: analogue
      return 30.0;
    } else if (hue >= 240 && hue < 300) {
      // Bleus/violets: tétradique
      return 90.0;
    } else {
      // Violets/rouges: complémentaire
      return 180.0;
    }
  }

  static Color _generateAIAdditionalColor(
    double hue,
    double saturation,
    double lightness,
    double variation,
  ) {
    final newHue = (hue + variation * 360) % 360;
    final newSaturation = (saturation * (1.0 + variation * 0.5)).clamp(
      0.0,
      1.0,
    );
    final newLightness = (lightness * (1.0 + variation * 0.3)).clamp(0.0, 1.0);

    return _hslToRgb(newHue, newSaturation, newLightness);
  }

  static Color _calculateOptimalBackground(Color primary, Color secondary) {
    // Analyse des couleurs pour choisir le meilleur fond
    final primaryLuminance = primary.computeLuminance();
    final secondaryLuminance = secondary.computeLuminance();

    if (primaryLuminance > 0.8 && secondaryLuminance > 0.8) {
      return Colors.grey[900]!; // Fond très sombre
    } else if (primaryLuminance < 0.2 && secondaryLuminance < 0.2) {
      return Colors.grey[50]!; // Fond très clair
    } else if (primaryLuminance > 0.6 || secondaryLuminance > 0.6) {
      return Colors.grey[200]!; // Fond moyen-clair
    } else {
      return Colors.grey[700]!; // Fond moyen-foncé
    }
  }

  static Color _calculateOptimalText(Color background) {
    final luminance = background.computeLuminance();

    if (luminance > 0.8) {
      return Colors.black87;
    } else if (luminance > 0.6) {
      return Colors.black54;
    } else if (luminance > 0.4) {
      return Colors.white;
    } else if (luminance > 0.2) {
      return Colors.white70;
    } else {
      return Colors.white;
    }
  }

  static Color _chooseAccessibleBackground(Color foreground) {
    final luminance = foreground.computeLuminance();

    if (luminance > 0.5) {
      // Couleur claire, utiliser fond sombre
      return Colors.grey[900]!;
    } else {
      // Couleur sombre, utiliser fond clair
      return Colors.white;
    }
  }

  static Color _chooseAccessibleTextColor(Color background) {
    final luminance = background.computeLuminance();

    if (luminance > 0.5) {
      return Colors.black87;
    } else {
      return Colors.white;
    }
  }

  static Color _ensureAccessibility(Color color, Color background) {
    // Ajuster la couleur pour garantir un contraste suffisant
    final ratio = _calculateContrastRatio(color, background);

    if (ratio >= 4.5) {
      return color; // Déjà accessible
    }

    // Ajuster la luminosité pour améliorer le contraste
    final backgroundLuminance = background.computeLuminance();
    final targetLuminance = backgroundLuminance > 0.5 ? 0.1 : 0.9;

    final hsl = _rgbToHsl(color);
    return _hslToRgb(hsl['h']!, hsl['s']!, targetLuminance);
  }

  /// Analyse une image et extrait les couleurs dominantes
  static Future<List<Color>> extractColorsFromImage(String imagePath) async {
    // Simulation - en réalité, utiliserait un package d'analyse d'image
    return [
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF4CAF50),
      const Color(0xFF9E9E9E),
      const Color(0xFFFFFFFF),
    ];
  }

  /// Recommande des palettes basées sur l'usage
  static List<AIColorPalette> getRecommendedPalettes(String usage) {
    switch (usage.toLowerCase()) {
      case 'business':
      case 'corporate':
        return [
          _generateMoodBasedPalette(ColorMood.professional),
          _generateMoodBasedPalette(ColorMood.luxurious),
        ];
      case 'creative':
      case 'artistic':
        return [
          _generateMoodBasedPalette(ColorMood.creative),
          _generateMoodBasedPalette(ColorMood.playful),
        ];
      case 'healthcare':
      case 'medical':
        return [
          _generateMoodBasedPalette(ColorMood.calm),
          _generateMoodBasedPalette(ColorMood.natural),
        ];
      case 'technology':
      case 'tech':
        return [
          _generateMoodBasedPalette(ColorMood.futuristic),
          _generateMoodBasedPalette(ColorMood.professional),
        ];
      case 'education':
      case 'learning':
        return [
          _generateMoodBasedPalette(ColorMood.energetic),
          _generateMoodBasedPalette(ColorMood.creative),
        ];
      default:
        return [
          _generateMoodBasedPalette(ColorMood.energetic),
          _generateMoodBasedPalette(ColorMood.calm),
          _generateMoodBasedPalette(ColorMood.professional),
        ];
    }
  }

  /// Valide une palette pour l'accessibilité
  static Map<String, dynamic> validateAccessibility(AIColorPalette palette) {
    final results = <String, dynamic>{};

    // Contraste texte sur fond
    final textContrast = _calculateContrastRatio(
      palette.textColor,
      palette.backgroundColor,
    );
    results['textContrast'] = {
      'ratio': textContrast,
      'wcagAA': textContrast >= 4.5,
      'wcagAAA': textContrast >= 7.0,
      'status': textContrast >= 4.5 ? 'Pass' : 'Fail',
    };

    // Contraste primaire sur fond
    final primaryContrast = _calculateContrastRatio(
      palette.primaryColor,
      palette.backgroundColor,
    );
    results['primaryContrast'] = {
      'ratio': primaryContrast,
      'wcagAA': primaryContrast >= 3.0,
      'status': primaryContrast >= 3.0 ? 'Pass' : 'Fail',
    };

    // Contraste secondaire sur fond
    final secondaryContrast = _calculateContrastRatio(
      palette.secondaryColor,
      palette.backgroundColor,
    );
    results['secondaryContrast'] = {
      'ratio': secondaryContrast,
      'wcagAA': secondaryContrast >= 3.0,
      'status': secondaryContrast >= 3.0 ? 'Pass' : 'Fail',
    };

    // Score global
    final passCount = [
      textContrast >= 4.5,
      primaryContrast >= 3.0,
      secondaryContrast >= 3.0,
    ].where((pass) => pass).length;

    results['overall'] = {
      'score': passCount / 3.0,
      'status': passCount == 3 ? 'Fully Compliant' : 'Needs Improvement',
      'recommendations': _getAccessibilityRecommendations(results),
    };

    return results;
  }

  static List<String> _getAccessibilityRecommendations(
    Map<String, dynamic> validationResults,
  ) {
    final recommendations = <String>[];

    if (!(validationResults['textContrast']['wcagAA'] as bool)) {
      recommendations.add('Augmenter le contraste entre le texte et le fond');
    }

    if (!(validationResults['primaryContrast']['wcagAA'] as bool)) {
      recommendations.add('Améliorer le contraste de la couleur primaire');
    }

    if (!(validationResults['secondaryContrast']['wcagAA'] as bool)) {
      recommendations.add('Améliorer le contraste de la couleur secondaire');
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'La palette respecte les normes d\'accessibilité WCAG AA',
      );
    }

    return recommendations;
  }
}
