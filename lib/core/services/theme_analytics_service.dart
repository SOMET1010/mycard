/// Service d'analytiques et statistiques pour les thèmes
library;
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AnalyticsEventType {
  themeCreated,        // Thème créé
  themeModified,       // Thème modifié
  themeDeleted,        // Thème supprimé
  themeExported,       // Thème exporté
  themeImported,       // Thème importé
  themeShared,         // Thème partagé
  themePreviewed,      // Thème prévisualisé
  colorChanged,        // Couleur changée
  fontChanged,         // Police changée
  patternChanged,      // Motif changé
  animationPlayed,     // Animation jouée
  collaborationStarted, // Collaboration démarrée
  collaborationEnded,   // Collaboration terminée
  searchPerformed,     // Recherche effectuée
  filterApplied,       // Filtre appliqué
  customRuleCreated,   // Règle personnalisée créée
  templateUsed,        // Template utilisé
  errorOccurred,       // Erreur survenue
  sessionStarted,      // Session démarrée
  sessionEnded,        // Session terminée
}

enum AnalyticsPeriod {
  hourly,            // Horaire
  daily,             // Quotidien
  weekly,            // Hebdomadaire
  monthly,           // Mensuel
  quarterly,         // Trimestriel
  yearly,            // Annuel
  custom,            // Personnalisé
}

class AnalyticsEvent {

  const AnalyticsEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    this.userId,
    this.sessionId,
    this.properties = const {},
    this.duration,
  });

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) => AnalyticsEvent(
      id: json['id'],
      type: AnalyticsEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AnalyticsEventType.sessionStarted,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      sessionId: json['sessionId'],
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
    );
  final String id;
  final AnalyticsEventType type;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic> properties;
  final Duration? duration;

  Map<String, dynamic> toJson() => {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'sessionId': sessionId,
      'properties': properties,
      'duration': duration?.inMilliseconds,
    };
}

class ThemeUsageMetrics {

  const ThemeUsageMetrics({
    required this.themeId,
    required this.themeName,
    required this.totalUsage,
    required this.uniqueUsers,
    required this.averageSessionDuration,
    required this.exportsCount,
    required this.sharesCount,
    required this.userSatisfaction,
    required this.topFeatures,
    required this.featureUsage,
    required this.lastUsed,
  });
  final String themeId;
  final String themeName;
  final int totalUsage;
  final int uniqueUsers;
  final double averageSessionDuration;
  final int exportsCount;
  final int sharesCount;
  final double userSatisfaction;
  final List<String> topFeatures;
  final Map<String, int> featureUsage;
  final DateTime lastUsed;
}

class UserBehaviorAnalytics {

  const UserBehaviorAnalytics({
    required this.userId,
    required this.sessionCount,
    required this.totalSessionTime,
    required this.themesCreated,
    required this.themesModified,
    required this.themesExported,
    required this.favoriteFeatures,
    required this.featureUsage,
    required this.lastActivity,
    required this.preferredColorSchemes,
    required this.preferredFonts,
  });
  final String userId;
  final int sessionCount;
  final Duration totalSessionTime;
  final int themesCreated;
  final int themesModified;
  final int themesExported;
  final List<String> favoriteFeatures;
  final Map<String, int> featureUsage;
  final DateTime lastActivity;
  final List<String> preferredColorSchemes;
  final List<String> preferredFonts;
}

class ThemeAnalyticsService {
  static const String _eventsKey = 'analytics_events';
  static const String _sessionsKey = 'analytics_sessions';
  static const String _metricsKey = 'analytics_metrics';

  static final List<AnalyticsEvent> _events = [];
  static final Map<String, DateTime> _sessions = {};
  static String? _currentSessionId;
  static Timer? _sessionTimer;
  static DateTime? _sessionStartTime;

  /// Initialise le service d'analytiques
  static Future<void> initialize() async {
    await _loadEvents();
    _startNewSession();
    _cleanupOldData();
  }

  /// Enregistre un événement analytique
  static Future<void> trackEvent({
    required AnalyticsEventType type,
    String? userId,
    Map<String, dynamic> properties = const {},
    Duration? duration,
  }) async {
    final event = AnalyticsEvent(
      id: _generateEventId(),
      type: type,
      timestamp: DateTime.now(),
      userId: userId ?? 'anonymous',
      sessionId: _currentSessionId,
      properties: properties,
      duration: duration,
    );

    _events.add(event);
    await _saveEvents();

    // Traiter l'événement en temps réel si nécessaire
    _processEvent(event);
  }

