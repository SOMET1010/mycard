/// Repository pour la gestion des événements
library;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mycard/data/models/event_overlay.dart';

class EventsRepository {
  static const String _eventsPath = 'assets/data/Events.json';

  List<EventOverlay> _events = [];
  bool _isLoading = false;

  /// Liste de tous les événements
  List<EventOverlay> get events => List.unmodifiable(_events);

  /// Événements actuellement actifs
  List<EventOverlay> get activeEvents => _events.where((e) => e.isCurrentlyActive()).toList();

  /// État de chargement
  bool get isLoading => _isLoading;

  /// Charge les événements depuis le fichier JSON
  Future<void> loadEvents() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      final jsonString = await rootBundle.loadString(_eventsPath);
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      if (jsonMap.containsKey('events')) {
        final List<dynamic> eventsJson = jsonMap['events'];
        _events = eventsJson
            .map((json) => EventOverlay.fromJson(json))
            .toList();
      } else {
        // Si le fichier n'a pas la structure attendue, utiliser les événements prédéfinis
        _events = List.from(EventOverlay.predefinedEvents);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des événements: $e');
      // En cas d'erreur, utiliser les événements prédéfinis
      _events = List.from(EventOverlay.predefinedEvents);
    } finally {
      _isLoading = false;
    }
  }

  /// Trouve un événement par son ID
  EventOverlay? findById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Recherche des événements par label ou description
  List<EventOverlay> searchEvents(String query) {
    if (query.isEmpty) return _events;

    final lowerQuery = query.toLowerCase();
    return _events.where((event) => event.label.toLowerCase().contains(lowerQuery) ||
             event.description.toLowerCase().contains(lowerQuery)).toList();
  }

  /// Filtre les événements par période
  List<EventOverlay> filterByPeriod(String period) => _events.where((event) => event.period.toLowerCase() == period.toLowerCase()).toList();

  /// Retourne les événements pour un mois spécifique
  List<EventOverlay> getEventsForMonth(int month) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];

    if (month < 1 || month > 12) return [];

    return filterByPeriod(months[month - 1]);
  }

  /// Rafraîchit la liste des événements
  Future<void> refresh() async {
    await loadEvents();
  }
}
