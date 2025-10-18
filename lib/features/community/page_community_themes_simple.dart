/// Page des thèmes communautaires simplifiée
library;
import 'package:flutter/material.dart';
import 'package:mycard/core/services/community_theme_service_simple.dart';
import 'package:mycard/data/models/event_theme_customization.dart';

class CommunityThemesPage extends StatefulWidget {
  const CommunityThemesPage({super.key});

  @override
  State<CommunityThemesPage> createState() => _CommunityThemesPageState();
}

class _CommunityThemesPageState extends State<CommunityThemesPage> {
  List<CommunityTheme> _themes = [];
  List<CommunityTheme> _filteredThemes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final themes = await CommunityThemeService.getPopularThemes();
      setState(() {
        _themes = themes;
        _filteredThemes = themes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterThemes() {
    setState(() {
      _filteredThemes = _themes.where((theme) {
        final matchesSearch = theme.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            theme.description.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesCategory = _selectedCategory == 'Tous' ||
            theme.tags.contains(_selectedCategory.toLowerCase());

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Thèmes Communautaires'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _showUploadDialog,
            tooltip: 'Partager un thème',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildThemesGrid(),
          ),
        ],
      ),
    );

  Widget _buildSearchBar() => Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Rechercher des thèmes...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _filterThemes();
        },
      ),
    );

  Widget _buildCategoryFilter() {
    final categories = ['Tous', 'professionnel', 'créatif', 'moderne', 'coloré', 'minimaliste'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
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
                _filterThemes();
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue[100],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemesGrid() {
    if (_filteredThemes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun thème trouvé',
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
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredThemes.length,
      itemBuilder: (context, index) {
        final theme = _filteredThemes[index];
        return _buildThemeCard(theme);
      },
    );
  }

  Widget _buildThemeCard(CommunityTheme theme) => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showThemeDetails(theme),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.theme.primaryColor,
                      theme.theme.secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildFavoriteButton(theme),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          theme.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          theme.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.download, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${theme.downloads}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildFavoriteButton(CommunityTheme theme) => FutureBuilder<bool>(
      future: CommunityThemeService.isFavorite(theme.id),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;

        return GestureDetector(
          onTap: () async {
            await CommunityThemeService.toggleFavorite(theme.id);
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: isFavorite ? Colors.red : Colors.white,
            ),
          ),
        );
      },
    );

  void _showThemeDetails(CommunityTheme theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.theme.primaryColor,
                    radius: 30,
                    child: Text(
                      theme.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Par ${theme.authorName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await CommunityThemeService.toggleFavorite(theme.id);
                      setState(() {});
                    },
                    icon: const Icon(Icons.favorite_border),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                theme.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildColorPalette(theme.theme),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: theme.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey[200],
                  )).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Appliquer le thème
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Thème "${theme.name}" appliqué')),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPalette(EventThemeCustomization theme) => Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.secondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.textColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partager un thème'),
        content: const Text(
          'Cette fonctionnalité sera bientôt disponible !\n\n'
          'Vous pourrez partager vos propres créations avec la communauté.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}