/// Service de thèmes adaptatifs avec détection automatique du contexte
library;
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mycard/features/events/page_event_theme_preview.dart';

enum AdaptationTrigger {
  timeOfDay,        // Heure de la journée
  weather,          // Météo
  location,         // Localisation
  userActivity,     // Activité de l'utilisateur
  deviceOrientation, // Orientation de l'appareil
  ambientLight,     // Lumière ambiante
  batteryLevel,     // Niveau de batterie
  userPreference,   // Préférence utilisateur
  systemTheme,      // Thème système
  season,           // Saison
  weekday,          // Jour de la semaine
  custom,           // Déclencheur personnalisé
}

enum ThemeAdaptationMode {
  automatic,        // Adaptation automatique
  scheduled,        // Adaptation planifiée
  manual,           // Adaptation manuelle
  hybrid,           // Mode hybride
}

class AdaptiveThemeRule {

  const AdaptiveThemeRule({
    required this.id,
    required this.trigger,
    required this.conditions,
    required this.targetTheme,
    required this.name,
    this.description = '',
    this.isActive = true,
    required this.createdAt,
    this.lastTriggered,
    this.triggerCount = 0,
    this.mode = ThemeAdaptationMode.automatic,
    this.scheduleTimes = const [],
    this.transitionDuration = const Duration(milliseconds: 500),
    this.transitionCurve = Curves.easeInOut,
  });

  factory AdaptiveThemeRule.fromJson(Map<String, dynamic> json) => AdaptiveThemeRule(
      id: json['id'],
      trigger: AdaptationTrigger.values.firstWhere(
        (e) => e.name == json['trigger'],
        orElse: () => AdaptationTrigger.custom,
      ),
      conditions: Map<String, dynamic>.from(json['conditions'] ?? {}),
      targetTheme: EventThemeCustomization.fromJson(json['targetTheme']),
      name: json['name'],
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastTriggered: json['lastTriggered'] != null
          ? DateTime.parse(json['lastTriggered'])
          : null,
      triggerCount: json['triggerCount'] ?? 0,
      mode: ThemeAdaptationMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => ThemeAdaptationMode.automatic,
      ),
      scheduleTimes: (json['scheduleTimes'] as List?)
          ?.map((time) => TimeOfDay(
                hour: time['hour'],
                minute: time['minute'],
              ))
          .toList() ?? [],
      transitionDuration: Duration(
        milliseconds: json['transitionDuration'] ?? 500,
      ),
      transitionCurve: _getCurveFromString(json['transitionCurve'] ?? 'easeInOut'),
    );
  final String id;
  final AdaptationTrigger trigger;
  final Map<String, dynamic> conditions;
  final EventThemeCustomization targetTheme;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggered;
  final int triggerCount;
  final ThemeAdaptationMode mode;
  final List<TimeOfDay> scheduleTimes;
  final Duration transitionDuration;
  final Curve transitionCurve;

  Map<String, dynamic> toJson() => {
      'id': id,
      'trigger': trigger.name,
      'conditions': conditions,
      'targetTheme': targetTheme.toJson(),
      'name': name,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
      'triggerCount': triggerCount,
      'mode': mode.name,
      'scheduleTimes': scheduleTimes.map((time) => {
        'hour': time.hour,
        'minute': time.minute,
      }).toList(),
      'transitionDuration': transitionDuration.inMilliseconds,
      'transitionCurve': _curveToString(transitionCurve),
    };

  static Curve _getCurveFromString(String curveString) {
    switch (curveString) {
      case 'linear': return Curves.linear;
      case 'easeIn': return Curves.easeIn;
      case 'easeOut': return Curves.easeOut;
      case 'easeInOut': return Curves.easeInOut;
      case 'bounceIn': return Curves.bounceIn;
      case 'bounceOut': return Curves.bounceOut;
      case 'elasticIn': return Curves.elasticIn;
      case 'elasticOut': return Curves.elasticOut;
      default: return Curves.easeInOut;
    }
  }

  static String _curveToString(Curve curve) {
    if (curve == Curves.linear) return 'linear';
    if (curve == Curves.easeIn) return 'easeIn';
    if (curve == Curves.easeOut) return 'easeOut';
    if (curve == Curves.easeInOut) return 'easeInOut';
    if (curve == Curves.bounceIn) return 'bounceIn';
    if (curve == Curves.bounceOut) return 'bounceOut';
    if (curve == Curves.elasticIn) return 'elasticIn';
    if (curve == Curves.elasticOut) return 'elasticOut';
    return 'easeInOut';
  }

  AdaptiveThemeRule copyWith({
    String? id,
    AdaptationTrigger? trigger,
    Map<String, dynamic>? conditions,
    EventThemeCustomization? targetTheme,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTriggered,
    int? triggerCount,
    ThemeAdaptationMode? mode,
    List<TimeOfDay>? scheduleTimes,
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) => AdaptiveThemeRule(
      id: id ?? this.id,
      trigger: trigger ?? this.trigger,
      conditions: conditions ?? this.conditions,
      targetTheme: targetTheme ?? this.targetTheme,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      triggerCount: triggerCount ?? this.triggerCount,
      mode: mode ?? this.mode,
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      transitionCurve: transitionCurve ?? this.transitionCurve,
    );
}

