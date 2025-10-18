/// Service de tests A/B pour les thèmes
library;
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TestStatus {
  draft,            // Brouillon
  active,           // Actif
  paused,           // En pause
  completed,        // Terminé
  cancelled,        // Annulé
}

enum TestType {
  themeComparison, // Comparaison de thèmes
  colorVariation,   // Variation de couleurs
  layoutTest,       // Test de mise en page
  fontTest,         // Test de police
  animationTest,    // Test d'animation
  featureTest,      // Test de fonctionnalité
  conversionTest,   // Test de conversion
}

enum AllocationMethod {
  random,           // Aléatoire
  weighted,         // Pondéré
  sequential,       // Séquentiel
  userSegment,      // Segment utilisateur
  custom,           // Personnalisé
}

class ABTestVariant {

  const ABTestVariant({
    required this.id,
    required this.name,
    required this.description,
    required this.theme,
    this.weight = 1,
    this.isActive = true,
    this.metadata = const {},
  });

  factory ABTestVariant.fromJson(Map<String, dynamic> json) => ABTestVariant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      theme: EventThemeCustomization.fromJson(json['theme']),
      weight: json['weight'] ?? 1,
      isActive: json['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  final String id;
  final String name;
  final String description;
  final EventThemeCustomization theme;
  final int weight;
  final bool isActive;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'description': description,
      'theme': theme.toJson(),
      'weight': weight,
      'isActive': isActive,
      'metadata': metadata,
    };
}

class ABTest {

  const ABTest({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.variants,
    required this.allocationMethod,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.targetSampleSize = 1000,
    this.currentSampleSize = 0,
    this.confidenceLevel = 0.95,
    this.minTestDuration = const Duration(days: 7),
    this.settings = const {},
    this.targetMetrics = const [],
    this.hypothesis = const {},
  });

  factory ABTest.fromJson(Map<String, dynamic> json) => ABTest(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: TestType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TestType.themeComparison,
      ),
      variants: (json['variants'] as List)
          .map((v) => ABTestVariant.fromJson(v))
          .toList(),
      allocationMethod: AllocationMethod.values.firstWhere(
        (e) => e.name == json['allocationMethod'],
        orElse: () => AllocationMethod.random,
      ),
      status: TestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TestStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'])
          : null,
      targetSampleSize: json['targetSampleSize'] ?? 1000,
      currentSampleSize: json['currentSampleSize'] ?? 0,
      confidenceLevel: (json['confidenceLevel'] ?? 0.95).toDouble(),
      minTestDuration: Duration(
        milliseconds: json['minTestDuration'] ?? 604800000, // 7 jours
      ),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      targetMetrics: List<String>.from(json['targetMetrics'] ?? []),
      hypothesis: Map<String, dynamic>.from(json['hypothesis'] ?? {}),
    );
  final String id;
  final String name;
  final String description;
  final TestType type;
  final List<ABTestVariant> variants;
  final AllocationMethod allocationMethod;
  final TestStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int targetSampleSize;
  final int currentSampleSize;
  final double confidenceLevel;
  final Duration minTestDuration;
  final Map<String, dynamic> settings;
  final List<String> targetMetrics;
  final Map<String, dynamic> hypothesis;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'variants': variants.map((v) => v.toJson()).toList(),
      'allocationMethod': allocationMethod.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'targetSampleSize': targetSampleSize,
      'currentSampleSize': currentSampleSize,
      'confidenceLevel': confidenceLevel,
      'minTestDuration': minTestDuration.inMilliseconds,
      'settings': settings,
      'targetMetrics': targetMetrics,
      'hypothesis': hypothesis,
    };

  ABTest copyWith({
    String? id,
    String? name,
    String? description,
    TestType? type,
    List<ABTestVariant>? variants,
    AllocationMethod? allocationMethod,
    TestStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    int? targetSampleSize,
    int? currentSampleSize,
    double? confidenceLevel,
    Duration? minTestDuration,
    Map<String, dynamic>? settings,
    List<String>? targetMetrics,
    Map<String, dynamic>? hypothesis,
  }) => ABTest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      variants: variants ?? this.variants,
      allocationMethod: allocationMethod ?? this.allocationMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      targetSampleSize: targetSampleSize ?? this.targetSampleSize,
      currentSampleSize: currentSampleSize ?? this.currentSampleSize,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      minTestDuration: minTestDuration ?? this.minTestDuration,
      settings: settings ?? this.settings,
      targetMetrics: targetMetrics ?? this.targetMetrics,
      hypothesis: hypothesis ?? this.hypothesis,
    );
}

