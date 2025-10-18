/// Renderer: avatar/photo à gauche, infos à droite
library;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';
import 'package:mycard/widgets/card_renderers/card_back_renderer.dart';

class PhotoBadgeRenderer implements CardRenderer {
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
    final primary = _color('primary', template, customColors);
    final secondary = _color('secondary', template, customColors);
    final accent = _color('accent', template, customColors);

    return Container(
      decoration: BoxDecoration(
        color: secondary.withValues(alpha: 0.08),
        border: Border.all(color: secondary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar / Logo
          CircleAvatar(
            radius: 24,
            backgroundColor: accent.withValues(alpha: 0.2),
            child: logoPath != null && logoPath.isNotEmpty
                ? ClipOval(
                    child: logoPath.startsWith('http')
                        ? Image.network(
                            logoPath,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Text(
                              _initials(fullName),
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : File(logoPath).existsSync()
                            ? Image.file(
                                File(logoPath),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Text(
                                  _initials(fullName),
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Text(
                                _initials(fullName),
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                  )
                : Text(
                    _initials(fullName),
                    style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(width: 12),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'Votre Nom' : fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: accent, fontFamily: fontFamily),
                ),
                if (title.isNotEmpty)
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: primary, fontFamily: fontFamily),
                  ),
                const SizedBox(height: 6),
                _contact(Icons.phone, phone, primary, fontFamily),
                _contact(Icons.email, email, primary, fontFamily),
                if (website?.isNotEmpty == true)
                  _contact(Icons.language, website!, primary, fontFamily),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  Widget _contact(IconData icon, String text, Color color, String? fontFamily) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
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
  }

  Color _color(String key, CardTemplate t, Map<String, String> custom) {
    final v = custom[key] ?? t.colors[key] ?? '#000000';
    return Color(int.parse('FF${v.replaceAll('#', '')}', radix: 16));
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

