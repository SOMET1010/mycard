import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modèle pour les informations extraites d'une photo
class PhotoColorExtraction {
  const PhotoColorExtraction({
    required this.dominantColors,
    required this.accentColors,
    required this.primaryColor,
    required this.secondaryColor,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.mood,
    required this.palette,
    required this.metadata,
  });

  factory PhotoColorExtraction.fromJson(Map<String, dynamic> json) =>
      PhotoColorExtraction(
        dominantColors: (json['dominantColors'] as List)
            .map((c) => Color(c as int))
            .toList(),
        accentColors: (json['accentColors'] as List)
            .map((c) => Color(c as int))
            .toList(),
        primaryColor: Color(json['primaryColor'] as int),
        secondaryColor: Color(json['secondaryColor'] as int),
        brightness: json['brightness'] as double,
        contrast: json['contrast'] as double,
        saturation: json['saturation'] as double,
        mood: json['mood'] as String,
        palette: (json['palette'] as List).map((c) => Color(c as int)).toList(),
        metadata: json['metadata'] as Map<String, dynamic>,
      );
  final List<Color> dominantColors;
  final List<Color> accentColors;
  final Color primaryColor;
  final Color secondaryColor;
  final double brightness;
  final double contrast;
  final double saturation;
  final String mood;
  final List<Color> palette;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
    'dominantColors': dominantColors.map((c) => c.value).toList(),
    'accentColors': accentColors.map((c) => c.value).toList(),
    'primaryColor': primaryColor.value,
    'secondaryColor': secondaryColor.value,
    'brightness': brightness,
    'contrast': contrast,
    'saturation': saturation,
    'mood': mood,
    'palette': palette.map((c) => c.value).toList(),
    'metadata': metadata,
  };
}

/// Modèle pour les filtres photo
class PhotoFilter {
  const PhotoFilter({
    required this.id,
    required this.name,
    required this.description,
    required this.parameters,
    required this.category,
  });

  factory PhotoFilter.fromJson(Map<String, dynamic> json) => PhotoFilter(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    parameters: json['parameters'] as Map<String, dynamic>,
    category: json['category'] as String,
  );
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final String category;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'parameters': parameters,
    'category': category,
  };
}

/// Service d'intégration photo pour l'analyse et l'extraction de thèmes
class PhotoIntegrationService {
  PhotoIntegrationService._();
  static PhotoIntegrationService? _instance;
  static PhotoIntegrationService get instance {
    _instance ??= PhotoIntegrationService._();
    return _instance!;
  }

  final ImagePicker _imagePicker = ImagePicker();
  final List<PhotoColorExtraction> _extractions = [];
  final List<PhotoFilter> _filters = [];
  Timer? _analysisTimer;

  /// Initialise le service
  Future<void> initialize() async {
    await _loadExtractions();
    await _loadFilters();
    _initializeDefaultFilters();
  }

