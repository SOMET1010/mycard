/// Page d'édition d'une carte de visite
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/app/di.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/core/services/accessibility_service.dart';
import 'package:mycard/core/services/export_service.dart';
import 'package:mycard/core/services/presets_service.dart';
import 'package:mycard/core/services/qr_service.dart';
import 'package:mycard/core/services/vcard_service.dart';
import 'package:mycard/data/models/business_card.dart';
import 'package:mycard/data/models/card_preset.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/features/editor/form_card_back.dart';
import 'package:mycard/features/editor/form_card_fields.dart';
import 'package:mycard/features/editor/preview_card.dart';
import 'package:mycard/features/templates/page_templates_list.dart';
import 'package:mycard/widgets/atoms/upload_area.dart';
import 'package:screenshot/screenshot.dart';

class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({super.key, this.card});
  final BusinessCard? card;

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _fullNameController;
  late TextEditingController _titleController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _notesController;

  // Contrôleurs pour le verso
  String? _backNotes;
  List<String>? _backServices;
  String? _backOpeningHours;
  Map<String, String>? _backSocialLinks;

  CardTemplate? _selectedTemplate;
  EventOverlay? _selectedEvent;
  Map<String, String> _customColors = {};
  final String _selectedColorScheme = 'Default Warm';
  String _fontFamily = 'Manrope';
  String _sizeKey = 'Standard';
  String? _logoPath;
  final ScreenshotController _screenshotController = ScreenshotController();
  final ScreenshotController _qrScreenshotController = ScreenshotController();

  // Modules métiers simples
  final String _selectedModule = 'Aucun';

  // Presets utilisateur
  List<CardPreset> _presets = [];
  CardPreset? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeTemplateAndEvent();
    _loadPresets();
  }

  void _initializeControllers() {
    final card = widget.card;
    _firstNameController = TextEditingController(text: card?.firstName ?? '');
    _lastNameController = TextEditingController(text: card?.lastName ?? '');
    _fullNameController = TextEditingController(
      text: '${card?.firstName ?? ''} ${card?.lastName ?? ''}'.trim(),
    );
    _titleController = TextEditingController(text: card?.title ?? '');
    _phoneController = TextEditingController(text: card?.phone ?? '');
    _emailController = TextEditingController(text: card?.email ?? '');
    _companyController = TextEditingController(text: card?.company ?? '');
    _websiteController = TextEditingController(text: card?.website ?? '');
    _addressController = TextEditingController(text: card?.address ?? '');
    _cityController = TextEditingController(text: card?.city ?? '');
    _postalCodeController = TextEditingController(text: card?.postalCode ?? '');
    _countryController = TextEditingController(text: card?.country ?? '');
    _notesController = TextEditingController(text: card?.notes ?? '');

    // Initialiser les valeurs du verso
    _backNotes = card?.backNotes;
    _backServices = card?.backServices;
    _backOpeningHours = card?.backOpeningHours;
    _backSocialLinks = card?.backSocialLinks;

    _attachListeners();

    // Pré-remplissage depuis l'utilisateur Firebase si création d'une nouvelle carte
    if (card == null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final dn = user.displayName ?? '';
        if (dn.isNotEmpty) {
          _fullNameController.text = dn;
        }
        if ((user.email ?? '').isNotEmpty) {
          _emailController.text = user.email!;
        }
      }
    }
  }

  void _attachListeners() {
    for (final c in [
      _firstNameController,
      _lastNameController,
      _titleController,
      _phoneController,
      _emailController,
      _companyController,
      _websiteController,
      _addressController,
      _cityController,
      _postalCodeController,
      _countryController,
      _notesController,
    ]) {
      c.addListener(() => setState(() {}));
    }

    // Synchroniser Nom complet -> Prénom/Nom
    _fullNameController.addListener(() {
      final value = _fullNameController.text.trim();
      final parts = value.split(RegExp(r'\s+'));
      var first = '';
      var last = '';
      if (parts.isNotEmpty) {
        first = parts.first;
        if (parts.length > 1) {
          last = parts.sublist(1).join(' ');
        }
      }

      if (_firstNameController.text != first) {
        _firstNameController.text = first;
        _firstNameController.selection = TextSelection.collapsed(
          offset: _firstNameController.text.length,
        );
      }
      if (_lastNameController.text != last) {
        _lastNameController.text = last;
        _lastNameController.selection = TextSelection.collapsed(
          offset: _lastNameController.text.length,
        );
      }
      setState(() {});
    });
  }

  void _initializeTemplateAndEvent() {
    if (widget.card != null) {
      _selectedTemplate = CardTemplate.findById(widget.card!.templateId);
      _selectedEvent = widget.card!.eventOverlayId != null
          ? EventOverlay.findById(widget.card!.eventOverlayId!)
          : null;
      _customColors = Map.from(widget.card!.customColors);
    }
    if (_customColors.isEmpty) {
      _applyColorScheme(_selectedColorScheme);
    }
    if (_selectedEvent != null) {
      _applyEventDesign(_selectedEvent!);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fullNameController.dispose();
    _titleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _notesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Éditeur de Carte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => context.go('/ai-generator'),
            tooltip: 'Générateur IA de couleurs',
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveCard),
        ],
      ),
      body: isWide ? _buildWideLayout() : _buildMobileLayout(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPreview,
        icon: const Icon(Icons.remove_red_eye_outlined),
        label: const Text('Preview'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMobileLayout() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CardFieldsForm(
          formKey: _formKey,
          fullNameController: _fullNameController,
          titleController: _titleController,
          companyController: _companyController,
          phoneController: _phoneController,
          emailController: _emailController,
        ),

        const SizedBox(height: 24),

        // Formulaire du verso
        CardBackForm(
          backNotes: _backNotes,
          backServices: _backServices,
          backOpeningHours: _backOpeningHours,
          backSocialLinks: _backSocialLinks,
          onChanged:
              ({
                String? backNotes,
                List<String>? backServices,
                String? backOpeningHours,
                Map<String, String>? backSocialLinks,
              }) {
                setState(() {
                  _backNotes = backNotes;
                  _backServices = backServices;
                  _backOpeningHours = backOpeningHours;
                  _backSocialLinks = backSocialLinks;
                });
              },
        ),

        const SizedBox(height: 16),
        const Text(
          'Logo/Photo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        UploadArea(
          initialPath: _logoPath,
          onSelected: (p) async {
            setState(() => _logoPath = p);
          },
        ),

        const SizedBox(height: 16),
        const Text(
          'Design',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildDesignSelectors(),

        const SizedBox(height: 24),
        SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveCard,
              child: const Text('Enregistrer la Carte'),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildDesignSelectors() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Ligne d'actions: choisir un modèle, gérer presets
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(
            onPressed: _openTemplatePicker,
            icon: const Icon(Icons.style),
            label: const Text('Choisir un modèle'),
          ),
          OutlinedButton.icon(
            onPressed: _saveCurrentAsPreset,
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Enregistrer comme preset'),
          ),
          if (_presets.isNotEmpty)
            DropdownButton<CardPreset>(
              hint: const Text('Appliquer un preset'),
              value: _selectedPreset,
              items: _presets
                  .map(
                    (p) => DropdownMenuItem<CardPreset>(
                      value: p,
                      child: Text(p.name),
                    ),
                  )
                  .toList(),
              onChanged: (p) {
                if (p == null) return;
                setState(() => _selectedPreset = p);
                _applyPreset(p);
              },
            ),
        ],
      ),
      const SizedBox(height: 8),
    ],
  );

  (double, double) _currentPreviewSize() {
    switch (_sizeKey) {
      case 'Compact':
        return (320, 180);
      case 'Large':
        return (400, 230);
      case 'Standard':
      default:
        return (350, 200);
    }
  }

  void _applyEventDesign(EventOverlay event) {
    _selectedTemplate =
        CardTemplate.findById('event_campaign') ?? _selectedTemplate;
    final accent = event.color.value
        .toRadixString(16)
        .substring(2)
        .toUpperCase();
    _customColors = {
      'primary': '6A1B9A',
      'secondary': '2E2E3A',
      'accent': accent,
    };
  }

  void _applyColorScheme(String key) {
    // Update custom colors to reflect selected scheme
    switch (key) {
      case 'Cool Blue':
        _customColors = {
          'primary': '0E4274', // deep-sapphire
          'secondary': '8DC5D2', // half-baked
          'accent': '1E81B0', // eastern-blue
        };
        break;
      case 'Deep Green':
        _customColors = {
          'primary': '21130D', // deep brown text as primary
          'secondary': '8DC5D2',
          'accent': '2E7D32',
        };
        break;
      case 'Default Warm':
      default:
        _customColors = {
          'primary': 'E28742', // burnt-sienna
          'secondary': 'EAB676', // tacao
          'accent': '21130D', // eternity
        };
    }
  }

  Widget _buildWideLayout() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CardFieldsForm(
          formKey: _formKey,
          fullNameController: _fullNameController,
          titleController: _titleController,
          companyController: _companyController,
          phoneController: _phoneController,
          emailController: _emailController,
        ),
        const SizedBox(height: 24),

        // Formulaire du verso
        CardBackForm(
          backNotes: _backNotes,
          backServices: _backServices,
          backOpeningHours: _backOpeningHours,
          backSocialLinks: _backSocialLinks,
          onChanged:
              ({
                String? backNotes,
                List<String>? backServices,
                String? backOpeningHours,
                Map<String, String>? backSocialLinks,
              }) {
                setState(() {
                  _backNotes = backNotes;
                  _backServices = backServices;
                  _backOpeningHours = backOpeningHours;
                  _backSocialLinks = backSocialLinks;
                });
              },
        ),
        const SizedBox(height: 16),
        const Text(
          'Logo/Photo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        UploadArea(
          initialPath: _logoPath,
          onSelected: (p) async {
            setState(() => _logoPath = p);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Design',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildDesignSelectors(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveCard,
            child: const Text('Enregistrer la Carte'),
          ),
        ),
      ],
    ),
  );

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cardsRepo = ref.read(cardsRepositoryProvider);
    if (!cardsRepo.isInitialized) {
      await cardsRepo.init();
    }

    try {
      if (widget.card == null) {
        await cardsRepo.createCard(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          title: _titleController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          company: _companyController.text,
          website: _websiteController.text,
          address: _addressController.text,
          city: _cityController.text,
          postalCode: _postalCodeController.text,
          country: _countryController.text,
          notes: _notesController.text,
          templateId:
              _selectedTemplate?.id ??
              CardTemplate.predefinedTemplates.first.id,
          eventOverlayId: _selectedEvent?.id,
          customColors: _customColors,
          logoPath: _logoPath,
          backNotes: _backNotes,
          backServices: _backServices,
          backOpeningHours: _backOpeningHours,
          backSocialLinks: _backSocialLinks,
        );
      } else {
        final updatedCard = widget.card!.copyWith(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          title: _titleController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          company: _companyController.text,
          website: _websiteController.text,
          address: _addressController.text,
          city: _cityController.text,
          postalCode: _postalCodeController.text,
          country: _countryController.text,
          notes: _notesController.text,
          templateId: _selectedTemplate?.id,
          eventOverlayId: _selectedEvent?.id,
          customColors: _customColors,
          logoPath: _logoPath ?? widget.card!.logoPath,
          backNotes: _backNotes,
          backServices: _backServices,
          backOpeningHours: _backOpeningHours,
          backSocialLinks: _backSocialLinks,
        );
        await cardsRepo.updateCard(updatedCard);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.card == null
                  ? 'Carte créée avec succès'
                  : 'Carte mise à jour avec succès',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }
  }

  void _openPreview() {
    final size = _currentPreviewSize();
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Preview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Screenshot(
                controller: _screenshotController,
                child: CardPreview(
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                  title: _titleController.text,
                  phone: _phoneController.text,
                  email: _emailController.text,
                  company: _companyController.text,
                  website: _websiteController.text,
                  address: _addressController.text,
                  city: _cityController.text,
                  postalCode: _postalCodeController.text,
                  country: _countryController.text,
                  template: _selectedTemplate,
                  eventOverlay: _selectedEvent,
                  customColors: _customColors,
                  fontFamily: _fontFamily,
                  logoPath: _logoPath,
                  previewWidth: size.$1,
                  previewHeight: size.$2,
                  backNotes: _backNotes,
                  backServices: _backServices,
                  backOpeningHours: _backOpeningHours,
                  backSocialLinks: _backSocialLinks,
                ),
              ),
              const SizedBox(height: 16),
              _buildExportButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportButtons() {
    final fileName = ExportService.generateFileName(
      name: '${_firstNameController.text}_${_lastNameController.text}',
      format: '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _exportAsPNG(fileName),
                icon: const Icon(Icons.image),
                label: const Text('PNG'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepSapphire,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _exportAsPDF(fileName),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _exportAsJPG(fileName),
                icon: const Icon(Icons.photo_camera),
                label: const Text('JPG'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _exportVCard(fileName),
                icon: const Icon(Icons.contact_page),
                label: const Text('vCard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openQrSheet,
                icon: const Icon(Icons.qr_code),
                label: const Text('QR Code'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportAsPNG(String fileName) async {
    final cleanName = fileName.replaceAll('.png', '');
    await ExportService.exportAsPNG(
      screenshotController: _screenshotController,
      fileName: cleanName,
      context: context,
    );
  }

  Future<void> _exportAsPDF(String fileName) async {
    final cleanName = fileName.replaceAll('.pdf', '');
    await ExportService.exportAsPDF(
      screenshotController: _screenshotController,
      fileName: cleanName,
      context: context,
    );
  }

  Future<void> _exportAsJPG(String fileName) async {
    final cleanName = fileName.replaceAll('.jpg', '');
    await ExportService.exportAsJPG(
      screenshotController: _screenshotController,
      fileName: cleanName,
      context: context,
    );
  }

  Future<void> _exportVCard(String fileName) async {
    final vCardContent = VCardService.generateVCard(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      title: _titleController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      company: _companyController.text,
      website: _websiteController.text,
      address: _addressController.text,
      city: _cityController.text,
      postalCode: _postalCodeController.text,
      country: _countryController.text,
    );

    final cleanName = fileName.replaceAll('.vcf', '');
    if (!mounted) return;
    await ExportService.exportVCard(
      vCardContent: vCardContent,
      fileName: cleanName,
      context: context,
    );
  }

  // Ouvre la galerie des modèles en mode sélection
  Future<void> _openTemplatePicker() async {
    final selected = await Navigator.push<CardTemplate>(
      context,
      MaterialPageRoute(
        builder: (context) => const TemplatesListPage(selectionMode: true),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedTemplate = selected;
        _customColors = Map<String, String>.from(selected.colors);
      });
    }
  }

  // Applique des réglages rapides selon le module métier
  void _applyModule(String module) {
    switch (module) {
      case 'Développeur':
        _titleController.text = _titleController.text.isEmpty
            ? 'Développeur'
            : _titleController.text;
        _selectedTemplate =
            CardTemplate.findById('creative') ?? _selectedTemplate;
        _applyColorScheme('Cool Blue');
        break;
      case 'Médecin':
        _titleController.text = _titleController.text.isEmpty
            ? 'Médecin'
            : _titleController.text;
        _selectedTemplate =
            CardTemplate.findById('corporate') ?? _selectedTemplate;
        _applyColorScheme('Deep Green');
        break;
      case 'Juriste':
        _titleController.text = _titleController.text.isEmpty
            ? 'Juriste'
            : _titleController.text;
        _selectedTemplate =
            CardTemplate.findById('corporate') ?? _selectedTemplate;
        _applyColorScheme('Default Warm');
        break;
      case 'Commercial':
        _titleController.text = _titleController.text.isEmpty
            ? 'Commercial'
            : _titleController.text;
        _selectedTemplate =
            CardTemplate.findById('corporate') ?? _selectedTemplate;
        _applyColorScheme('Default Warm');
        break;
      case 'Aucun':
      default:
        // Pas de changement spécifique
        break;
    }
    setState(() {});
  }

  // Charge les presets utilisateur
  Future<void> _loadPresets() async {
    final list = await PresetsService.getPresets();
    if (!mounted) return;
    setState(() => _presets = list);
  }

  // Enregistre l'état courant comme preset
  Future<void> _saveCurrentAsPreset() async {
    final nameController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nom du preset'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Ex: Carte Corporate Pro',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final preset = CardPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.isEmpty
          ? 'Preset ${_presets.length + 1}'
          : nameController.text,
      templateId:
          (_selectedTemplate ?? CardTemplate.predefinedTemplates.first).id,
      eventOverlayId: _selectedEvent?.id,
      customColors: _customColors,
      fontFamily: _fontFamily,
      sizeKey: _sizeKey,
    );
    await PresetsService.savePreset(preset);
    await _loadPresets();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preset enregistré')));
  }

  // Applique un preset existant
  void _applyPreset(CardPreset p) {
    _selectedTemplate =
        CardTemplate.findById(p.templateId) ?? _selectedTemplate;
    _selectedEvent = p.eventOverlayId != null
        ? EventOverlay.findById(p.eventOverlayId!)
        : _selectedEvent;
    _customColors = Map<String, String>.from(p.customColors);
    if (p.fontFamily != null) _fontFamily = p.fontFamily!;
    if (p.sizeKey != null) _sizeKey = p.sizeKey!;
    setState(() {});
  }

  // Affiche un résumé d'accessibilité (contraste texte/fond principal)
  Widget _buildAccessibilityCheck() {
    var fg = Colors.black;
    try {
      final hex = _customColors['primary'] ?? '000000';
      fg = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}
    const bg = Colors.white;
    final ok = AccessibilityService.hasSufficientContrast(fg.value, bg.value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (ok ? Colors.green : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ok ? Colors.green : Colors.orange),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.warning_amber,
            color: ok ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ok ? 'Contraste OK (WCAG AA)' : 'Contraste à améliorer (WCAG AA)',
              style: TextStyle(
                color: ok ? Colors.green[800] : Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ouvre une feuille avec le QR Code de contact
  void _openQrSheet() {
    final fullName = '${_firstNameController.text} ${_lastNameController.text}'
        .trim();
    final phone = _phoneController.text;
    final email = _emailController.text;
    final company = _companyController.text;
    final website = _websiteController.text;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Code QR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Screenshot(
              controller: _qrScreenshotController,
              child: QRService.generateContactQRCode(
                fullName,
                phone,
                email,
                company: company,
                website: website,
                size: 220,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
