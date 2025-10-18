/// Renderer dédié aux cartes d'événements (ex: Octobre Rose)
library;
import 'package:flutter/material.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';
import 'package:mycard/widgets/card_renderers/card_back_renderer.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventCampaignRenderer implements CardRenderer {
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
    final purple = _getColor('primary', template, customColors); // titres
    final pink = _getColor('accent', template, customColors); // accent événement
    const neutral = Color(0xFF2E2E3A);

    return Container(
      color: AppTheme.greenWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bande logo + ruban et filet
          Row(
            children: [
              Expanded(
                child: Text(
                  company?.isNotEmpty == true ? company! : 'Organization',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: purple,
                    fontFamily: fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (eventOverlay != null)
                Icon(Icons.emoji_events, color: pink, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: purple.withOpacity(0.6)),

          const SizedBox(height: 8),

          Expanded(
            child: Row(
              children: [
                // Colonne gauche: nom, titre, bloc événement, site
                Flexible(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fullName.isEmpty ? 'Your Name' : fullName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: pink,
                            fontFamily: fontFamily,
                          ),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (title.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            color: neutral,
                            fontFamily: fontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Bloc événement
                      if (eventOverlay != null) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.emoji_events, color: pink, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eventOverlay.label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: pink,
                                      fontFamily: fontFamily,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    eventOverlay.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: pink.withOpacity(0.9),
                                      fontFamily: fontFamily,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (website?.isNotEmpty == true)
                        Text(
                          website!,
                          style: TextStyle(
                            fontSize: 13,
                            color: neutral,
                            fontWeight: FontWeight.w600,
                            fontFamily: fontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 10),
                      // Socials placeholders
                      Row(
                        children: [
                          _pillIcon(Icons.facebook, purple),
                          const SizedBox(width: 6),
                          _pillIcon(Icons.alternate_email, purple),
                          const SizedBox(width: 6),
                          _pillIcon(Icons.ondemand_video, purple),
                        ],
                      ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Colonne droite: contacts + QR (QR en dessous pour laisser la place aux textes)
                Flexible(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (phone.isNotEmpty) _contactRow(Icons.phone, phone, neutral, fontFamily),
                      if (email.isNotEmpty) _contactRow(Icons.email, email, neutral, fontFamily),
                      if (address?.isNotEmpty == true)
                        _contactRow(
                          Icons.home,
                          '$address${city != null && city.isNotEmpty ? ', $city' : ''}',
                          neutral,
                          fontFamily,
                        ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 68,
                          height: 68,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: pink, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: QrImageView(
                            data: _qrData(fullName, phone, email, website),
                            version: QrVersions.auto,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillIcon(IconData icon, Color color) => Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14, color: color),
    );

  Widget _contactRow(IconData icon, String text, Color color, String? fontFamily) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: color, fontFamily: fontFamily),
            ),
          ),
        ],
      ),
    );

  String _qrData(String name, String phone, String email, String? website) {
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:3.0')
      ..writeln('FN:$name');
    if (phone.isNotEmpty) buffer.writeln('TEL:$phone');
    if (email.isNotEmpty) buffer.writeln('EMAIL:$email');
    if (website != null && website.isNotEmpty) buffer.writeln('URL:$website');
    buffer.writeln('END:VCARD');
    return buffer.toString();
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