class ABTestResult {

  const ABTestResult({
    required this.testId,
    required this.winnerVariantId,
    required this.variantScores,
    required this.statistics,
    required this.confidence,
    required this.completedAt,
    required this.recommendations,
  });
  final String testId;
  final String winnerVariantId;
  final Map<String, double> variantScores;
  final Map<String, dynamic> statistics;
  final Map<String, dynamic> confidence;
  final DateTime completedAt;
  final List<String> recommendations;
}

class ABTestSession {

  const ABTestSession({
    required this.id,
    required this.userId,
    required this.testId,
    required this.variantId,
    required this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.interactions = const {},
    this.metrics = const {},
    this.isConverted = false,
  });

  factory ABTestSession.fromJson(Map<String, dynamic> json) => ABTestSession(
      id: json['id'],
      userId: json['userId'],
      testId: json['testId'],
      variantId: json['variantId'],
      assignedAt: DateTime.parse(json['assignedAt']),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      interactions: Map<String, dynamic>.from(json['interactions'] ?? {}),
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
      isConverted: json['isConverted'] ?? false,
    );
  final String id;
  final String userId;
  final String testId;
  final String variantId;
  final DateTime assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> interactions;
  final Map<String, dynamic> metrics;
  final bool isConverted;

  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'testId': testId,
      'variantId': variantId,
      'assignedAt': assignedAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'interactions': interactions,
      'metrics': metrics,
      'isConverted': isConverted,
    };

  ABTestSession copyWith({
    String? id,
    String? userId,
    String? testId,
    String? variantId,
    DateTime? assignedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? interactions,
    Map<String, dynamic>? metrics,
    bool? isConverted,
  }) => ABTestSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      testId: testId ?? this.testId,
      variantId: variantId ?? this.variantId,
      assignedAt: assignedAt ?? this.assignedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      interactions: interactions ?? this.interactions,
      metrics: metrics ?? this.metrics,
      isConverted: isConverted ?? this.isConverted,
    );
}

class ThemeABTestingService {
  static const String _testsKey = 'ab_tests';
  static const String _sessionsKey = 'ab_test_sessions';
  static const String _assignmentsKey = 'ab_test_assignments';

  static final List<ABTest> _tests = [];
  static final List<ABTestSession> _sessions = [];
  static final Map<String, String> _userAssignments = {};

  /// Initialise le service de tests A/B
  static Future<void> initialize() async {
    await _loadTests();
    await _loadSessions();
    await _cleanupCompletedTests();
  }

  /// Crée un nouveau test A/B
  static Future<ABTest> createTest({
    required String name,
    required String description,
    required TestType type,
    required List<ABTestVariant> variants,
    AllocationMethod allocationMethod = AllocationMethod.random,
    int targetSampleSize = 1000,
    double confidenceLevel = 0.95,
    Duration minTestDuration = const Duration(days: 7),
    Map<String, dynamic> settings = const {},
    List<String> targetMetrics = const [],
    Map<String, dynamic> hypothesis = const {},
  }) async {
    final test = ABTest(
      id: _generateTestId(),
      name: name,
      description: description,
      type: type,
      variants: variants,
      allocationMethod: allocationMethod,
      status: TestStatus.draft,
      createdAt: DateTime.now(),
      targetSampleSize: targetSampleSize,
      confidenceLevel: confidenceLevel,
      minTestDuration: minTestDuration,
      settings: settings,
      targetMetrics: targetMetrics,
      hypothesis: hypothesis,
    );

    _tests.add(test);
    await _saveTests();

    return test;
  }

