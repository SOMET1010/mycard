/// Modèle pour la personnalisation de thèmes d'événements
library;
import 'package:flutter/material.dart';

class EventThemeCustomization {

  const EventThemeCustomization({
    required this.id,
    required this.name,
    required this.description,
    required this.colors,
    this.fontFamily = 'Roboto',
    this.fontSize = 14.0,
    this.layout = const {},
    this.backgroundImage = '',
    this.tags = const [],
    required this.createdAt,
    this.authorId,
    this.authorName,
    this.downloads = 0,
    this.rating = 0.0,
    this.isPublic = false,
  });

  factory EventThemeCustomization.fromJson(Map<String, dynamic> json) => EventThemeCustomization(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      colors: Map<String, Color>.from(
        (json['colors'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, Color(int.parse(value.substring(1), radix: 16) + 0xFF000000)),
        ) ?? {},
      ),
      fontFamily: json['fontFamily'] ?? 'Roboto',
      fontSize: (json['fontSize'] ?? 14.0).toDouble(),
      layout: Map<String, dynamic>.from(json['layout'] ?? {}),
      backgroundImage: json['backgroundImage'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      authorId: json['authorId'],
      authorName: json['authorName'],
      downloads: json['downloads'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      isPublic: json['isPublic'] ?? false,
    );
  final String id;
  final String name;
  final String description;
  final Map<String, Color> colors;
  final String fontFamily;
  final double fontSize;
  final Map<String, dynamic> layout;
  final String backgroundImage;
  final List<String> tags;
  final DateTime createdAt;
  final String? authorId;
  final String? authorName;
  final int downloads;
  final double rating;
  final bool isPublic;

  // Getters pour la compatibilité
  Color get primaryColor => colors['primary'] ?? Colors.blue;
  Color get secondaryColor => colors['secondary'] ?? Colors.green;
  Color get backgroundColor => colors['background'] ?? Colors.white;
  Color get textColor => colors['text'] ?? Colors.black;
  Color get accentColor => colors['accent'] ?? Colors.orange;
  double get borderRadius => (layout['borderRadius'] as double?) ?? 8.0;
  double get shadowOpacity => (layout['shadowOpacity'] as double?) ?? 0.1;
  bool get showBackgroundPattern => (layout['showBackgroundPattern'] as bool?) ?? false;
  String get backgroundPattern => (layout['backgroundPattern'] as String?) ?? 'none';

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'description': description,
      'colors': colors.map((key, value) => MapEntry(key, '#${value.value.toRadixString(16).substring(2)}')),
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'layout': layout,
      'backgroundImage': backgroundImage,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'authorId': authorId,
      'authorName': authorName,
      'downloads': downloads,
      'rating': rating,
      'isPublic': isPublic,
    };

  EventThemeCustomization copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, Color>? colors,
    String? fontFamily,
    double? fontSize,
    Map<String, dynamic>? layout,
    String? backgroundImage,
    List<String>? tags,
    DateTime? createdAt,
    String? authorId,
    String? authorName,
    int? downloads,
    double? rating,
    bool? isPublic,
  }) => EventThemeCustomization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colors: colors ?? this.colors,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      layout: layout ?? this.layout,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      downloads: downloads ?? this.downloads,
      rating: rating ?? this.rating,
      isPublic: isPublic ?? this.isPublic,
    );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventThemeCustomization && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'EventThemeCustomization(id: $id, name: $name, description: $description)';
}