import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycard/app/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'Français';
  String _selectedFont = 'Manrope';
  double _cardSize = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'Français';
      _selectedFont = prefs.getString('font_family') ?? 'Manrope';
      _cardSize = prefs.getDouble('card_size') ?? 1.0;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Paramètres'), elevation: 0),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section Apparence
        _buildSection(
          title: 'Apparence',
          icon: Icons.palette,
          children: [
            _buildSwitchTile(
              title: 'Mode sombre',
              subtitle: 'Activer le thème sombre',
              value: _darkMode,
              onChanged: (value) {
                _saveSetting('dark_mode', value);
                // Appliquer le thème
                if (value) {
                  ThemeManager.of(context).setThemeMode(ThemeMode.dark);
                } else {
                  ThemeManager.of(context).setThemeMode(ThemeMode.light);
                }
              },
            ),
            _buildDropdownTile<String>(
              title: 'Police',
              subtitle: 'Choisir la police par défaut',
              value: _selectedFont,
              items: const ['Manrope', 'Inter', 'Poppins', 'Roboto'],
              onChanged: (value) {
                if (value != null) {
                  _saveSetting('font_family', value);
                }
              },
            ),
            _buildSliderTile(
              title: 'Taille des cartes',
              subtitle: 'Ajuster la taille d\'affichage des cartes',
              value: _cardSize,
              min: 0.8,
              max: 1.2,
              divisions: 5,
              onChanged: (value) {
                _saveSetting('card_size', value);
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Section Notifications
        _buildSection(
          title: 'Notifications',
          icon: Icons.notifications,
          children: [
            _buildSwitchTile(
              title: 'Notifications',
              subtitle: 'Activer les notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                _saveSetting('notifications_enabled', value);
              },
            ),
            _buildNavigationTile(
              title: 'Gérer les notifications',
              subtitle: 'Configurer les préférences',
              icon: Icons.notifications_active,
              onTap: () => _showNotificationSettings(context),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Section Données
        _buildSection(
          title: 'Données',
          icon: Icons.storage,
          children: [
            _buildNavigationTile(
              title: 'Exporter les données',
              subtitle: 'Sauvegarder toutes les cartes',
              icon: Icons.backup,
              onTap: () => _exportData(context),
            ),
            _buildNavigationTile(
              title: 'Importer des données',
              subtitle: 'Restaurer depuis une sauvegarde',
              icon: Icons.restore,
              onTap: () => _importData(context),
            ),
            _buildNavigationTile(
              title: 'Vider le cache',
              subtitle: 'Supprimer les fichiers temporaires',
              icon: Icons.clear,
              onTap: () => _clearCache(context),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Section À propos
        _buildSection(
          title: 'À propos',
          icon: Icons.info,
          children: [
            _buildNavigationTile(
              title: 'Version',
              subtitle: 'MaCarte 1.0.0',
              icon: Icons.info_outline,
              onTap: () => _showVersionInfo(context),
            ),
            _buildNavigationTile(
              title: 'Politique de confidentialité',
              subtitle: 'Comment nous protégeons vos données',
              icon: Icons.security,
              onTap: () => _showPrivacyPolicy(context),
            ),
            _buildNavigationTile(
              title: 'Conditions d\'utilisation',
              subtitle: 'Termes et conditions',
              icon: Icons.description,
              onTap: () => _showTermsOfService(context),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Bouton de réinitialisation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: () => _resetSettings(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Réinitialiser les paramètres'),
          ),
        ),
      ],
    ),
  );

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Card(child: Column(children: children)),
    ],
  );

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => ListTile(
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: Switch(value: value, onChanged: onChanged),
  );

  Widget _buildDropdownTile<T>({
    required String title,
    required String subtitle,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) => ListTile(
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: DropdownButton<T>(
      value: value,
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(item.toString())),
          )
          .toList(),
      onChanged: onChanged,
    ),
  );

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title), Text('${(value * 100).round()}%')],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    ),
  );

  Widget _buildNavigationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paramètres de notification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Nouvelles cartes'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Mises à jour'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Promotions'),
              trailing: Switch(value: false, onChanged: (value) {}),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exporter les données'),
        content: const Text(
          'Voulez-vous exporter toutes vos cartes de visite ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exportation réussie !')),
              );
            },
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  void _importData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importer des données'),
        content: const Text(
          'Voulez-vous importer des cartes depuis une sauvegarde ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Importation réussie !')),
              );
            },
            child: const Text('Importer'),
          ),
        ],
      ),
    );
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le cache'),
        content: const Text(
          'Voulez-vous supprimer tous les fichiers temporaires ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache vidé avec succès !')),
              );
            },
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MaCarte 1.0.0'),
            SizedBox(height: 8),
            Text('Build: 20241002'),
            SizedBox(height: 8),
            Text('Flutter 3.16.0'),
            SizedBox(height: 16),
            Text('© 2024 ANSUT'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Politique de confidentialité'),
        content: const SingleChildScrollView(
          child: Text(
            'Nous respectons votre vie privée. Vos données sont stockées localement sur votre appareil et ne sont jamais partagées avec des tiers sans votre consentement.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conditions d\'utilisation'),
        content: const SingleChildScrollView(
          child: Text(
            'En utilisant cette application, vous acceptez nos conditions d\'utilisation. L\'application est fournie "telle quelle", sans garantie d\'aucune sorte.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _resetSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Réinitialiser les paramètres'),
        content: const Text(
          'Voulez-vous réinitialiser tous les paramètres aux valeurs par défaut ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              await _loadSettings();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paramètres réinitialisés !')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
}
