/// Renderer de carte style Ansut (moderne et créatif)
library;

import 'package:flutter/material.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';
import 'package:mycard/widgets/card_renderers/card_back_renderer.dart';

class AnsutStyleRenderer implements CardRenderer {
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
  }) {
    final primaryColor = _getColor('primary', template, customColors);
    final secondaryColor = _getColor('secondary', template, customColors);
    final accentColor = _getColor('accent', template, customColors);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.greenWhite,
      child: Stack(
        children: [
          // Fond décoratif
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne supérieure avec nom et éléments décoratifs
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontFamily: fontFamily,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (title.isNotEmpty)
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                color: secondaryColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: fontFamily,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Badge décoratif
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Entreprise avec style moderne
                if (company?.isNotEmpty == true) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      company!,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Informations de contact avec style moderne
                if (phone.isNotEmpty || email.isNotEmpty) ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      if (phone.isNotEmpty)
                        _buildModernContact(
                          Icons.phone,
                          phone,
                          primaryColor,
                          fontFamily,
                        ),
                      if (email.isNotEmpty)
                        _buildModernContact(
                          Icons.email,
                          email,
                          primaryColor,
                          fontFamily,
                        ),
                      if (website?.isNotEmpty == true)
                        _buildModernContact(
                          Icons.language,
                          website!,
                          primaryColor,
                          fontFamily,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Adresse avec style moderne
                if (address?.isNotEmpty == true ||
                    city?.isNotEmpty == true ||
                    postalCode?.isNotEmpty == true)
                  _buildModernAddress(
                    address,
                    city,
                    postalCode,
                    country,
                    secondaryColor,
                    fontFamily,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernContact(
    IconData icon,
    String text,
    Color color,
    String? fontFamily,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily,
          ),
        ),
      ],
    ),
  );

  Widget _buildModernAddress(
    String? address,
    String? city,
    String? postalCode,
    String? country,
    Color color,
    String? fontFamily,
  ) {
    final addressParts = <String>[];
    if (address?.isNotEmpty == true) addressParts.add(address!);
    if (city?.isNotEmpty == true) addressParts.add(city!);
    if (postalCode?.isNotEmpty == true) addressParts.add(postalCode!);
    if (country?.isNotEmpty == true) addressParts.add(country!);

    if (addressParts.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              addressParts.join(', '),
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(
    String colorType,
    CardTemplate template,
    Map<String, String> customColors,
  ) {
    final customColor = customColors[colorType];
    if (customColor != null) {
      // Retirer le # s'il est présent au début
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
    final renderer = CardBackRenderer();
    return renderer.render(
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
}
