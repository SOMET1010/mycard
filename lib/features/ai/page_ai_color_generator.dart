import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/app/di.dart';
import 'package:mycard/core/services/ai_color_generator_service.dart';

class AIColorGeneratorPage extends ConsumerStatefulWidget {
  const AIColorGeneratorPage({super.key});

  @override
  ConsumerState<AIColorGeneratorPage> createState() =>
      _AIColorGeneratorPageState();
}

class _AIColorGeneratorPageState extends ConsumerState<AIColorGeneratorPage> {
  final TextEditingController _descriptionController = TextEditingController();
  AIColorPalette? _generatedPalette;
  bool _isGenerating = false;
  ColorGenerationMethod _selectedMethod = ColorGenerationMethod.aiHarmony;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _generatePalette() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final aiService = ref.read(aiColorGeneratorProvider);

      // Simulation d'un délai pour l'IA
      await Future.delayed(const Duration(seconds: 1));

      final palette = AIColorGeneratorService.generatePalette(
        method: _selectedMethod,
        mood: _getMoodFromDescription(_descriptionController.text),
      );

      setState(() {
        _generatedPalette = palette;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  ColorMood? _getMoodFromDescription(String description) {
    final lowerDesc = description.toLowerCase();

    if (lowerDesc.contains('professionnel') || lowerDesc.contains('business')) {
      return ColorMood.professional;
    } else if (lowerDesc.contains('créatif') ||
        lowerDesc.contains('artistique')) {
      return ColorMood.creative;
    } else if (lowerDesc.contains('énergique') ||
        lowerDesc.contains('dynamique')) {
      return ColorMood.energetic;
    } else if (lowerDesc.contains('calme') || lowerDesc.contains('relax')) {
      return ColorMood.calm;
    } else if (lowerDesc.contains('naturel') || lowerDesc.contains('bio')) {
      return ColorMood.natural;
    } else if (lowerDesc.contains('luxe') || lowerDesc.contains('premium')) {
      return ColorMood.luxurious;
    }

    return null;
  }

  void _applyPaletteToEditor() {
    if (_generatedPalette != null) {
      // TODO: Implémenter l'application de la palette à l'éditeur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Palette appliquée à l\'éditeur!')),
      );
      // Naviguer vers l'éditeur avec la palette
      context.go('/editor');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/gallery'),
      ),
      title: const Text('Générateur IA de Couleurs'),
      actions: [
        if (_generatedPalette != null)
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _applyPaletteToEditor,
            tooltip: 'Appliquer à l\'éditeur',
          ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Méthode de génération',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ColorGenerationMethod>(
                    initialValue: _selectedMethod,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: ColorGenerationMethod.values
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(_getMethodName(method)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMethod = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description du thème (optionnel)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Ex: "Une carte professionnelle élégante"',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generatePalette,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        _isGenerating
                            ? 'Génération en cours...'
                            : 'Générer une palette',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_generatedPalette != null) _buildPaletteCard(context),
        ],
      ),
    ),
  );

  Widget _buildPaletteCard(BuildContext context) {
    final palette = _generatedPalette!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(palette.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              palette.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Affichage des couleurs principales
            Row(
              children: [
                Expanded(
                  child: _buildColorSwatch('Primaire', palette.primaryColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildColorSwatch(
                    'Secondaire',
                    palette.secondaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildColorSwatch('Accent', palette.accentColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildColorSwatch('Fond', palette.backgroundColor),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildColorSwatch('Texte', palette.textColor)),
                const SizedBox(width: 8),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _applyPaletteToEditor,
                    icon: const Icon(Icons.edit),
                    label: const Text('Appliquer à l\'éditeur'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _generatedPalette = null;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Nouvelle génération',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSwatch(String label, Color color) => Column(
    children: [
      Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    ],
  );

  String _getMethodName(ColorGenerationMethod method) {
    switch (method) {
      case ColorGenerationMethod.complementary:
        return 'Complémentaire';
      case ColorGenerationMethod.analogous:
        return 'Analogues';
      case ColorGenerationMethod.triadic:
        return 'Triadique';
      case ColorGenerationMethod.tetradic:
        return 'Tétradique';
      case ColorGenerationMethod.splitComplementary:
        return 'Split-Complémentaire';
      case ColorGenerationMethod.monochromatic:
        return 'Monochromatique';
      case ColorGenerationMethod.aiHarmony:
        return 'IA Harmony';
      case ColorGenerationMethod.moodBased:
        return 'Basé sur l\'humeur';
      case ColorGenerationMethod.brandBased:
        return 'Basé sur la marque';
      case ColorGenerationMethod.seasonal:
        return 'Saisonnier';
      case ColorGenerationMethod.random:
        return 'Aléatoire';
      case ColorGenerationMethod.gradientBased:
        return 'Basé sur dégradé';
      case ColorGenerationMethod.imageExtracted:
        return 'Extrait d\'image';
      case ColorGenerationMethod.accessibility:
        return 'Accessibilité';
    }
  }
}
