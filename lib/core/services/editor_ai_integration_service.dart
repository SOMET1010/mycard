/// Service d'intégration entre le générateur IA et l'éditeur
library;
import 'package:flutter/material.dart';
import 'package:mycard/core/services/ai_color_generator_service.dart';
import 'package:mycard/data/models/business_card.dart';

class EditorAIIntegrationService {
  static Map<String, String> _convertPaletteToCustomColors(AIColorPalette palette) => {
      'primary': _colorToHex(palette.primaryColor),
      'secondary': _colorToHex(palette.secondaryColor),
      'accent': _colorToHex(palette.accentColor),
      'background': _colorToHex(palette.backgroundColor),
      'text': _colorToHex(palette.textColor),
    };

  static String _colorToHex(Color color) => '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  /// Applique une palette IA à une carte de visite
  static BusinessCard applyPaletteToCard(BusinessCard card, AIColorPalette palette) {
    final customColors = _convertPaletteToCustomColors(palette);

    return card.copyWith(
      customColors: customColors,
      // Mettre à jour d'autres propriétés si nécessaire
      updatedAt: DateTime.now(),
    );
  }

  /// Génère une palette basée sur les couleurs existantes d'une carte
  static AIColorPalette generatePaletteFromCard(BusinessCard card) {
    // Extraire la couleur primaire existante ou en utiliser une par défaut
    Color baseColor = Colors.blue;
    if (card.customColors.isNotEmpty) {
      final primaryHex = card.customColors['primary'];
      if (primaryHex != null && primaryHex.startsWith('#')) {
        baseColor = Color(int.parse(primaryHex.substring(1), radix: 16) + 0xFF000000);
      }
    }

    // Générer une palette améliorée basée sur la couleur existante
    return AIColorGeneratorService.generatePalette(
      method: ColorGenerationMethod.aiHarmony,
      baseColor: baseColor,
    );
  }

  /// Recommande des améliorations pour les couleurs d'une carte
  static List<String> getColorRecommendations(BusinessCard card) {
    final recommendations = <String>[];

    if (card.customColors.isEmpty) {
      recommendations.add('Ajoutez des couleurs personnalisées pour rendre votre carte plus unique');
      return recommendations;
    }

    // Vérifier le contraste
    if (card.customColors.containsKey('text') && card.customColors.containsKey('background')) {
      final textHex = card.customColors['text']!;
      final bgHex = card.customColors['background']!;

      if (textHex.startsWith('#') && bgHex.startsWith('#')) {
        final textColor = Color(int.parse(textHex.substring(1), radix: 16) + 0xFF000000);
        final bgColor = Color(int.parse(bgHex.substring(1), radix: 16) + 0xFF000000);

        final contrast = _calculateContrastRatio(textColor, bgColor);
        if (contrast < 4.5) {
          recommendations.add('Améliorez le contraste entre le texte et le fond pour une meilleure lisibilité');
        }
      }
    }

    // Vérifier l'harmonie des couleurs
    if (card.customColors.length >= 2) {
      recommendations.add('Utilisez le générateur IA pour créer des palettes harmonieuses');
    }

    return recommendations;
  }

  static double _calculateContrastRatio(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();

    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Crée une variante de palette optimisée pour l'accessibilité
  static AIColorPalette createAccessibleVariant(AIColorPalette originalPalette) => AIColorGeneratorService.generatePalette(
      method: ColorGenerationMethod.accessibility,
      baseColor: originalPalette.primaryColor,
    );

  /// Analyse une carte et suggère la meilleure méthode de génération
  static ColorGenerationMethod suggestBestMethod(BusinessCard card) {
    // Basé sur le contenu de la carte, suggérer la meilleure méthode

    if (card.title.toLowerCase().contains('creative') == true ||
        card.title.toLowerCase().contains('artist') == true ||
        card.company?.toLowerCase().contains('studio') == true) {
      return ColorGenerationMethod.moodBased;
    }

    if (card.title.toLowerCase().contains('ceo') == true ||
        card.title.toLowerCase().contains('director') == true ||
        card.title.toLowerCase().contains('manager') == true) {
      return ColorGenerationMethod.moodBased;
    }

    if (card.company?.toLowerCase().contains('tech') == true ||
        card.company?.toLowerCase().contains('software') == true) {
      return ColorGenerationMethod.aiHarmony;
    }

    // Par défaut, utiliser l'harmonie IA
    return ColorGenerationMethod.aiHarmony;
  }
}