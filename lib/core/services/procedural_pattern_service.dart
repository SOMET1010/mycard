/// Service de génération de motifs procéduraux algorithmiques
library;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PatternType {
  geometric, // Formes géométriques
  organic, // Formes organiques
  noise, // Motifs de bruit
  fractal, // Motifs fractals
  cellular, // Motifs cellulaires
  particle, // Motifs de particules
  wave, // Motifs d'ondes
  spiral, // Motifs en spirale
  mandala, // Motifs mandala
  tessellation, // Tessellations
  procedural, // Motifs procéduraux
  generative, // Motifs génératifs
}

enum NoiseType {
  perlin, // Bruit Perlin
  simplex, // Bruit Simplex
  worley, // Bruit Worley
  value, // Bruit de valeur
  gradient, // Bruit de gradient
  cellular, // Bruit cellulaire
  ridged, // Bruit ridgé
  turbulence, // Turbulence
  fbm, // Fractional Brownian Motion
}

enum FractalType {
  mandelbrot, // Ensemble de Mandelbrot
  julia, // Ensemble de Julia
  sierpinski, // Triangle de Sierpinski
  koch, // Flocon de Koch
  dragon, // Courbe du dragon
  barnsley, // Fougère de Barnsley
  hilbert, // Courbe de Hilbert
  cantor, // Ensemble de Cantor
  lsystem, // Système L
}

class ProceduralPatternConfig {
  const ProceduralPatternConfig({
    required this.type,
    this.scale = 1.0,
    this.complexity = 0.5,
    this.density = 1.0,
    this.randomness = 0.1,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.green,
    this.backgroundColor = Colors.white,
    this.parameters = const {},
    this.seed = 0,
  });

  factory ProceduralPatternConfig.fromJson(Map<String, dynamic> json) =>
      ProceduralPatternConfig(
        type: PatternType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => PatternType.geometric,
        ),
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        complexity: (json['complexity'] as num?)?.toDouble() ?? 0.5,
        density: (json['density'] as num?)?.toDouble() ?? 1.0,
        randomness: (json['randomness'] as num?)?.toDouble() ?? 0.1,
        primaryColor: Color(json['primaryColor'] as int? ?? 0xFF0000FF),
        secondaryColor: Color(json['secondaryColor'] as int? ?? 0xFF00FF00),
        backgroundColor: Color(json['backgroundColor'] as int? ?? 0xFFFFFFFF),
        parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
        seed: json['seed'] as int? ?? 0,
      );
  final PatternType type;
  final double scale;
  final double complexity;
  final double density;
  final double randomness;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Map<String, dynamic> parameters;
  final int seed;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'scale': scale,
    'complexity': complexity,
    'density': density,
    'randomness': randomness,
    'primaryColor': primaryColor.value,
    'secondaryColor': secondaryColor.value,
    'backgroundColor': backgroundColor.value,
    'parameters': parameters,
    'seed': seed,
  };

  ProceduralPatternConfig copyWith({
    PatternType? type,
    double? scale,
    double? complexity,
    double? density,
    double? randomness,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Map<String, dynamic>? parameters,
    int? seed,
  }) => ProceduralPatternConfig(
    type: type ?? this.type,
    scale: scale ?? this.scale,
    complexity: complexity ?? this.complexity,
    density: density ?? this.density,
    randomness: randomness ?? this.randomness,
    primaryColor: primaryColor ?? this.primaryColor,
    secondaryColor: secondaryColor ?? this.secondaryColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    parameters: parameters ?? this.parameters,
    seed: seed ?? this.seed,
  );
}

class ProceduralPattern {
  const ProceduralPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.config,
    this.imageData,
    required this.createdAt,
    this.metadata = const {},
  });

  factory ProceduralPattern.fromJson(Map<String, dynamic> json) =>
      ProceduralPattern(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        config: _configFromJson(json['config']),
        imageData: json['imageData'] != null
            ? Uint8List.fromList(json['imageData'])
            : null,
        createdAt: DateTime.parse(json['createdAt']),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
  final String id;
  final String name;
  final String description;
  final ProceduralPatternConfig config;
  final Uint8List? imageData;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'config': _configToJson(config),
    'imageData': imageData?.toList(),
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };

  ProceduralPattern copyWith({
    String? id,
    String? name,
    String? description,
    ProceduralPatternConfig? config,
    Uint8List? imageData,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) => ProceduralPattern(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    config: config ?? this.config,
    imageData: imageData ?? this.imageData,
    createdAt: createdAt ?? this.createdAt,
    metadata: metadata ?? this.metadata,
  );
}

class ProceduralPatternService {
  static final Random _random = Random();
  static final Map<String, ProceduralPattern> _patterns = {};

  /// Génère un motif procédural
  static Future<ProceduralPattern> generatePattern({
    required PatternType type,
    ProceduralPatternConfig? config,
    String? name,
    String? description,
    int width = 512,
    int height = 512,
  }) async {
    final finalConfig = config ?? _getDefaultConfig(type);
    final finalName = name ?? _generatePatternName(type);
    final finalDescription = description ?? _generatePatternDescription(type);

    Uint8List? imageData;

    try {
      switch (type) {
        case PatternType.geometric:
          imageData = await _generateGeometricPattern(
            finalConfig,
            width,
            height,
          );
          break;
        case PatternType.noise:
          imageData = await _generateNoisePattern(finalConfig, width, height);
          break;
        case PatternType.fractal:
          imageData = await _generateFractalPattern(finalConfig, width, height);
          break;
        case PatternType.cellular:
          imageData = await _generateCellularPattern(
            finalConfig,
            width,
            height,
          );
          break;
        case PatternType.particle:
          imageData = await _generateParticlePattern(
            finalConfig,
            width,
            height,
          );
          break;
        case PatternType.wave:
          imageData = await _generateWavePattern(finalConfig, width, height);
          break;
        case PatternType.spiral:
          imageData = await _generateSpiralPattern(finalConfig, width, height);
          break;
        case PatternType.mandala:
          imageData = await _generateMandalaPattern(finalConfig, width, height);
          break;
        case PatternType.tessellation:
          imageData = await _generateTessellationPattern(
            finalConfig,
            width,
            height,
          );
          break;
        default:
          imageData = await _generateDefaultPattern(finalConfig, width, height);
      }
    } catch (e) {
      // En cas d'erreur, générer un motif par défaut
      imageData = await _generateDefaultPattern(finalConfig, width, height);
    }

    final pattern = ProceduralPattern(
      id: _generatePatternId(),
      name: finalName,
      description: finalDescription,
      config: finalConfig,
      imageData: imageData,
      createdAt: DateTime.now(),
    );

    _patterns[pattern.id] = pattern;
    return pattern;
  }

