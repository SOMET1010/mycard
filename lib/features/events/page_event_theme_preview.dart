/// Page d'aperçu et de personnalisation des thèmes d'événements
library;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycard/core/services/theme_service.dart';
import 'package:mycard/data/models/business_card.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/features/editor/preview_card.dart';
import 'package:mycard/widgets/atoms/color_picker_field.dart';
import 'package:mycard/widgets/atoms/loading_button.dart';

class EventThemePreviewPage extends StatefulWidget {

  const EventThemePreviewPage({super.key, required this.event});
  final EventOverlay event;

  @override
  State<EventThemePreviewPage> createState() => _EventThemePreviewPageState();
}

// Modèle de personnalisation de thème
class EventThemeCustomization {

  const EventThemeCustomization({
    this.templateId = 'minimal',
    this.intensity = 1.0,
    this.showEventBadge = true,
    this.accentColor = Colors.white,
    this.primaryColor = Colors.black,
    this.secondaryColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.fontFamily = 'Roboto',
    this.titleFontSize = 20.0,
    this.bodyFontSize = 14.0,
    this.cardPadding = 16.0,
    this.borderRadius = 8.0,
    this.shadowOpacity = 0.2,
    this.showBorder = false,
    this.borderWidth = 1.0,
    this.borderColor = Colors.grey,
    this.showBackgroundPattern = false,
    this.backgroundPattern = 'dots',
    this.overlayColor = Colors.black,
    this.overlayOpacity = 0.1,
    this.customTextStyles = const [],
  });

  factory EventThemeCustomization.fromJson(Map<String, dynamic> json) => EventThemeCustomization(
      templateId: json['templateId'] ?? 'minimal',
      intensity: json['intensity']?.toDouble() ?? 1.0,
      showEventBadge: json['showEventBadge'] ?? true,
      accentColor: Color(int.parse('FF${json['accentColor']}', radix: 16)),
      primaryColor: Color(int.parse('FF${json['primaryColor']}', radix: 16)),
      secondaryColor: Color(int.parse('FF${json['secondaryColor']}', radix: 16)),
      backgroundColor: Color(int.parse('FF${json['backgroundColor']}', radix: 16)),
      textColor: Color(int.parse('FF${json['textColor']}', radix: 16)),
      fontFamily: json['fontFamily'] ?? 'Roboto',
      titleFontSize: json['titleFontSize']?.toDouble() ?? 20.0,
      bodyFontSize: json['bodyFontSize']?.toDouble() ?? 14.0,
      cardPadding: json['cardPadding']?.toDouble() ?? 16.0,
      borderRadius: json['borderRadius']?.toDouble() ?? 8.0,
      shadowOpacity: json['shadowOpacity']?.toDouble() ?? 0.2,
      showBorder: json['showBorder'] ?? false,
      borderWidth: json['borderWidth']?.toDouble() ?? 1.0,
      borderColor: Color(int.parse('FF${json['borderColor']}', radix: 16)),
      showBackgroundPattern: json['showBackgroundPattern'] ?? false,
      backgroundPattern: json['backgroundPattern'] ?? 'dots',
      overlayColor: Color(int.parse('FF${json['overlayColor']}', radix: 16)),
      overlayOpacity: json['overlayOpacity']?.toDouble() ?? 0.1,
      customTextStyles: List<String>.from(json['customTextStyles'] ?? []),
    );
  final String templateId;
  final double intensity;
  final bool showEventBadge;
  final Color accentColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;
  final String fontFamily;
  final double titleFontSize;
  final double bodyFontSize;
  final double cardPadding;
  final double borderRadius;
  final double shadowOpacity;
  final bool showBorder;
  final double borderWidth;
  final Color borderColor;
  final bool showBackgroundPattern;
  final String backgroundPattern;
  final Color overlayColor;
  final double overlayOpacity;
  final List<String> customTextStyles;

