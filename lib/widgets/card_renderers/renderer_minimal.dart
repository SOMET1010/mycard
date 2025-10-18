/// Renderer de carte minimaliste
library;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';

class MinimalRenderer implements CardRenderer {
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
      decoration: const BoxDecoration(
        color: AppTheme.greenWhite,
      ),
      child: Stack(
        children: [
          // Logo dans l'angle supérieur droit
          if (logoPath != null && logoPath.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: logoPath.startsWith('http')
                      ? Image.network(
                          logoPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.business,
                              size: 24,
                              color: Colors.grey[400],
                            ),
                        )
                      : File(logoPath).existsSync()
                          ? Image.file(
                              File(logoPath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.business,
                                  size: 24,
                                  color: Colors.grey[400],
                                ),
                            )
                          : Icon(
                              Icons.business,
                              size: 24,
                              color: Colors.grey[400],
                            ),
                ),
              ),
            ),

          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                // Nom
                Text(
                  fullName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Titre
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: secondaryColor,
                      fontFamily: fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),

                // Entreprise
                if (company?.isNotEmpty == true) ...[
                  Text(
                    company!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: accentColor,
                      fontFamily: fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],

                // Séparateur
                Container(
                  width: 50,
                  height: 1.5,
                  color: accentColor,
                ),
                const SizedBox(height: 8),

                // Contact
                if (phone.isNotEmpty)
                  _buildContactRow(Icons.phone, phone, secondaryColor, fontFamily),
                if (email.isNotEmpty)
                  _buildContactRow(Icons.email, email, secondaryColor, fontFamily),
                if (website?.isNotEmpty == true)
                  _buildContactRow(Icons.language, website!, secondaryColor, fontFamily),

                const SizedBox(height: 8),

                // Adresse
                if (address?.isNotEmpty == true ||
                    city?.isNotEmpty == true ||
                    postalCode?.isNotEmpty == true) ...[
                  _buildAddressSection(address, city, postalCode, country, secondaryColor, fontFamily),
                ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, Color color, String? fontFamily) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontFamily: fontFamily,
              ),
              textAlign: TextAlign.center,
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
      children: [
        Icon(
          Icons.location_on,
          size: 14,
          color: color,
        ),
        const SizedBox(height: 2),
        Text(
          addressParts.join(', '),
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontFamily: fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
      decoration: const BoxDecoration(
        color: AppTheme.greenWhite,
      ),
      child: Stack(
        children: [
          // Logo en haut à droite style minimaliste
          if (logoPath != null && logoPath.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: logoPath.startsWith('http')
                      ? Image.network(
                          logoPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.business,
                              size: 18,
                              color: Colors.grey[400],
                            ),
                        )
                      : File(logoPath).existsSync()
                          ? Image.file(
                              File(logoPath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.business,
                                  size: 18,
                                  color: Colors.grey[400],
                                ),
                            )
                          : Icon(
                              Icons.business,
                              size: 18,
                              color: Colors.grey[400],
                            ),
                ),
              ),
            ),

          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête minimaliste
                if (company?.isNotEmpty == true) ...[
                  Center(
                    child: Text(
                      company!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: primaryColor,
                        fontFamily: fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 30,
                      height: 1,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notes
                        if (backNotes?.isNotEmpty == true) ...[
                          Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                              fontFamily: fontFamily,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...backServices.map((service) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 3,
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
                              )),
                          const SizedBox(height: 16),
                        ],

                        // Horaires
                        if (backOpeningHours?.isNotEmpty == true) ...[
                          Text(
                            'Horaires',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                              fontFamily: fontFamily,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.1),
                              ),
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
                            'Réseaux',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                              fontFamily: fontFamily,
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
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  platform.toLowerCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: accentColor,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: fontFamily,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String colorType, CardTemplate template, Map<String, String> customColors) {
    final customColor = customColors[colorType];
    if (customColor != null) {
      // Retirer le # s'il est présent au début
      final cleanColor = customColor.startsWith('#') ? customColor.substring(1) : customColor;
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