  /// Suit la création d'un thème
  static Future<void> trackThemeCreated({
    required String themeId,
    required String themeName,
    String? templateUsed,
    Map<String, dynamic>? themeProperties,
  }) async {
    await trackEvent(
      type: AnalyticsEventType.themeCreated,
      properties: {
        'themeId': themeId,
        'themeName': themeName,
        'templateUsed': templateUsed,
        'properties': themeProperties ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Suit la modification d'un thème
  static Future<void> trackThemeModified({
    required String themeId,
    required List<String> changedProperties,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  }) async {
    await trackEvent(
      type: AnalyticsEventType.themeModified,
      properties: {
        'themeId': themeId,
        'changedProperties': changedProperties,
        'oldValues': oldValues,
        'newValues': newValues,
        'changeCount': changedProperties.length,
      },
    );
  }

  /// Suit l'export d'un thème
  static Future<void> trackThemeExported({
    required String themeId,
    required String format,
    int? fileSize,
    bool? includePreview,
  }) async {
    await trackEvent(
      type: AnalyticsEventType.themeExported,
      properties: {
        'themeId': themeId,
        'format': format,
        'fileSize': fileSize,
        'includePreview': includePreview,
      },
    );
  }

  /// Suit l'utilisation d'une fonctionnalité
  static Future<void> trackFeatureUsed({
    required String featureName,
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(
      type: AnalyticsEventType.customRuleCreated, // Utiliser un type générique
      properties: {
        'feature': featureName,
        'action': action,
        'parameters': parameters ?? {},
      },
    );
  }

  /// Suit une recherche
  static Future<void> trackSearch({
    required String query,
    required int resultsCount,
    String? category,
    List<String>? filters,
  }) async {
    await trackEvent(
      type: AnalyticsEventType.searchPerformed,
      properties: {
        'query': query,
        'resultsCount': resultsCount,
        'category': category,
        'filters': filters ?? [],
        'queryLength': query.length,
      },
    );
  }

  /// Suit une erreur
  static Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    await trackEvent(
      type: AnalyticsEventType.errorOccurred,
      properties: {
        'errorType': errorType,
        'errorMessage': errorMessage,
        'stackTrace': stackTrace,
        'context': context ?? {},
      },
    );
  }

  /// Récupère les métriques d'utilisation pour un thème
  static ThemeUsageMetrics getThemeMetrics(String themeId) {
    final themeEvents = _events.where((e) =>
        e.properties['themeId'] == themeId).toList();

    if (themeEvents.isEmpty) {
      return ThemeUsageMetrics(
        themeId: themeId,
        themeName: 'Unknown Theme',
        totalUsage: 0,
        uniqueUsers: 0,
        averageSessionDuration: Duration.zero,
        exportsCount: 0,
        sharesCount: 0,
        userSatisfaction: 0.0,
        topFeatures: [],
        featureUsage: {},
        lastUsed: DateTime.now(),
      );
    }

    final totalUsage = themeEvents.length;
    final uniqueUsers = themeEvents
        .map((e) => e.userId)
        .toSet()
        .length;

    final sessionDurations = themeEvents
        .where((e) => e.duration != null)
        .map((e) => e.duration!)
        .toList();

    final averageSessionDuration = sessionDurations.isNotEmpty
        ? sessionDurations.reduce((a, b) => a + b) ~/ sessionDurations.length
        : Duration.zero;

    final exportsCount = themeEvents
        .where((e) => e.type == AnalyticsEventType.themeExported)
        .length;

    final sharesCount = themeEvents
        .where((e) => e.type == AnalyticsEventType.themeShared)
        .length;

    // Simuler la satisfaction utilisateur
    final userSatisfaction = 4.2 + (Random().nextDouble() * 0.8);

    // Analyser l'utilisation des fonctionnalités
    final featureUsage = <String, int>{};
    for (final event in themeEvents) {
      if (event.properties.containsKey('feature')) {
        final feature = event.properties['feature'] as String;
        featureUsage[feature] = (featureUsage[feature] ?? 0) + 1;
      }
    }

    final topFeatures = featureUsage.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        .take(5)
        .map((e) => e.key)
        .toList();

    final themeName = themeEvents.first.properties['themeName'] as String? ?? 'Unknown Theme';
    final lastUsed = themeEvents
        .map((e) => e.timestamp)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return ThemeUsageMetrics(
      themeId: themeId,
      themeName: themeName,
      totalUsage: totalUsage,
      uniqueUsers: uniqueUsers,
      averageSessionDuration: averageSessionDuration,
      exportsCount: exportsCount,
      sharesCount: sharesCount,
      userSatisfaction: userSatisfaction,
      topFeatures: topFeatures,
      featureUsage: featureUsage,
      lastUsed: lastUsed,
    );
  }

  /// Récupère les analytiques de comportement utilisateur
  static UserBehaviorAnalytics getUserAnalytics(String userId) {
    final userEvents = _events.where((e) => e.userId == userId).toList();

    final sessionCount = _sessions.entries
        .where((entry) => entry.key.startsWith(userId))
        .length;

    final sessionEvents = userEvents.where((e) => e.type == AnalyticsEventType.sessionStarted);
    final sessionEndEvents = userEvents.where((e) => e.type == AnalyticsEventType.sessionEnded);

    var totalSessionTime = Duration.zero;
    for (var i = 0; i < min(sessionEvents.length, sessionEndEvents.length); i++) {
      final start = sessionEvents.elementAt(i).timestamp;
      final end = sessionEndEvents.elementAt(i).timestamp;
      totalSessionTime += end.difference(start);
    }

    final themesCreated = userEvents
        .where((e) => e.type == AnalyticsEventType.themeCreated)
        .length;

    final themesModified = userEvents
        .where((e) => e.type == AnalyticsEventType.themeModified)
        .length;

    final themesExported = userEvents
        .where((e) => e.type == AnalyticsEventType.themeExported)
        .length;

    final featureUsage = <String, int>{};
    for (final event in userEvents) {
      if (event.properties.containsKey('feature')) {
        final feature = event.properties['feature'] as String;
        featureUsage[feature] = (featureUsage[feature] ?? 0) + 1;
      }
    }

    final favoriteFeatures = featureUsage.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        .take(5)
        .map((e) => e.key)
        .toList();

    final lastActivity = userEvents
        .map((e) => e.timestamp)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    // Simuler les préférences
    final preferredColorSchemes = ['blue', 'green', 'purple'];
    final preferredFonts = ['Roboto', 'Arial', 'Open Sans'];

    return UserBehaviorAnalytics(
      userId: userId,
      sessionCount: sessionCount,
      totalSessionTime: totalSessionTime,
      themesCreated: themesCreated,
      themesModified: themesModified,
      themesExported: themesExported,
      favoriteFeatures: favoriteFeatures,
      featureUsage: featureUsage,
      lastActivity: lastActivity,
      preferredColorSchemes: preferredColorSchemes,
      preferredFonts: preferredFonts,
    );
  }

  /// Génère un rapport d'analytiques
  static Future<Map<String, dynamic>> generateReport({
    AnalyticsPeriod period = AnalyticsPeriod.monthly,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? _getStartDateForPeriod(period, now);
    final end = endDate ?? now;

    final filteredEvents = _events.where((e) =>
        e.timestamp.isAfter(start) && e.timestamp.isBefore(end)).toList();

    return {
      'period': period.name,
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
      'totalEvents': filteredEvents.length,
      'uniqueUsers': filteredEvents.map((e) => e.userId).toSet().length,
      'activeSessions': _sessions.length,
      'summary': _generateSummary(filteredEvents),
      'themeMetrics': _generateThemeMetrics(filteredEvents),
      'userBehavior': _generateUserBehaviorMetrics(filteredEvents),
      'featureUsage': _generateFeatureUsage(filteredEvents),
      'trends': _generateTrends(filteredEvents, start, end),
      'recommendations': _generateRecommendations(filteredEvents),
    };
  }

  /// Récupère les tendances d'utilisation
  static Map<String, dynamic> getUsageTrends({int days = 30}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final filteredEvents = _events.where((e) =>
        e.timestamp.isAfter(startDate)).toList();

    final dailyUsage = <DateTime, int>{};
    for (var i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      dailyUsage[date] = 0;
    }

    for (final event in filteredEvents) {
      final date = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );
      dailyUsage[date] = (dailyUsage[date] ?? 0) + 1;
    }

    final sortedDates = dailyUsage.keys.toList()..sort();
    final usageData = sortedDates.map((date) => {
      'date': date.toIso8601String(),
      'count': dailyUsage[date] ?? 0,
    }).toList();

    // Calculer les tendances
    final totalCount = usageData.fold(0, (sum, data) => sum + (data['count'] as int));
    final averageDaily = totalCount / days;

    // Tendance de croissance
    final firstHalf = usageData.take(days ~/ 2);
    final secondHalf = usageData.skip(days ~/ 2);

    final firstHalfCount = firstHalf.fold(0, (sum, data) => sum + (data['count'] as int));
    final secondHalfCount = secondHalf.fold(0, (sum, data) => sum + (data['count'] as int));

    final growthRate = firstHalfCount > 0
        ? ((secondHalfCount - firstHalfCount) / firstHalfCount) * 100
        : 0.0;

    return {
      'period': '$days days',
      'totalEvents': totalCount,
      'averageDaily': averageDaily,
      'growthRate': growthRate,
      'dailyData': usageData,
      'peakDay': usageData.isNotEmpty
          ? usageData.reduce((a, b) => (a['count'] as int) > (b['count'] as int) ? a : b)
          : null,
    };
  }

  /// Obtient les thèmes les plus populaires
  static List<ThemeUsageMetrics> getPopularThemes({int limit = 10}) {
    final themeIds = _events
        .where((e) => e.properties.containsKey('themeId'))
        .map((e) => e.properties['themeId'] as String)
        .toSet();

    final metrics = themeIds
        .map(getThemeMetrics)
        .toList()
      ..sort((a, b) => b.totalUsage.compareTo(a.totalUsage));

    return metrics.take(limit).toList();
  }

  /// Obtient les fonctionnalités les plus utilisées
  static Map<String, int> getTopFeatures({int limit = 10}) {
    final featureUsage = <String, int>{};

    for (final event in _events) {
      if (event.properties.containsKey('feature')) {
        final feature = event.properties['feature'] as String;
        featureUsage[feature] = (featureUsage[feature] ?? 0) + 1;
      }
    }

    final sortedFeatures = featureUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedFeatures.take(limit));
  }

  /// Calcule le taux de rétention
  static double calculateRetentionRate({int days = 30}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    // Utilisateurs actifs dans la période
    final activeUsers = _events
        .where((e) => e.timestamp.isAfter(startDate))
        .map((e) => e.userId)
        .toSet();

    // Utilisateurs actifs dans la période précédente
    final previousStartDate = startDate.subtract(Duration(days: days));
    final previousActiveUsers = _events
        .where((e) => e.timestamp.isAfter(previousStartDate) && e.timestamp.isBefore(startDate))
        .map((e) => e.userId)
        .toSet();

    if (previousActiveUsers.isEmpty) return 0.0;

    // Utilisateurs retenus = utilisateurs actifs dans les deux périodes
    final retainedUsers = activeUsers.intersection(previousActiveUsers);

    return (retainedUsers.length / previousActiveUsers.length) * 100;
  }

  /// Termine la session en cours
  static Future<void> endSession() async {
    if (_currentSessionId != null && _sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!);

      await trackEvent(
        type: AnalyticsEventType.sessionEnded,
        properties: {
          'sessionDuration': duration.inMilliseconds,
        },
        duration: duration,
      );

      _currentSessionId = null;
      _sessionStartTime = null;
      _sessionTimer?.cancel();
      _sessionTimer = null;
    }
  }

  /// Exporte les données analytiques
  static Future<Map<String, dynamic>> exportAnalytics({
    AnalyticsPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? _getStartDateForPeriod(period ?? Analytics.monthly, now);
    final end = endDate ?? now;

    final filteredEvents = _events.where((e) =>
        e.timestamp.isAfter(start) && e.timestamp.isBefore(end)).toList();

    return {
      'exportInfo': {
        'exportDate': now.toIso8601String(),
        'period': period?.name ?? 'custom',
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
        'totalEvents': filteredEvents.length,
      },
      'events': filteredEvents.map((e) => e.toJson()).toList(),
      'sessions': _sessions.map((k, v) => MapEntry(k, v.toIso8601String())),
      'summary': await generateReport(period: period, startDate: start, endDate: end),
    };
  }

  /// Purge les anciennes données
  static Future<void> purgeOldData({int daysToKeep = 90}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    _events.removeWhere((e) => e.timestamp.isBefore(cutoffDate));

    _sessions.removeWhere((k, v) => v.isBefore(cutoffDate));

    await _saveEvents();
    await _saveSessions();
  }

  // Méthodes privées

  static String _generateEventId() => 'event_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';

  static void _startNewSession() {
    _currentSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _sessionStartTime = DateTime.now();
    _sessions[_currentSessionId!] = _sessionStartTime!;

    trackEvent(
      type: AnalyticsEventType.sessionStarted,
      properties: {
        'startTime': _sessionStartTime!.toIso8601String(),
      },
    );

    // Démarrer un timer pour suivre la durée de session
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      // Mettre à jour la durée de session
    });
  }

