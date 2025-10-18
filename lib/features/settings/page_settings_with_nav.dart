/// Page des paramètres avec barre de navigation
library;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/app/di.dart';

class SettingsPageWithNav extends ConsumerWidget {
  const SettingsPageWithNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/gallery'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _ProfileHeader(ref: ref),
          const SizedBox(height: 12),
          _buildSection(
            title: 'Personnalisation',
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil'),
                subtitle: const Text('Informations personnelles'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implémenter la page de profil
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Thème'),
                subtitle: const Text('Personnaliser l\'apparence'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showThemeDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Langue'),
                subtitle: const Text('Français'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Application',
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('À propos'),
                subtitle: const Text('Version et informations'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Aide'),
                subtitle: const Text('Centre d\'aide'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implémenter le centre d'aide
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Confidentialité'),
                subtitle: const Text('Politique de confidentialité'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showPrivacyDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Compte',
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Se déconnecter'),
                onTap: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'MyCard v1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildSection({required String title, required List<Widget> children}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Column(
            children: children,
          ),
        ),
      ],
    );

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thème'),
        content: const Text('Choisissez le thème de l\'application'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Système'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Clair'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sombre'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Langue'),
        content: const Text('Choisissez la langue de l\'application'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Français'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('English'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Español'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MyCard',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.credit_card),
      children: [
        const Text('Application de création de cartes de visite professionnelles'),
        const SizedBox(height: 16),
        const Text('Fonctionnalités principales :'),
        const Text('• Création de cartes personnalisées'),
        const Text('• Modèles prédéfinis'),
        const Text('• Générateur de couleurs IA'),
        const Text('• Thèmes communautaires'),
        const Text('• Exportation multiple formats'),
      ],
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confidentialité'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nous prenons votre confidentialité très au sérieux.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Données collectées :\n'
                '• Informations de profil\n'
                '• Préférences utilisateur\n'
                '• Données d\'utilisation anonymisées',
              ),
              SizedBox(height: 16),
              Text(
                'Utilisation des données :\n'
                '• Amélioration de l\'application\n'
                '• Personnalisation de l\'expérience\n'
                '• Support client',
              ),
              SizedBox(height: 16),
              Text(
                'Vos données ne sont jamais partagées avec des tiers sans votre consentement.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'Utilisateur';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[200],
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(email.isEmpty ? 'Non connecté' : email),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {},
          tooltip: 'Modifier le profil',
        ),
      ),
    );
  }
}
