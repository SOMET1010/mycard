/// Renderer pour carte Chercheur Académique
library;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';
import 'package:mycard/widgets/card_renderers/card_back_renderer.dart';

class AcademicResearcherRenderer implements CardRenderer {
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: primaryColor,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          // En-tête académique
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: Row(
              children: [
                // Logo université ou icône
                if (logoPath != null && File(logoPath).existsSync())
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: accentColor,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(logoPath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.school,
                            color: primaryColor,
                            size: 40,
                          ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: accentColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.school,
                      color: primaryColor,
                      size: 40,
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: fontFamily,
                        ),
                      ),
                      if (title.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontFamily: fontFamily,
                          ),
                        ),
                      ],
                      if (company?.isNotEmpty == true) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            company!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Corps académique
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Publications
                  Text(
                    'RESEARCH & CONTACT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontFamily: fontFamily,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (email.isNotEmpty)
                    _buildAcademicContact(Icons.email, email, primaryColor, fontFamily),
                  if (phone.isNotEmpty)
                    _buildAcademicContact(Icons.phone, phone, secondaryColor, fontFamily),
                  if (website?.isNotEmpty == true)
                    _buildAcademicContact(Icons.language, website!, accentColor, fontFamily),

                  const SizedBox(height: 16),

                  // Section Adresse institutionnelle
                  if ((address?.isNotEmpty == true) ||
                      (city?.isNotEmpty == true) ||
                      (postalCode?.isNotEmpty == true)) ...[
                    Text(
                      'INSTITUTION ADDRESS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontFamily: fontFamily,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAddressSection(address, city, postalCode, country, secondaryColor, fontFamily),
                  ],

                  const Spacer(),

                  // Pied de page académique
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.psychology,
                              size: 16,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Academic Excellence',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Research • Innovation • Education',
                          style: TextStyle(
                            fontSize: 8,
                            color: secondaryColor,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicContact(
    IconData icon,
    String text,
    Color color,
    String? fontFamily,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontFamily: fontFamily,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildAddressSection(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: addressParts.asMap().entries.map((entry) {
        final index = entry.key;
        final part = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < addressParts.length - 1 ? 2 : 0,
          ),
          child: Text(
            part,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontFamily: fontFamily,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getColor(String colorType, CardTemplate template, Map<String, String> customColors) {
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