  static void _processEvent(AnalyticsEvent event) {
    // Traitement en temps réel des événements
    switch (event.type) {
      case AnalyticsEventType.errorOccurred:
        _handleErrorEvent(event);
        break;
      case AnalyticsEventType.themeCreated:
        _handleThemeCreatedEvent(event);
        break;
      case AnalyticsEventType.themeExported:
        _handleThemeExportedEvent(event);
        break;
      default:
        break;
    }
  }

  static void _handleErrorEvent(AnalyticsEvent event) {
    // Logger les erreurs critiques
    final errorMessage = event.properties['errorMessage'] as String?;
    final errorType = event.properties['errorType'] as String?;

    // En cas d'erreur critique, déclencher une alerte
    if (errorType == 'critical' && errorMessage != null) {
      // Envoyer une notification ou un rapport d'erreur
    }
  }

  static void _handleThemeCreatedEvent(AnalyticsEvent event) {
    // Suivre la création de thèmes pour les recommandations
    final themeId = event.properties['themeId'] as String?;
    if (themeId != null) {
      // Mettre à jour les statistiques en temps réel
    }
  }

  static void _handleThemeExportedEvent(AnalyticsEvent event) {
    // Suivre les exports pour analyser les formats populaires
    final format = event.properties['format'] as String?;
    if (format != null) {
      // Mettre à jour les statistiques de format
    }
  }