  /// Prend une photo avec la caméra
  Future<String?> capturePhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );

      if (photo != null) {
        return photo.path;
      }
      return null;
    } catch (e) {
      debugPrint('Erreur capture photo: $e');
      return null;
    }
  }

  /// Sélectionne une photo depuis la galerie
  Future<String?> pickPhotoFromGallery() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (photo != null) {
        return photo.path;
      }
      return null;
    } catch (e) {
      debugPrint('Erreur sélection photo: $e');
      return null;
    }
  }

  /// Analyse les couleurs d'une photo
  Future<PhotoColorExtraction> analyzePhotoColors(String imagePath) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Impossible de convertir l\'image en bytes');
      }

      final pixels = byteData.buffer.asUint8List();
      final width = image.width;
      final height = image.height;

      // Extraire les couleurs dominantes
      final colorMap = <int, int>{};
      for (var i = 0; i < pixels.length; i += 4) {
        final r = pixels[i];
        final g = pixels[i + 1];
        final b = pixels[i + 2];
        final a = pixels[i + 3];

        if (a > 0) {
          final color = (r << 16) | (g << 8) | b;
          colorMap[color] = (colorMap[color] ?? 0) + 1;
        }
      }

      // Trier par fréquence
      final sortedColors = colorMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final dominantColors = sortedColors
          .take(5)
          .map((e) => Color(e.key))
          .toList();

      final accentColors = sortedColors
          .skip(5)
          .take(10)
          .map((e) => Color(e.key))
          .toList();

      // Calculer les statistiques
      final brightness = _calculateBrightness(pixels);
      final contrast = _calculateContrast(pixels);
      final saturation = _calculateSaturation(pixels);

      // Déterminer l'humeur
      final mood = _determineMood(brightness, saturation, dominantColors);

      // Créer la palette
      final palette = _createPalette(dominantColors, accentColors);

      final extraction = PhotoColorExtraction(
        dominantColors: dominantColors,
        accentColors: accentColors,
        primaryColor: dominantColors.isNotEmpty
            ? dominantColors.first
            : Colors.grey,
        secondaryColor: dominantColors.length > 1
            ? dominantColors[1]
            : Colors.grey,
        brightness: brightness,
        contrast: contrast,
        saturation: saturation,
        mood: mood,
        palette: palette,
        metadata: {
          'imagePath': imagePath,
          'analyzedAt': DateTime.now().toIso8601String(),
          'width': width,
          'height': height,
          'totalPixels': pixels.length ~/ 4,
        },
      );

      _extractions.add(extraction);
      await _saveExtractions();

      return extraction;
    } catch (e) {
      debugPrint('Erreur analyse photo: $e');
      throw Exception('Erreur lors de l\'analyse de la photo: $e');
    }
  }

  /// Génère un thème à partir d'une photo
  Future<Map<String, dynamic>> generateThemeFromPhoto(
    String imagePath,
    String themeName,
  ) async {
    try {
      final extraction = await analyzePhotoColors(imagePath);

      final theme = {
        'id': 'photo_${DateTime.now().millisecondsSinceEpoch}',
        'name': themeName,
        'description': 'Thème généré à partir de photo',
        'type': 'photo_generated',
        'createdAt': DateTime.now().toIso8601String(),
        'source': {
          'type': 'photo',
          'path': imagePath,
          'extraction': extraction.toJson(),
        },
        'colors': {
          'primary': extraction.primaryColor.value,
          'secondary': extraction.secondaryColor.value,
          'accent': extraction.accentColors.isNotEmpty
              ? extraction.accentColors.first.value
              : extraction.primaryColor.value,
          'background': _getBackgroundForMood(extraction.mood).value,
          'surface': _getSurfaceForMood(extraction.mood).value,
        },
        'palette': extraction.palette.map((c) => c.value).toList(),
        'mood': extraction.mood,
        'metadata': {
          'brightness': extraction.brightness,
          'contrast': extraction.contrast,
          'saturation': extraction.saturation,
          'dominantColors': extraction.dominantColors
              .map((c) => c.value)
              .toList(),
        },
        'styles': {
          'cardStyle': _getCardStyleForMood(extraction.mood),
          'buttonStyle': _getButtonStyleForMood(extraction.mood),
          'fontStyle': _getFontStyleForMood(extraction.mood),
        },
      };

      return theme;
    } catch (e) {
      debugPrint('Erreur génération thème: $e');
      throw Exception('Erreur lors de la génération du thème: $e');
    }
  }

  /// Applique un filtre à une photo
  Future<Uint8List> applyFilter(String imagePath, PhotoFilter filter) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) {
        throw Exception('Impossible de convertir l\'image en bytes');
      }

      final pixels = byteData.buffer.asUint8List();
      final filteredPixels = await _applyFilterToPixels(pixels, filter);

      // Recréer l'image filtrée
      final width = image.width;
      final height = image.height;

      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        filteredPixels.buffer.asUint8List(),
        width,
        height,
        ui.PixelFormat.rgba8888,
        completer.complete,
      );

      final filteredImage = await completer.future;
      final filteredByteData = await filteredImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return filteredByteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint('Erreur application filtre: $e');
      throw Exception('Erreur lors de l\'application du filtre: $e');
    }
  }

  /// Obtient les filtres disponibles
  List<PhotoFilter> getAvailableFilters() => List.unmodifiable(_filters);

  /// Obtient les extractions récentes
  List<PhotoColorExtraction> getRecentExtractions() =>
      List.unmodifiable(_extractions.reversed.take(10).toList());

  /// Supprime une extraction
  Future<void> removeExtraction(PhotoColorExtraction extraction) async {
    _extractions.remove(extraction);
    await _saveExtractions();
  }

  /// Recherche des extractions par humeur
  List<PhotoColorExtraction> searchExtractionsByMood(String mood) =>
      _extractions
          .where((e) => e.mood.toLowerCase().contains(mood.toLowerCase()))
          .toList();

  /// Calcule la luminosité moyenne
  double _calculateBrightness(Uint8List pixels) {
    double totalBrightness = 0;
    var pixelCount = 0;

    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final a = pixels[i + 3];

      if (a > 0) {
        final brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
        totalBrightness += brightness;
        pixelCount++;
      }
    }

    return pixelCount > 0 ? totalBrightness / pixelCount : 0.0;
  }

  /// Calcule le contraste
  double _calculateContrast(Uint8List pixels) {
    final brightness = _calculateBrightness(pixels);
    double totalVariation = 0;
    var pixelCount = 0;

    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final a = pixels[i + 3];

      if (a > 0) {
        final pixelBrightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
        totalVariation += (pixelBrightness - brightness).abs();
        pixelCount++;
      }
    }

    return pixelCount > 0 ? totalVariation / pixelCount : 0.0;
  }

  /// Calcule la saturation
  double _calculateSaturation(Uint8List pixels) {
    double totalSaturation = 0;
    var pixelCount = 0;

    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final a = pixels[i + 3];

      if (a > 0) {
        final max = math.max(r, math.max(g, b)) / 255.0;
        final min = math.min(r, math.min(g, b)) / 255.0;
        final saturation = max > 0 ? (max - min) / max : 0.0;
        totalSaturation += saturation;
        pixelCount++;
      }
    }

    return pixelCount > 0 ? totalSaturation / pixelCount : 0.0;
  }

  /// Détermine l'humeur de l'image
  String _determineMood(
    double brightness,
    double saturation,
    List<Color> colors,
  ) {
    if (brightness > 0.7 && saturation > 0.6) {
      return 'vibrant';
    } else if (brightness > 0.6) {
      return 'bright';
    } else if (brightness < 0.3) {
      return 'dark';
    } else if (saturation > 0.6) {
      return 'colorful';
    } else if (saturation < 0.3) {
      return 'monochrome';
    } else {
      return 'balanced';
    }
  }

  /// Crée une palette de couleurs harmonieuse
  List<Color> _createPalette(List<Color> dominant, List<Color> accent) {
    final palette = <Color>[];
    palette.addAll(dominant.take(3));
    palette.addAll(accent.take(2));

    // Ajouter des couleurs complémentaires si nécessaire
    while (palette.length < 8) {
      final baseColor = palette[palette.length % palette.length];
      final complementary = Color(0xFFFFFFFF - baseColor.value);
      palette.add(complementary);
    }

    return palette.take(8).toList();
  }

  /// Obtient la couleur de fond selon l'humeur
  Color _getBackgroundForMood(String mood) {
    switch (mood) {
      case 'vibrant':
        return Colors.white;
      case 'bright':
        return const Color(0xFFF8F9FA);
      case 'dark':
        return const Color(0xFF1A1A1A);
      case 'colorful':
        return const Color(0xFFF5F5F5);
      case 'monochrome':
        return const Color(0xFFE0E0E0);
      default:
        return Colors.white;
    }
  }

  /// Obtient la couleur de surface selon l'humeur
  Color _getSurfaceForMood(String mood) {
    switch (mood) {
      case 'vibrant':
        return const Color(0xFFF0F0F0);
      case 'bright':
        return const Color(0xFFFFFFFF);
      case 'dark':
        return const Color(0xFF2D2D2D);
      case 'colorful':
        return const Color(0xFFFFFFFF);
      case 'monochrome':
        return const Color(0xFF757575);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  /// Obtient le style de carte selon l'humeur
  String _getCardStyleForMood(String mood) {
    switch (mood) {
      case 'vibrant':
        return 'elevated_colorful';
      case 'bright':
        return 'flat_light';
      case 'dark':
        return 'dark_elevated';
      case 'colorful':
        return 'gradient_colorful';
      case 'monochrome':
        return 'minimal_monochrome';
      default:
        return 'standard';
    }
  }

  /// Obtient le style de bouton selon l'humeur
  String _getButtonStyleForMood(String mood) {
    switch (mood) {
      case 'vibrant':
        return 'rounded_gradient';
      case 'bright':
        return 'outlined_light';
      case 'dark':
        return 'filled_dark';
      case 'colorful':
        return 'shadow_colorful';
      case 'monochrome':
        return 'minimal_flat';
      default:
        return 'standard';
    }
  }

  /// Obtient le style de police selon l'humeur
  String _getFontStyleForMood(String mood) {
    switch (mood) {
      case 'vibrant':
        return 'bold_playful';
      case 'bright':
        return 'light_elegant';
      case 'dark':
        return 'medium_contrast';
      case 'colorful':
        return 'artistic_italic';
      case 'monochrome':
        return 'clean_minimal';
      default:
        return 'standard';
    }
  }

  /// Applique un filtre aux pixels
  Future<Uint8List> _applyFilterToPixels(
    Uint8List pixels,
    PhotoFilter filter,
  ) async {
    final filteredPixels = Uint8List(pixels.length);
    final params = filter.parameters;

    switch (filter.id) {
      case 'vintage':
        return _applyVintageFilter(pixels, params);
      case 'black_white':
        return _applyBlackWhiteFilter(pixels, params);
      case 'sepia':
        return _applySepiaFilter(pixels, params);
      case 'high_contrast':
        return _applyHighContrastFilter(pixels, params);
      case 'blur':
        return _applyBlurFilter(pixels, params);
      default:
        return pixels;
    }
  }

  /// Applique un filtre vintage
  Uint8List _applyVintageFilter(Uint8List pixels, Map<String, dynamic> params) {
    final intensity = params['intensity'] as double? ?? 0.5;
    final warmth = params['warmth'] as double? ?? 0.3;

    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final a = pixels[i + 3];

      if (a > 0) {
        final newR = (r * (1 + warmth * intensity)).clamp(0, 255);
        final newG = (g * (1 + warmth * intensity * 0.5)).clamp(0, 255);
        final newB = (b * (1 - warmth * intensity * 0.3)).clamp(0, 255);

        filteredPixels[i] = newR.toInt();
        filteredPixels[i + 1] = newG.toInt();
        filteredPixels[i + 2] = newB.toInt();
        filteredPixels[i + 3] = a;
      }
    }

    return filteredPixels;
  }

  /// Applique un filtre noir et blanc
  Uint8List _applyBlackWhiteFilter(
    Uint8List pixels,
    Map<String, dynamic> params,
  ) {
    final contrast = params['contrast'] as double? ?? 1.0;

    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final a = pixels[i + 3];

      if (a > 0) {
        final gray = 0.299 * r + 0.587 * g + 0.114 * b;
        final adjusted = ((gray - 128) * contrast + 128).clamp(0, 255);

        filteredPixels[i] = adjusted.toInt();
        filteredPixels[i + 1] = adjusted.toInt();
        filteredPixels[i + 2] = adjusted.toInt();
        filteredPixels[i + 3] = a;
      }
    }

    return filteredPixels;
  }

  /// Applique un filtre sépia
  Uint8List _applySepiaFilter(Uint8List pixels, Map<String, dynamic> params) {
    final intensity = params['intensity'] as double? ?? 0.8;

    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final a = pixels[i + 3];

      if (a > 0) {
        final tr = 0.393 * r + 0.769 * g + 0.189 * b;
        final tg = 0.349 * r + 0.686 * g + 0.168 * b;
        final tb = 0.272 * r + 0.534 * g + 0.131 * b;

        final newR = (tr * intensity + r * (1 - intensity)).clamp(0, 255);
        final newG = (tg * intensity + g * (1 - intensity)).clamp(0, 255);
        final newB = (tb * intensity + b * (1 - intensity)).clamp(0, 255);

        filteredPixels[i] = newR.toInt();
        filteredPixels[i + 1] = newG.toInt();
        filteredPixels[i + 2] = newB.toInt();
        filteredPixels[i + 3] = a;
      }
    }

    return filteredPixels;
  }

  /// Applique un filtre haut contraste
  Uint8List _applyHighContrastFilter(
    Uint8List pixels,
    Map<String, dynamic> params,
  ) {
    final factor = params['factor'] as double? ?? 2.0;

    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final a = pixels[i + 3];

      if (a > 0) {
        final newR = ((r - 128) * factor + 128).clamp(0, 255);
        final newG = ((g - 128) * factor + 128).clamp(0, 255);
        final newB = ((b - 128) * factor + 128).clamp(0, 255);

        filteredPixels[i] = newR.toInt();
        filteredPixels[i + 1] = newG.toInt();
        filteredPixels[i + 2] = newB.toInt();
        filteredPixels[i + 3] = a;
      }
    }

    return filteredPixels;
  }

  /// Applique un flou (simplifié)
  Uint8List _applyBlurFilter(Uint8List pixels, Map<String, dynamic> params) {
    final radius = params['radius'] as int? ?? 2;

    // Pour l'instant, retourne les pixels originaux
    // Une implémentation complète nécessiterait un algorithme de flou plus complexe
    return pixels;
  }

  /// Initialise les filtres par défaut
  void _initializeDefaultFilters() {
    if (_filters.isEmpty) {
      _filters.addAll([
        const PhotoFilter(
          id: 'vintage',
          name: 'Vintage',
          description: 'Effet vintage chaud',
          parameters: {'intensity': 0.5, 'warmth': 0.3},
          category: 'Color',
        ),
        const PhotoFilter(
          id: 'black_white',
          name: 'Noir et Blanc',
          description: 'Conversion noir et blanc',
          parameters: {'contrast': 1.2},
          category: 'Monochrome',
        ),
        const PhotoFilter(
          id: 'sepia',
          name: 'Sépia',
          description: 'Effet sépia classique',
          parameters: {'intensity': 0.8},
          category: 'Color',
        ),
        const PhotoFilter(
          id: 'high_contrast',
          name: 'Haut Contraste',
          description: 'Augmente le contraste',
          parameters: {'factor': 1.5},
          category: 'Adjustment',
        ),
        const PhotoFilter(
          id: 'blur',
          name: 'Flou',
          description: 'Effet de flou artistique',
          parameters: {'radius': 3},
          category: 'Effect',
        ),
      ]);
    }
  }

  /// Sauvegarde les extractions
  Future<void> _saveExtractions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final extractionsJson = _extractions
          .map((e) => jsonEncode(e.toJson()))
          .toList();
      await prefs.setStringList('photo_extractions', extractionsJson);
    } catch (e) {
      debugPrint('Erreur sauvegarde extractions: $e');
    }
  }

  /// Charge les extractions
  Future<void> _loadExtractions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final extractionsJson = prefs.getStringList('photo_extractions') ?? [];

      _extractions.clear();
      for (final extractionJson in extractionsJson) {
        final extractionData =
            jsonDecode(extractionJson) as Map<String, dynamic>;
        _extractions.add(PhotoColorExtraction.fromJson(extractionData));
      }
    } catch (e) {
      debugPrint('Erreur chargement extractions: $e');
    }
  }

  /// Sauvegarde les filtres
  Future<void> _saveFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = _filters.map((f) => jsonEncode(f.toJson())).toList();
      await prefs.setStringList('photo_filters', filtersJson);
    } catch (e) {
      debugPrint('Erreur sauvegarde filtres: $e');
    }
  }

  /// Charge les filtres
  Future<void> _loadFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getStringList('photo_filters') ?? [];

      _filters.clear();
      for (final filterJson in filtersJson) {
        final filterData = jsonDecode(filterJson) as Map<String, dynamic>;
        _filters.add(PhotoFilter.fromJson(filterData));
      }
    } catch (e) {
      debugPrint('Erreur chargement filtres: $e');
    }
  }

  /// Nettoie les ressources
  void dispose() {
    _analysisTimer?.cancel();
    _extractions.clear();
    _filters.clear();
  }
}