  /// Démarre un test A/B
  static Future<void> startTest(String testId) async {
    final testIndex = _tests.indexWhere((t) => t.id == testId);
    if (testIndex == -1) return;

    final test = _tests[testIndex];
    final updatedTest = test.copyWith(
      status: TestStatus.active,
      startedAt: DateTime.now(),
    );

    _tests[testIndex] = updatedTest;
    await _saveTests();
  }

  /// Met en pause un test A/B
  static Future<void> pauseTest(String testId) async {
    final testIndex = _tests.indexWhere((t) => t.id == testId);
    if (testIndex == -1) return;

    final test = _tests[testIndex];
    final updatedTest = test.copyWith(status: TestStatus.paused);

    _tests[testIndex] = updatedTest;
    await _saveTests();
  }

  /// Termine un test A/B
  static Future<ABTestResult?> completeTest(String testId) async {
    final testIndex = _tests.indexWhere((t) => t.id == testId);
    if (testIndex == -1) return null;

    final test = _tests[testIndex];
    final result = await _calculateTestResults(test);

    final updatedTest = test.copyWith(
      status: TestStatus.completed,
      endedAt: DateTime.now(),
    );

    _tests[testIndex] = updatedTest;
    await _saveTests();

    return result;
  }

  /// Annule un test A/B
  static Future<void> cancelTest(String testId) async {
    final testIndex = _tests.indexWhere((t) => t.id == testId);
    if (testIndex == -1) return;

    final test = _tests[testIndex];
    final updatedTest = test.copyWith(
      status: TestStatus.cancelled,
      endedAt: DateTime.now(),
    );

    _tests[testIndex] = updatedTest;
    await _saveTests();
  }

  /// Assigne un utilisateur à un test
  static Future<String?> assignUserToTest({
    required String userId,
    required String testId,
    Map<String, dynamic> userSegment = const {},
  }) async {
    final test = _tests.where((t) => t.id == testId).firstOrNull;
    if (test == null || test.status != TestStatus.active) return null;

    // Vérifier si l'utilisateur est déjà assigné
    final existingAssignment = _userAssignments[userId];
    if (existingAssignment != null) {
      final existingSession = _sessions
          .where((s) => s.userId == userId && s.testId == testId)
          .firstOrNull;
      if (existingSession != null) {
        return existingSession.variantId;
      }
    }

    // Sélectionner une variante selon la méthode d'allocation
    final variantId = _selectVariant(test, userSegment);

    // Créer la session
    final session = ABTestSession(
      id: _generateSessionId(),
      userId: userId,
      testId: testId,
      variantId: variantId,
      assignedAt: DateTime.now(),
    );

    _sessions.add(session);
    _userAssignments[userId] = variantId;
    await _saveSessions();

    // Mettre à jour le compteur d'échantillonnage
    await _updateTestSampleSize(testId);

    return variantId;
  }

  /// Enregistre une interaction utilisateur
  static Future<void> trackInteraction({
    required String userId,
    required String testId,
    required String interactionType,
    Map<String, dynamic> data = const {},
  }) async {
    final session = _sessions
        .where((s) => s.userId == userId && s.testId == testId)
        .firstOrNull;

    if (session == null) return;

    final sessionIndex = _sessions.indexOf(session);
    final updatedSession = session.copyWith(
      interactions: Map<String, dynamic>.from(session.interactions)
        ..[interactionType] = {
          'timestamp': DateTime.now().toIso8601String(),
          'data': data,
        },
      startedAt: session.startedAt ?? DateTime.now(),
    );

    _sessions[sessionIndex] = updatedSession;
    await _saveSessions();
  }

