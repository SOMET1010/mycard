import 'dart:io';

/// Classe pour représenter une vCard parsée
class VCardData {

  VCardData({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.title,
    this.company,
    this.website,
    this.address,
    this.city,
    this.postalCode,
    this.country,
  });
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String? title;
  final String? company;
  final String? website;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
}

/// Service pour la génération et le parsing de fichiers vCard (VCF)
class VCardService {
  /// Génère une vCard complète au format 3.0
  static String generateVCard({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    String? title,
    String? company,
    String? website,
    String? address,
    String? city,
    String? postalCode,
    String? country,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');

    // Nom complet et nom structuré
    final fullName = '$firstName $lastName'.trim();
    buffer.writeln('FN:$fullName');
    buffer.writeln('N:$lastName;$firstName;;;');

    // Téléphone
    buffer.writeln('TEL;TYPE=CELL,VOICE:$phone');

    // Email
    buffer.writeln('EMAIL:$email');

    // Titre
    if (title != null && title.isNotEmpty) {
      buffer.writeln('TITLE:$title');
    }

    // Entreprise
    if (company != null && company.isNotEmpty) {
      buffer.writeln('ORG:$company');
    }

    // Site web
    if (website != null && website.isNotEmpty) {
      buffer.writeln('URL:$website');
    }

    // Adresse complète
    if (address != null || city != null || postalCode != null || country != null) {
      final addressParts = [
        address ?? '',
        city ?? '',
        postalCode ?? '',
        country ?? ''
      ].where((part) => part.isNotEmpty).join(';');

      buffer.writeln('ADR;TYPE=WORK:;;$addressParts;;;;');
    }

    // Notes
    buffer.writeln('NOTE:Généré par MyCard App');

    // Version et fin
    buffer.writeln('REV:${DateTime.now().toIso8601String()}');
    buffer.writeln('END:VCARD');

    return buffer.toString();
  }

  /// Génère un nom de fichier pour la vCard
  static String generateFileName(String name) {
    final sanitized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return '${sanitized}_contact.vcf';
  }

  /// Valide les données minimales pour une vCard
  static bool validateMinimumData({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
  }) => firstName.isNotEmpty &&
           lastName.isNotEmpty &&
           phone.isNotEmpty &&
           email.isNotEmpty &&
           _validateEmail(email) == null &&
           _validatePhone(phone) == null;

  static String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!email.contains('@')) return 'Invalid email format';
    if (!email.contains('.')) return 'Invalid email format';
    return null;
  }

  static String? _validatePhone(String phone) {
    if (phone.isEmpty) return 'Phone is required';
    if (phone.length < 10) return 'Phone too short';
    return null;
  }

  /// Extrait les informations d'une vCard (implémentation avancée)
  static VCardData parseVCard(String vCardContent) {
    final lines = vCardContent.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();

    String? fullName;
    String? firstName;
    String? lastName;
    String? phone;
    String? email;
    String? title;
    String? company;
    String? website;
    String? address;
    String? city;
    String? postalCode;
    String? country;

    for (final line in lines) {
      // Handle folded lines (vCard 2.1)
      if (line.startsWith(' ') || line.startsWith('\t')) {
        continue; // Skip continuation lines for now
      }

      // Parse basic fields
      if (line.startsWith('FN:')) {
        fullName = line.substring(3);
        parseFullName(fullName, (first, last) {
          firstName = first;
          lastName = last;
        });
      } else if (line.startsWith('N:')) {
        final nameParts = line.substring(2).split(';');
        if (nameParts.length >= 2) {
          lastName = nameParts[0];
          firstName = nameParts[1];
        }
      } else if (line.startsWith('TEL')) {
        phone = extractValue(line, 'TEL');
      } else if (line.startsWith('EMAIL')) {
        email = extractValue(line, 'EMAIL');
      } else if (line.startsWith('TITLE')) {
        title = extractValue(line, 'TITLE');
      } else if (line.startsWith('ORG')) {
        company = extractValue(line, 'ORG');
      } else if (line.startsWith('URL')) {
        website = extractValue(line, 'URL');
      } else if (line.startsWith('ADR')) {
        final addressParts = extractValue(line, 'ADR').split(';');
        if (addressParts.length >= 7) {
          address = addressParts[2]; // Street
          city = addressParts[3];   // City
          postalCode = addressParts[5]; // Postal code
          country = addressParts[6];   // Country
        }
      }
    }

    // Fallback: try to extract from fullName if N field wasn't present
    if ((firstName == null || lastName == null) && fullName != null) {
      parseFullName(fullName, (first, last) {
        firstName = first;
        lastName = last;
      });
    }

    return VCardData(
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      phone: phone ?? '',
      email: email ?? '',
      title: title,
      company: company,
      website: website,
      address: address,
      city: city,
      postalCode: postalCode,
      country: country,
    );
  }

  /// Extrait la valeur d'un champ vCard (supporte les paramètres)
  static String extractValue(String line, String field) {
    if (line.startsWith('$field:')) {
      return line.substring(field.length + 1);
    } else if (line.startsWith('$field;')) {
      final colonIndex = line.indexOf(':');
      if (colonIndex != -1) {
        return line.substring(colonIndex + 1);
      }
    }
    return '';
  }

  /// Parse un nom complet en prénom et nom
  static void parseFullName(String fullName, void Function(String? firstName, String? lastName) callback) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      callback(parts[0], null);
    } else if (parts.length == 2) {
      callback(parts[0], parts[1]);
    } else {
      // Prendre le premier mot comme prénom et le reste comme nom
      callback(parts[0], parts.sublist(1).join(' '));
    }
  }

  /// Valide si le contenu ressemble à une vCard
  static bool isValidVCardFormat(String content) => content.toUpperCase().contains('BEGIN:VCARD') &&
           content.toUpperCase().contains('END:VCARD') &&
           (content.contains('FN:') || content.contains('N:'));

  /// Lit et parse un fichier vCard depuis le système de fichiers
  static Future<VCardData?> parseVCardFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      if (!isValidVCardFormat(content)) {
        return null;
      }

      return parseVCard(content);
    } catch (e) {
      return null;
    }
  }
}