class AdaptiveThemeService {
  static final List<AdaptiveThemeRule> _rules = [];
  static final List<StreamSubscription> _subscriptions = [];
  static EventThemeCustomization? _currentTheme;
  static final Map<AdaptationTrigger, Timer> _timers = {};
  static final StreamController<AdaptiveThemeEvent> _eventController =
      StreamController<AdaptiveThemeEvent>.broadcast();

  static Stream<AdaptiveThemeEvent> get events => _eventController.stream;

  /// Initialise le service de thèmes adaptatifs
  static Future<void> initialize() async {
    await _loadRules();
    _setupSystemListeners();
    _startScheduledRules();
    _startPeriodicChecks();
  }

  /// Ajoute une règle d'adaptation
  static Future<void> addRule(AdaptiveThemeRule rule) async {
    _rules.add(rule);
    await _saveRules();
    _eventController.add(AdaptiveThemeEvent(
      type: AdaptiveEventType.ruleAdded,
      ruleId: rule.id,
      data: {'rule': rule},
    ));
  }

  /// Met à jour une règle d'adaptation
  static Future<void> updateRule(AdaptiveThemeRule rule) async {
    final index = _rules.indexWhere((r) => r.id == rule.id);
    if (index != -1) {
      _rules[index] = rule;
      await _saveRules();
      _eventController.add(AdaptiveThemeEvent(
        type: AdaptiveEventType.ruleUpdated,
        ruleId: rule.id,
        data: {'rule': rule},
      ));
    }
  }

  /// Supprime une règle d'adaptation
  static Future<void> removeRule(String ruleId) async {
    _rules.removeWhere((r) => r.id == ruleId);
    await _saveRules();
    _eventController.add(AdaptiveThemeEvent(
      type: AdaptiveEventType.ruleRemoved,
      ruleId: ruleId,
    ));
  }

  /// Récupère toutes les règles
  static List<AdaptiveThemeRule> getRules() => List.unmodifiable(_rules);

  /// Récupère les règles actives
  static List<AdaptiveThemeRule> getActiveRules() => _rules.where((rule) => rule.isActive).toList();

  /// Définit le thème actuel
  static void setCurrentTheme(EventThemeCustomization theme) {
    _currentTheme = theme;
    _checkAdaptationRules();
  }

  /// Vérifie manuellement toutes les règles d'adaptation
  static Future<void> checkAdaptationRules() async {
    final currentContext = _getCurrentContext();
    if (currentContext == null) return;

    for (final rule in getActiveRules()) {
      if (await _shouldTriggerRule(rule, currentContext)) {
        await _triggerRule(rule);
      }
    }
  }

  /// Crée une règle d'adaptation basée sur l'heure
  static AdaptiveThemeRule createTimeBasedRule({
    required String name,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required EventThemeCustomization theme,
    List<int>? daysOfWeek, // 1-7 (Lundi-Dimanche)
  }) => AdaptiveThemeRule(
      id: _generateRuleId(),
      trigger: AdaptationTrigger.timeOfDay,
      conditions: {
        'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
        'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
        'daysOfWeek': daysOfWeek ?? [1, 2, 3, 4, 5], // Jours ouvrables par défaut
      },
      targetTheme: theme,
      name: name,
      description: 'Adaptation basée sur l\'heure: $startTime - $endTime',
      createdAt: DateTime.now(),
      mode: ThemeAdaptationMode.scheduled,
      scheduleTimes: [startTime],
    );

