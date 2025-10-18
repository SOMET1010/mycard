/// Renderer: fond dégradé moderne avec texte contrasté
library;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/widgets/card_renderers/card_renderer.dart';

class ModernGradientRenderer implements CardRenderer {
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
    final primary = _getColor('primary', template, customColors);
    final secondary = _getColor('secondary', template, customColors);
    final accent = _getColor('accent', template, customColors);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            secondary.withValues(alpha: 0.25),
            AppTheme.greenWhite
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Logo si disponible
          if (logoPath != null && logoPath.isNotEmpty) ...[
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: logoPath.startsWith('http')
                    ? Image.network(
                        logoPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.business,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                      )
                    : File(logoPath).existsSync()
                        ? Image.file(
                            File(logoPath),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.business,
                                color: Colors.grey[400],
                                size: 24,
                              ),
                          )
                        : Icon(
                            Icons.business,
                            color: Colors.grey[400],
                            size: 24,
                          ),
              ),
            ),
          ],

          // Bande décorative
          Container(
            width: 6,
            height: double.infinity,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),

          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (company?.isNotEmpty == true)
                  Text(
                    company!,
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.6,
                      fontFamily: fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  fullName.isEmpty ? 'Votre Nom' : fullName,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    fontFamily: fontFamily,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (title.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: primary,
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),

                // Contacts
                Row(
                  children: [
                    if (phone.isNotEmpty)
                      Expanded(child: _contact(Icons.phone, phone, primary, fontFamily)),
                    if (email.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(child: _contact(Icons.email, email, primary, fontFamily)),
                    ],
                  ],
                ),
                if (website?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  _contact(Icons.language, website!, primary, fontFamily),
                ],

                const Spacer(),
                // Liseré bas
                Container(height: 2, width: double.infinity, color: primary.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contact(IconData icon, String text, Color color, String? fontFamily) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
      );

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
    final primary = _getColor('primary', template, customColors);
    final secondary = _getColor('secondary', template, customColors);
    final accent = _getColor('accent', template, customColors);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.1),
            AppTheme.greenWhite,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // En-tête moderne avec logo
          Row(
            children: [
              if (logoPath != null && logoPath.isNotEmpty) ...[
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: logoPath.startsWith('http')
                        ? Image.network(
                            logoPath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.business,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                          )
                        : File(logoPath).existsSync()
                            ? Image.file(
                                File(logoPath),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.business,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                              )
                            : Icon(
                                Icons.business,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                  ),
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company?.isNotEmpty == true ? company! : 'Entreprise',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: 2,
                      color: accent,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Contenu du verso
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (backNotes?.isNotEmpty == true) ...[
                    Text(
                      'À propos',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      backNotes!,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 12,
                        fontFamily: fontFamily,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (backServices != null && backServices.isNotEmpty) ...[
                    Text(
                      'Services',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...backServices.map((service) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  service,
                                  style: TextStyle(
                                    color: secondary,
                                    fontSize: 12,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],

                  if (backOpeningHours?.isNotEmpty == true) ...[
                    Text(
                      'Horaires',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        backOpeningHours!,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 12,
                          fontFamily: fontFamily,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (backSocialLinks != null && backSocialLinks.isNotEmpty) ...[
                    Text(
                      'Réseaux',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: backSocialLinks.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: TextStyle(
                              color: accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
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
    );
  }

  Color _getColor(String key, CardTemplate t, Map<String, String> custom) {
    final v = custom[key] ?? t.colors[key] ?? '#000000';
    final clean = v.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

