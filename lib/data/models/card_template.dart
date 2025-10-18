/// Modèle de données pour un template de carte
library;

import 'package:flutter/material.dart';

class CardTemplate {
  const CardTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.colors,
    required this.rendererKey,
    required this.layout,
    required this.previewPath,
    this.isPremium = false,
    this.eventId,
    this.tags = const [],
  });

  /// Crée un template à partir d'un Map JSON
  factory CardTemplate.fromJson(Map<String, dynamic> json) => CardTemplate(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    colors: Map<String, String>.from(json['colors'] ?? {}),
    rendererKey: json['rendererKey'] ?? 'minimal',
    layout: json['layout'] ?? 'centered',
    previewPath: json['previewPath'] ?? '',
    isPremium: json['isPremium'] ?? false,
    eventId: json['eventId'],
    tags:
        (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
  );
  final String id;
  final String name;
  final String description;
  final Map<String, String> colors;
  final String rendererKey;
  final String layout;
  final String previewPath;
  final bool isPremium;
  final String? eventId; // identifiant d'événement associé (ex: octobre_rose)
  final List<String> tags; // mots-clés (ex: ['professionnel','bleu'])

  /// Couleur principale
  Color get primaryColor {
    debugPrint(
      'Getting primary color for $name: \\${colors['primary'] ?? '#000000'}',
    );
    return _hexToColor(colors['primary'] ?? '#000000');
  }

  /// Couleur secondaire
  Color get secondaryColor {
    debugPrint(
      'Getting secondary color for $name: \\${colors['secondary'] ?? '#666666'}',
    );
    return _hexToColor(colors['secondary'] ?? '#666666');
  }

  /// Couleur d'accent
  Color get accentColor {
    debugPrint(
      'Getting accent color for $name: \\${colors['accent'] ?? '#2563eb'}',
    );
    return _hexToColor(colors['accent'] ?? '#2563eb');
  }

  /// Convertit une chaîne hexadécimale en Color
  static Color _hexToColor(String hexString) {
    final hexCode = hexString.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  /// Templates prédéfinis
  static const List<CardTemplate> predefinedTemplates = [
    CardTemplate(
      id: 'minimal',
      name: 'Minimal',
      description: 'Design épuré et moderne',
      colors: {
        'primary': '#000000',
        'secondary': '#666666',
        'accent': '#2563eb',
      },
      rendererKey: 'minimal',
      layout: 'centered',
      previewPath: 'assets/templates/minimal_preview.png',
    ),
    CardTemplate(
      id: 'modern_gradient',
      name: 'Gradient Moderne',
      description: 'Fond dégradé moderne et lisible',
      colors: {
        'primary': '#0E4274',
        'secondary': '#8DC5D2',
        'accent': '#E28742',
      },
      rendererKey: 'modern_gradient',
      layout: 'modern',
      previewPath: 'assets/templates/modern_gradient_preview.png',
    ),
    CardTemplate(
      id: 'stripe_left',
      name: 'Bande à gauche',
      description: 'Bande verticale accent et style pro',
      colors: {
        'primary': '#21130D',
        'secondary': '#EAB676',
        'accent': '#E28742',
      },
      rendererKey: 'stripe_left',
      layout: 'left-aligned',
      previewPath: 'assets/templates/stripe_left_preview.png',
    ),
    CardTemplate(
      id: 'photo_badge',
      name: 'Photo Badge',
      description: 'Avatar/logo + infos compactes',
      colors: {
        'primary': '#1E293B',
        'secondary': '#64748B',
        'accent': '#E28742',
      },
      rendererKey: 'photo_badge',
      layout: 'two-columns',
      previewPath: 'assets/templates/photo_badge_preview.png',
    ),
    CardTemplate(
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
    CardTemplate(
      id: 'corporate',
      name: 'Corporate',
      description: 'Style professionnel et formel',
      colors: {
        'primary': '#1e293b',
        'secondary': '#64748b',
        'accent': '#0f172a',
      },
      rendererKey: 'corporate',
      layout: 'left-aligned',
      previewPath: 'assets/templates/corporate_preview.png',
    ),
    CardTemplate(
      id: 'creative',
      name: 'Créatif',
      description: 'Design original et dynamique',
      colors: {
        'primary': '#7c3aed',
        'secondary': '#a78bfa',
        'accent': '#fbbf24',
      },
      rendererKey: 'ansut_style',
      layout: 'modern',
      previewPath: 'assets/templates/creative_preview.png',
    ),
    CardTemplate(
      id: 'elegant',
      name: 'Élégant',
      description: 'Style sophistiqué et raffiné',
      colors: {
        'primary': '#374151',
        'secondary': '#9ca3af',
        'accent': '#d97706',
      },
      rendererKey: 'minimal',
      layout: 'centered',
      previewPath: 'assets/templates/elegant_preview.png',
      isPremium: true,
    ),
    // NOUVEAUX MODÈLES
    CardTemplate(
      id: 'tech_startup',
      name: 'Tech Startup',
      description: 'Design moderne et innovant pour startups',
      colors: {
        'primary': '#0F172A',
        'secondary': '#3B82F6',
        'accent': '#10B981',
      },
      rendererKey: 'tech_startup',
      layout: 'modern',
      previewPath: 'assets/templates/tech_startup_preview.png',
      tags: ['technologique', 'moderne', 'startup'],
    ),
    CardTemplate(
      id: 'medical_professional',
      name: 'Professionnel Médical',
      description: 'Style sobre et professionnel pour secteur médical',
      colors: {
        'primary': '#1F2937',
        'secondary': '#6B7280',
        'accent': '#059669',
      },
      rendererKey: 'medical_professional',
      layout: 'centered',
      previewPath: 'assets/templates/medical_professional_preview.png',
      tags: ['médical', 'professionnel', 'santé'],
    ),
    CardTemplate(
      id: 'creative_artist',
      name: 'Artiste Créatif',
      description: 'Design expressif et coloré pour créatifs',
      colors: {
        'primary': '#7C3AED',
        'secondary': '#EC4899',
        'accent': '#F59E0B',
      },
      rendererKey: 'creative_artist',
      layout: 'asymmetric',
      previewPath: 'assets/templates/creative_artist_preview.png',
      tags: ['créatif', 'artistique', 'coloré'],
    ),
    CardTemplate(
      id: 'academic_researcher',
      name: 'Chercheur Académique',
      description: 'Style formel et structuré pour milieu universitaire',
      colors: {
        'primary': '#1E3A8A',
        'secondary': '#6B7280',
        'accent': '#DC2626',
      },
      rendererKey: 'academic_researcher',
      layout: 'formal',
      previewPath: 'assets/templates/academic_researcher_preview.png',
      tags: ['académique', 'recherche', 'universitaire'],
    ),
    CardTemplate(
      id: 'real_estate_agent',
      name: 'Agent Immobilier',
      description: 'Design accueillant et professionnel pour immobilier',
      colors: {
        'primary': '#1F2937',
        'secondary': '#059669',
        'accent': '#F59E0B',
      },
      rendererKey: 'real_estate_agent',
      layout: 'property',
      previewPath: 'assets/templates/real_estate_agent_preview.png',
      tags: ['immobilier', 'professionnel', 'accueil'],
    ),
    CardTemplate(
      id: 'restaurant_culinary',
      name: 'Restaurant/Culinaire',
      description: 'Design gastronomique et appétissant',
      colors: {
        'primary': '#7F1D1D',
        'secondary': '#A16207',
        'accent': '#DC2626',
      },
      rendererKey: 'restaurant_culinary',
      layout: 'culinary',
      previewPath: 'assets/templates/restaurant_culinary_preview.png',
      tags: ['restaurant', 'culinaire', 'gastronomie'],
    ),
    CardTemplate(
      id: 'weprint_professional',
      name: 'WePrint Professional',
      description: 'Design moderne et professionnel à sections',
      colors: {
        'primary': '#1a1a1a',
        'secondary': '#666666',
        'accent': '#2563eb',
      },
      rendererKey: 'weprint_professional',
      layout: 'sectioned',
      previewPath: 'assets/templates/weprint_professional_preview.png',
      tags: ['professionnel', 'moderne', 'entreprise'],
    ),
  ];

  /// Trouve un template par son ID
  static CardTemplate? findById(String id) {
    try {
      return predefinedTemplates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Convertit en Map pour JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'colors': colors,
    'rendererKey': rendererKey,
    'layout': layout,
    'previewPath': previewPath,
    'isPremium': isPremium,
    'eventId': eventId,
    'tags': tags,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CardTemplate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CardTemplate(id: $id, name: $name)';
}