  /// Enregistre une conversion
  static Future<void> trackConversion({
    required String userId,
    required String testId,
    String? conversionType,
    Map<String, dynamic> data = const {},
  }) async {
    final session = _sessions
        .where((s) => s.userId == userId && s.testId == testId)
        .firstOrNull;

    if (session == null) return;

    final sessionIndex = _sessions.indexOf(session);
    final updatedSession = session.copyWith(
      isConverted: true,
      completedAt: DateTime.now(),
      metrics: Map<String, dynamic>.from(session.metrics)
        ..['conversionType'] = conversionType ?? 'default',
        ..['conversionData'] = data,
        ..['conversionTime'] = DateTime.now().difference(
          session.startedAt ?? session.assignedAt,
        ).inMilliseconds,
    );

    _sessions[sessionIndex] = updatedSession;
    await _saveSessions();

    // Mettre à jour les statistiques du test
    await _updateTestStatistics(testId);
  }

  /// Récupère les résultats en temps réel d'un test
  static Map<String, dynamic> getLiveResults(String testId) {
    final test = _tests.where((t) => t.id == testId).firstOrNull;
    if (test == null) return {};

    final testSessions = _sessions.where((s) => s.testId == testId).toList();
    final variantStats = <String, Map<String, dynamic>>{};

    for (final variant in test.variants) {
      final variantSessions = testSessions
          .where((s) => s.variantId == variant.id)
          .toList();

      final conversions = variantSessions.where((s) => s.isConverted).length;
      final totalSessions = variantSessions.length;

      variantStats[variant.id] = {
        'totalSessions': totalSessions,
        'conversions': conversions,
        'conversionRate': totalSessions > 0 ? (conversions / totalSessions) * 100 : 0.0,
        'interactions': _countInteractions(variantSessions),
        'averageSessionDuration': _calculateAverageDuration(variantSessions),
      };
    }

    return {
      'test': {
        'id': test.id,
        'name': test.name,
        'status': test.status.name,
        'currentSampleSize': test.currentSampleSize,
        'targetSampleSize': test.targetSampleSize,
        'startedAt': test.startedAt?.toIso8601String(),
      },
      'variants': variantStats,
      'overall': {
        'totalSessions': testSessions.length,
        'totalConversions': testSessions.where((s) => s.isConverted).length,
        'overallConversionRate': testSessions.isNotEmpty
            ? (testSessions.where((s) => s.isConverted).length / testSessions.length) * 100
            : 0.0,
      },
    };
  }

  /// Génère des recommandations pour l'optimisation
  static List<String> generateRecommendations(String testId) {
    final results = getLiveResults(testId);
    final recommendations = <String>[];

    final overall = results['overall'] as Map<String, dynamic>;
    final variants = results['variants'] as Map<String, dynamic>;

    // Recommandations basées sur les performances
    if (overall['totalSessions'] < 100) {
      recommendations.add('Augmenter le trafic pour obtenir des résultats statistiquement significatifs');
    }

    if (overall['overallConversionRate'] < 5.0) {
      recommendations.add('Le taux de conversion est faible - envisagez de tester des variantes radicalement différentes');
    }

    // Analyser les variantes
    var bestVariant = '';
    var bestConversionRate = 0.0;

    for (final entry in variants.entries) {
      final variantData = entry.value as Map<String, dynamic>;
      final conversionRate = variantData['conversionRate'] as double;

      if (conversionRate > bestConversionRate) {
        bestConversionRate = conversionRate;
        bestVariant = entry.key;
      }
    }

    if (bestConversionRate > 15.0) {
      recommendations.add('La variante $bestVariant performe très bien - envisagez de la déployer');
    }

    // Recommandations basées sur la durée des tests
    final test = _tests.where((t) => t.id == testId).firstOrNull;
    if (test != null && test.startedAt != null) {
      final testDuration = DateTime.now().difference(test.startedAt!);
      if (testDuration > test.minTestDuration * 2) {
        recommendations.add('Le test dure depuis longtemps - envisagez de l\'analyser et le terminer');
      }
    }

    recommendations.add('Considérez l\'ajout de métriques qualitatives pour mieux comprendre le comportement utilisateur');

    return recommendations;
  }