  /// Génère une galerie de motifs
  static Future<List<ProceduralPattern>> generateGallery({
    List<PatternType>? types,
    List<ProceduralPatternConfig>? configs,
    int count = 10,
    int width = 256,
    int height = 256,
  }) async {
    final patterns = <ProceduralPattern>[];
    final patternTypes = types ?? PatternType.values.take(8).toList();

    for (var i = 0; i < count; i++) {
      final type = patternTypes[i % patternTypes.length];
      final config = configs?.elementAt(i % configs.length);

      final pattern = await generatePattern(
        type: type,
        config: config,
        width: width,
        height: height,
      );

      patterns.add(pattern);
    }

    return patterns;
  }

  /// Crée un motif géométrique personnalisé
  static ProceduralPatternConfig createGeometricConfig({
    double scale = 1.0,
    int sides = 6,
    double rotation = 0.0,
    double strokeWidth = 2.0,
    bool filled = false,
    double spacing = 1.0,
  }) => ProceduralPatternConfig(
    type: PatternType.geometric,
    scale: scale,
    complexity: sides / 12.0, // Normaliser
    parameters: {
      'sides': sides,
      'rotation': rotation,
      'strokeWidth': strokeWidth,
      'filled': filled,
      'spacing': spacing,
    },
  );

  /// Crée une configuration de motif de bruit
  static ProceduralPatternConfig createNoiseConfig({
    NoiseType noiseType = NoiseType.perlin,
    double frequency = 0.01,
    double amplitude = 1.0,
    int octaves = 4,
    double persistence = 0.5,
    double lacunarity = 2.0,
  }) => ProceduralPatternConfig(
    type: PatternType.noise,
    complexity: persistence,
    parameters: {
      'noiseType': noiseType.name,
      'frequency': frequency,
      'amplitude': amplitude,
      'octaves': octaves,
      'persistence': persistence,
      'lacunarity': lacunarity,
    },
  );

  /// Crée une configuration de motif fractal
  static ProceduralPatternConfig createFractalConfig({
    FractalType fractalType = FractalType.mandelbrot,
    int maxIterations = 100,
    double escapeRadius = 2.0,
    double zoom = 1.0,
    double centerX = 0.0,
    double centerY = 0.0,
  }) => ProceduralPatternConfig(
    type: PatternType.fractal,
    scale: zoom,
    complexity: maxIterations / 100.0,
    parameters: {
      'fractalType': fractalType.name,
      'maxIterations': maxIterations,
      'escapeRadius': escapeRadius,
      'zoom': zoom,
      'centerX': centerX,
      'centerY': centerY,
    },
  );

  /// Génère un motif basé sur des règles L-System
  static Future<ProceduralPattern> generateLSystemPattern({
    required String axiom,
    required Map<String, String> rules,
    int iterations = 4,
    double angle = 25.0,
    double length = 10.0,
    ProceduralPatternConfig? config,
  }) async {
    final finalConfig =
        config ??
        ProceduralPatternConfig(
          type: PatternType.generative,
          parameters: {
            'axiom': axiom,
            'rules': rules,
            'iterations': iterations,
            'angle': angle,
            'length': length,
          },
        );

    // Simulation de génération L-System
    const width = 512;
    const height = 512;

    // En réalité, cette méthode implémenterait un véritable L-System
    final imageData = await _generateLSystemPattern(finalConfig, width, height);

    return ProceduralPattern(
      id: _generatePatternId(),
      name: 'L-System Pattern',
      description: 'Motif généré par système-L',
      config: finalConfig,
      imageData: imageData,
      createdAt: DateTime.now(),
    );
  }

  /// Analyse un motif existant pour extraire ses caractéristiques
  static Map<String, dynamic> analyzePattern(ProceduralPattern pattern) {
    final analysis = <String, dynamic>{};

    // Analyser la couleur dominante
    if (pattern.imageData != null) {
      analysis['dominantColor'] = _getDominantColor(pattern.imageData!);
      analysis['colorPalette'] = _extractColorPalette(pattern.imageData!);
    }

    // Analyser la complexité visuelle
    analysis['visualComplexity'] = _calculateVisualComplexity(
      pattern.imageData,
    );

    // Analyser les motifs répétitifs
    analysis['repetitivePatterns'] = _detectRepetitivePatterns(
      pattern.imageData,
    );

    // Analyser la symétrie
    analysis['symmetry'] = _calculateSymmetry(pattern.imageData);

    analysis['metadata'] = pattern.metadata;
    analysis['config'] = _configToJson(pattern.config);

    return analysis;
  }

  /// Optimise un motif pour les performances
  static Future<ProceduralPattern> optimizePattern(
    ProceduralPattern pattern,
  ) async {
    // Simplifier la configuration si nécessaire
    final optimizedConfig = _simplifyConfig(pattern.config);

    // Régénérer avec la configuration optimisée
    return generatePattern(
      type: pattern.config.type,
      config: optimizedConfig,
      name: pattern.name,
      description: '${pattern.description} (Optimized)',
    );
  }

  /// Convertit un motif en différent formats
  static Future<Map<String, dynamic>> exportPattern(
    ProceduralPattern pattern, {
    List<String> formats = const ['png', 'svg', 'json'],
  }) async {
    final exports = <String, dynamic>{};

    for (final format in formats) {
      switch (format.toLowerCase()) {
        case 'png':
          exports['png'] = await _exportAsPNG(pattern);
          break;
        case 'svg':
          exports['svg'] = await _exportAsSVG(pattern);
          break;
        case 'json':
          exports['json'] = await _exportAsJSON(pattern);
          break;
        case 'css':
          exports['css'] = await _exportAsCSS(pattern);
          break;
        case 'base64':
          exports['base64'] = _exportAsBase64(pattern);
          break;
      }
    }

    return exports;
  }