  static DateTime _getStartDateForPeriod(AnalyticsPeriod period, DateTime now) {
    switch (period) {
      case Analytics.hourly:
        return now.subtract(const Duration(hours: 1));
      case Analytics.daily:
        return now.subtract(const Duration(days: 1));
      case Analytics.weekly:
        return now.subtract(const Duration(days: 7));
      case Analytics.monthly:
        return now.subtract(const Duration(days: 30));
      case Analytics.quarterly:
        return now.subtract(const Duration(days: 90));
      case Analytics.yearly:
        return now.subtract(const Duration(days: 365));
      case Analytics.custom:
        return now.subtract(const Duration(days: 30));
    }
  }

  static Map<String, dynamic> _generateSummary(List<AnalyticsEvent> events) {
    final eventTypes = <AnalyticsEventType, int>{};
    for (final event in events) {
      eventTypes[event.type] = (eventTypes[event.type] ?? 0) + 1;
    }

    return {
      'totalEvents': events.length,
      'uniqueUsers': events.map((e) => e.userId).toSet().length,
      'eventTypes': eventTypes.map((k, v) => MapEntry(k.name, v)),
      'averageSessionDuration': _calculateAverageSessionDuration(events),
    };
  }

  static Map<String, dynamic> _generateThemeMetrics(List<AnalyticsEvent> events) {
    final themeEvents = events.where((e) => e.properties.containsKey('themeId')).toList();
    final themeIds = themeEvents.map((e) => e.properties['themeId'] as String).toSet();

    final metrics = <String, dynamic>{};
    for (final themeId in themeIds) {
      metrics[themeId] = getThemeMetrics(themeId);
    }

    return metrics;
  }

