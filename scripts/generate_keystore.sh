#!/bin/bash

# Script de génération du keystore de production pour MyCard
# Usage: ./scripts/generate_keystore.sh

set -e

echo "=== Génération du Keystore de Production MyCard ==="
echo ""

# Vérifier que keytool est installé
if ! command -v keytool &> /dev/null; then
    echo "❌ Erreur: keytool n'est pas installé."
    echo "   Installez Java JDK pour continuer."
    exit 1
fi

# Définir le chemin du keystore
KEYSTORE_DIR="$HOME/.android/keystores"
KEYSTORE_PATH="$KEYSTORE_DIR/mycard-release.jks"

# Créer le répertoire si nécessaire
mkdir -p "$KEYSTORE_DIR"

# Vérifier si le keystore existe déjà
if [ -f "$KEYSTORE_PATH" ]; then
    echo "⚠️  Un keystore existe déjà à: $KEYSTORE_PATH"
    read -p "Voulez-vous le remplacer? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Opération annulée."
        exit 0
    fi
    rm "$KEYSTORE_PATH"
fi

echo "📝 Génération du keystore..."
echo "   Vous allez être invité à fournir:"
echo "   - Un mot de passe pour le keystore (à retenir!)"
echo "   - Un mot de passe pour la clé (peut être le même)"
echo "   - Vos informations (nom, organisation, etc.)"
echo ""

# Générer le keystore
keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias upload

echo ""
echo "✅ Keystore généré avec succès!"
echo "   Chemin: $KEYSTORE_PATH"
echo ""
echo "📋 Prochaines étapes:"
echo "   1. Sauvegardez ce keystore dans un endroit sûr (cloud chiffré, gestionnaire de mots de passe)"
echo "   2. Notez les mots de passe dans un gestionnaire sécurisé"
echo "   3. Configurez les variables d'environnement:"
echo ""
echo "      export MYCARD_KEYSTORE_PATH=\"$KEYSTORE_PATH\""
echo "      export MYCARD_KEYSTORE_PASSWORD=\"<votre_mot_de_passe>\""
echo "      export MYCARD_KEY_ALIAS=\"upload\""
echo "      export MYCARD_KEY_PASSWORD=\"<votre_mot_de_passe_clé>\""
echo ""
echo "   4. Pour GitHub Actions, ajoutez ces valeurs comme secrets"
echo ""
echo "⚠️  IMPORTANT: Ne committez JAMAIS ce fichier dans Git!"