  /// Crée un test de comparaison de thèmes
  static Future<ABTest> createThemeComparisonTest({
    required String name,
    required List<EventThemeCustomization> themes,
    List<String> targetMetrics = const [],
  }) async {
    final variants = themes.asMap().entries.map((entry) => ABTestVariant(
        id: _generateVariantId(),
        name: 'Thème ${entry.key + 1}',
        description: 'Variante de test pour le thème ${entry.key + 1}',
        theme: entry.value,
        weight: 1,
      )).toList();

    return createTest(
      name: name,
      description: 'Test de comparaison de thèmes',
      type: TestType.themeComparison,
      variants: variants,
      targetMetrics: targetMetrics.isEmpty
          ? ['conversion_rate', 'user_satisfaction', 'time_to_conversion']
          : targetMetrics,
      hypothesis: {
        'null_hypothesis': 'Il n\'y a pas de différence significative entre les thèmes',
        'alternative_hypothesis': 'Un thème performe significativement mieux que les autres',
      },
    );
  }

  /// Crée un test de variation de couleurs
  static Future<ABTest> createColorVariationTest({
    required String name,
    required EventThemeCustomization baseTheme,
    required List<Color> colorVariations,
    List<String> targetMetrics = const [],
  }) async {
    final variants = colorVariations.asMap().entries.map((entry) {
      final variantTheme = baseTheme.copyWith(
        primaryColor: entry.value,
      );

      return ABTestVariant(
        id: _generateVariantId(),
        name: 'Variation ${entry.key + 1}',
        description: 'Variation de couleur ${entry.key + 1}',
        theme: variantTheme,
        weight: 1,
      );
    }).toList();

    return createTest(
      name: name,
      description: 'Test de variation de couleurs',
      type: TestType.colorVariation,
      variants: variants,
      targetMetrics: targetMetrics.isEmpty
          ? ['click_through_rate', 'engagement_time', 'conversion_rate']
          : targetMetrics,
      hypothesis: {
        'null_hypothesis': 'La couleur n\'affecte pas les performances',
        'alternative_hypothesis': 'Certaines couleurs améliorent les performances',
      },
    );
  }

  /// Récupère tous les tests
  static List<ABTest> getAllTests() => List.unmodifiable(_tests);

  /// Récupère les tests actifs
  static List<ABTest> getActiveTests() => _tests.where((t) => t.status == TestStatus.active).toList();

  /// Récupère les tests terminés
  static List<ABTest> getCompletedTests() => _tests.where((t) => t.status == TestStatus.completed).toList();

  /// Exporte les résultats d'un test
  static Map<String, dynamic> exportTestResults(String testId) {
    final test = _tests.where((t) => t.id == testId).firstOrNull;
    if (test == null) return {};

    final testSessions = _sessions.where((s) => s.testId == testId).toList();
    final liveResults = getLiveResults(testId);
    final recommendations = generateRecommendations(testId);

    return {
      'test': test.toJson(),
      'results': liveResults,
      'recommendations': recommendations,
      'exportDate': DateTime.now().toIso8601String(),
      'sessions': testSessions.map((s) => s.toJson()).toList(),
    };
  }

  // Méthodes privées

  static String _generateTestId() => 'test_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';

  static String _generateVariantId() => 'variant_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';

  static String _generateSessionId() => 'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';

  static String _selectVariant(ABTest test, Map<String, dynamic> userSegment) {
    final activeVariants = test.variants.where((v) => v.isActive).toList();

    switch (test.allocationMethod) {
      case AllocationMethod.random:
        return activeVariants[Random().nextInt(activeVariants.length)].id;

      case AllocationMethod.weighted:
        return _selectWeightedVariant(activeVariants);

      case AllocationMethod.sequential:
        return _selectSequentialVariant(test.id, activeVariants);

      case AllocationMethod.userSegment:
        return _selectSegmentedVariant(activeVariants, userSegment);

      case AllocationMethod.custom:
        return _selectCustomVariant(activeVariants, test.settings, userSegment);

      default:
        return activeVariants.first.id;
    }
  }