  static Map<String, dynamic> _generateUserBehaviorMetrics(List<AnalyticsEvent> events) {
    final userIds = events.map((e) => e.userId).toSet();
    final metrics = <String, dynamic>{};

    for (final userId in userIds) {
      metrics[userId] = getUserAnalytics(userId);
    }

    return metrics;
  }

  static Map<String, int> _generateFeatureUsage(List<AnalyticsEvent> events) {
    final featureUsage = <String, int>{};
    for (final event in events) {
      if (event.properties.containsKey('feature')) {
        final feature = event.properties['feature'] as String;
        featureUsage[feature] = (featureUsage[feature] ?? 0) + 1;
      }
    }
    return featureUsage;
  }

  static Map<String, dynamic> _generateTrends(List<AnalyticsEvent> events, DateTime start, DateTime end) => {
      'usageGrowth': _calculateUsageGrowth(events, start, end),
      'popularFeatures': getTopFeatures(limit: 5),
      'userEngagement': _calculateUserEngagement(events),
      'sessionDuration': _calculateSessionDurationTrends(events),
    };

  static List<String> _generateRecommendations(List<AnalyticsEvent> events) {
    final recommendations = <String>[];

    // Analyser les données pour générer des recommandations
    final featureUsage = _generateFeatureUsage(events);
    final popularFeatures = featureUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (popularFeatures.isNotEmpty) {
      final topFeature = popularFeatures.first.key;
      recommendations.add('Promouvoir la fonctionnalité "$topFeature" - très utilisée');
    }

    final errorEvents = events.where((e) => e.type == AnalyticsEventType.errorOccurred);
    if (errorEvents.length > events.length * 0.05) {
      recommendations.add('Améliorer la stabilité - taux d\'erreurs élevé');
    }

    recommendations.add('Optimiser les performances des thèmes les plus utilisés');
    recommendations.add('Ajouter des tutoriels pour les fonctionnalités complexes');

    return recommendations;
  }

