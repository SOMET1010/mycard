/// Panneau de style pour personnaliser l'apparence
library;

import 'package:flutter/material.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';

class StylePanel extends StatelessWidget {
  const StylePanel({
    super.key,
    required this.selectedTemplate,
    required this.selectedEvent,
    required this.customColors,
    required this.onTemplateChanged,
    required this.onEventChanged,
    required this.onColorsChanged,
  });
  final CardTemplate? selectedTemplate;
  final EventOverlay? selectedEvent;
  final Map<String, String> customColors;
  final Function(CardTemplate?) onTemplateChanged;
  final Function(EventOverlay?) onEventChanged;
  final Function(Map<String, String>) onColorsChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Style et apparence',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),

      // Sélection du template
      _buildTemplateSelector(),
      const SizedBox(height: 16),

      // Sélection de l'événement
      _buildEventSelector(),
      const SizedBox(height: 16),

      // Personnalisation des couleurs
      _buildColorCustomizer(),
    ],
  );

  Widget _buildTemplateSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Modèle',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: _showTemplateSelectionDialog,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedTemplate?.name ?? 'Choisir un modèle',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildEventSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Événement',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<EventOverlay?>(
        initialValue: selectedEvent,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        hint: const Text('Aucun événement'),
        items: [
          const DropdownMenuItem<EventOverlay?>(
            value: null,
            child: Text('Aucun événement'),
          ),
          ...EventOverlay.predefinedEvents.map(
            (event) => DropdownMenuItem<EventOverlay?>(
              value: event,
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: event.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(event.label),
                ],
              ),
            ),
          ),
        ],
        onChanged: onEventChanged,
      ),
    ],
  );

  Widget _buildColorCustomizer() {
    if (selectedTemplate == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Couleurs personnalisées',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ...['primary', 'secondary', 'accent'].map(
          (colorType) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getColorLabel(colorType),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                InkWell(
                  onTap: () => _showColorPicker(colorType),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCurrentColor(colorType),
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getCurrentColor(String colorType) {
    final customColor = customColors[colorType];
    if (customColor != null) {
      return Color(int.parse('FF$customColor', radix: 16));
    }

    switch (colorType) {
      case 'primary':
        return selectedTemplate?.primaryColor ?? Colors.black;
      case 'secondary':
        return selectedTemplate?.secondaryColor ?? Colors.grey;
      case 'accent':
        return selectedTemplate?.accentColor ?? Colors.blue;
      default:
        return Colors.black;
    }
  }

  String _getColorLabel(String colorType) {
    switch (colorType) {
      case 'primary':
        return 'Couleur principale';
      case 'secondary':
        return 'Couleur secondaire';
      case 'accent':
        return 'Couleur d\'accent';
      default:
        return colorType;
    }
  }

  void _showTemplateSelectionDialog() {
    // À implémenter : navigation vers la page de sélection de template
  }

  void _showColorPicker(String colorType) {
    // À implémenter : dialogue de sélection de couleur
  }
}
