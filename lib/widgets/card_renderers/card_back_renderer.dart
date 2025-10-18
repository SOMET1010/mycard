/// Renderer pour le verso de la carte de visite
library;

import 'package:flutter/material.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';

class CardBackRenderer implements CardRenderer {
  @override
  Widget render({
    required String fullName,
    required String title,
    required String phone,
    required String email,
    String? company,
    String? website,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    required CardTemplate template,
    required Map<String, String> customColors,
    String? fontFamily,
    String? logoPath,
    EventOverlay? eventOverlay,
    String? backNotes,
    List<String>? backServices,
    String? backOpeningHours,
    Map<String, String>? backSocialLinks,
  }) {
    // Debug logs pour vérifier les données
    debugPrint('CardBackRenderer - Données reçues:');
    debugPrint('  backNotes: $backNotes');
    debugPrint('  backServices: $backServices');
    debugPrint('  backOpeningHours: $backOpeningHours');
    debugPrint('  backSocialLinks: $backSocialLinks');
    debugPrint('  company: $company');

    final primaryColor = _getColor('primary', template, customColors);
    final secondaryColor = _getColor('secondary', template, customColors);
    final accentColor = _getColor('accent', template, customColors);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.greenWhite,
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec nom de l'entreprise
          if (company?.isNotEmpty == true)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                company!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          if (company?.isNotEmpty == true) const SizedBox(height: 16),

          // Notes supplémentaires
          if (backNotes?.isNotEmpty == true) ...[
            Text(
              'À propos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              backNotes!,
              style: TextStyle(
                fontSize: 12,
                color: secondaryColor,
                fontFamily: fontFamily,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Services
          if (backServices != null && backServices.isNotEmpty) ...[
            Text(
              'Services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            ...backServices.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        service,
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryColor,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Horaires d'ouverture
          if (backOpeningHours?.isNotEmpty == true) ...[
            Text(
              'Horaires',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                backOpeningHours!,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryColor,
                  fontFamily: fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Réseaux sociaux
          if (backSocialLinks != null && backSocialLinks.isNotEmpty) ...[
            Text(
              'Contact & Réseaux',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: backSocialLinks.entries.map((entry) {
                final platform = entry.key;
                final url = entry.value;
                IconData icon;
                Color color;

                switch (platform) {
                  case 'linkedin':
                    icon = Icons.work;
                    color = Colors.blue;
                    break;
                  case 'twitter':
                    icon = Icons.alternate_email;
                    color = Colors.lightBlue;
                    break;
                  case 'facebook':
                    icon = Icons.facebook;
                    color = Colors.blue.shade700;
                    break;
                  case 'instagram':
                    icon = Icons.camera_alt;
                    color = Colors.purple;
                    break;
                  case 'website':
                    icon = Icons.language;
                    color = primaryColor;
                    break;
                  default:
                    icon = Icons.link;
                    color = secondaryColor;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        platform.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          const Spacer(),

          // Pied de page
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'Carte générée avec MyCard',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget renderBack({
    required String fullName,
    required String title,
    required String phone,
    required String email,
    String? company,
    String? website,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    required CardTemplate template,
    required Map<String, String> customColors,
    String? fontFamily,
    String? logoPath,
    String? backNotes,
    List<String>? backServices,
    String? backOpeningHours,
    Map<String, String>? backSocialLinks,
  }) {
    // Pour le CardBackRenderer, renderBack() fait la même chose que render()
    return render(
      fullName: fullName,
      title: title,
      phone: phone,
      email: email,
      company: company,
      website: website,
      address: address,
      city: city,
      postalCode: postalCode,
      country: country,
      template: template,
      customColors: customColors,
      fontFamily: fontFamily,
      logoPath: logoPath,
      backNotes: backNotes,
      backServices: backServices,
      backOpeningHours: backOpeningHours,
      backSocialLinks: backSocialLinks,
    );
  }

  Color _getColor(
    String colorType,
    CardTemplate template,
    Map<String, String> customColors,
  ) {
    final customColor = customColors[colorType];
    if (customColor != null) {
      final cleanColor = customColor.startsWith('#')
          ? customColor.substring(1)
          : customColor;
      return Color(int.parse('FF$cleanColor', radix: 16));
    }

    switch (colorType) {
      case 'primary':
        return template.primaryColor;
      case 'secondary':
        return template.secondaryColor;
      case 'accent':
        return template.accentColor;
      default:
        return Colors.black;
    }
  }
}