  EventThemeCustomization copyWith({
    String? templateId,
    double? intensity,
    bool? showEventBadge,
    Color? accentColor,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? textColor,
    String? fontFamily,
    double? titleFontSize,
    double? bodyFontSize,
    double? cardPadding,
    double? borderRadius,
    double? shadowOpacity,
    bool? showBorder,
    double? borderWidth,
    Color? borderColor,
    bool? showBackgroundPattern,
    String? backgroundPattern,
    Color? overlayColor,
    double? overlayOpacity,
    List<String>? customTextStyles,
  }) => EventThemeCustomization(
      templateId: templateId ?? this.templateId,
      intensity: intensity ?? this.intensity,
      showEventBadge: showEventBadge ?? this.showEventBadge,
      accentColor: accentColor ?? this.accentColor,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      fontFamily: fontFamily ?? this.fontFamily,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
      cardPadding: cardPadding ?? this.cardPadding,
      borderRadius: borderRadius ?? this.borderRadius,
      shadowOpacity: shadowOpacity ?? this.shadowOpacity,
      showBorder: showBorder ?? this.showBorder,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      showBackgroundPattern: showBackgroundPattern ?? this.showBackgroundPattern,
      backgroundPattern: backgroundPattern ?? this.backgroundPattern,
      overlayColor: overlayColor ?? this.overlayColor,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      customTextStyles: customTextStyles ?? this.customTextStyles,
    );

  Map<String, dynamic> toJson() => {
      'templateId': templateId,
      'intensity': intensity,
      'showEventBadge': showEventBadge,
      'accentColor': accentColor.value.toRadixString(16),
      'primaryColor': primaryColor.value.toRadixString(16),
      'secondaryColor': secondaryColor.value.toRadixString(16),
      'backgroundColor': backgroundColor.value.toRadixString(16),
      'textColor': textColor.value.toRadixString(16),
      'fontFamily': fontFamily,
      'titleFontSize': titleFontSize,
      'bodyFontSize': bodyFontSize,
      'cardPadding': cardPadding,
      'borderRadius': borderRadius,
      'shadowOpacity': shadowOpacity,
      'showBorder': showBorder,
      'borderWidth': borderWidth,
      'borderColor': borderColor.value.toRadixString(16),
      'showBackgroundPattern': showBackgroundPattern,
      'backgroundPattern': backgroundPattern,
      'overlayColor': overlayColor.value.toRadixString(16),
      'overlayOpacity': overlayOpacity,
      'customTextStyles': customTextStyles,
    };
}

class _EventThemePreviewPageState extends State<EventThemePreviewPage> {
  late BusinessCard _previewCard;
  bool _isUsingTheme = false;
  late EventThemeCustomization _themeCustomization;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    await _loadThemeCustomization();
    _previewCard = _createPreviewCard();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadThemeCustomization() async {
    // Essayer de charger un thème personnalisé sauvegardé
    final savedTheme = await ThemeService.loadCustomTheme(widget.event.id);

    if (savedTheme != null) {
      setState(() {
        _themeCustomization = savedTheme;
      });
    } else {
      // Utiliser un thème prédéfini si aucun thème sauvegardé
      setState(() {
        _themeCustomization = ThemeService.getPredefinedTheme(widget.event);
      });
    }
  }

  BusinessCard _createPreviewCard() => BusinessCard(
      id: 'preview',
      firstName: 'Jean',
      lastName: 'Dupont',
      title: 'Directeur Marketing',
      phone: '+33 1 23 45 67 89',
      email: 'jean.dupont@example.com',
      company: 'Entreprise Exemple',
      website: 'www.example.com',
      address: '123 Rue de la Paix',
      city: 'Paris',
      postalCode: '75001',
      country: 'France',
      notes: 'Carte de visite professionnelle',
      templateId: _themeCustomization.templateId,
      customColors: {
        'primary': _themeCustomization.primaryColor.value.toRadixString(16),
        'secondary': _themeCustomization.secondaryColor.value.toRadixString(16),
        'accent': _themeCustomization.accentColor.value.toRadixString(16),
        'background': _themeCustomization.backgroundColor.value.toRadixString(16),
        'text': _themeCustomization.textColor.value.toRadixString(16),
      },
      eventOverlayId: widget.event.id,
    );

