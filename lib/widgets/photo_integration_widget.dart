import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycard/core/services/photo_integration_service.dart';
import 'package:mycard/core/services/theme_export_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Widget d'intégration photo pour la création de thèmes
class PhotoIntegrationWidget extends StatefulWidget {

  const PhotoIntegrationWidget({
    super.key,
    required this.onThemeGenerated,
    this.onColorsExtracted,
    this.showAdvancedOptions = false,
    this.enableFilters = true,
  });
  final Function(Map<String, dynamic>) onThemeGenerated;
  final Function(PhotoColorExtraction)? onColorsExtracted;
  final bool showAdvancedOptions;
  final bool enableFilters;

  @override
  State<PhotoIntegrationWidget> createState() => _PhotoIntegrationWidgetState();
}

class _PhotoIntegrationWidgetState extends State<PhotoIntegrationWidget>
    with TickerProviderStateMixin {
  final PhotoIntegrationService _photoService = PhotoIntegrationService.instance;
  final ThemeExportService _exportService = ThemeExportService.instance;

  String? _selectedImagePath;
  PhotoColorExtraction? _currentExtraction;
  List<PhotoFilter> _availableFilters = [];
  PhotoFilter? _selectedFilter;
  bool _isAnalyzing = false;
  bool _isProcessing = false;
  double _themeIntensity = 1.0;
  String _themeName = '';
  String _selectedMood = 'auto';
  String _selectedStyle = 'modern';

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _initializeServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await _photoService.initialize();
    setState(() {
      _availableFilters = _photoService.getAvailableFilters();
    });
  }

  @override
  Widget build(BuildContext context) => Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildTabBar(),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPhotoSelectionTab(),
              _buildAnalysisTab(),
              _buildThemeGenerationTab(),
            ],
          ),
        ),
        if (_selectedImagePath != null) ...[
          const SizedBox(height: 16),
          _buildBottomActions(),
        ],
      ],
    );

  Widget _buildHeader() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Intégration Photo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Créez des thèmes à partir de vos photos',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  Widget _buildTabBar() => DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        tabs: const [
          Tab(
            icon: Icon(Icons.photo_library),
            text: 'Sélection',
          ),
          Tab(
            icon: Icon(Icons.color_lens),
            text: 'Analyse',
          ),
          Tab(
            icon: Icon(Icons.palette),
            text: 'Thème',
          ),
        ],
      ),
    );

  Widget _buildPhotoSelectionTab() => Column(
      children: [
        Expanded(
          child: _selectedImagePath != null
              ? _buildPhotoPreview()
              : _buildPhotoSelector(),
        ),
        if (widget.enableFilters && _selectedImagePath != null) ...[
          const SizedBox(height: 16),
          _buildFilterSelector(),
        ],
      ],
    );

  Widget _buildPhotoSelector() => Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Sélectionnez une photo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Prenez une photo ou choisissez depuis la galerie',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _capturePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Appareil photo'),
              ),
              ElevatedButton.icon(
                onPressed: _pickPhotoFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galerie'),
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildPhotoPreview() => DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(_selectedImagePath!),
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: FloatingActionButton.small(
                onPressed: _changePhoto,
                child: const Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildFilterSelector() => SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableFilters.length,
        itemBuilder: (context, index) {
          final filter = _availableFilters[index];
          final isSelected = _selectedFilter?.id == filter.id;

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _selectFilter(filter),
              child: Card(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getFilterIcon(filter.category),
                        size: 24,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        filter.name,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

  Widget _buildAnalysisTab() {
    if (_currentExtraction == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.color_lens_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Analysez les couleurs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez une photo pour extraire les couleurs dominantes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorPalette(),
          const SizedBox(height: 16),
          _buildColorStatistics(),
          if (widget.showAdvancedOptions) ...[
            const SizedBox(height: 16),
            _buildAdvancedAnalysis(),
          ],
        ],
      ),
    );
  }

  Widget _buildColorPalette() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Palette de couleurs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentExtraction!.palette.map((color) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _copyColorValue(color),
                      child: Center(
                        child: Text(
                          _colorToHex(color),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getContrastColor(color),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                )).toList(),
            ),
          ],
        ),
      ),
    );

  Widget _buildColorStatistics() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildStatisticRow('Humeur', _currentExtraction!.mood),
            _buildStatisticRow(
              'Luminosité',
              '${(_currentExtraction!.brightness * 100).toStringAsFixed(1)}%',
            ),
            _buildStatisticRow(
              'Contraste',
              '${(_currentExtraction!.contrast * 100).toStringAsFixed(1)}%',
            ),
            _buildStatisticRow(
              'Saturation',
              '${(_currentExtraction!.saturation * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );

  Widget _buildStatisticRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

  Widget _buildAdvancedAnalysis() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analyse avancée',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Couleurs dominantes:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: _currentExtraction!.dominantColors.map((color) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _colorToHex(color),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getContrastColor(color),
                    ),
                  ),
                )).toList(),
            ),
          ],
        ),
      ),
    );

  Widget _buildThemeGenerationTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personnalisation du thème',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nom du thème',
                      hintText: 'Entrez un nom pour votre thème',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _themeName = value,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Style',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedStyle,
                    items: const [
                      DropdownMenuItem(value: 'modern', child: Text('Moderne')),
                      DropdownMenuItem(value: 'classic', child: Text('Classique')),
                      DropdownMenuItem(value: 'minimal', child: Text('Minimal')),
                      DropdownMenuItem(value: 'artistic', child: Text('Artistique')),
                    ],
                    onChanged: (value) => _selectedStyle = value!,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Humeur',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedMood,
                    items: const [
                      DropdownMenuItem(value: 'auto', child: Text('Automatique')),
                      DropdownMenuItem(value: 'bright', child: Text('Lumineux')),
                      DropdownMenuItem(value: 'dark', child: Text('Sombre')),
                      DropdownMenuItem(value: 'colorful', child: Text('Coloré')),
                      DropdownMenuItem(value: 'monochrome', child: Text('Monochrome')),
                    ],
                    onChanged: (value) => _selectedMood = value!,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _themeIntensity,
                    min: 0.1,
                    max: 2.0,
                    divisions: 19,
                    label: 'Intensité: ${_themeIntensity.toStringAsFixed(1)}',
                    onChanged: (value) => _themeIntensity = value,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateTheme,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Générer le thème'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
        ],
      ),
    );

  Widget _buildBottomActions() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_currentExtraction != null)
          OutlinedButton.icon(
            onPressed: _analyzeColors,
            icon: const Icon(Icons.color_lens),
            label: const Text('Analyser'),
          ),
        if (_currentExtraction != null)
          OutlinedButton.icon(
            onPressed: _exportColors,
            icon: const Icon(Icons.download),
            label: const Text('Exporter'),
          ),
        OutlinedButton.icon(
          onPressed: _clearPhoto,
          icon: const Icon(Icons.clear),
          label: const Text('Effacer'),
        ),
      ],
    );

  Future<void> _capturePhoto() async {
    final path = await _photoService.capturePhoto();
    if (path != null) {
      setState(() {
        _selectedImagePath = path;
        _currentExtraction = null;
      });
      _animationController.forward();
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    final path = await _photoService.pickPhotoFromGallery();
    if (path != null) {
      setState(() {
        _selectedImagePath = path;
        _currentExtraction = null;
      });
      _animationController.forward();
    }
  }

  void _changePhoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Prendre une photo'),
            onTap: () {
              Navigator.pop(context);
              _capturePhoto();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galerie'),
            onTap: () {
              Navigator.pop(context);
              _pickPhotoFromGallery();
            },
          ),
        ],
      ),
    );
  }

  void _selectFilter(PhotoFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilterToImage();
  }

  Future<void> _applyFilterToImage() async {
    if (_selectedImagePath == null || _selectedFilter == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final filteredBytes = await _photoService.applyFilter(
        _selectedImagePath!,
        _selectedFilter!,
      );

      // Sauvegarder l'image filtrée
      final directory = await getTemporaryDirectory();
      final fileName = 'filtered_${DateTime.now().millisecondsSinceEpoch}.png';
      final filteredPath = path.join(directory.path, fileName);
      final filteredFile = File(filteredPath);
      await filteredFile.writeAsBytes(filteredBytes);

      setState(() {
        _selectedImagePath = filteredPath;
        _currentExtraction = null;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur application filtre: $e')),
        );
      }
    }
  }

  Future<void> _analyzeColors() async {
    if (_selectedImagePath == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final extraction = await _photoService.analyzePhotoColors(_selectedImagePath!);
      setState(() {
        _currentExtraction = extraction;
        _isAnalyzing = false;
      });
      widget.onColorsExtracted?.call(extraction);
      _tabController.animateTo(1);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur analyse: $e')),
        );
      }
    }
  }

  Future<void> _generateTheme() async {
    if (_selectedImagePath == null || _themeName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une photo et nommer le thème')),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final theme = await _photoService.generateThemeFromPhoto(
        _selectedImagePath!,
        _themeName,
      );

      // Appliquer l'intensité et le style
      final adjustedTheme = _adjustTheme(theme);

      widget.onThemeGenerated(adjustedTheme);
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thème "$_themeName" généré avec succès!')),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur génération thème: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _adjustTheme(Map<String, dynamic> theme) {
    final adjustedTheme = Map<String, dynamic>.from(theme);

    // Ajuster l'intensité des couleurs
    final colors = adjustedTheme['colors'] as Map<String, dynamic>;
    colors.forEach((key, value) {
      final color = Color(value as int);
      final adjustedColor = _adjustColorIntensity(color, _themeIntensity);
      colors[key] = adjustedColor.value;
    });

    // Appliquer le style sélectionné
    adjustedTheme['style'] = _selectedStyle;
    if (_selectedMood != 'auto') {
      adjustedTheme['mood'] = _selectedMood;
    }

    return adjustedTheme;
  }

  Color _adjustColorIntensity(Color color, double intensity) => Color.fromARGB(
      (color.a * 255).round(),
      (color.r * intensity * 255).clamp(0, 255).round(),
      (color.g * intensity * 255).clamp(0, 255).round(),
      (color.b * intensity * 255).clamp(0, 255).round(),
    );

  Future<void> _exportColors() async {
    if (_currentExtraction == null) return;

    try {
      await _exportService.exportColorPalette(_currentExtraction!.palette);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Palette exportée avec succès!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur export: $e')),
        );
      }
    }
  }

  void _clearPhoto() {
    setState(() {
      _selectedImagePath = null;
      _currentExtraction = null;
      _selectedFilter = null;
      _themeName = '';
    });
    _animationController.reset();
  }

  void _copyColorValue(Color color) {
    Clipboard.setData(ClipboardData(text: _colorToHex(color)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Couleur ${_colorToHex(color)} copiée!')),
    );
  }

  String _colorToHex(Color color) => '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  Color _getContrastColor(Color color) {
    final luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  IconData _getFilterIcon(String category) {
    switch (category) {
      case 'Color':
        return Icons.palette;
      case 'Monochrome':
        return Icons.filter_b_and_w;
      case 'Adjustment':
        return Icons.tune;
      case 'Effect':
        return Icons.blur_on;
      default:
        return Icons.filter;
    }
  }
}
