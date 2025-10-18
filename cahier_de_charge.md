Cahier des charges – App “GouvCard Event”
1) Contexte & objectifs

Générer des cartes de visite professionnelles personnalisables à partir de modèles.

Activer des sur-thèmes événementiels (ex. Octobre Rose) avec logos/slogans/couleurs dédiés.

Prévisualisation en temps réel, QR Code (vCard/URL), export PNG & PDF, partage.

Stockage local hors-ligne (obligatoire). Sync Firebase (optionnel v1.1+).

2) Cibles & plateformes

Utilisateurs: agents publics, entreprises, freelances.

Plateformes: Android (minSDK 23), iOS (iOS 13+). Web en option (v1.2+).

3) Périmètre fonctionnel (v1.0)
3.1 Authentification

v1.0: sans compte (local).

v1.1 (option): Email/Google via Firebase Auth.

3.2 Modèles & thèmes

Bibliothèque de modèles (layout, couleurs, polices, zones).

Événements/sur-thèmes: liste (Octobre Rose, Journée environnement, etc.) avec:

icône/logo, couleur d’accent, slogans, période de validité (facultatif).

Activation manuelle ou suggestion selon le calendrier.

Personnalisation: couleurs, polices (Google Fonts), tailles, espacements, visibilité des blocs.

3.3 Éditeur de carte

Champs:

Identité: nom complet, fonction/titre, organisation, sous-titre.

Contacts: téléphone 1/2, email, site, adresse.

Médias: logo entreprise (PNG/SVG), logo événement (SVG/PNG), photo (option).

QR Code: vCard (VCF 3.0) ou URL personnalisée.

Réseaux sociaux (option v1.1): Facebook, X/Twitter, LinkedIn, YouTube.

Actions:

Prévisualisation temps réel.

Duplication, renommage, suppression de cartes.

Import vCard (.vcf) → préremplit les champs.

3.4 Export & partage

PNG haute résolution (min 300 DPI sur 85×55 mm).

PDF (1 page recto, fond perdu optionnel 3 mm).

Partage via système (WhatsApp, email, etc.).

Marge de sécurité & zone de coupe (guides optionnels).

3.5 Gestion & stockage

Local: Hive (ou Drift) – toutes les cartes + médias liés.

Cloud (option v1.1): Firestore + Firebase Storage pour sync multi-devices.

Sauvegarde/restauration: Export/Import JSON + assets (zip).

4) Hors périmètre v1.0

Édition “drag & drop” libre (prévu v2.0).

Impression recto/verso (v1.2).

Multi-équipes & partage temps réel (v2.0).

5) Exigences non fonctionnelles

Performance: preview < 100 ms après modification; export PNG < 2 s sur device moyen.

Accessibilité: contrastes AA, tailles de police ajustables.

Offline-first: toutes les fonctions clés sans réseau.

Sécurité: pas de secrets embarqués; chiffrement repos (optionnel) via keystore.

RGPD: données locales par défaut; effacement simple; consentement pour sync.