  /// Applique un filtre à un motif
  static Future<ProceduralPattern> applyFilter(
    ProceduralPattern pattern, {
    String filterType = 'blur',
    double intensity = 0.5,
    Map<String, dynamic> parameters = const {},
  }) async {
    final filteredImageData = await _applyFilterToImageData(
      pattern.imageData!,
      filterType,
      intensity,
      parameters,
    );

    return pattern.copyWith(
      imageData: filteredImageData,
      metadata: Map<String, dynamic>.from(pattern.metadata)
        ..['filter'] = filterType
        ..['filterIntensity'] = intensity
        ..['filterParameters'] = parameters,
    );
  }

  /// Anime un motif procédural
  static Stream<ProceduralPattern> animatePattern({
    required ProceduralPattern initialPattern,
    Duration duration = const Duration(seconds: 5),
    int frames = 30,
    Map<String, dynamic> animationParameters = const {},
  }) {
    final controller = StreamController<ProceduralPattern>();

    _startPatternAnimation(
      controller,
      initialPattern,
      duration,
      frames,
      animationParameters,
    );

    return controller.stream;
  }

  // Méthodes de génération privées

  static Future<Uint8List> _generateGeometricPattern(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);
    final random = Random(config.seed);

    final sides = config.parameters['sides'] as int? ?? 6;
    final rotation = config.parameters['rotation'] as double? ?? 0.0;
    final strokeWidth = config.parameters['strokeWidth'] as double? ?? 2.0;
    final filled = config.parameters['filled'] as bool? ?? false;
    final spacing = config.parameters['spacing'] as double? ?? 1.0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final color = _calculateGeometricColor(
          x,
          y,
          width,
          height,
          sides,
          rotation,
          strokeWidth,
          filled,
          spacing,
          config,
          random,
        );

