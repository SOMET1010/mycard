/// Modèle de données pour une carte de visite
library;

import 'package:hive/hive.dart';

part 'business_card.g.dart';

@HiveType(typeId: 0)
class BusinessCard extends HiveObject {
  BusinessCard({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.phone,
    required this.email,
    this.company,
    this.website,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.notes,
    required this.templateId,
    this.eventOverlayId,
    Map<String, String>? customColors,
    this.logoPath,
    this.backNotes,
    this.backServices,
    this.backOpeningHours,
    this.backSocialLinks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : customColors = customColors ?? {},
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Crée une carte à partir d'un Map JSON
  factory BusinessCard.fromJson(Map<String, dynamic> json) => BusinessCard(
    id: json['id'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    title: json['title'],
    phone: json['phone'],
    email: json['email'],
    company: json['company'],
    website: json['website'],
    address: json['address'],
    city: json['city'],
    postalCode: json['postalCode'],
    country: json['country'],
    notes: json['notes'],
    templateId: json['templateId'],
    eventOverlayId: json['eventOverlayId'],
    customColors: Map<String, String>.from(json['customColors'] ?? {}),
    logoPath: json['logoPath'],
    backNotes: json['backNotes'],
    backServices: (json['backServices'] as List?)
        ?.where((e) => e != null)
        .map((e) => e.toString())
        .toList(),
    backOpeningHours: json['backOpeningHours'],
    backSocialLinks: json['backSocialLinks'] != null
        ? Map<String, String>.from(json['backSocialLinks'])
        : null,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
  @HiveField(0)
  final String id;

  @HiveField(1)
  String firstName;

  @HiveField(2)
  String lastName;

  @HiveField(3)
  String title;

  @HiveField(4)
  String phone;

  @HiveField(5)
  String email;

  @HiveField(6)
  String? company;

  @HiveField(7)
  String? website;

  @HiveField(8)
  String? address;

  @HiveField(9)
  String? city;

  @HiveField(10)
  String? postalCode;

  @HiveField(11)
  String? country;

  @HiveField(12)
  String? notes;

  @HiveField(13)
  String templateId;

  @HiveField(14)
  String? eventOverlayId;

  @HiveField(15)
  Map<String, String> customColors;

  @HiveField(16)
  String? logoPath;

  @HiveField(17)
  String? backNotes;

  @HiveField(18)
  List<String>? backServices;

  @HiveField(19)
  String? backOpeningHours;

  @HiveField(20)
  Map<String, String>? backSocialLinks;

  @HiveField(21)
  DateTime createdAt;

  @HiveField(22)
  DateTime updatedAt;

  /// Nom complet
  String get fullName => '$firstName $lastName'.trim();

  /// URL du site web formatée
  String? get formattedWebsite {
    if (website == null || website!.isEmpty) return null;

    if (website!.startsWith('http://') || website!.startsWith('https://')) {
      return website;
    }

    return 'https://$website';
  }

  /// Adresse complète formatée
  String? get fullAddress {
    final parts = <String>[];

    if (address?.isNotEmpty == true) parts.add(address!);
    if (postalCode?.isNotEmpty == true) parts.add(postalCode!);
    if (city?.isNotEmpty == true) parts.add(city!);
    if (country?.isNotEmpty == true) parts.add(country!);

    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Copie la carte avec de nouvelles valeurs
  BusinessCard copyWith({
    String? firstName,
    String? lastName,
    String? title,
    String? phone,
    String? email,
    String? company,
    String? website,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? notes,
    String? templateId,
    String? eventOverlayId,
    Map<String, String>? customColors,
    String? logoPath,
    String? backNotes,
    List<String>? backServices,
    String? backOpeningHours,
    Map<String, String>? backSocialLinks,
    DateTime? updatedAt,
  }) => BusinessCard(
    id: id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    title: title ?? this.title,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    company: company ?? this.company,
    website: website ?? this.website,
    address: address ?? this.address,
    city: city ?? this.city,
    postalCode: postalCode ?? this.postalCode,
    country: country ?? this.country,
    notes: notes ?? this.notes,
    templateId: templateId ?? this.templateId,
    eventOverlayId: eventOverlayId ?? this.eventOverlayId,
    customColors: customColors ?? this.customColors,
    logoPath: logoPath ?? this.logoPath,
    backNotes: backNotes ?? this.backNotes,
    backServices: backServices ?? this.backServices,
    backOpeningHours: backOpeningHours ?? this.backOpeningHours,
    backSocialLinks: backSocialLinks ?? this.backSocialLinks,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  /// Convertit en Map pour JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'title': title,
    'phone': phone,
    'email': email,
    'company': company,
    'website': website,
    'address': address,
    'city': city,
    'postalCode': postalCode,
    'country': country,
    'notes': notes,
    'templateId': templateId,
    'eventOverlayId': eventOverlayId,
    'customColors': customColors,
    'logoPath': logoPath,
    'backNotes': backNotes,
    'backServices': backServices,
    'backOpeningHours': backOpeningHours,
    'backSocialLinks': backSocialLinks,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessCard &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phone == phone &&
        other.email == email;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      phone.hashCode ^
      email.hashCode;

  @override
  String toString() =>
      'BusinessCard(id: $id, fullName: $fullName, email: $email)';
}
