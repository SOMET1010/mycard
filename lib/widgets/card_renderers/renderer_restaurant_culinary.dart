/// Renderer pour carte Restaurant/Culinaire
library;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';
import 'package:mycard/widgets/card_renderers/card_back_renderer.dart';

class RestaurantCulinaryRenderer implements CardRenderer {
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
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header restaurant
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                // Logo restaurant
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor,
                      width: 2,
                    ),
                    color: Colors.white,
                  ),
                  child: logoPath != null && File(logoPath).existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(logoPath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.restaurant,
                                color: primaryColor,
                                size: 35,
                              ),
                          ),
                        )
                      : Icon(
                          Icons.restaurant,
                          color: primaryColor,
                          size: 35,
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
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                company!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Corps restaurant
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section réservation
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.dinner_dining,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'RÉSERVATION & CONTACT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (phone.isNotEmpty)
                    _buildCulinaryContact(Icons.phone, phone, primaryColor, fontFamily),
                  if (email.isNotEmpty)
                    _buildCulinaryContact(Icons.email, email, secondaryColor, fontFamily),
                  if (website?.isNotEmpty == true)
                    _buildCulinaryContact(Icons.language, website!, accentColor, fontFamily),

                  const SizedBox(height: 16),

                  // Section adresse
                  if ((address?.isNotEmpty == true) ||
                      (city?.isNotEmpty == true) ||
                      (postalCode?.isNotEmpty == true)) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: secondaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: secondaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ADRESSE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildAddressSection(address, city, postalCode, country, secondaryColor, fontFamily),
                  ],

                  const Spacer(),

                  // Services culinaires
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: secondaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'SPÉCIALITÉS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            fontFamily: fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCulinaryBadge('CUISINE', primaryColor),
                            _buildCulinaryBadge('VINS', accentColor),
                            _buildCulinaryBadge('SERVICE', secondaryColor),
                          ],
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

  Widget _buildCulinaryContact(
    IconData icon,
    String text,
    Color color,
    String? fontFamily,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
            ],
          ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.location_on,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              addressParts.join(', '),
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCulinaryBadge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

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