/// Widget d'aperçu de la carte de visite
library;

import 'package:flutter/material.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';
import 'package:mycard/widgets/card_renderers/card_back_renderer.dart';
import 'package:mycard/widgets/card_renderers/renderer_academic_researcher.dart';
import 'package:mycard/widgets/card_renderers/renderer_ansut_style.dart';
import 'package:mycard/widgets/card_renderers/renderer_corporate.dart';
import 'package:mycard/widgets/card_renderers/renderer_creative_artist.dart';
import 'package:mycard/widgets/card_renderers/renderer_event_campaign.dart';
import 'package:mycard/widgets/card_renderers/renderer_medical_professional.dart';
import 'package:mycard/widgets/card_renderers/renderer_minimal.dart';
import 'package:mycard/widgets/card_renderers/renderer_modern_gradient.dart';
import 'package:mycard/widgets/card_renderers/renderer_photo_badge.dart';
import 'package:mycard/widgets/card_renderers/renderer_real_estate_agent.dart';
import 'package:mycard/widgets/card_renderers/renderer_restaurant_culinary.dart';
import 'package:mycard/widgets/card_renderers/renderer_stripe_left.dart';
import 'package:mycard/widgets/card_renderers/renderer_tech_startup.dart';
import 'package:mycard/widgets/card_renderers/renderer_weprint_professional.dart';

class CardPreview extends StatefulWidget {
  const CardPreview({
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
    this.backNotes,
    this.backServices,
    this.backOpeningHours,
    this.backSocialLinks,
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
  final String? backNotes;
  final List<String>? backServices;
  final String? backOpeningHours;
  final Map<String, String>? backSocialLinks;

  @override
  State<CardPreview> createState() => _CardPreviewState();
}

class _CardPreviewState extends State<CardPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isBackVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isBackVisible) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    _isBackVisible = !_isBackVisible;
  }

  bool _hasBackContent() =>
      (widget.backNotes?.isNotEmpty == true) ||
      (widget.backServices?.isNotEmpty == true) ||
      (widget.backOpeningHours?.isNotEmpty == true) ||
      (widget.backSocialLinks?.isNotEmpty == true);

  @override
  Widget build(BuildContext context) {
    final hasBackContent = _hasBackContent();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: widget.previewWidth ?? 350,
          height: widget.previewHeight ?? 200,
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
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final isShowingBack = _animation.value > 0.5;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_animation.value * 3.14159),
                child: isShowingBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159),
                        child: _buildBackContent(),
                      )
                    : _buildFrontContent(),
              );
            },
          ),
        ),
        if (hasBackContent) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isBackVisible ? Icons.keyboard_return : Icons.flip_to_back,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _toggleCard,
                icon: const SizedBox(),
                label: Text(
                  _isBackVisible ? 'Voir recto' : 'Voir verso',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFrontContent() {
    final effectiveTemplate =
        widget.template ?? CardTemplate.predefinedTemplates.first;
    final renderer = _getRenderer(effectiveTemplate.rendererKey);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          // Carte de base
          renderer.render(
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
            template: effectiveTemplate,
            customColors: widget.customColors,
            fontFamily: widget.fontFamily,
            logoPath: widget.logoPath,
            eventOverlay: widget.eventOverlay,
          ),

          // Overlay événementiel
          if (widget.eventOverlay != null)
            _buildEventOverlay(widget.eventOverlay!),
        ],
      ),
    );
  }

  Widget _buildBackContent() {
    final effectiveTemplate =
        widget.template ?? CardTemplate.predefinedTemplates.first;
    final renderer = _getRenderer(effectiveTemplate.rendererKey);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: renderer.renderBack(
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
        template: effectiveTemplate,
        customColors: widget.customColors,
        fontFamily: widget.fontFamily,
        logoPath: widget.logoPath,
        backNotes: widget.backNotes,
        backServices: widget.backServices,
        backOpeningHours: widget.backOpeningHours,
        backSocialLinks: widget.backSocialLinks,
      ),
    );
  }

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
      case 'modern_gradient':
        return ModernGradientRenderer();
      case 'stripe_left':
        return StripeLeftRenderer();
      case 'photo_badge':
        return PhotoBadgeRenderer();
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