  static String _selectWeightedVariant(List<ABTestVariant> variants) {
    final totalWeight = variants.fold(0, (sum, v) => sum + v.weight);
    final random = Random().nextInt(totalWeight);

    var currentWeight = 0;
    for (final variant in variants) {
      currentWeight += variant.weight;
      if (random < currentWeight) {
        return variant.id;
      }
    }

    return variants.first.id;
  }

  static String _selectSequentialVariant(String testId, List<ABTestVariant> variants) {
    final assignmentCount = _userAssignments.values
        .where((variantId) => _sessions
            .any((s) => s.testId == testId && s.variantId == variantId))
        .length;

    return variants[assignmentCount % variants.length].id;
  }

  static String _selectSegmentedVariant(List<ABTestVariant> variants, Map<String, dynamic> segment) {
    // Logique de sélection basée sur les segments utilisateur
    // Implémentation simplifiée
    return variants.first.id;
  }

  static String _selectCustomVariant(
    List<ABTestVariant> variants,
    Map<String, dynamic> settings,
    Map<String, dynamic> segment,
  ) {
    // Logique de sélection personnalisée
    // Implémentation simplifiée
    return variants.first.id;
  }

  static Future<ABTestResult> _calculateTestResults(ABTest test) async {
    final testSessions = _sessions.where((s) => s.testId == test.id).toList();
    final variantScores = <String, double>{};

    // Calculer les scores pour chaque variante
    for (final variant in test.variants) {
      final variantSessions = testSessions
          .where((s) => s.variantId == variant.id)
          .toList();

      final score = _calculateVariantScore(variant, variantSessions, test.targetMetrics);
      variantScores[variant.id] = score;
    }

    // Déterminer le gagnant
    final winnerVariant = variantScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Calculer les statistiques
    final statistics = _calculateStatistics(testSessions, test);
    final confidence = _calculateConfidence(variantScores, testSessions.length);

    final recommendations = generateRecommendations(test.id);

    return ABTestResult(
      testId: test.id,
      winnerVariantId: winnerVariant,
      variantScores: variantScores,
      statistics: statistics,
      confidence: confidence,
      completedAt: DateTime.now(),
      recommendations: recommendations,
    );
  }

  static double _calculateVariantScore(
    ABTestVariant variant,
    List<ABTestSession> sessions,
    List<String> targetMetrics,
  ) {
    var score = 0.0;

    // Score basé sur le taux de conversion
    final conversions = sessions.where((s) => s.isConverted).length;
    final totalSessions = sessions.length;
    if (totalSessions > 0) {
      score += (conversions / totalSessions) * 50;
    }

    // Score basé sur l'engagement
    final avgDuration = _calculateAverageDuration(sessions);
    score += (avgDuration.inMinutes / 10) * 20; // Plus de temps = plus d'engagement

    // Score basé sur les interactions
    final interactionCount = _countInteractions(sessions);
    score += (interactionCount / totalSessions) * 30;

    return score;
  }

  static Map<String, dynamic> _calculateStatistics(
    List<ABTestSession> sessions,
    ABTest test,
  ) {
    final totalSessions = sessions.length;
    final totalConversions = sessions.where((s) => s.isConverted).length;

    return {
      'totalParticipants': totalSessions,
      'totalConversions': totalConversions,
      'overallConversionRate': totalSessions > 0 ? (totalConversions / totalSessions) * 100 : 0.0,
      'averageSessionDuration': _calculateAverageDuration(sessions).inMinutes,
      'testDuration': test.startedAt != null
          ? DateTime.now().difference(test.startedAt!).inDays
          : 0,
      'variantDistribution': _calculateVariantDistribution(sessions, test),
    };
  }

  static Map<String, dynamic> _calculateConfidence(
    Map<String, double> scores,
    int sampleSize,
  ) {
    // Calcul simplifié de l'intervalle de confiance
    final winnerScore = scores.values.reduce((a, b) => a > b ? a : b);
    final confidenceInterval = 1.96 / sqrt(sampleSize); // Approximation pour 95% de confiance

    return {
      'confidenceLevel': 0.95,
      'winnerScore': winnerScore,
      'marginOfError': confidenceInterval,
      'isSignificant': winnerScore > confidenceInterval,
    };
  }

