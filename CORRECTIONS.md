# Corrections Appliquées - MyCard

## Date : 18 octobre 2025

Ce document liste toutes les corrections appliquées suite à l'audit de production.

## 1. Sécurité (Priorité CRITIQUE)

### ✅ Protection des clés Firebase

**Problème :** Le fichier `google-services.json` était versionné dans Git, exposant les clés d'API.

**Corrections appliquées :**
- ✅ Ajout de `google-services.json` et `GoogleService-Info.plist` au `.gitignore`
- ✅ Création d'un fichier `google-services.json.example` comme template
- ✅ Documentation dans `SECURITY.md` pour la gestion des clés

**Actions manuelles requises :**
- ⚠️ **IMPORTANT :** Supprimer `google-services.json` de l'historique Git avec `git filter-repo`
- ⚠️ **IMPORTANT :** Révoquer et régénérer les clés Firebase dans la console Firebase
- ⚠️ Configurer les secrets dans GitHub Actions pour l'injection des clés

### ✅ Configuration de signature Android

**Problème :** L'application utilisait les clés de debug pour les builds release.

**Corrections appliquées :**
- ✅ Configuration de `signingConfigs` dans `android/app/build.gradle.kts`
- ✅ Utilisation de variables d'environnement pour les credentials du keystore
- ✅ Fallback vers debug keys pour le développement local

**Actions manuelles requises :**
- ⚠️ Générer un keystore de production : `keytool -genkey -v -keystore ~/mycard-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
- ⚠️ Configurer les variables d'environnement :
  - `MYCARD_KEYSTORE_PATH`
  - `MYCARD_KEYSTORE_PASSWORD`
  - `MYCARD_KEY_ALIAS`
  - `MYCARD_KEY_PASSWORD`

### ✅ Obfuscation du code

**Problème :** Pas de protection contre le reverse engineering.

**Corrections appliquées :**
- ✅ Activation de R8 avec `isMinifyEnabled = true` et `isShrinkResources = true`
- ✅ Création du fichier `proguard-rules.pro` avec règles appropriées
- ✅ Configuration pour préserver les classes Firebase, Hive, et modèles

**Build de production :**
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

## 2. Configuration (Priorité ÉLEVÉE)

### ✅ Gestion des environnements

**Corrections appliquées :**
- ✅ Création d'un fichier `.env.example` pour documenter les variables d'environnement
- ✅ Ajout de `.env` au `.gitignore`
- ✅ Documentation de la configuration dans `SECURITY.md`

**Actions recommandées :**
- 📝 Implémenter des flavors Flutter (dev, staging, prod) pour une séparation complète
- 📝 Utiliser `flutter_dotenv` pour charger les variables d'environnement

### ✅ Permissions Android

**Problème :** Aucune permission déclarée dans le manifeste.

**Corrections appliquées :**
- ✅ Ajout des permissions essentielles dans `AndroidManifest.xml` :
  - `INTERNET`
  - `CAMERA`
  - `READ_EXTERNAL_STORAGE`
  - `WRITE_EXTERNAL_STORAGE` (API ≤ 28)
  - `READ_MEDIA_IMAGES`

**Actions recommandées :**
- 📝 Implémenter la gestion des permissions runtime avec `permission_handler`

## 3. Qualité du Code (Priorité ÉLEVÉE)

### ✅ Remplacement des print() par debugPrint()

**Problème :** 12 appels à `print()` dans le code de production.

**Corrections appliquées :**
- ✅ `lib/data/repo/cards_repo.dart` : 1 remplacement
- ✅ `lib/features/gallery/widget_card_grid_tile.dart` : 1 remplacement
- ✅ `lib/features/templates/page_templates_list.dart` : 4 remplacements
- ✅ `lib/widgets/card_renderers/card_back_renderer.dart` : 6 remplacements

**Total :** 12 occurrences corrigées

### ✅ Organisation des dépendances

**Problème :** Dépendances non triées alphabétiquement (warning du linter).

**Corrections appliquées :**
- ✅ Réorganisation de `pubspec.yaml` avec tri alphabétique des dépendances
- ✅ Suppression de `golden_toolkit` (package discontinué)

**Actions recommandées :**
- 📝 Exécuter `flutter pub upgrade --major-versions` pour mettre à jour toutes les dépendances
- 📝 Gérer les breaking changes de GoRouter, Riverpod et Firebase

## 4. Documentation (Priorité MOYENNE)

### ✅ Documentation de sécurité

**Corrections appliquées :**
- ✅ Création de `SECURITY.md` avec :
  - Guide de génération du keystore
  - Configuration des variables d'environnement
  - Checklist de sécurité avant release
  - Procédure de révocation de clés exposées
  - Recommandations de monitoring

### ✅ Documentation des corrections

**Corrections appliquées :**
- ✅ Création de ce fichier `CORRECTIONS.md`

## 5. Fichiers Créés ou Modifiés

### Nouveaux fichiers
- ✅ `.env.example` - Template de configuration
- ✅ `android/app/google-services.json.example` - Template Firebase
- ✅ `android/app/proguard-rules.pro` - Règles d'obfuscation
- ✅ `SECURITY.md` - Guide de sécurité
- ✅ `CORRECTIONS.md` - Ce fichier

### Fichiers modifiés
- ✅ `.gitignore` - Ajout des fichiers sensibles
- ✅ `android/app/build.gradle.kts` - Configuration signing et obfuscation
- ✅ `android/app/src/main/AndroidManifest.xml` - Ajout des permissions
- ✅ `pubspec.yaml` - Tri des dépendances
- ✅ `lib/data/repo/cards_repo.dart` - print → debugPrint
- ✅ `lib/features/gallery/widget_card_grid_tile.dart` - print → debugPrint
- ✅ `lib/features/templates/page_templates_list.dart` - print → debugPrint
- ✅ `lib/widgets/card_renderers/card_back_renderer.dart` - print → debugPrint

## 6. Actions Manuelles Requises (IMPORTANT)

### 🔴 Critique - À faire immédiatement

1. **Nettoyer l'historique Git**
   ```bash
   pip install git-filter-repo
   git filter-repo --path android/app/google-services.json --invert-paths
   git push --force
   ```

2. **Révoquer les clés Firebase exposées**
   - Aller dans Firebase Console > Project Settings
   - Régénérer les clés API
   - Télécharger les nouveaux fichiers de configuration

3. **Générer le keystore de production**
   ```bash
   keytool -genkey -v -keystore ~/mycard-release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

