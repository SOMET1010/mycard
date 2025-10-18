/// Service de versioning et gestion de l'historique des thèmes
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeVersionStatus {
  draft, // Brouillon
  active, // Actif
  archived, // Archivé
  deleted, // Supprimé
  published, // Publié
  underReview, // En révision
}

enum ChangeType {
  created, // Créé
  modified, // Modifié
  deleted, // Supprimé
  published, // Publié
  archived, // Archivé
  restored, // Restauré
  duplicated, // Dupliqué
  merged, // Fusionné
}

class ThemeVersion {
  const ThemeVersion({
    required this.id,
    required this.themeId,
    required this.version,
    required this.theme,
    this.changeDescription,
    required this.changeType,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.publishedAt,
    required this.status,
    this.tags = const [],
    this.metadata = const {},
    this.parentVersionId,
    this.childVersionIds = const [],
    this.isMajorVersion = false,
    this.isMinorVersion = false,
    this.isPatchVersion = false,
    this.changelog = const {},
  });

  factory ThemeVersion.fromJson(Map<String, dynamic> json) => ThemeVersion(
    id: json['id'],
    themeId: json['themeId'],
    version: json['version'],
    theme: EventThemeCustomization.fromJson(json['theme']),
    changeDescription: json['changeDescription'],
    changeType: ChangeType.values.firstWhere(
      (e) => e.name == json['changeType'],
      orElse: () => ChangeType.modified,
    ),
    authorId: json['authorId'],
    authorName: json['authorName'],
    createdAt: DateTime.parse(json['createdAt']),
    publishedAt: json['publishedAt'] != null
        ? DateTime.parse(json['publishedAt'])
        : null,
    status: ThemeVersionStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => ThemeVersionStatus.draft,
    ),
    tags: List<String>.from(json['tags'] ?? []),
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    parentVersionId: json['parentVersionId'],
    childVersionIds: List<String>.from(json['childVersionIds'] ?? []),
    isMajorVersion: json['isMajorVersion'] ?? false,
    isMinorVersion: json['isMinorVersion'] ?? false,
    isPatchVersion: json['isPatchVersion'] ?? false,
    changelog: Map<String, dynamic>.from(json['changelog'] ?? {}),
  );
  final String id;
  final String themeId;
  final int version;
  final EventThemeCustomization theme;
  final String? changeDescription;
  final ChangeType changeType;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final ThemeVersionStatus status;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final String? parentVersionId;
  final List<String> childVersionIds;
  final bool isMajorVersion;
  final bool isMinorVersion;
  final bool isPatchVersion;
  final Map<String, dynamic> changelog;

  Map<String, dynamic> toJson() => {
    'id': id,
    'themeId': themeId,
    'version': version,
    'theme': theme.toJson(),
    'changeDescription': changeDescription,
    'changeType': changeType.name,
    'authorId': authorId,
    'authorName': authorName,
    'createdAt': createdAt.toIso8601String(),
    'publishedAt': publishedAt?.toIso8601String(),
    'status': status.name,
    'tags': tags,
    'metadata': metadata,
    'parentVersionId': parentVersionId,
    'childVersionIds': childVersionIds,
    'isMajorVersion': isMajorVersion,
    'isMinorVersion': isMinorVersion,
    'isPatchVersion': isPatchVersion,
    'changelog': changelog,
  };

  String get versionLabel {
    if (isMajorVersion) return '$version.0.0';
    if (isMinorVersion) return '${(version / 100).floor()}.${version % 100}.0';
    return '${(version / 10000).floor()}.${(version / 100).floor() % 100}.${version % 100}';
  }

  ThemeVersion copyWith({
    String? id,
    String? themeId,
    int? version,
    EventThemeCustomization? theme,
    String? changeDescription,
    ChangeType? changeType,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? publishedAt,
    ThemeVersionStatus? status,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? parentVersionId,
    List<String>? childVersionIds,
    bool? isMajorVersion,
    bool? isMinorVersion,
    bool? isPatchVersion,
    Map<String, dynamic>? changelog,
  }) => ThemeVersion(
    id: id ?? this.id,
    themeId: themeId ?? this.themeId,
    version: version ?? this.version,
    theme: theme ?? this.theme,
    changeDescription: changeDescription ?? this.changeDescription,
    changeType: changeType ?? this.changeType,
    authorId: authorId ?? this.authorId,
    authorName: authorName ?? this.authorName,
    createdAt: createdAt ?? this.createdAt,
    publishedAt: publishedAt ?? this.publishedAt,
    status: status ?? this.status,
    tags: tags ?? this.tags,
    metadata: metadata ?? this.metadata,
    parentVersionId: parentVersionId ?? this.parentVersionId,
    childVersionIds: childVersionIds ?? this.childVersionIds,
    isMajorVersion: isMajorVersion ?? this.isMajorVersion,
    isMinorVersion: isMinorVersion ?? this.isMinorVersion,
    isPatchVersion: isPatchVersion ?? this.isPatchVersion,
    changelog: changelog ?? this.changelog,
  );
}

