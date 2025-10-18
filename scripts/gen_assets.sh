#!/bin/bash

# Script pour générer les assets et vérifier la structure
# Usage: ./scripts/gen_assets.sh

echo "=== Vérification des assets ==="

# Vérifier si les répertoires d'assets existent
for dir in fonts icons logos events templates; do
    if [ ! -d "assets/$dir" ]; then
        echo "Création du répertoire assets/$dir"
        mkdir -p "assets/$dir"
    fi
done

# Vérifier les fichiers de données
if [ ! -f "assets/data/Templates.json" ]; then
    echo "Création du fichier Templates.json par défaut"
    cat > "assets/data/Templates.json" << 'EOF'
{
  "templates": [
    {
      "id": "minimal",
      "name": "Minimal",
      "colors": {
        "primary": "#000000",
        "secondary": "#666666",
        "accent": "#2563eb"
      },
      "rendererKey": "minimal",
      "layout": "centered"
    },
    {
      "id": "corporate",
      "name": "Corporate",
      "colors": {
        "primary": "#1e293b",
        "secondary": "#64748b",
        "accent": "#0f172a"
      },
      "rendererKey": "corporate",
      "layout": "left-aligned"
    },
    {
      "id": "creative",
      "name": "Créatif",
      "colors": {
        "primary": "#7c3aed",
        "secondary": "#a78bfa",
        "accent": "#fbbf24"
      },
      "rendererKey": "ansut_style",
      "layout": "modern"
    }
  ]
}
EOF
fi

if [ ! -f "assets/data/Events.json" ]; then
    echo "Création du fichier Events.json par défaut"
    cat > "assets/data/Events.json" << 'EOF'
{
  "events": [
    {
      "id": "octobre_rose",
      "label": "Octobre Rose",
      "color": "#ff69b4",
      "icon": "ribbon",
      "period": "octobre"
    },
    {
      "id": "noel",
      "label": "Noël",
      "color": "#228b22",
      "icon": "tree",
      "period": "décembre"
    },
    {
      "id": "fete_des_meres",
      "label": "Fête des Mères",
      "color": "#ff1493",
      "icon": "heart",
      "period": "mai"
    }
  ]
}
EOF
fi

echo "=== Mise à jour de pubspec.yaml ==="
flutter pub get

echo "=== Vérification des assets terminée ==="