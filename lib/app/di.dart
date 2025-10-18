/// Configuration de l'injection de dépendances
library;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycard/core/services/ai_color_generator_service.dart';
import 'package:mycard/core/services/auth_repository.dart';
import 'package:mycard/core/services/auth_service.dart';
import 'package:mycard/core/services/community_theme_service_simple.dart';
import 'package:mycard/data/repo/cards_repo.dart';
import 'package:mycard/data/repo/events_repo.dart';
import 'package:mycard/data/repo/templates_repo.dart';
// import 'package:mycard/core/services/photo_integration_service.dart';
// import 'package:mycard/core/services/theme_analytics_service.dart';

// Providers pour les repositories
final templatesRepositoryProvider = Provider<TemplatesRepository>((ref) => TemplatesRepository());

final eventsRepositoryProvider = Provider<EventsRepository>((ref) => EventsRepository());

final cardsRepositoryProvider = Provider<CardsRepository>((ref) => CardsRepository());

// Auth
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final authStateProvider = StreamProvider<User?>((ref) => ref.read(authRepositoryProvider).authStateChanges);

// Service d'authentification amélioré
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// État d'initialisation de l'auth
final authInitializationProvider = FutureProvider<void>((ref) async {
  final authService = ref.read(authServiceProvider);
  await authService.initialize();
});

// Providers pour les services avancés
final aiColorGeneratorProvider = Provider<AIColorGeneratorService>((ref) => AIColorGeneratorService());

final communityThemeProvider = Provider<CommunityThemeService>((ref) => CommunityThemeService());

// Services temporaires pour éviter les erreurs (à implémenter plus tard)
class PhotoIntegrationService {
  PhotoIntegrationService._();
  static final instance = PhotoIntegrationService._();
}

class ThemeAnalyticsWrapper {
  static Future<void> initialize() async {}
  static Future<void> trackEvent({required String type, String? userId, Map<String, dynamic> properties = const {}, Duration? duration}) async {}
  static Future<void> trackThemeCreated({required String themeId, required String themeName, String? templateUsed, Map<String, dynamic>? themeProperties}) async {}
  static Future<void> trackThemeModified({required String themeId, required List<String> changedProperties, Map<String, dynamic>? oldValues, Map<String, dynamic>? newValues}) async {}
  static Future<void> trackThemeExported({required String themeId, required String format, int? fileSize, bool? includePreview}) async {}
  static Future<void> trackFeatureUsed({required String featureName, required String action, Map<String, dynamic>? parameters}) async {}
  static Future<void> trackSearch({required String query, required int resultsCount, String? category, List<String>? filters}) async {}
  static Future<void> trackError({required String errorType, required String errorMessage, String? stackTrace, Map<String, dynamic>? context}) async {}
  static Future<void> endSession() async {}
}

final themeAnalyticsProvider = Provider<ThemeAnalyticsWrapper>((ref) => ThemeAnalyticsWrapper());

// Services temporaires pour éviter les erreurs (à implémenter plus tard)
class AdaptiveThemeWrapper {
  static Future<void> initialize() async {}
  static Future<void> applyTheme(String themeId) async {}
  static Future<void> toggleDarkMode() async {}
  static bool isDarkMode() => false;
  static String getCurrentTheme() => 'default';
}

class CollaborativeThemeWrapper {
  static Future<void> initialize() async {}
  static Future<String> createSession(String themeId) async => 'session_id';
  static Future<void> joinSession(String sessionId) async {}
  static Future<void> leaveSession(String sessionId) async {}
  static Stream<Map<String, dynamic>> getSessionUpdates(String sessionId) => const Stream.empty();
  static Future<void> updateTheme(String sessionId, Map<String, dynamic> updates) async {}
}

final adaptiveThemeProvider = Provider<AdaptiveThemeWrapper>((ref) => AdaptiveThemeWrapper());

final collaborativeThemeProvider = Provider<CollaborativeThemeWrapper>((ref) => CollaborativeThemeWrapper());

// Providers pour l'état de l'application
final isLoadingProvider = StateProvider<bool>((ref) => false);
final errorMessageProvider = StateProvider<String?>((ref) => null);

// Provider pour l'initialisation de l'application
final appInitializationProvider = FutureProvider<void>((ref) async {
  // Initialiser les repositories
  final templatesRepo = ref.read(templatesRepositoryProvider);
  final eventsRepo = ref.read(eventsRepositoryProvider);
  final cardsRepo = ref.read(cardsRepositoryProvider);

  // Charger les données initiales
  await templatesRepo.loadTemplates();
  await eventsRepo.loadEvents();
  await cardsRepo.init();
});
