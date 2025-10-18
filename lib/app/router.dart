import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/app/di.dart';
import 'package:mycard/data/models/business_card.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/features/ai/page_ai_color_generator.dart';
import 'package:mycard/features/auth/forgot_password_page.dart';
import 'package:mycard/features/auth/login_page.dart';
import 'package:mycard/features/auth/profile_page.dart';
import 'package:mycard/features/auth/signup_page.dart';
import 'package:mycard/features/community/page_community_themes_simple.dart';
import 'package:mycard/features/comparison/page_theme_comparison.dart';
import 'package:mycard/features/editor/page_editor.dart';
import 'package:mycard/features/events/page_events_picker.dart';
import 'package:mycard/features/export/page_export.dart';
import 'package:mycard/features/gallery/page_gallery.dart';
import 'package:mycard/features/settings/page_settings_with_nav.dart';
import 'package:mycard/features/templates/page_templates_list.dart';
import 'package:mycard/widgets/molecules/main_nav_bar.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = notifyListeners;
    _subscription = stream.asBroadcastStream().listen((_) => notifyListener());
  }
  late final VoidCallback notifyListener;
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.read(authRepositoryProvider);
  final refresh = GoRouterRefreshStream(auth.authStateChanges);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.currentUser != null;
      final location = state.matchedLocation;

      final isAuthRoute =
          location.startsWith('/login') ||
          location.startsWith('/signup') ||
          location.startsWith('/forgot');

      // Si l'utilisateur est connecté et sur une page d'auth, rediriger vers la galerie
      if (loggedIn && isAuthRoute) {
        return '/gallery';
      }

      // Si l'utilisateur n'est pas connecté et n'est pas sur une page d'auth
      if (!loggedIn && !isAuthRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(
        path: '/forgot',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/gallery',
            builder: (context, state) => const GalleryPage(),
          ),
          GoRoute(
            path: '/templates',
            builder: (context, state) => const TemplatesListPage(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsPickerPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPageWithNav(),
          ),
        ],
      ),
      GoRoute(
        path: '/editor',
        builder: (context, state) {
          final card = state.extra as BusinessCard?;
          return EditorPage(card: card);
        },
      ),
      GoRoute(
        path: '/export',
        builder: (context, state) {
          final card = state.extra as BusinessCard;
          return ExportPage(card: card);
        },
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      // Routes pour les fonctionnalités avancées
      GoRoute(
        path: '/comparison',
        builder: (context, state) {
          const event = EventOverlay(
            id: 'comparison',
            label: 'Comparaison',
            icon: 'compare',
            period: 'now',
            description: 'Comparer des thèmes',
            color: Colors.blue,
          );
          return const ThemeComparisonPage(event: event);
        },
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityThemesPage(),
      ),
      GoRoute(
        path: '/ai-generator',
        builder: (context, state) => const AIColorGeneratorPage(),
      ),
      GoRoute(
        path: '/photo-integration',
        builder: (context, state) {
          // Page pour l'intégration photo
          return Scaffold(
            appBar: AppBar(title: const Text('Intégration Photo')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_camera, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Intégration Photo',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  const Text('Fonctionnalité en cours d\'intégration'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.go('/editor'),
                    child: const Text('Retour à l\'Éditeur'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: MainNavBar(currentIndex: _getCurrentIndex(context)),
  );

  static int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/gallery')) return 0;
    if (location.startsWith('/templates')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('MyCard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _showSettings(context),
        ),
      ],
    ),
    body: GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildFeatureCard(
          context,
          title: 'Créer une carte',
          icon: Icons.add,
          color: Colors.blue,
          onTap: () => context.go('/editor'),
        ),
        _buildFeatureCard(
          context,
          title: 'Mes cartes',
          icon: Icons.collections_bookmark,
          color: Colors.green,
          onTap: () => context.go('/gallery'),
        ),
        _buildFeatureCard(
          context,
          title: 'Modèles',
          icon: Icons.style,
          color: Colors.purple,
          onTap: () => context.go('/templates'),
        ),
        _buildFeatureCard(
          context,
          title: 'Événements',
          icon: Icons.event,
          color: Colors.orange,
          onTap: () => context.go('/events'),
        ),
        _buildFeatureCard(
          context,
          title: 'Générateur IA',
          icon: Icons.auto_awesome,
          color: Colors.purple,
          onTap: () => context.go('/ai-generator'),
        ),
        _buildFeatureCard(
          context,
          title: 'Comparaison',
          icon: Icons.compare,
          color: Colors.teal,
          onTap: () => context.go('/comparison'),
        ),
        _buildFeatureCard(
          context,
          title: 'Communauté',
          icon: Icons.people,
          color: Colors.red,
          onTap: () => context.go('/community'),
        ),
        _buildFeatureCard(
          context,
          title: 'Intégration Photo',
          icon: Icons.photo_camera,
          color: Colors.green,
          onTap: () => context.go('/photo-integration'),
        ),
      ],
    ),
  );

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Langue'),
              trailing: const Text('Français'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Thème'),
              trailing: const Text('Système'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('À propos'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