  /// Crée une règle d'adaptation basée sur la météo
  static AdaptiveThemeRule createWeatherBasedRule({
    required String name,
    required List<String> weatherConditions,
    required EventThemeCustomization theme,
  }) => AdaptiveThemeRule(
      id: _generateRuleId(),
      trigger: AdaptationTrigger.weather,
      conditions: {
        'conditions': weatherConditions,
        'temperature': null, // Optionnel: {min, max}
        'humidity': null,    // Optionnel: {min, max}
      },
      targetTheme: theme,
      name: name,
      description: 'Adaptation basée sur la météo: ${weatherConditions.join(', ')}',
      createdAt: DateTime.now(),
      mode: ThemeAdaptationMode.automatic,
    );

  /// Crée une règle d'adaptation basée sur la localisation
  static AdaptiveThemeRule createLocationBasedRule({
    required String name,
    required List<String> locations,
    required EventThemeCustomization theme,
    double? radius, // Rayon en km
  }) => AdaptiveThemeRule(
      id: _generateRuleId(),
      trigger: AdaptationTrigger.location,
      conditions: {
        'locations': locations,
        'radius': radius ?? 1.0,
        'currentLocation': null, // Sera rempli automatiquement
      },
      targetTheme: theme,
      name: name,
      description: 'Adaptation basée sur la localisation: ${locations.join(', ')}',
      createdAt: DateTime.now(),
      mode: ThemeAdaptationMode.automatic,
    );

  /// Crée une règle d'adaptation basée sur l'activité utilisateur
  static AdaptiveThemeRule createActivityBasedRule({
    required String name,
    required List<String> activities,
    required EventThemeCustomization theme,
  }) => AdaptiveThemeRule(
      id: _generateRuleId(),
      trigger: AdaptationTrigger.userActivity,
      conditions: {
        'activities': activities, // ['work', 'leisure', 'exercise', 'sleep']
        'duration': null,       // Optionnel: durée en minutes
      },
      targetTheme: theme,
      name: name,
      description: 'Adaptation basée sur l\'activité: ${activities.join(', ')}',
      createdAt: DateTime.now(),
      mode: ThemeAdaptationMode.automatic,
    );

  /// Crée une règle d'adaptation basée sur la batterie
  static AdaptiveThemeRule createBatteryBasedRule({
    required String name,
    required int minBatteryLevel,
    required EventThemeCustomization theme,
    bool isLowPowerMode = false,
  }) => AdaptiveThemeRule(
      id: _generateRuleId(),
      trigger: AdaptationTrigger.batteryLevel,
      conditions: {
        'minLevel': minBatteryLevel,
        'maxLevel': 100,
        'isLowPowerMode': isLowPowerMode,
      },
      targetTheme: theme,
      name: name,
      description: 'Adaptation basée sur la batterie: <$minBatteryLevel%',
      createdAt: DateTime.now(),
      mode: ThemeAdaptationMode.automatic,
    );

  /// Crée une règle d'adaptation saisonnière
  static AdaptiveThemeRule createSeasonalRule({
    required String name,
    required List<String> seasons,
    required EventThemeCustomization theme,
  }) => AdaptiveThemeRule(
      id: _generateRuleId(),
      trigger: AdaptationTrigger.season,
      conditions: {
        'seasons': seasons, // ['spring', 'summer', 'autumn', 'winter']
      },
      targetTheme: theme,
      name: name,
      description: 'Adaptation saisonnière: ${seasons.join(', ')}',
      createdAt: DateTime.now(),
      mode: ThemeAdaptationMode.automatic,
    );

