/// Repository pour la gestion des templates
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';

class TemplatesRepository {
  static const String _templatesPath = 'assets/data/Templates.json';

  List<CardTemplate> _templates = [];
  bool _isLoading = false;

  /// Liste de tous les templates
  List<CardTemplate> get templates => List.unmodifiable(_templates);

  /// Templates gratuits
  List<CardTemplate> get freeTemplates =>
      _templates.where((t) => !t.isPremium).toList();

  /// Templates premium
  List<CardTemplate> get premiumTemplates =>
      _templates.where((t) => t.isPremium).toList();

  /// État de chargement
  bool get isLoading => _isLoading;

  /// Charge les templates depuis le fichier JSON
  Future<void> loadTemplates() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      final jsonString = await rootBundle.loadString(_templatesPath);
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      debugPrint('JSON loaded successfully');
      if (jsonMap.containsKey('templates')) {
        final List<dynamic> templatesJson = jsonMap['templates'];
        debugPrint('Found \\${templatesJson.length} templates in JSON');
        _templates = templatesJson
            .map((json) => CardTemplate.fromJson(json))
            .toList();
      } else {
        debugPrint('No templates key in JSON, using predefined templates');
        // Si le fichier n'a pas la structure attendue, utiliser les templates prédéfinis
        _templates = List.from(CardTemplate.predefinedTemplates);
      }
      _appendEventTemplates();
    } catch (e) {
      debugPrint('Erreur lors du chargement des templates: $e');
      debugPrint('Using predefined templates as fallback');
      // En cas d'erreur, utiliser les templates prédéfinis
      _templates = List.from(CardTemplate.predefinedTemplates);
      _appendEventTemplates();
    } finally {
      debugPrint('Final templates count: \\${_templates.length}');
      _isLoading = false;
    }
  }

  /// Force le rechargement des templates
  Future<void> refreshTemplates() async {
    _templates.clear(); // Vider la liste avant de recharger
    await loadTemplates();
  }

  /// Ajoute dynamiquement des templates dérivés pour chaque événement
  void _appendEventTemplates() {
    try {
      // Trouver une base event_campaign si disponible
      final base = _templates.firstWhere(
        (t) => t.rendererKey == 'event_campaign',
        orElse: () => const CardTemplate(
          id: 'event_campaign',
          name: 'Event Campaign',
          description: 'Deux colonnes + QR, accent événement',
          colors: {
            'primary': '#6A1B9A',
            'secondary': '#2E2E3A',
            'accent': '#FF69B4',
          },
          rendererKey: 'event_campaign',
          layout: 'two-columns',
          previewPath: 'assets/templates/event_campaign_preview.png',
        ),
      );

      final eventTemplates = <CardTemplate>[];
      for (final event in EventOverlay.predefinedEvents) {
        final accentHex = event.color.value
            .toRadixString(16)
            .substring(2)
            .toUpperCase();
        final id = 'event_${event.id}';
        // Ne pas dupliquer si déjà présent
        final exists = _templates.any((t) => t.id == id);
        if (exists) continue;

        eventTemplates.add(
          CardTemplate(
            id: id,
            name: event.label,
            description: 'Campagne événementielle — ${event.label}',
            colors: {
              'primary': base.colors['primary'] ?? '#6A1B9A',
              'secondary': base.colors['secondary'] ?? '#2E2E3A',
              'accent': '#$accentHex',
            },
            rendererKey: 'event_campaign',
            layout: 'two-columns',
            previewPath: base.previewPath,
            isPremium: false,
            eventId: event.id,
            tags: const ['event'],
          ),
        );
      }

      _templates.addAll(eventTemplates);
    } catch (e) {
      debugPrint('Erreur appendEventTemplates: $e');
    }
  }

  /// Trouve un template par son ID
  CardTemplate? findById(String id) {
    try {
      return _templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Recherche des templates par nom ou description
  List<CardTemplate> searchTemplates(String query) {
    if (query.isEmpty) return _templates;

    final lowerQuery = query.toLowerCase();
    return _templates
        .where(
          (template) =>
              template.name.toLowerCase().contains(lowerQuery) ||
              template.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Filtre les templates par layout
  List<CardTemplate> filterByLayout(String layout) =>
      _templates.where((template) => template.layout == layout).toList();

  /// Rafraîchit la liste des templates
  Future<void> refresh() async {
    await loadTemplates();
  }
}
