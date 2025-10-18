/// Widget d'aperçu de carte optimisé pour les performances
library;

import 'package:flutter/material.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';
import 'package:mycard/widgets/card_renderers/renderer_academic_researcher.dart';
import 'package:mycard/widgets/card_renderers/renderer_ansut_style.dart';
import 'package:mycard/widgets/card_renderers/renderer_corporate.dart';
import 'package:mycard/widgets/card_renderers/renderer_creative_artist.dart';
import 'package:mycard/widgets/card_renderers/renderer_event_campaign.dart';
import 'package:mycard/widgets/card_renderers/renderer_medical_professional.dart';
import 'package:mycard/widgets/card_renderers/renderer_minimal.dart';
import 'package:mycard/widgets/card_renderers/renderer_real_estate_agent.dart';
import 'package:mycard/widgets/card_renderers/renderer_restaurant_culinary.dart';
import 'package:mycard/widgets/card_renderers/renderer_tech_startup.dart';
import 'package:mycard/widgets/card_renderers/renderer_weprint_professional.dart';

class OptimizedCardPreview extends StatefulWidget {
  const OptimizedCardPreview({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.phone,
    required this.email,
    this.company,
    this.website,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.template,
    this.eventOverlay,
    required this.customColors,
    this.fontFamily,
    this.logoPath,
    this.previewWidth,
    this.previewHeight,
  });
  final String firstName;
  final String lastName;
  final String title;
  final String phone;
  final String email;
  final String? company;
  final String? website;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final CardTemplate? template;
  final EventOverlay? eventOverlay;
  final Map<String, String> customColors;
  final String? fontFamily;
  final String? logoPath;
  final double? previewWidth;
  final double? previewHeight;

  @override
  State<OptimizedCardPreview> createState() => _OptimizedCardPreviewState();
}

class _OptimizedCardPreviewState extends State<OptimizedCardPreview> {
  late CardTemplate _effectiveTemplate;
  late CardRenderer _renderer;

  @override
  void initState() {
    super.initState();
    _effectiveTemplate =
        widget.template ?? CardTemplate.predefinedTemplates.first;
    _renderer = _getRenderer(_effectiveTemplate.rendererKey);
  }

  @override
  void didUpdateWidget(OptimizedCardPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.template != widget.template) {
      _effectiveTemplate =
          widget.template ?? CardTemplate.predefinedTemplates.first;
      _renderer = _getRenderer(_effectiveTemplate.rendererKey);
    }
  }

  CardRenderer _getRenderer(String rendererKey) {
    switch (rendererKey) {
      case 'minimal':
        return MinimalRenderer();
      case 'corporate':
        return CorporateRenderer();
      case 'ansut_style':
        return AnsutStyleRenderer();
      case 'event_campaign':
        return EventCampaignRenderer();
      // Nouveaux renderers
      case 'tech_startup':
        return TechStartupRenderer();
      case 'medical_professional':
        return MedicalProfessionalRenderer();
      case 'creative_artist':
        return CreativeArtistRenderer();
      case 'academic_researcher':
        return AcademicResearcherRenderer();
      case 'real_estate_agent':
        return RealEstateAgentRenderer();
      case 'restaurant_culinary':
        return RestaurantCulinaryRenderer();
      case 'weprint_professional':
        return WePrintProfessionalRenderer();
      default:
        return MinimalRenderer();
    }
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: SizedBox(
      width: widget.previewWidth ?? 350,
      height: widget.previewHeight ?? 200,
      child: _buildOptimizedCardContent(),
    ),
  );

  Widget _buildOptimizedCardContent() => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Carte de base avec optimisation
          _buildOptimizedCard(),
          // Overlay événementiel
          if (widget.eventOverlay != null)
            _buildEventOverlay(widget.eventOverlay!),
        ],
      ),
    ),
  );

  Widget _buildOptimizedCard() => _renderer.render(
    fullName: '${widget.firstName} ${widget.lastName}'.trim(),
    title: widget.title,
    phone: widget.phone,
    email: widget.email,
    company: widget.company,
    website: widget.website,
    address: widget.address,
    city: widget.city,
    postalCode: widget.postalCode,
    country: widget.country,
    template: _effectiveTemplate,
    customColors: widget.customColors,
    fontFamily: widget.fontFamily,
    logoPath: widget.logoPath,
    eventOverlay: widget.eventOverlay,
  );

  Widget _buildEventOverlay(EventOverlay event) => Positioned(
    top: 8,
    right: 8,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: event.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getEventIcon(event.icon), color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            event.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );

  IconData _getEventIcon(String iconName) {
    switch (iconName) {
      case 'ribbon':
        return Icons.emoji_events;
      case 'tree':
        return Icons.forest;
      case 'heart':
        return Icons.favorite;
      case 'mustache':
        return Icons.face;
      case 'tie':
        return Icons.work;
      case 'love':
        return Icons.favorite;
      case 'pumpkin':
        return Icons.circle;
      case 'champagne':
        return Icons.celebration;
      default:
        return Icons.event;
    }
  }
}
