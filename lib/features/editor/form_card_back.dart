/// Formulaire pour le verso de la carte de visite
library;
import 'package:flutter/material.dart';

class CardBackForm extends StatefulWidget {
  const CardBackForm({
    super.key,
    this.backNotes,
    this.backServices,
    this.backOpeningHours,
    this.backSocialLinks,
    this.onChanged,
  });

  final String? backNotes;
  final List<String>? backServices;
  final String? backOpeningHours;
  final Map<String, String>? backSocialLinks;
  final Function({
    String? backNotes,
    List<String>? backServices,
    String? backOpeningHours,
    Map<String, String>? backSocialLinks,
  })? onChanged;

  @override
  State<CardBackForm> createState() => _CardBackFormState();
}

class _CardBackFormState extends State<CardBackForm> {
  late TextEditingController _notesController;
  late TextEditingController _openingHoursController;
  final List<TextEditingController> _serviceControllers = [];
  final Map<String, TextEditingController> _socialControllers = {};

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.backNotes ?? '');
    _openingHoursController = TextEditingController(text: widget.backOpeningHours ?? '');

    // Initialiser les contrôleurs de services
    final services = widget.backServices ?? [];
    if (services.isNotEmpty) {
      _serviceControllers.addAll(services.map((s) => TextEditingController(text: s)));
    } else {
      _serviceControllers.add(TextEditingController()); // Au moins un champ
    }

    // Initialiser les contrôleurs de réseaux sociaux
    final socialLinks = widget.backSocialLinks ?? {};
    _socialControllers.addAll({
      'linkedin': TextEditingController(text: socialLinks['linkedin'] ?? ''),
      'twitter': TextEditingController(text: socialLinks['twitter'] ?? ''),
      'facebook': TextEditingController(text: socialLinks['facebook'] ?? ''),
      'instagram': TextEditingController(text: socialLinks['instagram'] ?? ''),
      'website': TextEditingController(text: socialLinks['website'] ?? ''),
    });

    _attachListeners();
  }

  void _attachListeners() {
    _notesController.addListener(_notifyChanged);
    _openingHoursController.addListener(_notifyChanged);

    for (final controller in _serviceControllers) {
      controller.addListener(_notifyChanged);
    }

    for (final controller in _socialControllers.values) {
      controller.addListener(_notifyChanged);
    }
  }

  void _notifyChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(
        backNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        backServices: _serviceControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
        backOpeningHours: _openingHoursController.text.trim().isEmpty ? null : _openingHoursController.text.trim(),
        backSocialLinks: {
          for (final entry in _socialControllers.entries)
            if (entry.value.text.trim().isNotEmpty)
              entry.key: entry.value.text.trim()
        },
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _openingHoursController.dispose();
    for (final controller in _serviceControllers) {
      controller.dispose();
    }
    for (final controller in _socialControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informations du verso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Notes supplémentaires
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes supplémentaires',
            hintText: 'Description, mission, valeurs...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        // Services
        const Text('Services proposés', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ..._serviceControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: index == 0 ? 'Service principal' : 'Service ${index + 1}',
                      hintText: 'Ex: Conseil en stratégie',
                      border: const OutlineInputBorder(),
                      suffixIcon: index == _serviceControllers.length - 1
                          ? IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addServiceField,
                            )
                          : _serviceControllers.length > 1
                              ? IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => _removeServiceField(index),
                                )
                              : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),

        // Horaires d'ouverture
        TextFormField(
          controller: _openingHoursController,
          decoration: const InputDecoration(
            labelText: 'Horaires d\'ouverture',
            hintText: 'Ex: Lun-Ven: 9h-18h',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Réseaux sociaux
        const Text('Réseaux sociaux', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _buildSocialField('LinkedIn', 'linkedin', Icons.work),
        _buildSocialField('Twitter', 'twitter', Icons.alternate_email),
        _buildSocialField('Facebook', 'facebook', Icons.facebook),
        _buildSocialField('Instagram', 'instagram', Icons.camera_alt),
        _buildSocialField('Site web', 'website', Icons.language),
      ],
    );

  Widget _buildSocialField(String label, String key, IconData icon) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: _socialControllers[key]!,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          hintText: 'URL du profil',
          border: const OutlineInputBorder(),
        ),
      ),
    );

  void _addServiceField() {
    setState(() {
      _serviceControllers.add(TextEditingController());
      _serviceControllers.last.addListener(_notifyChanged);
    });
  }

  void _removeServiceField(int index) {
    setState(() {
      final controller = _serviceControllers.removeAt(index);
      controller.removeListener(_notifyChanged);
      controller.dispose();
    });
  }
}