  static Duration _calculateAverageDuration(List<ABTestSession> sessions) {
    if (sessions.isEmpty) return Duration.zero;

    final durations = sessions
        .map((s) => s.completedAt != null && s.startedAt != null
            ? s.completedAt!.difference(s.startedAt!)
            : Duration.zero)
        .where((d) => d.inMilliseconds > 0)
        .toList();

    if (durations.isEmpty) return Duration.zero;

    final totalMs = durations.fold(0, (sum, d) => sum + d.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ durations.length);
  }

  static int _countInteractions(List<ABTestSession> sessions) => sessions.fold(0, (sum, s) => sum + s.interactions.length);

  static Map<String, int> _calculateVariantDistribution(
    List<ABTestSession> sessions,
    ABTest test,
  ) {
    final distribution = <String, int>{};

    for (final variant in test.variants) {
      final count = sessions.where((s) => s.variantId == variant.id).length;
      distribution[variant.id] = count;
    }

    return distribution;
  }

  static Future<void> _updateTestSampleSize(String testId) async {
    final testIndex = _tests.indexWhere((t) => t.id == testId);
    if (testIndex == -1) return;

    final test = _tests[testIndex];
    final currentSampleSize = _sessions
        .where((s) => s.testId == testId)
        .map((s) => s.userId)
        .toSet()
        .length;

    if (currentSampleSize != test.currentSampleSize) {
      final updatedTest = test.copyWith(currentSampleSize: currentSampleSize);
      _tests[testIndex] = updatedTest;
      await _saveTests();
    }
  }

  static Future<void> _updateTestStatistics(String testId) async {
    // Mettre à jour les statistiques en temps réel
    // Cette méthode pourrait être appelée périodiquement
  }

  static Future<void> _cleanupCompletedTests() async {
    final now = DateTime.now();
    final cutoffDate = now.subtract(const Duration(days: 30));

    // Archiver les tests terminés depuis plus de 30 jours
    for (var i = 0; i < _tests.length; i++) {
      final test = _tests[i];
      if (test.status == TestStatus.completed &&
          test.endedAt != null &&
          test.endedAt!.isBefore(cutoffDate)) {
        // Supprimer les sessions associées
        _sessions.removeWhere((s) => s.testId == test.id);

        // Marquer le test comme archivé
        _tests[i] = test.copyWith(
          status: TestStatus.completed,
          // Ajouter une propriété pour l'archivage si nécessaire
        );
      }
    }

    await _saveTests();
    await _saveSessions();
  }

  // Persistance

  static Future<void> _loadTests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final testsJson = prefs.getString(_testsKey);

      if (testsJson != null) {
        final testsList = json.decode(testsJson) as List;
        _tests.clear();
        _tests.addAll(testsList.map((json) => ABTest.fromJson(json)));
      }
    } catch (e) {
      // Gérer l'erreur de chargement
    }
  }

  static Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey);

      if (sessionsJson != null) {
        final sessionsList = json.decode(sessionsJson) as List;
        _sessions.clear();
        _sessions.addAll(sessionsList.map((json) => ABTestSession.fromJson(json)));
      }

      final assignmentsJson = prefs.getString(_assignmentsKey);
      if (assignmentsJson != null) {
        _userAssignments.clear();
        _userAssignments.addAll(Map<String, String>.from(json.decode(assignmentsJson)));
      }
    } catch (e) {
      // Gérer l'erreur de chargement
    }
  }

  static Future<void> _saveTests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_testsKey, json.encode(_tests.map((t) => t.toJson()).toList()));
    } catch (e) {
      // Gérer l'erreur de sauvegarde
    }
  }

  static Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionsKey, json.encode(_sessions.map((s) => s.toJson()).toList()));
      await prefs.setString(_assignmentsKey, json.encode(_userAssignments));
    } catch (e) {
      // Gérer l'erreur de sauvegarde
    }
  }

  /// Dispose le service
  static Future<void> dispose() async {
    // Nettoyer les ressources
  }
}
