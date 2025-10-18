/// Page de gestion des thèmes personnalisés
library;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycard/core/services/theme_service.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/features/events/page_event_theme_preview.dart';

class CustomThemesManagerPage extends StatefulWidget {
  const CustomThemesManagerPage({super.key});

  @override
  State<CustomThemesManagerPage> createState() => _CustomThemesManagerPageState();
}

class _CustomThemesManagerPageState extends State<CustomThemesManagerPage> {
  Map<String, Map<String, dynamic>> _customThemes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomThemes();
  }

  Future<void> _loadCustomThemes() async {
    final themes = await ThemeService.getAllCustomThemes();
    setState(() {
      _customThemes = themes;
      _isLoading = false;
    });
  }

  Future<void> _deleteTheme(String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le thème'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce thème personnalisé ?\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ThemeService.deleteCustomTheme(eventId);
      if (success) {
        await _loadCustomThemes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thème supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la suppression'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _importTheme() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importer un thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Collez le code du thème à importer:'),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Code du thème...',
              ),
              controller: TextEditingController(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement theme import
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonction d\'import à implémenter'),
                  ),
                );
              }
            },
            child: const Text('Importer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Thèmes personnalisés'),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: _importTheme,
              tooltip: 'Importer un thème',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadCustomThemes,
              tooltip: 'Actualiser',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _customThemes.isEmpty
                ? _buildEmptyState()
                : _buildThemesList(),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun thème personnalisé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez des thèmes personnalisés pour vos événements préférés',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour aux événements'),
            ),
          ],
        ),
      );

  Widget _buildThemesList() => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customThemes.length,
        itemBuilder: (context, index) {
          final entry = _customThemes.entries.elementAt(index);
          final eventId = entry.key;
          final themeData = entry.value;
          final eventName = themeData['eventName'] as String;
          final savedAt = DateTime.parse(themeData['savedAt'] as String);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.palette, color: Colors.grey),
              ),
              title: Text(
                eventName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: $eventId'),
                  Text(
                    'Sauvegardé le: ${_formatDate(savedAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editTheme(eventId);
                      break;
                    case 'duplicate':
                      _duplicateTheme(eventId);
                      break;
                    case 'export':
                      _exportTheme(eventId);
                      break;
                    case 'delete':
                      _deleteTheme(eventId);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Dupliquer'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Exporter'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () => _viewTheme(eventId),
            ),
          );
        },
      );

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year} à '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';

  void _viewTheme(String eventId) async {
    // Trouver l'événement correspondant
    final event = EventOverlay.findById(eventId);
    if (event == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événement non trouvé'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Naviguer vers la page de prévisualisation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventThemePreviewPage(event: event),
      ),
    ).then((_) => _loadCustomThemes());
  }

  void _editTheme(String eventId) {
    _viewTheme(eventId);
  }

  void _duplicateTheme(String eventId) {
    // TODO: Implement theme duplication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonction de duplication à implémenter'),
      ),
    );
  }

  void _exportTheme(String eventId) async {
    final themeData = _customThemes[eventId];
    if (themeData == null) return;

    final eventName = themeData['eventName'] as String;
    final customization = EventThemeCustomization.fromJson(
      themeData['customization'] as Map<String, dynamic>,
    );

    final themeJson = ThemeService.exportTheme(customization, eventName);
    await Clipboard.setData(ClipboardData(text: themeJson));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thème exporté dans le presse-papiers'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}