  static Duration _calculateAverageSessionDuration(List<AnalyticsEvent> events) {
    final sessionDurations = events
        .where((e) => e.duration != null)
        .map((e) => e.duration!)
        .toList();

    if (sessionDurations.isEmpty) return Duration.zero;

    final totalMs = sessionDurations.fold(0, (sum, d) => sum + d.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ sessionDurations.length);
  }

  static double _calculateUsageGrowth(List<AnalyticsEvent> events, DateTime start, DateTime end) {
    final midPoint = start.add(end.difference(start) ~/ 2);

    final firstHalf = events.where((e) => e.timestamp.isBefore(midPoint)).length;
    final secondHalf = events.where((e) => e.timestamp.isAfter(midPoint)).length;

    if (firstHalf == 0) return 0.0;
    return ((secondHalf - firstHalf) / firstHalf) * 100;
  }

  static double _calculateUserEngagement(List<AnalyticsEvent> events) {
    final userIds = events.map((e) => e.userId).toSet();
    if (userIds.isEmpty) return 0.0;

    var totalEngagement = 0.0;
    for (final userId in userIds) {
      final userEvents = events.where((e) => e.userId == userId).length;
      totalEngagement += userEvents;
    }

    return totalEngagement / userIds.length;
  }

  static Map<String, dynamic> _calculateSessionDurationTrends(List<AnalyticsEvent> events) {
    final sessions = events.where((e) => e.type == AnalyticsEventType.sessionEnded);

    if (sessions.isEmpty) {
      return {
        'average': 0.0,
        'median': 0.0,
        'shortest': 0.0,
        'longest': 0.0,
      };
    }

    final durations = sessions
        .where((e) => e.duration != null)
        .map((e) => e.duration!.inMinutes.toDouble())
        .toList()
      ..sort();

    return {
      'average': durations.reduce((a, b) => a + b) / durations.length,
      'median': durations[durations.length ~/ 2],
      'shortest': durations.first,
      'longest': durations.last,
    };
  }

  static Future<void> _loadEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsKey);

      if (eventsJson != null) {
        final eventsList = json.decode(eventsJson) as List;
        _events.clear();
        _events.addAll(eventsList.map((json) => AnalyticsEvent.fromJson(json)));
      }

      final sessionsJson = prefs.getString(_sessionsKey);
      if (sessionsJson != null) {
        final sessionsData = json.decode(sessionsJson) as Map<String, dynamic>;
        _sessions.clear();
        _sessions.addAll(sessionsData.map((k, v) => MapEntry(k, DateTime.parse(v))));
      }
    } catch (e) {
      // Gérer l'erreur de chargement
    }
  }

  static Future<void> _saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Limiter le nombre d'événements pour éviter les problèmes de performance
      final eventsToSave = _events.length > 10000
          ? _events.skip(_events.length - 10000).toList()
          : _events;

      await prefs.setString(_eventsKey, json.encode(eventsToSave.map((e) => e.toJson()).toList()));
    } catch (e) {
      // Gérer l'erreur de sauvegarde
    }
  }

  static Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionsKey, json.encode(
        _sessions.map((k, v) => MapEntry(k, v.toIso8601String()))
      ));
    } catch (e) {
      // Gérer l'erreur de sauvegarde
    }
  }

  static Future<void> _cleanupOldData() async {
    await purgeOldData(daysToKeep: 90);
  }

  /// Dispose le service
  static Future<void> dispose() async {
    await endSession();
  }
}