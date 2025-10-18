import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/app/theme.dart';

class MainNavBar extends StatelessWidget {
  const MainNavBar({super.key, required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: AppTheme.greenWhite,
        indicatorColor: AppTheme.burntSienna.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        onDestinationSelected: (i) => switch (i) {
          0 => context.go('/gallery'),
          1 => context.go('/templates'),
          2 => context.go('/settings'),
          _ => null,
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.badge_outlined, color: AppTheme.deepSapphire),
            selectedIcon: Icon(Icons.badge, color: AppTheme.burntSienna),
            label: 'Mes Cartes',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined, color: AppTheme.deepSapphire),
            selectedIcon: Icon(Icons.style, color: AppTheme.burntSienna),
            label: 'Modèles',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: AppTheme.deepSapphire),
            selectedIcon: Icon(Icons.settings, color: AppTheme.burntSienna),
            label: 'Paramètres',
          ),
        ],
      );
}