4. **Configurer les secrets GitHub Actions**
   - `MYCARD_KEYSTORE_PATH` (ou encoder le keystore en base64)
   - `MYCARD_KEYSTORE_PASSWORD`
   - `MYCARD_KEY_ALIAS`
   - `MYCARD_KEY_PASSWORD`
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_API_KEY`

### 🟠 Important - À faire avant la release

5. **Mettre à jour les dépendances**
   ```bash
   flutter pub upgrade --major-versions
   flutter pub get
   ```

6. **Corriger les warnings du linter**
   ```bash
   flutter analyze
   # Corriger les deprecated_member_use et unawaited_futures
   ```

7. **Ajouter des tests**
   - Créer des tests unitaires pour la logique métier
   - Viser 70%+ de couverture de code

8. **Configurer le monitoring**
   - Intégrer Sentry ou Firebase Crashlytics
   - Configurer Firebase Analytics

### 🟡 Recommandé - Améliorations futures

9. **Implémenter les flavors**
   - Utiliser `flutter_flavorizr` ou configuration manuelle
   - Créer des environnements dev/staging/prod séparés

10. **Améliorer la CI/CD**
    - Automatiser les builds avec injection de secrets
    - Ajouter des tests automatisés
    - Déploiement automatique vers Firebase App Distribution

## 7. Vérification des Corrections

Pour vérifier que les corrections ont été appliquées correctement :

```bash
# Vérifier que les fichiers sensibles sont ignorés
git status

# Vérifier qu'il n'y a plus de print()
grep -r "print(" lib/ --include="*.dart"

# Vérifier la configuration de build
cat android/app/build.gradle.kts | grep -A 10 "buildTypes"

# Tester le build (nécessite le keystore configuré)
flutter build appbundle --release --obfuscate
```

## 8. Résumé

| Catégorie | Problèmes | Corrigés | Restants |
|-----------|-----------|----------|----------|
| Sécurité critique | 3 | 3 | 0 (actions manuelles requises) |
| Configuration | 2 | 2 | 0 |
| Qualité du code | 2 | 2 | 0 |
| Documentation | 1 | 1 | 0 |
| **TOTAL** | **8** | **8** | **0** |

**Note :** Toutes les corrections automatisables ont été appliquées. Les actions manuelles critiques (nettoyage Git, révocation de clés, génération keystore) doivent être effectuées avant tout déploiement en production.

