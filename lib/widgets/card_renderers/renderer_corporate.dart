/// Renderer de carte corporate
library;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';

class CorporateRenderer implements CardRenderer {
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.greenWhite,
        border: Border(
          left: BorderSide(
            color: primaryColor,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section supérieure : Logo + Nom/Entreprise
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo si disponible
              if (logoPath != null && File(logoPath).existsSync())
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 16, bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.file(
                      File(logoPath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => ColoredBox(
                          color: Colors.grey.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.business,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                    ),
                  ),
                ),

              // Nom et titre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 24,
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
                          fontSize: 14,
                          color: secondaryColor,
                          fontWeight: FontWeight.w500,
                          fontFamily: fontFamily,
                        ),
                      ),
                    if (company?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        company!,
                        style: TextStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Séparateur
          if (phone.isNotEmpty || email.isNotEmpty || website?.isNotEmpty == true)
            Container(
              width: double.infinity,
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 12),
              color: accentColor.withValues(alpha: 0.3),
            ),

          // Informations de contact
          if (phone.isNotEmpty || email.isNotEmpty || website?.isNotEmpty == true)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (phone.isNotEmpty)
                    _buildContactInfo(
                      Icons.phone,
                      phone,
                      secondaryColor,
                      fontFamily,
                    ),
                  if (email.isNotEmpty)
                    _buildContactInfo(
                      Icons.email,
                      email,
                      secondaryColor,
                      fontFamily,
                    ),
                  if (website?.isNotEmpty == true)
                    _buildContactInfo(
                      Icons.language,
                      website!,
                      secondaryColor,
                      fontFamily,
                    ),
                ],
              ),
            ),

          // Adresse
          if (address?.isNotEmpty == true ||
              city?.isNotEmpty == true ||
              postalCode?.isNotEmpty == true)
            _buildAddressSection(
              address,
              city,
              postalCode,
              country,
              secondaryColor,
              fontFamily,
            ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(
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
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                size: 12,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
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

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adresse',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          ...addressParts.map((part) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  part,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontFamily: fontFamily,
                  ),
                ),
              )),
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
    final primaryColor = _getColor('primary', template, customColors);
    final secondaryColor = _getColor('secondary', template, customColors);
    final accentColor = _getColor('accent', template, customColors);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.greenWhite,
        border: Border(
          left: BorderSide(
            color: primaryColor,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête corporate avec logo
          Row(
            children: [
              if (logoPath != null && File(logoPath).existsSync()) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(
                      File(logoPath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.business,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company ?? 'Entreprise',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 2,
                      color: accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Contenu du verso
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notes
                  if (backNotes?.isNotEmpty == true) ...[
                    Text(
                      'NOTES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        fontFamily: fontFamily,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      backNotes!,
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryColor,
                        fontFamily: fontFamily,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Services
                  if (backServices != null && backServices.isNotEmpty) ...[
                    Text(
                      'SERVICES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        fontFamily: fontFamily,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...backServices.map((service) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 2,
                                margin: const EdgeInsets.only(top: 6),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  service,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: secondaryColor,
                                    fontFamily: fontFamily,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],

                  // Horaires
                  if (backOpeningHours?.isNotEmpty == true) ...[
                    Text(
                      'HORAIRES D\'OUVERTURE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        fontFamily: fontFamily,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.05),
                        border: Border(
                          left: BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        backOpeningHours!,
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryColor,
                          fontFamily: fontFamily,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Réseaux sociaux
                  if (backSocialLinks != null && backSocialLinks.isNotEmpty) ...[
                    Text(
                      'RÉSEAUX SOCIAUX',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        fontFamily: fontFamily,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: backSocialLinks.entries.map((entry) {
                        final platform = entry.key;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            platform.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                              fontFamily: fontFamily,
                              letterSpacing: 0.8,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Pied de page corporate
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
              'PROFESSIONNEL • QUALITÉ • CONFIANCE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                color: accentColor,
                fontFamily: fontFamily,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
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
}