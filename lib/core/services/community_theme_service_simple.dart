/// Service simplifié pour la gestion de la bibliothèque de thèmes communautaires
library;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mycard/data/models/event_theme_customization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityTheme {

  const CommunityTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.theme,
    required this.authorId,
    this.authorName = 'Anonyme',
    required this.createdAt,
    this.downloads = 0,
    this.rating = 0.0,
    this.tags = const [],
    this.isPublic = true,
  });

  factory CommunityTheme.fromJson(Map<String, dynamic> json) => CommunityTheme(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      theme: EventThemeCustomization.fromJson(json['theme'] ?? {}),
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? 'Anonyme',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      downloads: json['downloads'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['isPublic'] ?? true,
    );
  final String id;
  final String name;
  final String description;
  final EventThemeCustomization theme;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int downloads;
  final double rating;
  final List<String> tags;
  final bool isPublic;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'description': description,
      'theme': theme.toJson(),
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'downloads': downloads,
      'rating': rating,
      'tags': tags,
      'isPublic': isPublic,
    };
}

class CommunityThemeService {
  static const String _cacheKey = 'community_themes_cache';
  static const String _favoritesKey = 'favorite_themes';
  static const int _cacheTimeout = 3600000; // 1 hour
  static List<CommunityTheme> _themes = [];
  static DateTime? _lastCacheUpdate;

  static Future<List<CommunityTheme>> getPopularThemes() async {
    await _loadThemes();
    return _themes.where((theme) => theme.isPublic).toList();
  }

  static Future<List<CommunityTheme>> getFavoriteThemes() async {
    await _loadThemes();
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];

    return _themes.where((theme) => favoriteIds.contains(theme.id)).toList();
  }

  static Future<void> _loadThemes() async {
    if (_themes.isNotEmpty && _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!).inMilliseconds < _cacheTimeout) {
      return;
    }

    // Charger depuis le cache ou générer des thèmes par défaut
    final prefs = await SharedPreferences.getInstance();
    final cachedThemes = prefs.getString(_cacheKey);

    if (cachedThemes != null) {
      try {
        final List<dynamic> jsonList = json.decode(cachedThemes);
        _themes = jsonList.map((json) => CommunityTheme.fromJson(json)).toList();
        _lastCacheUpdate = DateTime.now();
        return;
      } catch (e) {
        // Erreur de chargement, générer des thèmes par défaut
      }
    }

    // Générer des thèmes de démonstration
    _themes = _generateDemoThemes();
    _lastCacheUpdate = DateTime.now();

    // Sauvegarder en cache
    await prefs.setString(_cacheKey, json.encode(_themes.map((t) => t.toJson()).toList()));
  }

  static List<CommunityTheme> _generateDemoThemes() => [
      CommunityTheme(
        id: 'theme-1',
        name: 'Élégance Professionnelle',
        description: 'Un thème sobre et professionnel pour les entreprises',
        theme: EventThemeCustomization(
          id: 'theme-1',
          name: 'Élégance Professionnelle',
          description: 'Un thème sobre et professionnel',
          colors: const {
            'primary': Color(0xFF37474F),
            'secondary': Color(0xFF607D8B),
            'background': Color(0xFFF5F5F5),
            'text': Color(0xFF37474F),
          },
          createdAt: DateTime(2024, 1, 1),
        ),
        authorId: 'demo-user-1',
        authorName: 'Designer Pro',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        downloads: 150,
        rating: 4.5,
        tags: ['professionnel', 'entreprise', 'sobre'],
      ),
      CommunityTheme(
        id: 'theme-2',
        name: 'Créativité Colorée',
        description: 'Un thème vibrant et créatif pour les artistes',
        theme: EventThemeCustomization(
          id: 'theme-2',
          name: 'Créativité Colorée',
          description: 'Un thème vibrant et créatif',
          colors: const {
            'primary': Color(0xFFFF6B6B),
            'secondary': Color(0xFF4ECDC4),
            'background': Color(0xFFFFF8E1),
            'text': Color(0xFF37474F),
          },
          createdAt: DateTime(2024, 1, 2),
        ),
        authorId: 'demo-user-2',
        authorName: 'Artiste Créatif',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        downloads: 200,
        rating: 4.8,
        tags: ['créatif', 'coloré', 'artiste'],
      ),
      CommunityTheme(
        id: 'theme-3',
        name: 'Moderne Minimaliste',
        description: 'Un thème épuré et moderne',
        theme: EventThemeCustomization(
          id: 'theme-3',
          name: 'Moderne Minimaliste',
          description: 'Un thème épuré et moderne',
          colors: const {
            'primary': Color(0xFF212121),
            'secondary': Color(0xFF757575),
            'background': Color(0xFFFAFAFA),
            'text': Color(0xFF212121),
          },
          createdAt: DateTime(2024, 1, 3),
        ),
        authorId: 'demo-user-3',
        authorName: 'Minimaliste Designer',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        downloads: 120,
        rating: 4.2,
        tags: ['moderne', 'minimaliste', 'épuré'],
      ),
    ];

  static Future<void> toggleFavorite(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];

    if (favoriteIds.contains(themeId)) {
      favoriteIds.remove(themeId);
    } else {
      favoriteIds.add(themeId);
    }

    await prefs.setStringList(_favoritesKey, favoriteIds);
  }

  static Future<bool> isFavorite(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
    return favoriteIds.contains(themeId);
  }

  static Future<CommunityTheme> uploadTheme({
    required EventThemeCustomization theme,
    required String authorId,
    required String authorName,
    required String name,
    required String description,
    List<String> tags = const [],
  }) async {
    final newTheme = CommunityTheme(
      id: 'uploaded-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      theme: theme,
      authorId: authorId,
      authorName: authorName,
      createdAt: DateTime.now(),
      tags: tags,
      isPublic: true,
    );

    _themes.add(newTheme);

    // Mettre à jour le cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json.encode(_themes.map((t) => t.toJson()).toList()));

    return newTheme;
  }

  static Future<List<CommunityTheme>> searchThemes(String query) async {
    await _loadThemes();
    final lowercaseQuery = query.toLowerCase();

    return _themes.where((theme) =>
        theme.name.toLowerCase().contains(lowercaseQuery) ||
        theme.description.toLowerCase().contains(lowercaseQuery) ||
        theme.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  static Future<List<CommunityTheme>> getThemesByCategory(String category) async {
    await _loadThemes();
    return _themes.where((theme) =>
        theme.tags.contains(category.toLowerCase()) ||
        theme.name.toLowerCase().contains(category.toLowerCase())
    ).toList();
  }
}