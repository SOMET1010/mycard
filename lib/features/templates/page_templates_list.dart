/// Page affichant la grille des modèles disponibles
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/app/di.dart';
import 'package:mycard/data/models/business_card.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/features/templates/widget_template_card.dart';

class TemplatesListPage extends ConsumerStatefulWidget {
  const TemplatesListPage({super.key, this.selectionMode = false, this.onTemplateSelected});

  /// Si true, la page retourne un template au lieu de naviguer vers l'éditeur
  final bool selectionMode;
  final void Function(CardTemplate template)? onTemplateSelected;

  @override
  ConsumerState<TemplatesListPage> createState() => _TemplatesListPageState();
}

class _TemplatesListPageState extends ConsumerState<TemplatesListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasLoaded = false;
  String _selectedCategory = 'Tous';
  final Set<String> _favoriteTemplates = {};
  String? _selectedEventId;

  @override
  void initState() {
    super.initState();
    // Charger les templates au démarrage
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final templatesRepo = ref.read(templatesRepositoryProvider);
    // Toujours forcer le rechargement pour corriger le bug
    if (!templatesRepo.isLoading) {
      await templatesRepo.refreshTemplates();
      _hasLoaded = true;
      setState(() {}); // Forcer le rebuild après chargement
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rafraîchir les templates quand la page redevient visible, mais seulement une fois
    if (!_hasLoaded) {
      _loadTemplates();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templatesRepo = ref.watch(templatesRepositoryProvider);
    final templates = templatesRepo.templates;
    final isLoading = templatesRepo.isLoading;

    // Debug: afficher le nombre de templates chargés
    print('Templates loaded: ${templates.length}');
    print('Is loading: $isLoading');
    if (templates.isNotEmpty) {
      print('First template: ${templates.first.name}');
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Modèles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => context.go('/ai-generator'),
            tooltip: 'Générateur IA',
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.go('/community'),
            tooltip: 'Communauté',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un modèle...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCategoryFilter(),
                _buildAdvancedFilters(),
                Expanded(child: _buildTemplatesGrid(templates)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/ai-generator'),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Générer avec IA'),
        tooltip: 'Créer un thème avec l\'IA',
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Tous', 'Favoris', 'Gratuits', 'Premium', 'Professionnel', 'Créatif', 'Événements'];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedFilters() => SizedBox(
        height: 56,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  hint: const Text('Événement'),
                  value: _selectedEventId,
                  onChanged: (value) {
                    setState(() => _selectedEventId = value);
                  },
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Tous les événements')),
                    ...EventOverlay.predefinedEvents.map((e) => DropdownMenuItem<String?>(
                          value: e.id,
                          child: Text(e.label),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildTemplatesGrid(List<CardTemplate> templates) {
    final searchQuery = _searchController.text.toLowerCase();
    
    // Filtrer par recherche et par catégorie
    var filteredTemplates = templates.where((template) => 
        template.name.toLowerCase().contains(searchQuery) ||
        template.description.toLowerCase().contains(searchQuery)).toList();

    // Appliquer le filtre de catégorie
    if (_selectedCategory != 'Tous') {
      switch (_selectedCategory) {
        case 'Favoris':
          filteredTemplates = filteredTemplates.where((t) => _favoriteTemplates.contains(t.id)).toList();
          break;
        case 'Gratuits':
          filteredTemplates = filteredTemplates.where((t) => !t.isPremium).toList();
          break;
        case 'Premium':
          filteredTemplates = filteredTemplates.where((t) => t.isPremium).toList();
          break;
        case 'Professionnel':
          filteredTemplates = filteredTemplates.where((t) => 
              t.name.toLowerCase().contains('corporate') ||
              t.layout == 'left-aligned').toList();
          break;
        case 'Créatif':
          filteredTemplates = filteredTemplates.where((t) => 
              t.name.toLowerCase().contains('créatif') ||
              t.name.toLowerCase().contains('creative') ||
              t.layout == 'modern').toList();
          break;
        case 'Événements':
          filteredTemplates = filteredTemplates.where((t) => t.eventId != null).toList();
          break;
      }
    }

    // Filtre spécifique par événement
    if (_selectedEventId != null) {
      filteredTemplates = filteredTemplates.where((t) => t.eventId == _selectedEventId).toList();
    }

    print('Building templates grid with ${filteredTemplates.length} filtered templates from ${templates.length} total');

    if (filteredTemplates.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun modèle trouvé',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredTemplates.length,
      itemBuilder: (context, index) {
        final template = filteredTemplates[index];
        return TemplateCard(
          template: template,
          onTap: () => _onTapTemplate(context, template),
          isFavorite: _favoriteTemplates.contains(template.id),
          onFavoriteToggle: () => _toggleFavorite(template.id),
        );
      },
    );
  }

  void _toggleFavorite(String templateId) {
    setState(() {
      if (_favoriteTemplates.contains(templateId)) {
        _favoriteTemplates.remove(templateId);
      } else {
        _favoriteTemplates.add(templateId);
      }
    });
  }

  void _onTapTemplate(BuildContext context, CardTemplate template) {
    if (widget.selectionMode) {
      // Mode sélection depuis l'éditeur: retourner le template
      if (widget.onTemplateSelected != null) {
        widget.onTemplateSelected!(template);
      }
      Navigator.pop(context, template);
      return;
    }

    // Mode normal: créer une nouvelle carte et ouvrir l'éditeur
    final newCard = BusinessCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: 'Prénom',
      lastName: 'Nom',
      title: 'Votre titre',
      phone: '+00 000 000 000',
      email: 'email@example.com',
      templateId: template.id,
      customColors: template.colors,
    );

    context.push('/editor', extra: newCard);
  }
}