  void _updatePreview() {
    setState(() {
      _previewCard = _createPreviewCard();
    });
  }

  void _updateThemeCustomization(EventThemeCustomization newTheme) {
    setState(() {
      _themeCustomization = newTheme;
    });
    _updatePreview();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(widget.event.label),
        backgroundColor: widget.event.color.withValues(alpha: 0.1),
        foregroundColor: widget.event.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showEventInfo,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement du thème...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Aperçu de la carte
                  _buildPreviewSection(),
                  const SizedBox(height: 24),

                  // Options de personnalisation
                  _buildCustomizationSection(),
                  const SizedBox(height: 24),

                  // Actions
                  _buildActionButtons(),
                ],
              ),
            ),
    );

  Widget _buildPreviewSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aperçu du thème',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: CardPreview(
              firstName: _previewCard.firstName,
              lastName: _previewCard.lastName,
              title: _previewCard.title,
              phone: _previewCard.phone,
              email: _previewCard.email,
              company: _previewCard.company,
              website: _previewCard.website,
              address: _previewCard.address,
              city: _previewCard.city,
              postalCode: _previewCard.postalCode,
              country: _previewCard.country,
              customColors: _previewCard.customColors,
              eventOverlay: widget.event,
              previewWidth: 300,
              previewHeight: 180,
            ),
          ),
        ),
      ],
    );

  Widget _buildCustomizationSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personnalisation avancée',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Navigation par onglets pour les différentes catégories
        _buildCustomizationTabs(),
      ],
    );

  Widget _buildCustomizationTabs() => DefaultTabController(
      length: 5,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: widget.event.color,
            unselectedLabelColor: Colors.grey,
            indicatorColor: widget.event.color,
            tabs: const [
              Tab(text: 'Basique'),
              Tab(text: 'Couleurs'),
              Tab(text: 'Typographie'),
              Tab(text: 'Style'),
              Tab(text: 'Arrière-plan'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: TabBarView(
              children: [
                _buildBasicTab(),
                _buildColorsTab(),
                _buildTypographyTab(),
                _buildStyleTab(),
                _buildBackgroundTab(),
              ],
            ),
          ),
        ],
      ),
    );

  // Onglets de personnalisation
  Widget _buildBasicTab() => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTemplateSelector(),
          const SizedBox(height: 24),
          _buildIntensitySlider(),
          const SizedBox(height: 24),
          _buildEventBadgeToggle(),
        ],
      ),
    );

  Widget _buildColorsTab() => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColorPickerField(
            label: 'Couleur principale',
            selectedColor: _themeCustomization.primaryColor,
            onColorChanged: (color) => _updateThemeCustomization(
              _themeCustomization.copyWith(primaryColor: color),
            ),
            helperText: 'Couleur dominante du thème',
          ),
          const SizedBox(height: 16),
          ColorPickerField(
            label: 'Couleur secondaire',
            selectedColor: _themeCustomization.secondaryColor,
            onColorChanged: (color) => _updateThemeCustomization(
              _themeCustomization.copyWith(secondaryColor: color),
            ),
            helperText: 'Couleur complémentaire',
          ),
          const SizedBox(height: 16),
          ColorPickerField(
            label: 'Couleur d\'accentuation',
            selectedColor: _themeCustomization.accentColor,
            onColorChanged: (color) => _updateThemeCustomization(
              _themeCustomization.copyWith(accentColor: color),
            ),
            helperText: 'Couleur pour les éléments importants',
          ),
          const SizedBox(height: 16),
          ColorPickerField(
            label: 'Couleur de fond',
            selectedColor: _themeCustomization.backgroundColor,
            onColorChanged: (color) => _updateThemeCustomization(
              _themeCustomization.copyWith(backgroundColor: color),
            ),
            helperText: 'Arrière-plan de la carte',
          ),
          const SizedBox(height: 16),
          ColorPickerField(
            label: 'Couleur du texte',
            selectedColor: _themeCustomization.textColor,
            onColorChanged: (color) => _updateThemeCustomization(
              _themeCustomization.copyWith(textColor: color),
            ),
            helperText: 'Couleur principale du texte',
          ),
        ],
      ),
    );

  Widget _buildTypographyTab() => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFontFamilySelector(),
          const SizedBox(height: 24),
          _buildTitleFontSizeSlider(),
          const SizedBox(height: 24),
          _buildBodyFontSizeSlider(),
        ],
      ),
    );

  Widget _buildStyleTab() => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardPaddingSlider(),
          const SizedBox(height: 24),
          _buildBorderRadiusSlider(),
          const SizedBox(height: 24),
          _buildShadowOpacitySlider(),
          const SizedBox(height: 24),
          _buildBorderToggle(),
          const SizedBox(height: 24),
          if (_themeCustomization.showBorder) ...[
            _buildBorderWidthSlider(),
            const SizedBox(height: 16),
            ColorPickerField(
              label: 'Couleur de la bordure',
              selectedColor: _themeCustomization.borderColor,
              onColorChanged: (color) => _updateThemeCustomization(
                _themeCustomization.copyWith(borderColor: color),
              ),
            ),
          ],
        ],
      ),
    );

  Widget _buildBackgroundTab() => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackgroundPatternToggle(),
          const SizedBox(height: 24),
          if (_themeCustomization.showBackgroundPattern)
            _buildPatternSelector(),
          const SizedBox(height: 24),
          ColorPickerField(
            label: 'Couleur de superposition',
            selectedColor: _themeCustomization.overlayColor,
            onColorChanged: (color) => _updateThemeCustomization(
              _themeCustomization.copyWith(overlayColor: color),
            ),
            helperText: 'Couleur de l\'overlay événementiel',
          ),
          const SizedBox(height: 16),
          _buildOverlayOpacitySlider(),
        ],
      ),
    );

  // Widgets de base
  Widget _buildTemplateSelector() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modèle de carte',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildTemplateOption('minimal', 'Minimal'),
            _buildTemplateOption('corporate', 'Entreprise'),
            _buildTemplateOption('ansut_style', 'Moderne'),
          ],
        ),
      ],
    );

  Widget _buildTemplateOption(String template, String label) {
    final isSelected = _themeCustomization.templateId == template;
    return InkWell(
      onTap: () => _updateThemeCustomization(
        _themeCustomization.copyWith(templateId: template),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
                ? widget.event.color.withValues(alpha: 0.1)
                : Colors.transparent,
          border: Border.all(
            color: isSelected ? widget.event.color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? widget.event.color : Colors.grey[700],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildIntensitySlider() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Intensité de la couleur'),
            Text('${(_themeCustomization.intensity * 100).round()}%'),
          ],
        ),
        Slider(
          value: _themeCustomization.intensity,
          min: 0.1,
          max: 1.0,
          divisions: 10,
          onChanged: (value) => _updateThemeCustomization(
            _themeCustomization.copyWith(intensity: value),
          ),
        ),
        Text(
          'Ajuste l\'intensité de la couleur du thème',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );

  Widget _buildEventBadgeToggle() => SwitchListTile(
      title: const Text('Afficher le badge événement'),
      subtitle: const Text('Affiche un badge spécial pour cet événement'),
      value: _themeCustomization.showEventBadge,
      onChanged: (value) => _updateThemeCustomization(
        _themeCustomization.copyWith(showEventBadge: value),
      ),
    );

  // Widgets de typographie
  Widget _buildFontFamilySelector() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Famille de police',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _themeCustomization.fontFamily,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
            DropdownMenuItem(value: 'Arial', child: Text('Arial')),
            DropdownMenuItem(value: 'Times New Roman', child: Text('Times New Roman')),
            DropdownMenuItem(value: 'Georgia', child: Text('Georgia')),
            DropdownMenuItem(value: 'Verdana', child: Text('Verdana')),
            DropdownMenuItem(value: 'Courier New', child: Text('Courier New')),
          ],
          onChanged: (value) {
            if (value != null) {
              _updateThemeCustomization(
                _themeCustomization.copyWith(fontFamily: value),
              );
            }
          },
        ),
      ],
    );

  Widget _buildTitleFontSizeSlider() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Taille du titre'),
            Text('${_themeCustomization.titleFontSize.round()}px'),
          ],
        ),
        Slider(
          value: _themeCustomization.titleFontSize,
          min: 12.0,
          max: 32.0,
          divisions: 20,
          onChanged: (value) => _updateThemeCustomization(
            _themeCustomization.copyWith(titleFontSize: value),
          ),
        ),
      ],
    );

  Widget _buildBodyFontSizeSlider() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Taille du texte'),
            Text('${_themeCustomization.bodyFontSize.round()}px'),
          ],
        ),
        Slider(
          value: _themeCustomization.bodyFontSize,
          min: 10.0,
          max: 20.0,
          divisions: 10,
          onChanged: (value) => _updateThemeCustomization(
            _themeCustomization.copyWith(bodyFontSize: value),
          ),
        ),
      ],
    );

  // Widgets de style
  Widget _buildCardPaddingSlider() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Marge intérieure'),
            Text('${_themeCustomization.cardPadding.round()}px'),
          ],
        ),
        Slider(
          value: _themeCustomization.cardPadding,
          min: 8.0,
          max: 32.0,
          divisions: 12,
          onChanged: (value) => _updateThemeCustomization(
            _themeCustomization.copyWith(cardPadding: value),
          ),
        ),
      ],
    );

  Widget _buildBorderRadiusSlider() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Rayon des coins'),
            Text('${_themeCustomization.borderRadius.round()}px'),
          ],
        ),
        Slider(
          value: _themeCustomization.borderRadius,
          min: 0.0,
          max: 24.0,
          divisions: 12,
          onChanged: (value) => _updateThemeCustomization(
            _themeCustomization.copyWith(borderRadius: value),
          ),
        ),
      ],
    );

  Widget _buildShadowOpacitySlider() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Intensité de l\'ombre'),
            Text('${(_themeCustomization.shadowOpacity * 100).round()}%'),
          ],
        ),
        Slider(
          value: _themeCustomization.shadowOpacity,
          min: 0.0,
          max: 0.5,
          divisions: 10,
          onChanged: (value) => _updateThemeCustomization(
            _themeCustomization.copyWith(shadowOpacity: value),
          ),
        ),
      ],
    );

  Widget _buildBorderToggle() => SwitchListTile(
      title: const Text('Afficher une bordure'),
      subtitle: const Text('Ajoute une bordure autour de la carte'),
      value: _themeCustomization.showBorder,
      onChanged: (value) => _updateThemeCustomization(
        _themeCustomization.copyWith(showBorder: value),
      ),
    );

  Widget _buildBorderWidthSlider() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Épaisseur de la bordure'),
            Text('${_themeCustomization.borderWidth.round()}px'),
          ],
        ),
        Slider(
          value: _themeCustomization.borderWidth,
          min: 1.0,
          max: 8.0,
          divisions: 7,
          onChanged: (value) => _updateThemeCustomization(
            _themeCustomization.copyWith(borderWidth: value),
          ),
        ),
      ],
    );

  // Widgets d'arrière-plan
  Widget _buildBackgroundPatternToggle() => SwitchListTile(
      title: const Text('Motif d\'arrière-plan'),
      subtitle: const Text('Ajoute un motif subtil en arrière-plan'),
      value: _themeCustomization.showBackgroundPattern,
      onChanged: (value) => _updateThemeCustomization(
        _themeCustomization.copyWith(showBackgroundPattern: value),
      ),
    );

  Widget _buildPatternSelector() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de motif',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildPatternOption('dots', 'Points'),
            _buildPatternOption('lines', 'Lignes'),
            _buildPatternOption('grid', 'Grille'),
            _buildPatternOption('diagonal', 'Diagonal'),
          ],
        ),
      ],
    );

  Widget _buildPatternOption(String pattern, String label) {
    final isSelected = _themeCustomization.backgroundPattern == pattern;
    return InkWell(
      onTap: () => _updateThemeCustomization(
        _themeCustomization.copyWith(backgroundPattern: pattern),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
                ? widget.event.color.withValues(alpha: 0.1)
                : Colors.transparent,
          border: Border.all(
            color: isSelected ? widget.event.color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? widget.event.color : Colors.grey[700],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayOpacitySlider() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Opacité de la superposition'),
            Text('${(_themeCustomization.overlayOpacity * 100).round()}%'),
          ],
        ),
        Slider(
          value: _themeCustomization.overlayOpacity,
          min: 0.0,
          max: 0.5,
          divisions: 10,
          onChanged: (value) => _updateThemeCustomization(
            _themeCustomization.copyWith(overlayOpacity: value),
          ),
        ),
      ],
    );

  Widget _buildActionButtons() => Column(
      children: [
        Row(
          children: [
            Expanded(
              child: LoadingButton(
                text: 'Utiliser ce thème',
                isLoading: _isUsingTheme,
                onPressed: _useTheme,
                icon: const Icon(Icons.check),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saveTheme,
                icon: const Icon(Icons.save),
                label: const Text('Sauvegarder'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetToDefault,
                icon: const Icon(Icons.refresh),
                label: const Text('Réinitialiser'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exportTheme,
                icon: const Icon(Icons.share),
                label: const Text('Exporter'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Retour'),
        ),
      ],
    );

  void _showEventInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.event.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.description),
            const SizedBox(height: 16),
            Text(
              'Période: ${widget.event.period}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _useTheme() async {
    setState(() => _isUsingTheme = true);

    // Simuler l'application du thème
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isUsingTheme = false);

      // Naviguer vers l'éditeur avec le thème appliqué
      Navigator.pushReplacementNamed(
        context,
        '/editor',
        arguments: {
          'event': widget.event,
          'template': _themeCustomization.templateId,
          'themeCustomization': _themeCustomization,
          'customColors': {
            'primary': _themeCustomization.primaryColor.value.toRadixString(16),
            'secondary': _themeCustomization.secondaryColor.value.toRadixString(16),
            'accent': _themeCustomization.accentColor.value.toRadixString(16),
            'background': _themeCustomization.backgroundColor.value.toRadixString(16),
            'text': _themeCustomization.textColor.value.toRadixString(16),
          },
          'intensity': _themeCustomization.intensity,
          'showEventBadge': _themeCustomization.showEventBadge,
        },
      );
    }
  }

  void _saveTheme() async {
    final success = await ThemeService.saveCustomTheme(
      eventId: widget.event.id,
      eventName: widget.event.label,
      customization: _themeCustomization,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Thème sauvegardé avec succès' : 'Erreur lors de la sauvegarde',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _resetToDefault() {
    final defaultTheme = ThemeService.getPredefinedTheme(widget.event);
    setState(() {
      _themeCustomization = defaultTheme;
    });
    _updatePreview();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thème réinitialisé aux valeurs par défaut'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _exportTheme() {
    final themeJson = ThemeService.exportTheme(
      _themeCustomization,
      widget.event.label,
    );

    Clipboard.setData(ClipboardData(text: themeJson));

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thème exporté'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Le thème a été copié dans le presse-papiers.'),
              const SizedBox(height: 16),
              const Text(
                'Vous pouvez partager ce code avec d\'autres utilisateurs pour qu\'ils puissent importer votre thème.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  themeJson.length > 100
                      ? '${themeJson.substring(0, 100)}...'
                      : themeJson,
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
            ],
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
}
