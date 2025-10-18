import 'dart:convert';
import 'dart:io';

import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Classe pour représenter une carte de visite sauvegardée
class SavedCard {
  SavedCard({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.phone,
    required this.email,
    this.company,
    this.website,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.templateId,
    this.eventOverlayId,
    required this.customColors,
    this.fontFamily,
    this.logoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedCard.fromJson(Map<String, dynamic> json) => SavedCard(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    title: json['title'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String,
    company: json['company'] as String?,
    website: json['website'] as String?,
    address: json['address'] as String?,
    city: json['city'] as String?,
    postalCode: json['postalCode'] as String?,
    country: json['country'] as String?,
    templateId: json['templateId'] as String?,
    eventOverlayId: json['eventOverlayId'] as String?,
    customColors: Map<String, String>.from(json['customColors'] as Map),
    fontFamily: json['fontFamily'] as String?,
    logoPath: json['logoPath'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
  final String id;
  final String firstName;
  final String lastName;
  final String title;
  final String phone;
  final String email;
  final String? company;
  final String? website;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? templateId;
  final String? eventOverlayId;
  final Map<String, String> customColors;
  final String? fontFamily;
  final String? logoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'title': title,
    'phone': phone,
    'email': email,
    'company': company,
    'website': website,
    'address': address,
    'city': city,
    'postalCode': postalCode,
    'country': country,
    'templateId': templateId,
    'eventOverlayId': eventOverlayId,
    'customColors': customColors,
    'fontFamily': fontFamily,
    'logoPath': logoPath,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

/// Classe pour représenter une sauvegarde complète
class BackupData {
  BackupData({
    required this.version,
    required this.createdAt,
    required this.cards,
    required this.templates,
    required this.eventOverlays,
  });

  factory BackupData.fromJson(Map<String, dynamic> json) => BackupData(
    version: json['version'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    cards: (json['cards'] as List)
        .map((card) => SavedCard.fromJson(card as Map<String, dynamic>))
        .toList(),
    templates: (json['templates'] as List)
        .map(
          (template) => CardTemplate.fromJson(template as Map<String, dynamic>),
        )
        .toList(),
    eventOverlays: (json['eventOverlays'] as List)
        .map((event) => EventOverlay.fromJson(event as Map<String, dynamic>))
        .toList(),
  );
  final String version;
  final DateTime createdAt;
  final List<SavedCard> cards;
  final List<CardTemplate> templates;
  final List<EventOverlay> eventOverlays;

  Map<String, dynamic> toJson() => {
    'version': version,
    'createdAt': createdAt.toIso8601String(),
    'cards': cards.map((card) => card.toJson()).toList(),
    'templates': templates.map((template) => template.toJson()).toList(),
    'eventOverlays': eventOverlays.map((event) => event.toJson()).toList(),
  };
}

/// Service pour la sauvegarde et restauration des données
class BackupService {
  static const String _backupVersion = '1.0.0';
  static const String _backupFileName = 'mycard_backup.json';

  /// Crée une sauvegarde complète des données
  static Future<String> createBackup({
    required List<SavedCard> cards,
    List<CardTemplate>? templates,
    List<EventOverlay>? eventOverlays,
  }) async {
    final backupData = BackupData(
      version: _backupVersion,
      createdAt: DateTime.now(),
      cards: cards,
      templates: templates ?? [],
      eventOverlays: eventOverlays ?? [],
    );

    final jsonString = jsonEncode(backupData.toJson());

    // Sauvegarder dans le répertoire de documents
    final directory = await getApplicationDocumentsDirectory();
    final backupFile = File('${directory.path}/$_backupFileName');
    await backupFile.writeAsString(jsonString);

    return backupFile.path;
  }

  /// Partage une sauvegarde
  static Future<void> shareBackup(String backupPath) async {
    final file = File(backupPath);
    if (await file.exists()) {
      await Share.shareXFiles(
        [
          XFile(
            backupPath,
            name: 'mycard_backup.json',
            mimeType: 'application/json',
          ),
        ],
        subject: 'MyCard Backup',
        text: 'Sauvegarde de vos cartes de visite MyCard',
      );
    }
  }

  /// Restaure des données depuis un fichier de sauvegarde
  static Future<BackupData?> restoreBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Valider la version de la sauvegarde
      final version = jsonData['version'] as String?;
      if (version == null || !_isVersionCompatible(version)) {
        throw Exception('Version de sauvegarde incompatible: $version');
      }

      return BackupData.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si une version de sauvegarde est compatible
  static bool isVersionCompatible(String version) {
    // Pour l'instant, on accepte seulement la version actuelle
    return version == _backupVersion;
  }

  /// @visibleForTesting - Vérifie si une version de sauvegarde est compatible
  static bool _isVersionCompatible(String version) =>
      isVersionCompatible(version);

  /// Supprime une sauvegarde
  static Future<bool> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Récupère la liste des sauvegardes disponibles
  static Future<List<File>> getAvailableBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = await directory
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      // Filtrer pour ne garder que les fichiers de sauvegarde valides
      final validBackups = <File>[];
      for (final file in files) {
        try {
          final content = await file.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;
          if (json['version'] != null && json['createdAt'] != null) {
            validBackups.add(file);
          }
        } catch (e) {
          // Ignorer les fichiers invalides
        }
      }

      // Trier par date de modification (plus récent en premier)
      validBackups.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      return validBackups;
    } catch (e) {
      return [];
    }
  }

  /// Calcule la taille d'une sauvegarde en octets
  static Future<int> getBackupSize(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Valide un fichier de sauvegarde
  static Future<bool> validateBackup(String backupPath) async {
    try {
      final backupData = await restoreBackup(backupPath);
      return backupData != null;
    } catch (e) {
      return false;
    }
  }

  /// Exporte une sauvegarde vers un format spécifique
  static Future<String> exportBackup({
    required BackupData backupData,
    BackupFormat format = BackupFormat.json,
  }) async {
    switch (format) {
      case BackupFormat.json:
        return jsonEncode(backupData.toJson());
      case BackupFormat.csv:
        return exportToCsv(backupData);
    }
  }

  /// Exporte les données au format CSV
  static String exportToCsv(BackupData backupData) {
    final buffer = StringBuffer();

    // En-tête CSV
    buffer.writeln(
      'ID,Prénom,Nom,Titre,Téléphone,Email,Entreprise,Site Web,Adresse,Ville,Code Postal,Pays,Template,Événement,Créé le,Modifié le',
    );

    // Lignes de données
    for (final card in backupData.cards) {
      buffer.writeln(
        [
          card.id,
          card.firstName,
          card.lastName,
          card.title,
          card.phone,
          card.email,
          card.company ?? '',
          card.website ?? '',
          card.address ?? '',
          card.city ?? '',
          card.postalCode ?? '',
          card.country ?? '',
          card.templateId ?? '',
          card.eventOverlayId ?? '',
          card.createdAt.toIso8601String(),
          card.updatedAt.toIso8601String(),
        ].join(','),
      );
    }

    return buffer.toString();
  }
}

/// Formats d'export supportés
enum BackupFormat { json, csv }
