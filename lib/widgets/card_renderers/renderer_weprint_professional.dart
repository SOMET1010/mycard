/// Renderer pour carte WePrint Professional
library;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';
import 'package:mycard/widgets/card_renderers/card_back_renderer.dart';

class WePrintProfessionalRenderer implements CardRenderer {
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section 1: Header avec logo et informations principales
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Logo/Photo section
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: logoPath != null && File(logoPath).existsSync()
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.file(
                                  File(logoPath),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.business,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      size: 40,
                                    ),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.business,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 40,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Informations principales
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fullName,
                          style: TextStyle(
                            fontSize: 20,
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
          ),

          // Ligne de séparation
          Container(
            height: 2,
            color: accentColor.withValues(alpha: 0.3),
          ),

          // Section 2: Contact
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (phone.isNotEmpty)
                    _buildContactItem(Icons.phone, phone, primaryColor, fontFamily),
                  if (email.isNotEmpty)
                    _buildContactItem(Icons.email, email, primaryColor, fontFamily),
                  if (website?.isNotEmpty == true)
                    _buildContactItem(Icons.language, website!, primaryColor, fontFamily),
                ],
              ),
            ),
          ),

          // Ligne de séparation
          Container(
            height: 2,
            color: accentColor.withValues(alpha: 0.3),
          ),

          // Section 3: Adresse
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: _buildAddressSection(address, city, postalCode, country, secondaryColor, fontFamily),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String text,
    Color color,
    String? fontFamily,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                size: 14,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
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

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.location_on,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
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