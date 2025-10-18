import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mycard/data/models/business_card.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';
import 'package:mycard/widgets/card_renderers/renderer_minimal.dart';
import 'package:mycard/widgets/card_renderers/renderer_corporate.dart';
import 'package:mycard/widgets/card_renderers/renderer_ansut_style.dart';
import 'package:mycard/widgets/card_renderers/renderer_event_campaign.dart';
import 'package:mycard/widgets/card_renderers/renderer_modern_gradient.dart';
import 'package:mycard/widgets/card_renderers/renderer_photo_badge.dart';
import 'package:mycard/widgets/card_renderers/renderer_stripe_left.dart';
import 'package:mycard/widgets/card_renderers/renderer_tech_startup.dart';
import 'package:mycard/widgets/card_renderers/renderer_medical_professional.dart';
import 'package:mycard/widgets/card_renderers/renderer_creative_artist.dart';
import 'package:mycard/widgets/card_renderers/renderer_academic_researcher.dart';
import 'package:mycard/widgets/card_renderers/renderer_real_estate_agent.dart';
import 'package:mycard/widgets/card_renderers/renderer_restaurant_culinary.dart';
import 'package:mycard/widgets/card_renderers/renderer_weprint_professional.dart';

class CardGridTile extends StatefulWidget {
  const CardGridTile({super.key, required this.card, required this.onTap});
  final BusinessCard? card; // null => create tile
  final VoidCallback onTap;

  @override
  State<CardGridTile> createState() => _CardGridTileState();
}

class _CardGridTileState extends State<CardGridTile> with SingleTickerProviderStateMixin {
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

  bool _hasBackContent(BusinessCard card) {
    final hasContent = (card.backNotes?.isNotEmpty == true) ||
           (card.backServices?.isNotEmpty == true) ||
           (card.backOpeningHours?.isNotEmpty == true) ||
           (card.backSocialLinks?.isNotEmpty == true);

    // Debug: afficher dans la console si une carte a du contenu verso
    if (hasContent) {
      print('Carte avec verso: ${card.fullName}');
    }

    return hasContent;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.card == null) return _buildCreateTile(context);
    return _buildCardTile(context, widget.card!);
  }

  Widget _buildCardTile(BuildContext context, BusinessCard c) {
    final cs = Theme.of(context).colorScheme;
    final hasBackContent = _hasBackContent(c);

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Expanded(
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
                          child: _buildBackSide(c),
                        )
                      : _buildFrontSide(c),
                );
              },
            ),
          ),
          // Toujours afficher le bouton pour tester (à retirer après)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isBackVisible ? Icons.keyboard_return : Icons.flip_to_back,
                  size: 16,
                  color: hasBackContent ? cs.primary : Colors.grey,
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: hasBackContent ? _toggleCard : () {
                    // Message temporaire pour indiquer qu'il faut ajouter du contenu verso
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ajoutez du contenu verso dans l\'éditeur pour voir le verso!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    _isBackVisible ? 'Voir recto' : 'Voir verso',
                    style: TextStyle(
                      fontSize: 10,
                      color: hasBackContent ? cs.primary : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!hasBackContent)
            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Éditer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFrontSide(BusinessCard c) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _AvatarLarge(name: c.fullName, path: c.logoPath),
            const SizedBox(height: 12),
            Text(
              c.fullName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (c.title.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                c.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (c.company?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                c.company!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackSide(BusinessCard c) {
    final template = CardTemplate.findById(c.templateId);
    final frontRenderer = _getRenderer(template?.rendererKey ?? 'minimal');

    return Container(
      padding: const EdgeInsets.all(0),
      child: frontRenderer.renderBack(
        fullName: c.fullName,
        title: c.title,
        phone: c.phone,
        email: c.email,
        company: c.company,
        website: c.website,
        address: c.address,
        city: c.city,
        postalCode: c.postalCode,
        country: c.country,
        template: template ?? CardTemplate.predefinedTemplates.first,
        customColors: c.customColors,
        logoPath: c.logoPath,
        backNotes: c.backNotes,
        backServices: c.backServices,
        backOpeningHours: c.backOpeningHours,
        backSocialLinks: c.backSocialLinks,
      ),
    );
  }

  Widget _buildCreateTile(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primary.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, color: primary, size: 28),
              const SizedBox(height: 8),
              Text(
                'Nouvelle carte',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      case 'modern_gradient':
        return ModernGradientRenderer();
      case 'stripe_left':
        return StripeLeftRenderer();
      case 'photo_badge':
        return PhotoBadgeRenderer();
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
}

class _AvatarLarge extends StatelessWidget {
  const _AvatarLarge({required this.name, this.path});
  final String name;
  final String? path;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final bg = Colors.grey[200];
    final textColor = Colors.grey[800];
    if (path != null && path!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: FileImage(File(path!)),
        backgroundColor: bg,
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: bg,
      child: Text(
        initials,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      ),
    );
  }

  String _initials(String n) {
    final parts = n.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}
