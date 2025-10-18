visicard/
├── android/
├── ios/
├── web/                      # (optionnel v1.2)
├── macos/ linux/ windows/    # (si tu cibles desktop)
├── assets/
│   ├── fonts/                # Polices custom (si besoin)
│   ├── icons/                # Icônes (SVG/PNG)
│   ├── logos/                # Logos de démo (entreprise)
│   ├── events/               # Logos/illustrations événements (ex: octobre_rose.svg)
│   ├── templates/            # Images d’aperçu des modèles
│   └── data/
│       ├── Templates.json    # Définition des modèles (id, couleurs, rendererKey, layout)
│       └── Events.json       # Sur-thèmes événementiels (id, label, couleur, icône, période)
├── scripts/
│   ├── gen_assets.sh         # MAJ pubspec + vérif assets
│   └── build_release.sh      # Build APK/AAB + numérotation
├── test/
│   ├── unit/                 # Tests unitaires (vCard, QR, sérialisation)
│   ├── widget/               # Tests widget (éditeur, preview)
│   └── golden/               # Captures de référence des modèles
├── .github/
│   └── workflows/
│       └── ci.yml            # Lints + tests + build debug
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── app/
    │   ├── router.dart       # GoRouter / routes nommées
    │   ├── theme.dart        # Thèmes clair/sombre, tokens couleur
    │   └── di.dart           # Injections (repos/services)
    ├── core/
    │   ├── constants.dart    # Tailles, paddings, DPI, formats
    │   ├── utils/
    │   │   ├── dpi_utils.dart        # mm <-> px, 300DPI helpers
    │   │   ├── color_utils.dart
    │   │   └── validators.dart       # email/tel/URL
    │   └── services/
    │       ├── qr_service.dart       # Encodage QR (vCard/URL)
    │       ├── vcard_service.dart    # Génération VCF 3.0
    │       ├── export_service.dart   # PNG/PDF, partage
    │       └── file_service.dart     # FilePicker, paths
    ├── data/
    │   ├── models/
    │   │   ├── business_card.dart    # Données d’une carte
    │   │   ├── card_template.dart    # Définition d’un modèle
    │   │   └── event_overlay.dart    # Sur-thème événementiel
    │   ├── repo/
    │   │   ├── templates_repo.dart   # Charge Templates.json
    │   │   ├── events_repo.dart      # Charge Events.json
    │   │   └── cards_repo.dart       # CRUD cartes (Hive)
    │   └── local/
    │       ├── hive_adapters.dart    # Adapters + boxes
    │       └── hive_boxes.dart
    ├── features/
    │   ├── templates/
    │   │   ├── page_templates_list.dart     # Grille des modèles
    │   │   └── widget_template_card.dart    # Tuile modèle
    │   ├── editor/
    │   │   ├── page_editor.dart            # Form + Preview
    │   │   ├── form_card_fields.dart       # Nom, titre, contacts…
    │   │   ├── form_style_panel.dart       # Couleurs, polices
    │   │   └── preview_card.dart           # Aperçu live (renderer)
    │   ├── events/
    │   │   ├── page_events_picker.dart     # Sélecteur d’événements
    │   │   └── widget_event_chip.dart
    │   ├── gallery/
    │   │   ├── page_gallery.dart           # Liste des cartes
    │   │   └── widget_card_tile.dart
    │   └── export/
    │       ├── page_export.dart            # Options PNG/PDF
    │       └── widget_export_result.dart
    ├── widgets/
    │   ├── atoms/                  # Boutons, chips, pickers, loaders
    │   ├── molecules/              # Groupes (ligne contact, header)
    │   └── card_renderers/
    │       ├── renderer_minimal.dart
    │       ├── renderer_corporate.dart
    │       └── renderer_ansut_style.dart   # Style proche de ta maquette
    └── l10n/
        ├── app_fr.arb
        └── app_en.arb
