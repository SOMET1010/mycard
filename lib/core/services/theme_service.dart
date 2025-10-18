/// Service pour gérer la sauvegarde et le chargement des thèmes personnalisés
library;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/features/events/page_event_theme_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _customThemesKey = 'custom_event_themes';

  /// Sauvegarde un thème personnalisé
  static Future<bool> saveCustomTheme({
    required String eventId,
    required String eventName,
    required EventThemeCustomization customization,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingThemes = prefs.getString(_customThemesKey);

      var themes = <String, dynamic>{};
      if (existingThemes != null) {
        themes = json.decode(existingThemes);
      }

      themes[eventId] = {
        'eventName': eventName,
        'customization': customization.toJson(),
        'savedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_customThemesKey, json.encode(themes));
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du thème: $e');
      return false;
    }
  }

  /// Charge un thème personnalisé pour un événement
  static Future<EventThemeCustomization?> loadCustomTheme(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingThemes = prefs.getString(_customThemesKey);

      if (existingThemes == null) return null;

      final themes = json.decode(existingThemes) as Map<String, dynamic>;
      final themeData = themes[eventId];

      if (themeData == null) return null;

      return EventThemeCustomization.fromJson(themeData['customization']);
    } catch (e) {
      debugPrint('Erreur lors du chargement du thème: $e');
      return null;
    }
  }

  /// Récupère tous les thèmes sauvegardés
  static Future<Map<String, Map<String, dynamic>>> getAllCustomThemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingThemes = prefs.getString(_customThemesKey);

      if (existingThemes == null) return {};

      return Map<String, Map<String, dynamic>>.from(
        json.decode(existingThemes) as Map
      );
    } catch (e) {
      debugPrint('Erreur lors de la récupération des thèmes: $e');
      return {};
    }
  }

  /// Supprime un thème sauvegardé
  static Future<bool> deleteCustomTheme(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingThemes = prefs.getString(_customThemesKey);

      if (existingThemes == null) return true;

      final themes = json.decode(existingThemes) as Map<String, dynamic>;
      themes.remove(eventId);

      await prefs.setString(_customThemesKey, json.encode(themes));
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la suppression du thème: $e');
      return false;
    }
  }

  /// Vérifie si un thème personnalisé existe pour un événement
  static Future<bool> hasCustomTheme(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingThemes = prefs.getString(_customThemesKey);

      if (existingThemes == null) return false;

      final themes = json.decode(existingThemes) as Map<String, dynamic>;
      return themes.containsKey(eventId);
    } catch (e) {
      debugPrint('Erreur lors de la vérification du thème: $e');
      return false;
    }
  }

  /// Applique un thème prédéfini basé sur le type d'événement
  static EventThemeCustomization getPredefinedTheme(EventOverlay event) {
    switch (event.id) {
      case 'octobre_rose':
        return const EventThemeCustomization(
          templateId: 'minimal',
          primaryColor: Color(0xFFFF69B4),
          secondaryColor: Color(0xFFFFB6C1),
          accentColor: Color(0xFFC71585),
          backgroundColor: Color(0xFFFFF0F5),
          textColor: Color(0xFF8B008B),
          intensity: 0.9,
          showEventBadge: true,
          overlayColor: Color(0xFFFF69B4),
          overlayOpacity: 0.15,
        );

      case 'movember':
        return const EventThemeCustomization(
          templateId: 'corporate',
          primaryColor: Color(0xFF8B4513),
          secondaryColor: Color(0xFFD2691E),
          accentColor: Color(0xFFA0522D),
          backgroundColor: Color(0xFFFFFAF0),
          textColor: Color(0xFF654321),
          intensity: 0.85,
          showEventBadge: true,
          overlayColor: Color(0xFF8B4513),
          overlayOpacity: 0.12,
        );

      case 'noel':
        return const EventThemeCustomization(
          templateId: 'ansut_style',
          primaryColor: Color(0xFF228B22),
          secondaryColor: Color(0xFFDC143C),
          accentColor: Color(0xFFFFD700),
          backgroundColor: Color(0xFFFFFAFA),
          textColor: Color(0xFF2F4F4F),
          intensity: 1.0,
          showEventBadge: true,
          overlayColor: Color(0xFF228B22),
          overlayOpacity: 0.2,
          showBackgroundPattern: true,
          backgroundPattern: 'dots',
        );

      case 'st_valentin':
        return const EventThemeCustomization(
          templateId: 'minimal',
          primaryColor: Color(0xFFDC143C),
          secondaryColor: Color(0xFFFF69B4),
          accentColor: Color(0xFFFF1493),
          backgroundColor: Color(0xFFFFF0F5),
          textColor: Color(0xFF8B0000),
          intensity: 0.95,
          showEventBadge: true,
          overlayColor: Color(0xFFDC143C),
          overlayOpacity: 0.18,
          borderRadius: 16.0,
        );

      case 'halloween':
        return const EventThemeCustomization(
          templateId: 'ansut_style',
          primaryColor: Color(0xFF8B008B),
          secondaryColor: Color(0xFFFF8C00),
          accentColor: Color(0xFF000000),
          backgroundColor: Color(0xFFFFFAF0),
          textColor: Color(0xFF4B0082),
          intensity: 0.9,
          showEventBadge: true,
          overlayColor: Color(0xFF8B008B),
          overlayOpacity: 0.25,
          showBackgroundPattern: true,
          backgroundPattern: 'diagonal',
        );

      default:
        return EventThemeCustomization(
          templateId: 'minimal',
          primaryColor: event.color,
          secondaryColor: event.color.withValues(alpha: 0.7),
          accentColor: event.color.withValues(alpha: 0.8),
          backgroundColor: Colors.white,
          textColor: Colors.black,
          intensity: 1.0,
          showEventBadge: true,
          overlayColor: event.color,
          overlayOpacity: 0.1,
        );
    }
  }

  /// Exporte un thème vers un format partageable
  static String exportTheme(EventThemeCustomization customization, String eventName) {
    final exportData = {
      'eventName': eventName,
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'customization': customization.toJson(),
    };

    return json.encode(exportData);
  }

  /// Importe un thème depuis un format partageable
  static Future<EventThemeCustomization?> importTheme(String themeJson) async {
    try {
      final data = json.decode(themeJson) as Map<String, dynamic>;

      if (!data.containsKey('customization')) {
        throw Exception('Format de thème invalide');
      }

      return EventThemeCustomization.fromJson(data['customization']);
    } catch (e) {
      debugPrint('Erreur lors de l\'import du thème: $e');
      return null;
    }
  }
}