class ThemeVersioningService {
  static const String _versionsKey = 'theme_versions';
  static const String _activeVersionsKey = 'active_theme_versions';
  static const String _versionHistoryKey = 'theme_version_history';

  static final Map<String, List<ThemeVersion>> _themeVersions = {};
  static final Map<String, String> _activeVersions = {};
  static final Map<String, List<String>> _versionHistory = {};

  /// Crée une nouvelle version d'un thème
  static Future<ThemeVersion> createVersion({
    required String themeId,
    required EventThemeCustomization theme,
    required String authorId,
    required String authorName,
    String? changeDescription,
    ChangeType changeType = ChangeType.modified,
    bool isMajorVersion = false,
    bool isMinorVersion = false,
    bool isPatchVersion = true,
    String? parentVersionId,
    List<String> tags = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    final versions = await getThemeVersions(themeId);
    final nextVersion = _calculateNextVersion(
      versions,
      isMajorVersion,
      isMinorVersion,
    );

    final version = ThemeVersion(
      id: _generateVersionId(),
      themeId: themeId,
      version: nextVersion,
      theme: theme,
      changeDescription: changeDescription,
      changeType: changeType,
      authorId: authorId,
      authorName: authorName,
      createdAt: DateTime.now(),
      status: ThemeVersionStatus.draft,
      tags: tags,
      metadata: metadata,
      parentVersionId: parentVersionId,
      isMajorVersion: isMajorVersion,
      isMinorVersion: isMinorVersion,
      isPatchVersion: isPatchVersion,
      changelog: _generateChangelog(theme, parentVersionId),
    );

    await saveVersion(version);

    // Mettre à jour les relations parent-enfant
    if (parentVersionId != null) {
      final parentVersion = await getVersion(parentVersionId);
      if (parentVersion != null) {
        final updatedChildren = List<String>.from(parentVersion.childVersionIds)
          ..add(version.id);
        await updateVersion(
          parentVersion.copyWith(childVersionIds: updatedChildren),
        );
      }
    }

    return version;
  }

  /// Sauvegarde une version de thème
  static Future<void> saveVersion(ThemeVersion version) async {
    final versions = _themeVersions[version.themeId] ?? [];
    versions.add(version);
    _themeVersions[version.themeId] = versions;

    // Ajouter à l'historique
    final history = _versionHistory[version.themeId] ?? [];
    history.insert(0, version.id);
    _versionHistory[version.themeId] = history;

    await _persistVersions();
  }

  /// Récupère toutes les versions d'un thème
  static Future<List<ThemeVersion>> getThemeVersions(String themeId) async {
    await _loadVersions();
    return List.unmodifiable(_themeVersions[themeId] ?? []);
  }

  /// Récupère une version spécifique
  static Future<ThemeVersion?> getVersion(String versionId) async {
    await _loadVersions();

    for (final versions in _themeVersions.values) {
      for (final version in versions) {
        if (version.id == versionId) {
          return version;
        }
      }
    }
    return null;
  }

  /// Récupère la version active d'un thème
  static Future<ThemeVersion?> getActiveVersion(String themeId) async {
    await _loadVersions();
    final activeVersionId = _activeVersions[themeId];
    if (activeVersionId == null) return null;

    return getVersion(activeVersionId);
  }

  /// Définit la version active d'un thème
  static Future<void> setActiveVersion(String themeId, String versionId) async {
    _activeVersions[themeId] = versionId;
    await _persistActiveVersions();
  }

  /// Met à jour une version existante
  static Future<void> updateVersion(ThemeVersion version) async {
    final versions = _themeVersions[version.themeId] ?? [];
    final index = versions.indexWhere((v) => v.id == version.id);

    if (index != -1) {
      versions[index] = version;
      _themeVersions[version.themeId] = versions;
      await _persistVersions();
    }
  }

  /// Supprime une version
  static Future<void> deleteVersion(String versionId) async {
    await _loadVersions();

    for (final themeId in _themeVersions.keys) {
      final versions = _themeVersions[themeId]!;
      final index = versions.indexWhere((v) => v.id == versionId);

      if (index != -1) {
        // Marquer comme supprimé au lieu de supprimer réellement
        versions[index] = versions[index].copyWith(
          status: ThemeVersionStatus.deleted,
        );
        _themeVersions[themeId] = versions;

        // Retirer de l'historique
        final history = _versionHistory[themeId] ?? [];
        history.remove(versionId);
        _versionHistory[themeId] = history;

        await _persistVersions();
        break;
      }
    }
  }

  /// Publie une version
  static Future<void> publishVersion(String versionId) async {
    final version = await getVersion(versionId);
    if (version != null) {
      final updatedVersion = version.copyWith(
        status: ThemeVersionStatus.published,
        publishedAt: DateTime.now(),
      );
      await updateVersion(updatedVersion);
      await setActiveVersion(version.themeId, versionId);
    }
  }

  /// Archive une version
  static Future<void> archiveVersion(String versionId) async {
    final version = await getVersion(versionId);
    if (version != null) {
      final updatedVersion = version.copyWith(
        status: ThemeVersionStatus.archived,
      );
      await updateVersion(updatedVersion);
    }
  }

  /// Restaure une version archivée
  static Future<void> restoreVersion(String versionId) async {
    final version = await getVersion(versionId);
    if (version != null && version.status == ThemeVersionStatus.archived) {
      final updatedVersion = version.copyWith(status: ThemeVersionStatus.draft);
      await updateVersion(updatedVersion);
    }
  }

  /// Duplique une version
  static Future<ThemeVersion> duplicateVersion({
    required String versionId,
    required String newThemeId,
    required String authorId,
    required String authorName,
    String? changeDescription,
  }) async {
    final originalVersion = await getVersion(versionId);
    if (originalVersion == null) {
      throw Exception('Version non trouvée');
    }

    return createVersion(
      themeId: newThemeId,
      theme: originalVersion.theme,
      authorId: authorId,
      authorName: authorName,
      changeDescription:
          changeDescription ??
          'Dupliqué depuis ${originalVersion.versionLabel}',
      changeType: ChangeType.duplicated,
      parentVersionId: versionId,
      tags: originalVersion.tags,
      metadata: Map<String, dynamic>.from(originalVersion.metadata)
        ..['duplicatedFrom'] = versionId,
    );
  }

  /// Fusionne deux versions
  static Future<ThemeVersion> mergeVersions({
    required String versionId1,
    required String versionId2,
    required String authorId,
    required String authorName,
    String? changeDescription,
  }) async {
    final version1 = await getVersion(versionId1);
    final version2 = await getVersion(versionId2);

    if (version1 == null || version2 == null) {
      throw Exception('Versions non trouvées');
    }

    // Logique de fusion simple - utiliser la version la plus récente comme base
    final baseVersion = version1.createdAt.isAfter(version2.createdAt)
        ? version1
        : version2;
    final otherVersion = baseVersion == version1 ? version2 : version1;

    // Fusionner les métadonnées
    final mergedMetadata = Map<String, dynamic>.from(baseVersion.metadata);
    mergedMetadata.addAll(otherVersion.metadata);
    mergedMetadata['mergedFrom'] = [versionId1, versionId2];

    // Fusionner les tags
    final mergedTags = {...baseVersion.tags, ...otherVersion.tags}.toList();

    return createVersion(
      themeId: baseVersion.themeId,
      theme: baseVersion.theme,
      authorId: authorId,
      authorName: authorName,
      changeDescription:
          changeDescription ??
          'Fusion de ${version1.versionLabel} et ${version2.versionLabel}',
      changeType: ChangeType.merged,
      parentVersionId: baseVersion.id,
      tags: mergedTags,
      metadata: mergedMetadata,
    );
  }

  /// Compare deux versions
  static Future<Map<String, dynamic>> compareVersions(
    String versionId1,
    String versionId2,
  ) async {
    final version1 = await getVersion(versionId1);
    final version2 = await getVersion(versionId2);

    if (version1 == null || version2 == null) {
      throw Exception('Versions non trouvées');
    }

    return {
      'version1': {
        'id': version1.id,
        'version': version1.versionLabel,
        'createdAt': version1.createdAt,
        'author': version1.authorName,
      },
      'version2': {
        'id': version2.id,
        'version': version2.versionLabel,
        'createdAt': version2.createdAt,
        'author': version2.authorName,
      },
      'differences': _calculateDifferences(version1.theme, version2.theme),
      'similarity': _calculateSimilarity(version1.theme, version2.theme),
    };
  }

  /// Récupère l'historique des changements d'un thème
  static Future<List<ThemeVersion>> getVersionHistory(
    String themeId, {
    int limit = 50,
  }) async {
    await _loadVersions();
    final history = _versionHistory[themeId] ?? [];
    final versions = <ThemeVersion>[];

    for (final versionId in history.take(limit)) {
      final version = await getVersion(versionId);
      if (version != null && version.status != ThemeVersionStatus.deleted) {
        versions.add(version);
      }
    }

    return versions;
  }

  /// Recherche des versions par critères
  static Future<List<ThemeVersion>> searchVersions({
    String? themeId,
    String? authorId,
    ThemeVersionStatus? status,
    ChangeType? changeType,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    String? query,
  }) async {
    await _loadVersions();
    final results = <ThemeVersion>[];

    for (final versions in _themeVersions.values) {
      for (final version in versions) {
        if (version.status == ThemeVersionStatus.deleted) continue;

        // Filtrer par thème
        if (themeId != null && version.themeId != themeId) continue;

        // Filtrer par auteur
        if (authorId != null && version.authorId != authorId) continue;

        // Filtrer par statut
        if (status != null && version.status != status) continue;

        // Filtrer par type de changement
        if (changeType != null && version.changeType != changeType) continue;

        // Filtrer par date
        if (startDate != null && version.createdAt.isBefore(startDate))
          continue;
        if (endDate != null && version.createdAt.isAfter(endDate)) continue;

        // Filtrer par tags
        if (tags != null && !tags.any(version.tags.contains)) continue;

        // Filtrer par recherche textuelle
        if (query != null) {
          final searchLower = query.toLowerCase();
          if (!version.authorName.toLowerCase().contains(searchLower) &&
              !(version.changeDescription?.toLowerCase().contains(
                    searchLower,
                  ) ??
                  false) &&
              !version.tags.any(
                (tag) => tag.toLowerCase().contains(searchLower),
              )) {
            continue;
          }
        }

        results.add(version);
      }
    }

    // Trier par date de création (plus récent d'abord)
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return results;
  }

  /// Exporte l'historique d'un thème
  static Future<Map<String, dynamic>> exportThemeHistory(String themeId) async {
    final versions = await getThemeVersions(themeId);
    final history = await getVersionHistory(themeId);

    return {
      'themeId': themeId,
      'exportDate': DateTime.now().toIso8601String(),
      'totalVersions': versions.length,
      'activeVersion': _activeVersions[themeId],
      'versions': versions.map((v) => v.toJson()).toList(),
      'history': history.map((v) => v.id).toList(),
      'statistics': _calculateThemeStatistics(versions),
    };
  }

  /// Importe l'historique d'un thème
  static Future<void> importThemeHistory(Map<String, dynamic> data) async {
    final themeId = data['themeId'] as String;
    final versionsData = data['versions'] as List;

    for (final versionData in versionsData) {
      final version = ThemeVersion.fromJson(versionData);
      await saveVersion(version);
    }

    final activeVersionId = data['activeVersion'] as String?;
    if (activeVersionId != null) {
      await setActiveVersion(themeId, activeVersionId);
    }
  }

  // Méthodes privées

  static int _calculateNextVersion(
    List<ThemeVersion> versions,
    bool isMajor,
    bool isMinor,
  ) {
    if (versions.isEmpty) return 100; // 1.0.0

    final sortedVersions = List<ThemeVersion>.from(versions)
      ..sort((a, b) => b.version.compareTo(a.version));

    final latestVersion = sortedVersions.first;

    if (isMajor) {
      // Nouvelle version majeure: X+1.0.0
      final major = (latestVersion.version / 10000).floor();
      return (major + 1) * 10000;
    } else if (isMinor) {
      // Nouvelle version mineure: X.Y+1.0
      final major = (latestVersion.version / 10000).floor();
      final minor = (latestVersion.version / 100).floor() % 100;
      return major * 10000 + (minor + 1) * 100;
    } else {
      // Nouvelle version patch: X.Y.Z+1
      return latestVersion.version + 1;
    }
  }

  static String _generateVersionId() =>
      'version_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';

  static Map<String, dynamic> _generateChangelog(
    EventThemeCustomization theme,
    String? parentVersionId,
  ) {
    // Simulation de génération de changelog
    return {
      'colors': {
        'primaryChanged': true,
        'secondaryChanged': true,
        'backgroundChanged': false,
      },
      'typography': {'fontChanged': false, 'sizeChanged': true},
      'layout': {'paddingChanged': true, 'borderRadiusChanged': false},
      'effects': {'shadowsChanged': true, 'animationsChanged': false},
      'generatedAt': DateTime.now().toIso8601String(),
      'autoGenerated': true,
    };
  }

  static Map<String, dynamic> _calculateDifferences(
    EventThemeCustomization theme1,
    EventThemeCustomization theme2,
  ) {
    final differences = <String, dynamic>{};

    // Comparer les couleurs
    if (theme1.primaryColor != theme2.primaryColor) {
      differences['primaryColor'] = {
        'from': theme1.primaryColor.value,
        'to': theme2.primaryColor.value,
      };
    }

    if (theme1.secondaryColor != theme2.secondaryColor) {
      differences['secondaryColor'] = {
        'from': theme1.secondaryColor.value,
        'to': theme2.secondaryColor.value,
      };
    }

    // Comparer les typographies
    if (theme1.titleFontSize != theme2.titleFontSize) {
      differences['titleFontSize'] = {
        'from': theme1.titleFontSize,
        'to': theme2.titleFontSize,
      };
    }

    // Comparer les autres propriétés
    final allDifferences = <String>[];
    for (var i = 0; i < theme1.toJson().keys.length; i++) {
      final key = theme1.toJson().keys.elementAt(i);
      final val1 = theme1.toJson()[key];
      final val2 = theme2.toJson()[key];
      if (val1 != val2) {
        allDifferences.add(key);
      }
    }

    differences['allChanged'] = allDifferences;
    differences['changeCount'] = allDifferences.length;

    return differences;
  }

  static double _calculateSimilarity(
    EventThemeCustomization theme1,
    EventThemeCustomization theme2,
  ) {
    final allProperties = theme1.toJson().keys;
    if (allProperties.isEmpty) return 1.0;

    var similarCount = 0;
    for (final key in allProperties) {
      if (theme1.toJson()[key] == theme2.toJson()[key]) {
        similarCount++;
      }
    }

    return similarCount / allProperties.length;
  }

  static Map<String, dynamic> _calculateThemeStatistics(
    List<ThemeVersion> versions,
  ) {
    final authors = <String, int>{};
    final changeTypes = <ChangeType, int>{};
    final versionsByMonth = <String, int>{};

    for (final version in versions) {
      // Compter par auteur
      authors[version.authorName] = (authors[version.authorName] ?? 0) + 1;

      // Compter par type de changement
      changeTypes[version.changeType] =
          (changeTypes[version.changeType] ?? 0) + 1;

      // Compter par mois
      final monthKey =
          '${version.createdAt.year}-${version.createdAt.month.toString().padLeft(2, '0')}';
      versionsByMonth[monthKey] = (versionsByMonth[monthKey] ?? 0) + 1;
    }

    return {
      'totalVersions': versions.length,
      'uniqueAuthors': authors.length,
      'mostActiveAuthor': authors.entries.isNotEmpty
          ? authors.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : null,
      'changeTypeDistribution': changeTypes.map((k, v) => MapEntry(k.name, v)),
      'monthlyActivity': versionsByMonth,
      'averageVersionsPerMonth': versions.isNotEmpty
          ? versions.length / 12.0
          : 0.0,
    };
  }

  // Persistance

  static Future<void> _loadVersions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final versionsJson = prefs.getString(_versionsKey);

      if (versionsJson != null) {
        final versionsData = json.decode(versionsJson) as Map<String, dynamic>;

        _themeVersions.clear();
        for (final entry in versionsData.entries) {
          final versionsList = (entry.value as List)
              .map((json) => ThemeVersion.fromJson(json))
              .toList();
          _themeVersions[entry.key] = versionsList;
        }
      }

      final activeVersionsJson = prefs.getString(_activeVersionsKey);
      if (activeVersionsJson != null) {
        _activeVersions.clear();
        _activeVersions.addAll(
          Map<String, String>.from(json.decode(activeVersionsJson)),
        );
      }

      final historyJson = prefs.getString(_versionHistoryKey);
      if (historyJson != null) {
        _versionHistory.clear();
        final historyData = json.decode(historyJson) as Map<String, dynamic>;
        for (final entry in historyData.entries) {
          _versionHistory[entry.key] = List<String>.from(entry.value);
        }
      }
    } catch (e) {
      // En cas d'erreur, initialiser avec des valeurs vides
      _themeVersions.clear();
      _activeVersions.clear();
      _versionHistory.clear();
    }
  }

  static Future<void> _persistVersions() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final versionsData = <String, dynamic>{};
      for (final entry in _themeVersions.entries) {
        versionsData[entry.key] = entry.value.map((v) => v.toJson()).toList();
      }

      await prefs.setString(_versionsKey, json.encode(versionsData));
    } catch (e) {
      // Gérer l'erreur de persistance
    }
  }

  static Future<void> _persistActiveVersions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeVersionsKey, json.encode(_activeVersions));
    } catch (e) {
      // Gérer l'erreur de persistance
    }
  }

  /// Nettoie les anciennes versions
  static Future<void> cleanupOldVersions({int maxVersionsPerTheme = 50}) async {
    await _loadVersions();

    for (final themeId in _themeVersions.keys) {
      final versions = _themeVersions[themeId]!;

      if (versions.length > maxVersionsPerTheme) {
        // Trier par date (plus ancien d'abord)
        versions.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        // Garder les versions les plus récentes
        final versionsToKeep = versions
            .skip(versions.length - maxVersionsPerTheme)
            .toList();

        // Marquer les anciennes comme archivées
        for (var i = 0; i < versions.length - maxVersionsPerTheme; i++) {
          versions[i] = versions[i].copyWith(
            status: ThemeVersionStatus.archived,
          );
        }

        _themeVersions[themeId] = versions;
      }
    }

    await _persistVersions();
  }

  /// Obtient des statistiques globales sur le versioning
  static Future<Map<String, dynamic>> getGlobalStatistics() async {
    await _loadVersions();

    var totalVersions = 0;
    var totalThemes = 0;
    final authors = <String>{};
    final statusDistribution = <ThemeVersionStatus, int>{};

    for (final versions in _themeVersions.values) {
      totalThemes++;
      totalVersions += versions.length;

      for (final version in versions) {
        authors.add(version.authorId);
        statusDistribution[version.status] =
            (statusDistribution[version.status] ?? 0) + 1;
      }
    }

    return {
      'totalThemes': totalThemes,
      'totalVersions': totalVersions,
      'uniqueAuthors': authors.length,
      'averageVersionsPerTheme': totalThemes > 0
          ? totalVersions / totalThemes
          : 0.0,
      'statusDistribution': statusDistribution.map(
        (k, v) => MapEntry(k.name, v),
      ),
      'activeVersionsCount': _activeVersions.length,
    };
  }
}
