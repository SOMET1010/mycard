/// Modèle de données pour un overlay événementiel
library;

import 'package:flutter/material.dart';

class EventOverlay {
  const EventOverlay({
    required this.id,
    required this.label,
    required this.color,
    required this.icon,
    required this.period,
    required this.description,
    this.isActive = true,
  });

  /// Crée un événement à partir d'un Map JSON
  factory EventOverlay.fromJson(Map<String, dynamic> json) => EventOverlay(
    id: json['id'],
    label: json['label'],
    color: Color(int.parse('FF${json['color']}', radix: 16)),
    icon: json['icon'],
    period: json['period'],
    description: json['description'],
    isActive: json['isActive'] ?? true,
  );
  final String id;
  final String label;
  final Color color;
  final String icon;
  final String period;
  final String description;
  final bool isActive;

  /// Vérifie si l'événement est actif pour la date actuelle
  bool isCurrentlyActive() {
    if (!isActive) return false;

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    switch (period.toLowerCase()) {
      case 'janvier':
        return currentMonth == 1;
      case 'février':
        return currentMonth == 2;
      case 'mars':
        return currentMonth == 3;
      case 'avril':
        return currentMonth == 4;
      case 'mai':
        return currentMonth == 5;
      case 'juin':
        return currentMonth == 6;
      case 'juillet':
        return currentMonth == 7;
      case 'août':
        return currentMonth == 8;
      case 'septembre':
        return currentMonth == 9;
      case 'octobre':
        return currentMonth == 10;
      case 'novembre':
        return currentMonth == 11;
      case 'décembre':
        return currentMonth == 12;
      case 'toute l\'année':
        return true;
      default:
        return false;
    }
  }

  /// Événements prédéfinis
  static const List<EventOverlay> predefinedEvents = [
    EventOverlay(
      id: 'octobre_rose',
      label: 'Octobre Rose',
      color: Color(0xFFFF69B4),
      icon: 'ribbon',
      period: 'octobre',
      description: 'Sensibilisation au cancer du sein',
      isActive: true,
    ),
    EventOverlay(
      id: 'movember',
      label: 'Movember',
      color: Color(0xFF8B4513),
      icon: 'mustache',
      period: 'novembre',
      description: 'Sensibilisation à la santé masculine',
      isActive: true,
    ),
    EventOverlay(
      id: 'noel',
      label: 'Noël',
      color: Color(0xFF228B22),
      icon: 'tree',
      period: 'décembre',
      description: 'Période des fêtes de fin d\'année',
      isActive: true,
    ),
    EventOverlay(
      id: 'fete_des_meres',
      label: 'Fête des Mères',
      color: Color(0xFFFF1493),
      icon: 'heart',
      period: 'mai',
      description: 'Célébration des mères',
      isActive: true,
    ),
    EventOverlay(
      id: 'fete_des_peres',
      label: 'Fête des Pères',
      color: Color(0xFF4169E1),
      icon: 'tie',
      period: 'juin',
      description: 'Célébration des pères',
      isActive: true,
    ),
    EventOverlay(
      id: 'st_valentin',
      label: 'Saint-Valentin',
      color: Color(0xFFDC143C),
      icon: 'love',
      period: 'février',
      description: 'Fête des amoureux',
      isActive: true,
    ),
    EventOverlay(
      id: 'halloween',
      label: 'Halloween',
      color: Color(0xFF8B008B),
      icon: 'pumpkin',
      period: 'octobre',
      description: 'Fête d\'Halloween',
      isActive: true,
    ),
    EventOverlay(
      id: 'nouvel_an',
      label: 'Nouvel An',
      color: Color(0xFFDAA520),
      icon: 'champagne',
      period: 'janvier',
      description: 'Célébration du nouvel an',
      isActive: true,
    ),
  ];

  /// Trouve un événement par son ID
  static EventOverlay? findById(String id) {
    try {
      return predefinedEvents.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Retourne les événements actuellement actifs
  static List<EventOverlay> getActiveEvents() =>
      predefinedEvents.where((event) => event.isCurrentlyActive()).toList();

  /// Convertit en Map pour JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'color': color.value.toRadixString(16),
    'icon': icon,
    'period': period,
    'description': description,
    'isActive': isActive,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventOverlay && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'EventOverlay(id: $id, label: $label)';
}
