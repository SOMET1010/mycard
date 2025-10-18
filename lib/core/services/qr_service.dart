/// Service pour la génération de codes QR
library;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRService {
  /// Génère un widget QR code pour une vCard
  static Widget generateQRCode(String data, {double size = 200}) => QrImageView(
    data: data,
    version: QrVersions.auto,
    size: size,
    backgroundColor: Colors.white,
    errorStateBuilder: (context, error) => Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: const Icon(Icons.error, color: Colors.red),
    ),
  );

  /// Valide si une chaîne peut être encodée en QR code
  static bool canEncode(String data) {
    return data.isNotEmpty && data.length <= 4296; // Limite QR code version 40
  }

  /// Génère une URL de partage pour la carte
  static String generateShareUrl(String cardId) {
    // URL de base de l'application (à configurer)
    const baseUrl = 'https://mycard.app/share';
    return '$baseUrl/$cardId';
  }

  /// Crée un code QR pour une URL de partage
  static Widget generateShareQRCode(String cardId, {double size = 200}) {
    final url = generateShareUrl(cardId);
    return generateQRCode(url, size: size);
  }

  /// Génère un code QR pour un contact direct
  static Widget generateContactQRCode(
    String name,
    String phone,
    String email, {
    String? company,
    String? website,
    double size = 200,
  }) {
    final vCardData = _buildVCard(
      name: name,
      phone: phone,
      email: email,
      company: company,
      website: website,
    );
    return generateQRCode(vCardData, size: size);
  }

  /// Construit une vCard simple pour le QR code
  static String _buildVCard({
    required String name,
    required String phone,
    required String email,
    String? company,
    String? website,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    buffer.writeln('FN:$name');
    buffer.writeln('TEL:$phone');
    buffer.writeln('EMAIL:$email');

    if (company != null && company.isNotEmpty) {
      buffer.writeln('ORG:$company');
    }

    if (website != null && website.isNotEmpty) {
      buffer.writeln('URL:$website');
    }

    buffer.writeln('END:VCARD');
    return buffer.toString();
  }
}
