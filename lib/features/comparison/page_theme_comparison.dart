/// Page de comparaison de thèmes en mode split view
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/data/models/event_theme_customization.dart';

class ThemeComparisonPage extends StatefulWidget {
  const ThemeComparisonPage({
    super.key,
    required this.event,
    this.initialTheme1,
    this.initialTheme2,
  });

  final EventOverlay event;
  final EventThemeCustomization? initialTheme1;
  final EventThemeCustomization? initialTheme2;

  @override
  State<ThemeComparisonPage> createState() => _ThemeComparisonPageState();
}

class _ThemeComparisonPageState extends State<ThemeComparisonPage> {
  late EventThemeCustomization _theme1;
  late EventThemeCustomization _theme2;
  bool _isSyncEnabled = false;
  double _splitPosition = 0.5;

  @override
  void initState() {
    super.initState();

    // Créer des thèmes par défaut si aucun n'est fourni
    _theme1 = widget.initialTheme1 ?? _createDefaultTheme('Thème 1');
    _theme2 = widget.initialTheme2 ?? _createDefaultTheme('Thème 2');
  }

  EventThemeCustomization _createDefaultTheme(String name) =>
      EventThemeCustomization(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: 'Thème par défaut',
        colors: {
          'primary': Colors.blue,
          'secondary': Colors.green,
          'background': Colors.white,
          'text': Colors.black,
        },
        createdAt: DateTime.now(),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/gallery'),
      ),
      title: const Text('Comparaison de Thèmes'),
      actions: [
        IconButton(
          icon: Icon(_isSyncEnabled ? Icons.link : Icons.link_off),
          onPressed: () {
            setState(() {
              _isSyncEnabled = !_isSyncEnabled;
            });
          },
          tooltip: _isSyncEnabled
              ? 'Désactiver la synchro'
              : 'Activer la synchro',
        ),
      ],
    ),
    body: Column(
      children: [
        _buildComparisonHeader(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: (_splitPosition * 100).round(),
                child: _buildThemePanel(_theme1, 'Thème 1', true),
              ),
              _buildDivider(),
              Expanded(
                flex: ((1 - _splitPosition) * 100).round(),
                child: _buildThemePanel(_theme2, 'Thème 2', false),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildComparisonHeader() => Container(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thème 1: ${_theme1.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _theme1.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(width: 1, height: 40, color: Colors.grey),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thème 2: ${_theme2.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _theme2.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildDivider() => GestureDetector(
    onHorizontalDragUpdate: (details) {
      setState(() {
        final box = context.findRenderObject() as RenderBox;
        final size = box.size;
        _splitPosition = (details.localPosition.dx / size.width).clamp(
          0.2,
          0.8,
        );
      });
    },
    child: Container(
      width: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.symmetric(
          vertical: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
      ),
      child: const Center(
        child: VerticalDivider(width: 2, thickness: 2, color: Colors.grey),
      ),
    ),
  );

  Widget _buildThemePanel(
    EventThemeCustomization theme,
    String title,
    bool isLeft,
  ) => Container(
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        _buildThemeHeader(theme, title),
        Expanded(child: _buildThemePreview(theme)),
        _buildThemeActions(theme, isLeft),
      ],
    ),
  );

  Widget _buildThemeHeader(EventThemeCustomization theme, String title) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colors['background'] ?? Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colors['primary'] ?? Colors.blue,
              radius: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colors['text'] ?? Colors.black,
                    ),
                  ),
                  Text(
                    theme.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colors['text'] ?? Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildThemePreview(EventThemeCustomization theme) => Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors['background'] ?? Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Aperçu du thème\n${theme.name}',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colors['text'] ?? Colors.black),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildColorPalette(theme),
      ],
    ),
  );

  Map<String, String> _convertThemeToCustomColors(
    EventThemeCustomization theme,
  ) => theme.colors.map(
    (key, value) => MapEntry(
      key,
      '#${value.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
    ),
  );

  Widget _buildColorPalette(EventThemeCustomization theme) => Container(
    height: 60,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: theme.colors.entries
          .map(
            (entry) => Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 10,
                      color: entry.value.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _buildThemeActions(EventThemeCustomization theme, bool isLeft) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Appliquer le thème
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Thème "${theme.name}" appliqué')),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Appliquer'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                _showThemeOptions(theme, isLeft);
              },
              icon: const Icon(Icons.more_vert),
              tooltip: 'Options',
            ),
          ],
        ),
      );

  void _showThemeOptions(EventThemeCustomization theme, bool isLeft) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Personnaliser'),
              onTap: () {
                context.pop();
                // TODO: Ouvrir l'éditeur de thème
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Dupliquer'),
              onTap: () {
                context.pop();
                // TODO: Dupliquer le thème
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Partager'),
              onTap: () {
                context.pop();
                // TODO: Partager le thème
              },
            ),
          ],
        ),
      ),
    );
  }
}