        final index = (y * width + x) * 4;
        buffer[index] = (color.red * 255).round();
        buffer[index + 1] = (color.green * 255).round();
        buffer[index + 2] = (color.blue * 255).round();
        buffer[index + 3] = (color.alpha * 255).round();
      }
    }

    return buffer;
  }

  static Future<Uint8List> _generateNoisePattern(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);

    final noiseType = config.parameters['noiseType'] as String? ?? 'perlin';
    final frequency = config.parameters['frequency'] as double? ?? 0.01;
    final amplitude = config.parameters['amplitude'] as double? ?? 1.0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final noiseValue = _calculateNoiseValue(
          x / width.toDouble(),
          y / height.toDouble(),
          noiseType,
          frequency,
          amplitude,
          config,
        );

        final color = _lerpColor(
          config.backgroundColor,
          config.primaryColor,
          noiseValue,
        );

        final index = (y * width + x) * 4;
        buffer[index] = (color.red * 255).round();
        buffer[index + 1] = (color.green * 255).round();
        buffer[index + 2] = (color.blue * 255).round();
        buffer[index + 3] = (color.alpha * 255).round();
      }
    }

    return buffer;
  }

  static Future<Uint8List> _generateFractalPattern(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);

    final fractalType =
        config.parameters['fractalType'] as String? ?? 'mandelbrot';
    final maxIterations = config.parameters['maxIterations'] as int? ?? 100;
    final escapeRadius = config.parameters['escapeRadius'] as double? ?? 2.0;
    final zoom = config.scale;
    final centerX = config.parameters['centerX'] as double? ?? 0.0;
    final centerY = config.parameters['centerY'] as double? ?? 0.0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final fractalValue = _calculateFractalValue(
          x / width.toDouble(),
          y / height.toDouble(),
          width,
          height,
          fractalType,
          maxIterations,
          escapeRadius,
          zoom,
          centerX,
          centerY,
        );

        final color = _lerpColor(
          config.backgroundColor,
          config.primaryColor,
          fractalValue,
        );

        final index = (y * width + x) * 4;
        buffer[index] = color.red;
        buffer[index + 1] = color.green;
        buffer[index + 2] = color.blue;
        buffer[index + 3] = color.alpha;
      }
    }

    return buffer;
  }

  static Future<Uint8List> _generateCellularPattern(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);
    final random = Random(config.seed);

    final cellSize = (10.0 * config.scale).round();
    final gridWidth = (width / cellSize).ceil();
    final gridHeight = (height / cellSize).ceil();

    for (var gy = 0; gy < gridHeight; gy++) {
      for (var gx = 0; gx < gridWidth; gx++) {
        final cellX = gx * cellSize;
        final cellY = gy * cellSize;

        final cellValue = _calculateCellularValue(
          cellX / width.toDouble(),
          cellY / height.toDouble(),
          width,
          height,
          config,
          random,
        );

        final color = _lerpColor(
          config.backgroundColor,
          config.primaryColor,
          cellValue,
        );

        // Remplir la cellule
        for (var y = 0; y < cellSize && gy * cellSize + y < height; y++) {
          for (var x = 0; x < cellSize && gx * cellSize + x < width; x++) {
            final index =
                ((gy * cellSize + y) * width + (gx * cellSize + x)) * 4;
            buffer[index] = color.red;
            buffer[index + 1] = color.green;
            buffer[index + 2] = color.blue;
            buffer[index + 3] = color.alpha;
          }
        }
      }
    }

    return buffer;
  }

  Future<Uint8List> _generateParticlePattern(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);
    final random = Random(config.seed);

    // Initialiser les particules
    final particles = <Particle>[];
    final particleCount = (100 * config.density).round();

    for (var i = 0; i < particleCount; i++) {
      particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          vx: (random.nextDouble() - 0.5) * 0.02,
          vy: (random.nextDouble() - 0.5) * 0.02,
          size: random.nextDouble() * 3 + 1,
          life: 1.0,
          color: _lerpColor(
            config.primaryColor,
            config.secondaryColor,
            random.nextDouble(),
          ),
        ),
      );
    }

    // Simuler les particules
    for (var frame = 0; frame < 10; frame++) {
      for (final particle in particles) {
        particle.x += particle.vx;
        particle.y += particle.vy;
        particle.life -= 0.01;

        // Ajouter de la turbulence
        particle.vx += (random.nextDouble() - 0.5) * 0.001;
        particle.vy += (random.nextDouble() - 0.5) * 0.001;

        // Garder les particules dans les limites
        if (particle.x < 0) particle.x = 1.0;
        if (particle.x > 1) particle.x = 0.0;
        if (particle.y < 0) particle.y = 1.0;
        if (particle.y > 1) particle.y = 0.0;
      }
    }

    // Rendre les particules
    for (final particle in particles) {
      final x = (particle.x * width).round();
      final y = (particle.y * height).round();
      final size = particle.size;
      final alpha = (particle.life * 255).round();

      for (var dy = -size.toInt(); dy <= size.toInt(); dy++) {
        for (var dx = -size.toInt(); dx <= size.toInt(); dx++) {
          final px = x + dx;
          final py = y + dy;

          if (px >= 0 && px < width && py >= 0 && py < height) {
            final index = (py * width + px) * 4;

            final distance = sqrt(dx * dx + dy * dy);
            if (distance <= size) {
              final particleAlpha = alpha * (1.0 - distance / size);
              final finalAlpha = (particleAlpha * 255).round();

              final currentColor = Color.fromARGB(
                finalAlpha,
                particle.color.red,
                particle.color.green,
                particle.color.blue,
              );

              buffer[index] = currentColor.red;
              buffer[index + 1] = currentColor.green;
              buffer[index + 2] = currentColor.blue;
              buffer[index + 3] = currentColor.alpha;
            }
          }
        }
      }
    }

    return buffer;
  }

  Future<Uint8List> _generateWavePattern(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);

    final waveType = config.parameters['waveType'] as String? ?? 'sine';
    final frequency = config.parameters['frequency'] as double? ?? 0.1;
    final amplitude = config.parameters['amplitude'] as double? ?? 0.5;
    final phase = config.parameters['phase'] as double? ?? 0.0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final waveValue = _calculateWaveValue(
          x / width.toDouble(),
          y / height.toDouble(),
          waveType,
          frequency,
          amplitude,
          phase,
        );

        final color = _lerpColor(
          config.backgroundColor,
          config.primaryColor,
          waveValue,
        );

        final index = (y * width + x) * 4;
        buffer[index] = color.red;
        buffer[index + 1] = color.green;
        buffer[index + 2] = color.blue;
        buffer[index + 3] = color.alpha;
      }
    }

    return buffer;
  }

  Future<Uint8List> _generateSpiralPattern(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);
    final random = Random(config.seed);

    final centerX = width / 2.0;
    final centerY = height / 2.0;
    final maxRadius = min(centerX, centerY);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final dx = x - centerX;
        final dy = y - centerY;
        final distance = sqrt(dx * dx + dy * dy);

        final angle = atan2(dy, dx);
        final spiralValue = _calculateSpiralValue(
          distance,
          angle,
          maxRadius,
          config,
          random,
        );

        final color = _lerpColor(
          config.backgroundColor,
          config.primaryColor,
          spiralValue,
        );

        final index = (y * width + x) * 4;
        buffer[index] = color.red;
        buffer[index + 1] = color.green;
        buffer[index + 2] = color.blue;
        buffer[index + 3] = color.alpha;
      }
    }

    return buffer;
  }

  Future<Uint8List> _generateMandalaPattern(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);
    final random = Random(config.seed);

    final centerX = width / 2.0;
    final centerY = height / 2.0;
    final maxRadius = min(centerX, centerY);
    final layers = (config.complexity * 8).round();

    for (var layer = 0; layer < layers; layer++) {
      final layerRadius = maxRadius * (layer + 1) / layers;
      final elements =
          6 + layer * 2; // Augmenter le nombre d'éléments par couche

      for (var i = 0; i < elements; i++) {
        final angle = (2 * pi * i) / elements + (layer * pi / 12);
        final x = centerX + cos(angle) * layerRadius;
        final y = centerY + sin(angle) * layerRadius;

        final mandalaValue = _calculateMandalaValue(
          x / width.toDouble(),
          y / height.toDouble(),
          layer,
          layers,
          config,
          random,
        );

        final color = _lerpColor(
          config.backgroundColor,
          _lerpColor(
            config.primaryColor,
            config.secondaryColor,
            layer / layers,
          ),
          mandalaValue,
        );

        final px = x.round();
        final py = y.round();

        if (px >= 0 && px < width && py >= 0 && py < height) {
          final index = (py * width + px) * 4;
          buffer[index] = color.red;
          buffer[index + 1] = color.green;
          buffer[index + 2] = color.blue;
          buffer[index + 3] = color.alpha;
        }
      }
    }

    return buffer;
  }

  Future<Uint8List> _generateTessellationPattern(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);
    final random = Random(config.seed);

    final tessellationType =
        config.parameters['tessellationType'] as String? ?? 'triangular';

    switch (tessellationType) {
      case 'triangular':
        return _generateTriangularTessellation(config, width, height);
      case 'square':
        return _generateSquareTessellation(config, width, height);
      case 'hexagonal':
        return _generateHexagonalTessellation(config, width, height);
      default:
        return _generateTriangularTessellation(config, width, height);
    }
  }

  Future<Uint8List> _generateDefaultPattern(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);

    final random = Random(config.seed);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final value = random.nextDouble();
        final color = _lerpColor(
          config.backgroundColor,
          config.primaryColor,
          value,
        );

        final index = (y * width + x) * 4;
        buffer[index] = color.red;
        buffer[index + 1] = color.green;
        buffer[index + 2] = color.blue;
        buffer[index + 3] = color.alpha;
      }
    }

    return buffer;
  }

  Future<Uint8List> _generateLSystemPattern(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);

    // Simulation d'un L-System
    final axiom = config.parameters['axiom'] as String;
    final rules = config.parameters['rules'] as Map<String, String>;
    final iterations = config.parameters['iterations'] as int? ?? 4;
    final angle = config.parameters['angle'] as double? ?? 25.0;
    final length = config.parameters['length'] as double? ?? 10.0;

    // En réalité, implémenterait un véritable moteur L-System
    // Pour l'instant, générer un motif simple

    return buffer;
  }

  // Méthodes utilitaires

  Color _lerpColor(Color color1, Color color2, double t) => Color.fromARGB(
    (color1.alpha + (color2.alpha - color1.alpha) * t).round().clamp(0, 255),
    (color1.red + (color2.red - color1.red) * t).round().clamp(0, 255),
    (color1.green + (color2.green - color1.green) * t).round().clamp(0, 255),
    (color1.blue + (color2.blue - color1.blue) * t).round().clamp(0, 255),
  );

  Color _calculateGeometricColor(
    int x,
    int y,
    int width,
    int height,
    int sides,
    double rotation,
    double strokeWidth,
    bool filled,
    double spacing,
    ProceduralPatternConfig config,
    Random random,
  ) {
    final centerX = width / 2.0;
    final centerY = height / 2.0;
    final dx = x - centerX;
    final dy = y - centerY;
    final distance = sqrt(dx * dx + dy * dy);
    final angle = atan2(dy, dx) + rotation * pi / 180;

    final segmentAngle = (2 * pi) / sides;
    final segmentIndex =
        ((angle + segmentAngle / 2) / segmentAngle).floor() % sides;
    final localAngle = angle - segmentIndex * segmentAngle;

    if (distance < 0.5 * spacing) {
      if (filled) {
        return config.primaryColor;
      } else {
        final proximity = 1.0 - (distance / (0.5 * spacing));
        return Color.lerp(
              config.primaryColor,
              config.secondaryColor,
              proximity,
            ) ??
            config.primaryColor;
      }
    } else {
      return config.backgroundColor;
    }
  }

  double _calculateNoiseValue(
    double x,
    double y,
    String noiseType,
    double frequency,
    double amplitude,
    ProceduralPatternConfig config,
  ) {
    switch (noiseType) {
      case 'perlin':
        return _perlinNoise(x * frequency, y * frequency, config.seed) *
            amplitude;
      case 'simplex':
        return _simplexNoise(x * frequency, y * frequency, config.seed) *
            amplitude;
      case 'worley':
        return _worleyNoise(x * frequency, y * frequency, config.seed) *
            amplitude;
      case 'value':
        return _valueNoise(x * frequency, y * frequency, config.seed) *
            amplitude;
      default:
        return _perlinNoise(x * frequency, y * frequency, config.seed) *
            amplitude;
    }
  }

  double _perlinNoise(double x, double y, int seed) {
    final X = (x + seed * 37.0) * 0.0625;
    final Y = (y + seed * 57.0) * 0.0625;
    return _perlinNoise2(X, Y, seed) * 0.5 + 0.5;
  }

  double _perlinNoise2(double x, double y, int seed) {
    final a = x + y;
    final b = x - y;
    final c = 2.0 * y + seed;
    final d = (a + b) * 0.5;
    final e = (a - b) * 0.5;
    final f = (c + d) * 0.5;
    final g = (e + f) * 0.5;
    final h = (f + g) * 0.5;
    final i = (g + h) * 0.5;
    return (i + (i / 256) * 0.987 + (i / 262144)) * 0.987 +
        (i / 67108864.0) * 0.987;
  }

  double _simplexNoise(double x, double y, int seed) {
    // Simulation du bruit Simplex
    return _perlinNoise(x, y, seed);
  }

  double _worleyNoise(double x, double y, int seed) {
    // Simulation du bruit Worley
    final i = (x + seed * 73.0) * 0.36;
    final j = (y + seed * 37.0) * 0.46;
    final k = i + j;
    return (k % 1000) / 1000.0;
  }

  double _valueNoise(double x, double y, int seed) {
    // Simulation du bruit de valeur
    final i = (x + seed * 13.0) * 0.26;
    final j = (y + seed * 17.0) * 0.31;
    return sin(i * pi) * cos(j * pi) * 0.5 + 0.5;
  }

  double _calculateFractalValue(
    double x,
    double y,
    int width,
    int height,
    String fractalType,
    int maxIterations,
    double escapeRadius,
    double zoom,
    double centerX,
    double centerY,
  ) {
    switch (fractalType) {
      case 'mandelbrot':
        return _mandelbrot(
          x,
          y,
          width,
          height,
          maxIterations,
          escapeRadius,
          zoom,
          centerX,
          centerY,
        );
      case 'julia':
        return _julia(
          x,
          y,
          width,
          height,
          maxIterations,
          escapeRadius,
          zoom,
          centerX,
          centerY,
        );
      case 'sierpinski':
        return _sierpinski(
          x,
          y,
          width,
          height,
          maxIterations,
          escapeRadius,
          zoom,
          centerX,
          centerY,
        );
      default:
        return _mandelbrot(
          x,
          y,
          width,
          height,
          maxIterations,
          escapeRadius,
          zoom,
          centerX,
          centerY,
        );
    }
  }

  double _mandelbrot(
    double x,
    double y,
    int width,
    int height,
    int maxIterations,
    double escapeRadius,
    double zoom,
    double centerX,
    double centerY,
  ) {
    // Adapter les coordonnées pour le centre
    final zx = (x - 0.5) * zoom * 4.0 - 2.0;
    final zy = (y - 0.5) * zoom * 4.0 - 2.0;

    var zr = 0.0;
    var zi = 0.0;

    for (var i = 0; i < maxIterations; i++) {
      final temp = zr * zr - zi * zi + zx;
      zi = 2.0 * zr * zi + zy;
      zr = temp;

      if (zr * zr + zi * zi > escapeRadius * escapeRadius) {
        return i / maxIterations.toDouble();
      }
    }

    return 0.0;
  }

  double _julia(
    double x,
    double y,
    int width,
    int height,
    int maxIterations,
    double escapeRadius,
    double zoom,
    double centerX,
    double centerY,
  ) {
    // Simulation d'ensemble de Julia
    final cx = centerX;
    final cy = centerY;
    final zx = (x - 0.5) * zoom * 4.0 - 2.0;
    final zy = (y - 0.5) * zoom * 4.0 - 2.0;

    final zx2 = zx * zx - zy * zy;
    final zy2 = 2.0 * zx * zy + cy;

    var zr = 0.0;
    var zi = 0.0;

    for (var i = 0; i < maxIterations; i++) {
      zi = zr * zi - zy2 + cx;
      zr = 2.0 * zi * zi - zx2;
      zi = zi + zi;

      if (zi * zi + zr * zr > escapeRadius * escapeRadius) {
        return i / maxIterations.toDouble();
      }
    }

    return 0.0;
  }

  double _sierpinski(
    double x,
    double y,
    int width,
    int height,
    int maxIterations,
    double escapeRadius,
    double zoom,
    double centerX,
    double centerY,
  ) {
    // Simulation du triangle de Sierpinski
    return (x + y) / (width + height) * zoom;
  }

  double _calculateCellularValue(
    double x,
    double y,
    int width,
    int height,
    ProceduralPatternConfig config,
    Random random,
  ) {
    final cellX = (x * 20).floor();
    final cellY = (y * 20).floor();

    final hash = _hash(cellX, cellY, config.seed);
    return (hash % 1000) / 1000.0;
  }

  double _calculateCellularValue2(double x, double y, int width, int height) {
    final cellX = (x * 10).floor();
    final cellY = (y * 10).floor();

    // Distance au point le plus proche
    final distances = <double>[];
    for (var i = -1; i <= 1; i++) {
      for (var j = -1; j <= 1; j++) {
        final neighborX = cellX + i;
        final neighborY = cellY + j;
        final distance = sqrt(
          pow(neighborX - x * 10, 2) + pow(neighborY - y * 10, 2),
        );
        distances.add(distance);
      }
    }

    distances.sort();
    return distances.first;
  }

  int _hash(int x, int y, int seed) {
    var h = seed;
    h ^= x + 0x9e3779b97; // 32-bit FNV-1a prime
    h ^= h >> 16;
    h ^= h >> 8;
    h ^= y;
    return h;
  }

  double _calculateWaveValue(
    double x,
    double y,
    String waveType,
    double frequency,
    double amplitude,
    double phase,
  ) {
    switch (waveType) {
      case 'sine':
        return sin(2 * pi * frequency * x + phase) * amplitude;
      case 'cosine':
        return cos(2 * pi * frequency * x + phase) * amplitude;
      case 'tangent':
        return tan(2 * pi * frequency * x + phase) * amplitude;
      case 'square':
        return sin(2 * pi * frequency * x + phase) *
            amplitude *
            sin(2 * pi * frequency * y + phase) *
            amplitude;
      default:
        return sin(2 * pi * frequency * x + phase) * amplitude;
    }
  }

  double _calculateSpiralValue(
    double distance,
    double angle,
    double maxRadius,
    ProceduralPatternConfig config,
    Random random,
  ) {
    final spiralTight = 1.0 - (distance / maxRadius);
    final rotationOffset = angle / (2 * pi);

    return (sin(rotationOffset * 4 * pi) * 0.5 + 0.5) * spiralTight;
  }

  double _calculateMandalaValue(
    double x,
    double y,
    int layer,
    int totalLayers,
    ProceduralPatternConfig config,
    Random random,
  ) {
    const centerX = 0.5;
    const centerY = 0.5;
    final dx = x - centerX;
    final dy = y - centerY;
    final distance = sqrt(dx * dx + dy * dy);

    final layerProgress = layer / totalLayers;
    final rotation = (distance * 20) + (layer * pi / 12);

    final pattern = sin(rotation) * 0.5 + 0.5;
    final noise =
        _perlinNoise(distance * 0.1, dy * 0.1, config.seed + layer) * 0.2;

    return (pattern + noise) * 0.5 + 0.5;
  }

  // Méthodes d'exportation

  Future<Uint8List> _exportAsPNG(ProceduralPattern pattern) async =>
      pattern.imageData ?? Uint8List(0);

  Future<String> _exportAsSVG(ProceduralPattern pattern) async {
    if (pattern.imageData == null) return '';

    final width = sqrt(pattern.imageData!.length / 4).round();
    final height = width;

    final buffer = StringBuffer();
    buffer.writeln(
      '<svg width="$width" height="$height" xmlns="http://www.w3.org/2000/svg">',
    );

    for (var y = 0; y < height; y++) {
      buffer.writeln(
        '<rect width="$width" height="1" y="$y" fill="none" stroke="none" />',
      );
    }

    buffer.writeln('</svg>');

    return buffer.toString();
  }

  Future<Map<String, dynamic>> _exportAsJSON(ProceduralPattern pattern) async =>
      pattern.toJson();

  Future<String> _exportAsCSS(ProceduralPattern pattern) async =>
      '''
        .procedural-pattern {
          background-image: url('data:image/png;base64,${_exportAsBase64(pattern)}');
          background-size: cover;
        }
      ''';

  String _exportAsBase64(ProceduralPattern pattern) {
    if (pattern.imageData == null) return '';

    // En réalité, convertirait les données image en base64
    return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAQCAAAAAAA';
  }

  // Méthodes d'analyse

  Color _getDominantColor(Uint8List imageData) {
    final colorCounts = <Color, int>{};

    for (var i = 0; i < imageData.length; i += 4) {
      final color = Color.fromARGB(
        imageData[i + 3],
        imageData[i],
        imageData[i + 1],
        imageData[i + 2],
      );

      colorCounts[color] = (colorCounts[color] ?? 0) + 1;
    }

    if (colorCounts.isEmpty) return Colors.black;

    var dominantColor = Colors.black;
    var maxCount = 0;

    for (final entry in colorCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        dominantColor = entry.key;
      }
    }

    return dominantColor;
  }

  List<Color> _extractColorPalette(Uint8List imageData) {
    final colors = <Color>{};
    final colorSet = <Color>{};

    for (var i = 0; i < imageData.length; i += 4) {
      final color = Color.fromARGB(
        imageData[i + 3],
        imageData[i],
        imageData[i + 1],
        imageData[i + 2],
      );

      if (colorSet.add(color)) {
        colors.add(color);
      }
    }

    return colors.take(10).toList();
  }

  double _calculateVisualComplexity(Uint8List? imageData) {
    if (imageData == null) return 0.0;

    var edgeCount = 0;
    final width = sqrt(imageData.length / 4).round();

    for (var y = 1; y < width - 1; y++) {
      for (var x = 1; x < width - 1; x++) {
        final currentColor = Color.fromARGB(
          imageData[(y * width + x) * 4 + 3],
          imageData[(y * width + x) * 4],
          imageData[(y * width + x) * 4 + 1],
          imageData[(y * width + x) * 4 + 2],
        );

        final leftColor = Color.fromARGB(
          imageData[(y * width + x - 1) * 4 + 3],
          imageData[(y * width + x - 1) * 4],
          imageData[(y * width + x - 1) * 4 + 1],
          imageData[(y * width + x - 1) * 4 + 2],
        );

        if (_colorsDiffer(currentColor, leftColor)) {
          edgeCount++;
        }
      }
    }

    return edgeCount / (width * height * 2);
  }

  bool _colorsDiffer(Color color1, Color color2) =>
      color1.value != color2.value;

  Map<String, dynamic> _detectRepetitivePatterns(Uint8List? imageData) {
    if (imageData == null) return {};

    final patterns = <String, dynamic>{};

    // Simulation de détection de motifs répétitifs
    // En réalité, implémenterait des algorithmes de détection

    return patterns;
  }

  double _calculateSymmetry(Uint8List? imageData) {
    if (imageData == null) return 0.0;

    final width = sqrt(imageData.length / 4).round();
    final height = width;
    var symmetryScore = 0;

    // Vérifier la symétrie horizontale simplifiée
    for (var y = 0; y < height ~/ 2; y++) {
      for (var x = 0; x < width ~/ 2; x++) {
        final leftIndex = (y * width + x) * 4;
        final rightIndex = (y * width + (width - 1 - x)) * 4;

        if (leftIndex + 3 < imageData.length &&
            rightIndex + 3 < imageData.length) {
          final leftColor = Color.fromARGB(
            imageData[leftIndex + 3],
            imageData[leftIndex],
            imageData[leftIndex + 1],
            imageData[leftIndex + 2],
          );

          final rightColor = Color.fromARGB(
            imageData[rightIndex + 3],
            imageData[rightIndex],
            imageData[rightIndex + 1],
            imageData[rightIndex + 2],
          );

          if (_colorsSimilar(leftColor, rightColor)) {
            symmetryScore++;
          }
        }
      }
    }

    return symmetryScore / ((width ~/ 2) * (height ~/ 2));
  }

  bool _colorsSimilar(Color color1, Color color2) {
    // Simulation de comparaison de couleurs
    final dr = (color1.red - color2.red).abs();
    final dg = (color1.green - color2.green).abs();
    final db = (color1.blue - color2.blue).abs();
    return (dr + dg + db) < 30;
  }

  ProceduralPatternConfig _simplifyConfig(ProceduralPatternConfig config) =>
      config.copyWith(
        complexity: (config.complexity * 0.8).clamp(0.1, 1.0),
        randomness: (config.randomness * 0.8).clamp(0.0, 1.0),
        density: (config.density * 0.8).clamp(0.1, 2.0),
      );

  Future<Uint8List> _applyFilterToImageData(
    Uint8List imageData,
    String filterType,
    double intensity,
    Map<String, dynamic> parameters,
  ) async {
    final width = sqrt(imageData.length / 4).round();
    final height = width;
    final filtered = Uint8List(width * height * 4);

    switch (filterType.toLowerCase()) {
      case 'blur':
        return _applyBlurFilter(
          imageData,
          width,
          height,
          intensity,
          parameters,
        );
      case 'sharpen':
        return _applySharpenFilter(
          imageData,
          width,
          height,
          intensity,
          parameters,
        );
      case 'edge':
        return _applyEdgeDetection(imageData, width, height, parameters);
      case 'emboss':
        return _applyEmbossFilter(
          imageData,
          width,
          height,
          intensity,
          parameters,
        );
      default:
        return imageData;
    }
  }

  Uint8List _applyBlurFilter(
    Uint8List imageData,
    int width,
    int height,
    double intensity,
    Map<String, dynamic> parameters,
  ) {
    // Implémentation simplifiée du flou
    final filtered = Uint8List.fromList(imageData);
    return filtered;
  }

  List<double> _createGaussianKernel(int size) {
    final kernel = <double>[];
    final sigma = size / 6.0;
    var sum = 0.0;

    for (var i = -size; i <= size; i++) {
      final weight = exp(-(i * i) / (2 * sigma * sigma));
      kernel.add(weight);
      sum += weight;
    }

    // Normaliser le noyau
    for (var i = 0; i < kernel.length; i++) {
      kernel[i] /= sum;
    }

    return kernel;
  }

  Uint8List _applySharpenFilter(
    Uint8List imageData,
    int width,
    int height,
    double intensity,
    Map<String, dynamic> parameters,
  ) {
    // Implementation simplifiée du filtre de netteté
    return imageData;
  }

  Uint8List _applyEdgeDetection(
    Uint8List imageData,
    int width,
    int height,
    Map<String, dynamic> parameters,
  ) {
    // Implementation simplifiée de détection d'arêtes
    return imageData;
  }

  Uint8List _applyEmbossFilter(
    Uint8List imageData,
    int width,
    int height,
    double intensity,
    Map<String, dynamic> parameters,
  ) {
    // Implementation simplifiée d'effet de relief
    return imageData;
  }

  // Méthodes utilitaires

  String _generatePatternId() =>
      'pattern_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';

  String _generatePatternName(PatternType type) {
    switch (type) {
      case PatternType.geometric:
        return 'Geometric Pattern';
      case PatternType.noise:
        return 'Noise Pattern';
      case PatternType.fractal:
        return 'Fractal Pattern';
      case PatternType.cellular:
        return 'Cellular Pattern';
      case PatternType.particle:
        return 'Particle Pattern';
      case PatternType.wave:
        return 'Wave Pattern';
      case PatternType.spiral:
        return 'Spiral Pattern';
      case PatternType.mandala:
        return 'Mandala Pattern';
      case PatternType.tessellation:
        return 'Tessellation Pattern';
      case PatternType.procedural:
        return 'Procedural Pattern';
      case PatternType.organic:
        return 'Organic Pattern';
      default:
        return 'Generated Pattern';
    }
  }

  String _generatePatternDescription(PatternType type) {
    switch (type) {
      case PatternType.geometric:
        return 'Géométrique: formes basiques créées algorithmiquement';
      case PatternType.noise:
        return 'Bruit: motifs basés sur le bruit algorithmique';
      case PatternType.fractal:
        return 'Fractal: motifs mathématiques auto-similaires';
      case PatternType.cellular:
        return 'Cellulaire: motifs basés sur des grilles cellulaires';
      case PatternType.particle:
        return 'Particules: simulation de particules';
      case PatternType.wave:
        return 'Ondulation: motifs basés sur des fonctions d\'onde';
      case PatternType.spiral:
        return 'Spirale: motifs en spirale logarithmique';
      case PatternType.mandala:
        return 'Mandala: motifs symétriques circulaires';
      case PatternType.tessellation:
        return 'Tessellation: motifs qui remplissent l\'espace';
      case PatternType.procedural:
        return 'Procédural: motifs générés par algorithmes';
      case PatternType.organic:
        return 'Organique: motifs fluides et naturels';
      default:
        return 'Généré: motif créé par algorithme';
    }
  }

  ProceduralPatternConfig _getDefaultConfig(PatternType type) {
    switch (type) {
      case PatternType.geometric:
        return const ProceduralPatternConfig(
          type: PatternType.geometric,
          scale: 1.0,
          complexity: 0.5,
          density: 1.0,
          randomness: 0.1,
          primaryColor: Colors.blue,
          secondaryColor: Colors.green,
          backgroundColor: Colors.white,
          parameters: {
            'sides': 6,
            'rotation': 0.0,
            'strokeWidth': 2.0,
            'filled': false,
            'spacing': 1.0,
          },
        );
      case PatternType.noise:
        return const ProceduralPatternConfig(
          type: PatternType.noise,
          scale: 1.0,
          complexity: 0.5,
          density: 1.0,
          randomness: 0.1,
          primaryColor: Colors.blue,
          secondaryColor: Colors.green,
          backgroundColor: Colors.white,
          parameters: {
            'noiseType': 'perlin',
            'frequency': 0.01,
            'amplitude': 1.0,
            'octaves': 4,
            'persistence': 0.5,
            'lacunarity': 2.0,
          },
        );
      case PatternType.fractal:
        return const ProceduralPatternConfig(
          type: PatternType.fractal,
          scale: 1.0,
          complexity: 0.7,
          density: 1.0,
          randomness: 0.05,
          primaryColor: Colors.blue,
          secondaryColor: Colors.purple,
          backgroundColor: Colors.white,
          parameters: {
            'fractalType': 'mandelbrot',
            'maxIterations': 100,
            'escapeRadius': 2.0,
            'zoom': 1.0,
            'centerX': 0.0,
            'centerY': 0.0,
          },
        );
      default:
        return const ProceduralPatternConfig();
    }
  }

  // Méthodes d'animation

  void _startPatternAnimation(
    StreamController<ProceduralPattern> controller,
    ProceduralPattern initialPattern,
    Duration duration,
    int frames,
    Map<String, dynamic> parameters,
  ) {
    Timer.periodic(duration ~/ frames, (timer) async {
      final frame = timer.tick;
      final progress = frame / frames;

      // Créer une variation du motif
      final variedConfig = _animatePatternConfig(
        initialPattern.config,
        progress,
        parameters,
      );

      final variedPattern = await ProceduralPatternService.generatePattern(
        type: initialPattern.config.type,
        config: variedConfig,
        width: 512,
        height: 512,
      );

      controller.add(variedPattern);

      if (frame >= frames - 1) {
        controller.close();
      }
    });
  }

  ProceduralPatternConfig _animatePatternConfig(
    ProceduralPatternConfig baseConfig,
    double progress,
    Map<String, dynamic> animationParameters,
  ) {
    // Animation basée sur le temps
    final time = progress;

    return baseConfig.copyWith(
      scale: baseConfig.scale * (1.0 + sin(time * 2 * pi) * 0.2),
      randomness: baseConfig.randomness * (0.5 + sin(time * 4 * pi) * 0.3),
    );
  }

  /// Dispose le service
  void dispose() {
    _patterns.clear();
  }

  // Méthodes utilitaires pour la configuration
  ProceduralPatternConfig _configFromJson(Map<String, dynamic> json) =>
      ProceduralPatternConfig(
        type: PatternType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => PatternType.geometric,
        ),
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        complexity: (json['complexity'] as num?)?.toDouble() ?? 0.5,
        density: (json['density'] as num?)?.toDouble() ?? 1.0,
        randomness: (json['randomness'] as num?)?.toDouble() ?? 0.1,
        primaryColor: Color(json['primaryColor'] as int? ?? 0xFF0000FF),
        secondaryColor: Color(json['secondaryColor'] as int? ?? 0xFF00FF00),
        backgroundColor: Color(json['backgroundColor'] as int? ?? 0xFFFFFFFF),
        parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
        seed: json['seed'] as int? ?? 0,
      );

  Map<String, dynamic> _configToJson(ProceduralPatternConfig config) => {
    'type': config.type.name,
    'scale': config.scale,
    'complexity': config.complexity,
    'density': config.density,
    'randomness': config.randomness,
    'primaryColor': config.primaryColor.value,
    'secondaryColor': config.secondaryColor.value,
    'backgroundColor': config.backgroundColor.value,
    'parameters': config.parameters,
    'seed': config.seed,
  };

  // Méthodes de génération de tessellation
  Future<Uint8List> _generateTriangularTessellation(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async {
    final buffer = Uint8List(width * height * 4);
    // Implémentation simplifiée
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final index = (y * width + x) * 4;
        final color = ((x + y) % 2 == 0)
            ? config.primaryColor
            : config.secondaryColor;
        buffer[index] = (color.red * 255).round();
        buffer[index + 1] = (color.green * 255).round();
        buffer[index + 2] = (color.blue * 255).round();
        buffer[index + 3] = (color.alpha * 255).round();
      }
    }
    return buffer;
  }

  Future<Uint8List> _generateSquareTessellation(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async => _generateTriangularTessellation(config, width, height);

  Future<Uint8List> _generateHexagonalTessellation(
    ProceduralPatternConfig config,
    int width,
    int height,
  ) async => _generateTriangularTessellation(config, width, height);
}

class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.life,
    required this.color,
  });
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double life;
  Color color;
}

class PatternPainter extends CustomPainter {
  const PatternPainter({required this.pattern});
  final ProceduralPattern pattern;

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern.imageData == null) return;

    // Pour l'instant, dessiner un rectangle simple
    final paint = Paint()
      ..color = pattern.config.primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant oldDelegate) => false;
}

class AnimatedPatternWidget extends StatefulWidget {
  const AnimatedPatternWidget({
    super.key,
    required this.pattern,
    this.duration = const Duration(seconds: 3),
    this.curve = Curves.easeInOut,
    this.reverse = false,
  });

  final ProceduralPattern pattern;
  final Duration duration;
  final Curve curve;
  final bool reverse;

  @override
  State<AnimatedPatternWidgetState> createState() =>
      _AnimatedPatternWidgetState();
}

class _AnimatedPatternWidgetState extends State<AnimatedPatternWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ProceduralPattern _currentPattern;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    _currentPattern = widget.pattern;

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder: (context, child) => CustomPaint(
      painter: PatternPainter(pattern: _currentPattern),
      child: child,
    ),
  );
}
