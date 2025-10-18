import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycard/app/di.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/core/services/auth_service.dart';

/// Écran de chargement pendant la vérification de l'authentification
class AuthLoadingScreen extends ConsumerStatefulWidget {
  const AuthLoadingScreen({super.key});

  @override
  ConsumerState<AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends ConsumerState<AuthLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _logoAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthState();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _logoController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _checkAuthState() async {
    final authRepository = ref.read(authRepositoryProvider);

    // Attendre un peu pour l'animation
    await Future.delayed(const Duration(milliseconds: 2000));

    // L'état sera géré par le GoRouter et le Stream<User?>
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0806) : AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animé
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) => Transform.scale(
                  scale: _logoAnimation.value,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.contact_page_outlined,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ),
                ),
            ),

            const SizedBox(height: 40),

            // Titre avec animation de fade
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) => FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'MyCard',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cartes de visite professionnelles',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B5E56),
                        ),
                      ),
                    ],
                  ),
                ),
            ),

            const SizedBox(height: 60),

            // Indicateur de chargement personnalisé
            Column(
              children: [
                Text(
                  'Vérification de votre connexion...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B5E56),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Message informatif
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1A17) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF3A332E) : const Color(0xFFE7D9CF),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isDark ? const Color(0xFF60A5FA) : AppTheme.easternBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Restez connecté et accédez à vos cartes rapidement',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B5E56),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// État de chargement pour l'authentification
class AuthLoadingState {

  const AuthLoadingState({
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });
  final bool isLoading;
  final bool isInitialized;
  final String? error;

  AuthLoadingState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? error,
  }) => AuthLoadingState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
    );
}

/// Provider pour l'état de chargement d'authentification
final authLoadingProvider = StateNotifierProvider<AuthLoadingNotifier, AuthLoadingState>((ref) => AuthLoadingNotifier());

class AuthLoadingNotifier extends StateNotifier<AuthLoadingState> {
  AuthLoadingNotifier() : super(const AuthLoadingState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final authService = AuthService();
      await authService.initialize();

      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const AuthLoadingState();
  }
}