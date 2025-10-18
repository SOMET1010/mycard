Backlog produit (Epic → User stories → Critères d’acceptation)
Epic A – Fondations & données

A1 – Initialiser projet Flutter

En tant qu’ingénieur, je veux un squelette Flutter avec l’architecture définie.

CA: lancer l’app, routing fonctionnel, thèmes clair/sombre basiques.

Priorité: Must | Estimation: 3 pts

A2 – Modèles & Renderers

En tant qu’utilisateur, je veux choisir un modèle de carte prédéfini.

CA: au moins 3 modèles (Pro, Minimal, Corporate) rendus fidèlement; preview ok.

Must | 8 pts

A3 – Stockage local

En tant qu’utilisateur, je veux que mes cartes soient sauvegardées hors-ligne.

CA: persistance Hive, CRUD cartes, imports assets stockés localement.

Must | 5 pts

Epic B – Éditeur & contenu

B1 – Formulaire d’édition

Je peux saisir nom, fonction, org, contacts, site, adresse.

CA: validations (email/tel), erreurs inline, autosave brouillon.

Must | 5 pts

B2 – Logo & photo

Je peux importer un logo/photo depuis la galerie/fichiers.

CA: PNG/JPG/SVG supportés; mise à l’échelle/recadrage simple.

Should | 5 pts

B3 – Styles personnalisés

Je peux changer couleurs/typographies et tailles (simples).

CA: liste de polices Google Fonts; palette couleurs; reset par défaut.

Should | 5 pts

B4 – Réseaux sociaux (v1.1)

Je peux ajouter LinkedIn/X/Facebook/YouTube.

CA: champs dédiés + icônes conditionnelles à l’affichage.

Could | 3 pts

Epic C – Événements & sur-thèmes

C1 – Bibliothèque d’événements

Je peux parcourir/activer un événement (Octobre Rose, etc.).

CA: couleur accent + icône + slogan s’appliquent à la preview.

Must | 5 pts

C2 – Suggestion par calendrier

L’app me propose l’événement du mois au démarrage.

CA: si now ∈ activeRange, bannière de suggestion activable.

Should | 3 pts

C3 – Logo événement personnalisé

Je peux téléverser mon propre logo de campagne.

CA: asset user enregistré; rendu cohérent; fallback si supprimé.

Should | 3 pts

Epic D – QR & vCard

D1 – Génération vCard

L’app génère une vCard 3.0 à partir du formulaire.

CA: export texte conforme; champs optionnels exclus proprement.

Must | 3 pts

D2 – QR Code

Je choisis QR = vCard ou URL.

CA: QR scannable; correction d’erreurs par défaut; tests sur 3 modèles.

Must | 3 pts

Epic E – Export & partage

E1 – Export PNG

J’exporte ma carte en PNG 300 DPI (85×55 mm).

CA: fichier de 1016×657 px min (≈300 DPI) ou mieux (configurable).

Must | 5 pts

E2 – Export PDF

J’exporte en PDF 1 page avec fond perdu (option 3 mm).

CA: PDF A8 personnalisé (ou custom size 85×55 mm), repères optionnels.

Must | 5 pts

E3 – Partage

Je partage depuis l’app (WhatsApp, Mail, etc.).

CA: feuille de partage OS; métadonnées correctes; chemin accessible.

Should | 3 pts

Epic F – Galerie & gestion

F1 – Galerie de cartes

Je vois toutes mes cartes en grille, je duplique/supprime/renomme.

CA: actions rapides; tri par date/nom.

Must | 5 pts

F2 – Import vCard

J’importe un fichier .vcf pour auto-remplir le formulaire.

CA: mapping champs; aperçu; rejet si corrompu.

Should | 3 pts

F3 – Export/Import JSON (sauvegarde)

Je sauvegarde/restaure toutes mes cartes + assets dans un zip.

CA: export “.gouvcard.zip”; import qui recrée cartes & fichiers.

Could | 5 pts

Epic G – Qualité, accessibilité, perf

G1 – Accessibilité

Taille police ajustable; contrastes conformes; labels pour lecteurs.

Must | 3 pts

G2 – Tests & CI

Couverture minimale 60% core; goldens des 3 templates.

CA: pipeline GitHub Actions vert; lints propres.

Must | 5 pts

G3 – Optimisations export

PNG < 5 Mo; temps export < 2 s mid-range.

CA: compression/qualité; pixelRatio paramétrable.

Should | 3 pts

Epic H – Cloud (v1.1 option)

H1 – Auth Firebase

Login Email/Google; profil local synchronisé.

Should | 5 pts

H2 – Sync Firestore/Storage

Cartes & assets synchronisés entre devices.

CA: conflits gérés par “last write wins” (v1.1); bandeau statut.

Should | 8 pts

Tableau de priorisation (MoSCoW – v1.0)

Must: A1, A2, A3, B1, C1, D1, D2, E1, E2, F1, G1, G2

Should: B2, B3, C2, C3, E3, F2, G3

Could: B4, F3

Won’t (v1.0): Auth/Sync (Epic H), drag & drop libre

Roadmap (macro)

S1: A1, A2(partie 1), G2(setup)

S2: A2(partie 2), B1, D1

S3: C1, C2, D2

S4: E1, E2, G3

S5: A3, F1, B2

S6: B3, F2, E3, G1 + Release Android

Critères de réception (extraits)

3 modèles livrés conformes aux maquettes (pixel-perfect à ±4px).

Activation Octobre Rose applique couleur + ruban + slogan sans chevauchement.

Exports PNG 300 DPI et PDF s’ouvrent et s’impriment sans artefacts.

QR vCard validé par 2 apps de scan différentes; données correctes.

20 cas de test réussis (unit/widget/e2e); rapport QA fourni.

APK release signée + guide d’installation.

Annexes pratiques
Conversion taille (mm → px à 300 DPI)

85 × 55 mm ≈ 3.346 × 2.165 pouces

px ≈ 1004 × 650 (arrondir à 1016×657 pour marge).
Recommander un pixelRatio de 3–4 lors de la capture.