  /// Analyse les tendances d'utilisation
  static Future<Map<String, dynamic>> analyzeUsagePatterns() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // Simuler l'analyse des patterns d'utilisation
    return {
      'peakUsageHours': [9, 14, 20], // Heures de pic d'utilisation
      'preferredThemes': [
        {'theme': 'professional', 'usage': 45},
        {'theme': 'creative', 'usage': 30},
        {'theme': 'minimal', 'usage': 25},
      ],
      'adaptationFrequency': 12, // Nombre d'adaptations cette semaine
      'mostTriggeredRules': [
        {'rule': 'Morning Theme', 'count': 8},
        {'rule': 'Evening Theme', 'count': 6},
        {'rule': 'Low Battery', 'count': 3},
      ],
      'userSatisfaction': 4.2, // Score sur 5
      'recommendations': [
        'Optimiser les transitions pour les changements fréquents',
        'Ajouter des règles pour le week-end',
        'Personnaliser davantage selon l\'heure',
      ],
    };
  }

  /// Génère des suggestions d'adaptation automatiques
  static Future<List<AdaptiveThemeRule>> generateSmartSuggestions() async {
    final patterns = await analyzeUsagePatterns();
    final suggestions = <AdaptiveThemeRule>[];

    // Suggestion 1: Thème matin basé sur l'heure de pic
    if (patterns['peakUsageHours'].contains(9)) {
      suggestions.add(_generateMorningSuggestion());
    }

    // Suggestion 2: Thème basse consommation
    if (patterns['adaptationFrequency'] > 10) {
      suggestions.add(_generateBatterySuggestion());
    }

    // Suggestion 3: Thème week-end
    suggestions.add(_generateWeekendSuggestion());

    return suggestions;
  }

  /// Teste une règle d'adaptation
  static Future<bool> testRule(AdaptiveThemeRule rule) async {
    final context = _getCurrentContext();
    if (context == null) return false;

    return _shouldTriggerRule(rule, context);
  }

  /// Exporte les règles d'adaptation
  static Map<String, dynamic> exportRules() => {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'rules': _rules.map((rule) => rule.toJson()).toList(),
      'statistics': {
        'totalRules': _rules.length,
        'activeRules': getActiveRules().length,
        'rulesByTrigger': _rules.fold<Map<AdaptationTrigger, int>>(
          {},
          (map, rule) {
            map[rule.trigger] = (map[rule.trigger] ?? 0) + 1;
            return map;
          },
        ).map((k, v) => MapEntry(k.name, v)),
      },
    };

  /// Importe des règles d'adaptation
  static Future<void> importRules(Map<String, dynamic> data) async {
    final rulesData = data['rules'] as List?;
    if (rulesData != null) {
      for (final ruleData in rulesData) {
        final rule = AdaptiveThemeRule.fromJson(ruleData);
        await addRule(rule);
      }
    }
  }

  /// Réinitialise toutes les règles
  static Future<void> resetRules() async {
    _rules.clear();
    await _saveRules();
    _eventController.add(const AdaptiveThemeEvent(
      type: AdaptiveEventType.rulesReset,
    ));
  }

  // Méthodes privées

  static String _generateRuleId() => 'rule_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';

  static Map<String, dynamic>? _getCurrentContext() {
    final now = DateTime.now();

    return {
      'timeOfDay': now.hour,
      'dayOfWeek': now.weekday,
      'season': _getCurrentSeason(now),
      'batteryLevel': 85, // Simulé
      'weather': 'sunny', // Simulé
      'location': 'Paris', // Simulé
      'activity': 'work', // Simulé
      'deviceOrientation': 'portrait', // Simulé
      'ambientLight': 'bright', // Simulé
      'systemTheme': 'light', // Simulé
    };
  }

  static String _getCurrentSeason(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  static Future<bool> _shouldTriggerRule(AdaptiveThemeRule rule, Map<String, dynamic> context) async {
    switch (rule.trigger) {
      case AdaptationTrigger.timeOfDay:
        return _checkTimeCondition(rule.conditions, context);
      case AdaptationTrigger.weather:
        return _checkWeatherCondition(rule.conditions, context);
      case AdaptationTrigger.location:
        return _checkLocationCondition(rule.conditions, context);
      case AdaptationTrigger.userActivity:
        return _checkActivityCondition(rule.conditions, context);
      case AdaptationTrigger.batteryLevel:
        return _checkBatteryCondition(rule.conditions, context);
      case AdaptationTrigger.season:
        return _checkSeasonCondition(rule.conditions, context);
      case AdaptationTrigger.weekday:
        return _checkWeekdayCondition(rule.conditions, context);
      case AdaptationTrigger.systemTheme:
        return _checkSystemThemeCondition(rule.conditions, context);
      default:
        return false;
    }
  }

  static bool _checkTimeCondition(Map<String, dynamic> conditions, Map<String, dynamic> context) {
    final currentTime = context['timeOfDay'] as int;
    final startTime = conditions['startTime']['hour'] as int;
    final endTime = conditions['endTime']['hour'] as int;
    final daysOfWeek = (conditions['daysOfWeek'] as List?)?.cast<int>() ?? [];

    // Vérifier le jour de la semaine
    if (daysOfWeek.isNotEmpty && !daysOfWeek.contains(context['dayOfWeek'])) {
      return false;
    }

    // Vérifier l'heure
    if (startTime <= endTime) {
      return currentTime >= startTime && currentTime < endTime;
    } else {
      // Cas où la période traverse minuit (ex: 22h - 6h)
      return currentTime >= startTime || currentTime < endTime;
    }
  }

  static bool _checkWeatherCondition(Map<String, dynamic> conditions, Map<String, dynamic> context) {
    final currentWeather = context['weather'] as String;
    final conditionsList = (conditions['conditions'] as List?)?.cast<String>() ?? [];

    return conditionsList.contains(currentWeather);
  }

  static bool _checkLocationCondition(Map<String, dynamic> conditions, Map<String, dynamic> context) {
    final currentLocation = context['location'] as String;
    final locations = (conditions['locations'] as List?)?.cast<String>() ?? [];

    return locations.contains(currentLocation);
  }

  static bool _checkActivityCondition(Map<String, dynamic> conditions, Map<String, dynamic> context) {
    final currentActivity = context['activity'] as String;
    final activities = (conditions['activities'] as List?)?.cast<String>() ?? [];

    return activities.contains(currentActivity);
  }

  static bool _checkBatteryCondition(Map<String, dynamic> conditions, Map<String, dynamic> context) {
    final currentBattery = context['batteryLevel'] as int;
    final minLevel = conditions['minLevel'] as int;

    return currentBattery <= minLevel;
  }

  static bool _checkSeasonCondition(Map<String, dynamic> conditions, Map<String, dynamic> context) {
    final currentSeason = context['season'] as String;
    final seasons = (conditions['seasons'] as List?)?.cast<String>() ?? [];

    return seasons.contains(currentSeason);
  }

  static bool _checkWeekdayCondition(Map<String, dynamic> conditions, Map<String, dynamic> context) {
    final currentDay = context['dayOfWeek'] as int;
    final days = (conditions['days'] as List?)?.cast<int>() ?? [];

    return days.contains(currentDay);
  }

  static bool _checkSystemThemeCondition(Map<String, dynamic> conditions, Map<String, dynamic> context) {
    final currentTheme = context['systemTheme'] as String;
    final themes = (conditions['themes'] as List?)?.cast<String>() ?? [];

    return themes.contains(currentTheme);
  }

  static Future<void> _triggerRule(AdaptiveThemeRule rule) async {
    // Mettre à jour les statistiques de la règle
    final updatedRule = rule.copyWith(
      lastTriggered: DateTime.now(),
      triggerCount: rule.triggerCount + 1,
    );

    final index = _rules.indexWhere((r) => r.id == rule.id);
    if (index != -1) {
      _rules[index] = updatedRule;
      await _saveRules();
    }

    // Émettre l'événement d'adaptation
    _eventController.add(AdaptiveThemeEvent(
      type: AdaptiveEventType.themeAdapted,
      ruleId: rule.id,
      data: {
        'theme': rule.targetTheme,
        'transition': {
          'duration': rule.transitionDuration,
          'curve': rule.transitionCurve,
        },
      },
    ));

    // Appliquer le thème (simulé)
    _currentTheme = rule.targetTheme;
  }

  static void _setupSystemListeners() {
    // Écouter les changements système
    // Note: Ceci est une simulation, en réalité utiliserait des plugins spécifiques
    _subscriptions.add(Stream.periodic(const Duration(minutes: 1))
        .listen((_) => _checkAdaptationRules()));
  }

  static void _startScheduledRules() {
    for (final rule in getActiveRules()) {
      if (rule.mode == ThemeAdaptationMode.scheduled && rule.scheduleTimes.isNotEmpty) {
        _scheduleRule(rule);
      }
    }
  }

  static void _scheduleRule(AdaptiveThemeRule rule) {
    for (final scheduledTime in rule.scheduleTimes) {
      final now = TimeOfDay.now();
      final scheduled = TimeOfDay(hour: scheduledTime.hour, minute: scheduledTime.minute);

      // Calculer le délai jusqu'à la prochaine exécution
      final nowMinutes = now.hour * 60 + now.minute;
      final scheduledMinutes = scheduled.hour * 60 + scheduled.minute;

      int delayMinutes;
      if (scheduledMinutes > nowMinutes) {
        delayMinutes = scheduledMinutes - nowMinutes;
      } else {
        delayMinutes = (24 * 60) - nowMinutes + scheduledMinutes;
      }

      final timer = Timer(Duration(minutes: delayMinutes), () {
        _triggerRule(rule);
        // Replanifier pour le lendemain
        _scheduleRule(rule);
      });

      _timers[rule.trigger] = timer;
    }
  }

  static void _startPeriodicChecks() {
    // Vérifications périodiques pour les triggers automatiques
    Timer.periodic(const Duration(minutes: 5), (_) {
      _checkAdaptationRules();
    });
  }

  static Future<void> _loadRules() async {
    // Simuler le chargement depuis le stockage local
    // En réalité, utiliserait SharedPreferences ou une base de données
  }

  static Future<void> _saveRules() async {
    // Simuler la sauvegarde dans le stockage local
    // En réalité, utiliserait SharedPreferences ou une base de données
  }

  static AdaptiveThemeRule _generateMorningSuggestion() => createTimeBasedRule(
      name: 'Morning Focus Theme',
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 12, minute: 0),
      theme: const EventThemeCustomization(
        primaryColor: Color(0xFF2196F3),
        backgroundColor: Color(0xFFFFFFFF),
        textColor: Color(0xFF212121),
      ),
    );

  static AdaptiveThemeRule _generateBatterySuggestion() => createBatteryBasedRule(
      name: 'Power Saver Mode',
      minBatteryLevel: 20,
      theme: const EventThemeCustomization(
        primaryColor: Color(0xFF757575),
        backgroundColor: Color(0xFFFAFAFA),
        textColor: Color(0xFF212121),
        showBackgroundPattern: false,
        shadowOpacity: 0.05,
      ),
    );

  static AdaptiveThemeRule _generateWeekendSuggestion() => AdaptiveThemeRule(
      id: _generateRuleId(),
      trigger: AdaptationTrigger.weekday,
      conditions: {
        'days': [6, 7], // Samedi, Dimanche
      },
      targetTheme: const EventThemeCustomization(
        primaryColor: Color(0xFF4CAF50),
        backgroundColor: Color(0xFFF1F8E9),
        textColor: Color(0xFF1B5E20),
      ),
      name: 'Weekend Relax Theme',
      description: 'Thème détente pour le week-end',
      createdAt: DateTime.now(),
      mode: ThemeAdaptationMode.automatic,
    );

  /// Dispose le service
  static void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }

    for (final timer in _timers.values) {
      timer.cancel();
    }

    _timers.clear();
    _eventController.close();
  }
}

class AdaptiveThemeEvent {

  const AdaptiveThemeEvent({
    required this.type,
    this.ruleId,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? const Duration().inMilliseconds != 0
           ? DateTime.now()
           : DateTime.now();

  factory AdaptiveThemeEvent.fromJson(Map<String, dynamic> json) => AdaptiveThemeEvent(
      type: AdaptiveEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AdaptiveEventType.unknown,
      ),
      ruleId: json['ruleId'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  final AdaptiveEventType type;
  final String? ruleId;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
      'type': type.name,
      'ruleId': ruleId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
}

enum AdaptiveEventType {
  unknown,
  ruleAdded,
  ruleUpdated,
  ruleRemoved,
  rulesReset,
  themeAdapted,
  adaptationFailed,
  userPreferenceChanged,
  systemContextChanged,
}
