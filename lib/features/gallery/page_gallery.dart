/// Page "Mes Cartes" avec grille et barre d'onglets
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/app/di.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/data/models/business_card.dart';
import 'package:mycard/features/gallery/widget_card_grid_tile.dart';

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  String _searchQuery = '';
  final int _navIndex = 0;
  String _sortBy = 'date'; // 'date' | 'name' | 'company'

  @override
  void initState() {
    super.initState();
    _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    final cardsRepo = ref.read(cardsRepositoryProvider);
    if (!cardsRepo.isInitialized) {
      await cardsRepo.init();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsRepo = ref.watch(cardsRepositoryProvider);

    // Vérifier si le repository est initialisé
    if (!cardsRepo.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    var cards = cardsRepo.getAllCards();

    // Appliquer la recherche
    if (_searchQuery.isNotEmpty) {
      cards = cardsRepo.searchCards(_searchQuery);
    }

    // Tri par date desc
    cards = cardsRepo.getCardsSortedByDate(descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Cartes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: ref.read(cardsRepositoryProvider).listenable,
        builder: (context, box, _) {
          // Recalculer la liste à chaque changement
          var current = ref.read(cardsRepositoryProvider).getCardsSortedByDate(descending: true);
          if (_searchQuery.isNotEmpty) {
            current = ref.read(cardsRepositoryProvider).searchCards(_searchQuery);
          }
          current = _applySort(current);

          return Column(
            children: [
              const SizedBox(height: 8),
              _buildToolbar(context),
              const SizedBox(height: 8),
              Expanded(child: _buildGrid(current)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône animée avec gradient
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                    AppTheme.secondaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.contact_page_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Titre
            Text(
              'Aucune carte de visite',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.accentColor,
              ),
            ),

            const SizedBox(height: 12),

            // Sous-titre
            Text(
              'Créez votre première carte de visite professionnelle',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B5E56),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Liste de fonctionnalités
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1A17) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildFeatureItem(
                    icon: Icons.design_services,
                    title: 'Design personnalisé',
                    description: 'Choisissez parmi nos modèles professionnels',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.qr_code,
                    title: 'Code QR intégré',
                    description: 'Partagez facilement vos informations',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.share,
                    title: 'Export simple',
                    description: 'Exportez en PDF ou image',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bouton d'action principal
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _createNewCard,
                icon: const Icon(Icons.add, size: 24),
                label: const Text(
                  'Créer ma première carte',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bouton secondaire
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/templates'),
                icon: const Icon(Icons.style, size: 20),
                label: Text(
                  'Voir les modèles',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFFEAB676) : AppTheme.primaryColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? const Color(0xFF3A332E) : const Color(0xFFE7D9CF),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.accentColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B5E56),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(List<BusinessCard> cards) {
    final filtered = _searchQuery.isEmpty
        ? cards
        : cards.where((c) => c.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (c.company ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    // Afficher l'état vide s'il n'y a pas de cartes
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final card = filtered[index];
        return CardGridTile(
          card: card,
          onTap: () => _editCard(card),
        );
      },
    );
  }

  void _createNewCard() {
    context.push('/editor');
  }

  void _viewCard(BusinessCard card) {
    // À implémenter : navigation vers la page de visualisation
  }

  void _editCard(BusinessCard card) {
    context.push('/editor', extra: card);
  }

  void _deleteCard(BusinessCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la carte'),
        content: Text('Êtes-vous sûr de vouloir supprimer la carte de ${card.fullName} ?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              await ref.read(cardsRepositoryProvider).deleteCard(card.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Carte supprimée avec succès'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _shareCard(BusinessCard card) {
    // À implémenter : partage de la carte
  }

  void _openSearch() async {
    final controller = TextEditingController(text: _searchQuery);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recherche'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Rechercher des cartes...'),
          onSubmitted: (_) => context.pop(),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Fermer')),
        ],
      ),
    );
    setState(() => _searchQuery = controller.text);
  }

  // Toolbar
  Widget _buildToolbar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _SortByButton(
            value: _sortBy,
            onChanged: (v) => setState(() => _sortBy = v),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _createNewCard,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Ajouter une carte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  List<BusinessCard> _applySort(List<BusinessCard> list) {
    final items = List<BusinessCard>.from(list);
    switch (_sortBy) {
      case 'name':
        items.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
      case 'company':
        items.sort((a, b) => (a.company ?? '').toLowerCase().compareTo((b.company ?? '').toLowerCase()));
        break;
      case 'date':
      default:
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return items;
  }
}

class _SortByButton extends StatelessWidget {
  const _SortByButton({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  String get _label {
    switch (value) {
      case 'name':
        return 'Nom';
      case 'company':
        return 'Entreprise';
      case 'date':
      default:
        return 'Date';
    }
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () async {
          final box = context.findRenderObject() as RenderBox;
          final offset = box.localToGlobal(Offset.zero);
          final v = await showMenu<String>(
            context: context,
            position: RelativeRect.fromLTRB(offset.dx, offset.dy + 40, 0, 0),
            items: const [
              PopupMenuItem(value: 'date', child: Text('Date')),
              PopupMenuItem(value: 'name', child: Text('Nom')),
              PopupMenuItem(value: 'company', child: Text('Entreprise')),
            ],
          );
          if (v != null) onChanged(v);
        },
        icon: const Icon(Icons.sort, size: 18),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Trier: $_label'),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      );
}
