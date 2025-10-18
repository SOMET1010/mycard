# Guide de Sécurité MyCard

## Configuration de Production

### 1. Génération du Keystore Android

Pour créer un keystore de production :

```bash
keytool -genkey -v -keystore ~/mycard-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important :** Conservez ce fichier en lieu sûr et ne le committez JAMAIS dans Git.

### 2. Configuration des Variables d'Environnement

#### Pour le Build Local

Créez un fichier `.env` à la racine du projet (déjà ignoré par Git) :

```bash
cp .env.example .env
# Puis éditez .env avec vos vraies valeurs
```

#### Pour GitHub Actions

Configurez les secrets suivants dans Settings > Secrets and variables > Actions :

- `MYCARD_KEYSTORE_PATH` : Chemin vers le keystore (ou encodé en base64)
- `MYCARD_KEYSTORE_PASSWORD` : Mot de passe du keystore
- `MYCARD_KEY_ALIAS` : Alias de la clé
- `MYCARD_KEY_PASSWORD` : Mot de passe de la clé
- `FIREBASE_PROJECT_ID` : ID du projet Firebase
- `FIREBASE_API_KEY` : Clé API Firebase

### 3. Fichiers Firebase

Les fichiers de configuration Firebase ne doivent PAS être versionnés :

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

**Solution :** Utilisez des fichiers `.example` et injectez les vrais fichiers via la CI/CD.

### 4. Build de Production

Pour créer un build de production avec obfuscation :

```bash
# Android
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols

# iOS
flutter build ipa --release --obfuscate --split-debug-info=build/ios/outputs/symbols
```

### 5. Checklist de Sécurité Avant Release

- [ ] Keystore de production créé et sécurisé
- [ ] Variables d'environnement configurées
- [ ] `google-services.json` retiré de Git
- [ ] Obfuscation activée
- [ ] ProGuard/R8 configuré
- [ ] Permissions Android minimales
- [ ] Tests de sécurité effectués
- [ ] Pas de `print()` dans le code
- [ ] Logs sensibles supprimés
- [ ] Crash reporting configuré (Sentry/Crashlytics)

### 6. Révocation de Clés Exposées

Si des clés ont été exposées dans Git :

1. **Firebase :** Allez dans Firebase Console > Project Settings > General, et régénérez les clés
2. **Keystore :** Créez un nouveau keystore et mettez à jour l'application
3. **Nettoyez l'historique Git :**

```bash
# Utilisez git-filter-repo pour supprimer les fichiers sensibles de l'historique
pip install git-filter-repo
git filter-repo --path android/app/google-services.json --invert-paths
```

### 7. Monitoring de Sécurité

- Activez les alertes de sécurité GitHub (Dependabot)
- Configurez Firebase App Check
- Mettez en place des règles de sécurité Firestore strictes
- Surveillez les logs d'accès Firebase

## Ressources

- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

