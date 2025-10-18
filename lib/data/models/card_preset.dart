/// Modèle pour un preset de personnalisation de carte
library;

class CardPreset {
  const CardPreset({
    required this.id,
    required this.name,
    required this.templateId,
    this.eventOverlayId,
    this.customColors = const {},
    this.fontFamily,
    this.sizeKey,
  });

  factory CardPreset.fromJson(Map<String, dynamic> json) => CardPreset(
        id: json['id'] as String,
        name: json['name'] as String,
        templateId: json['templateId'] as String,
        eventOverlayId: json['eventOverlayId'] as String?,
        customColors: Map<String, String>.from(json['customColors'] ?? {}),
        fontFamily: json['fontFamily'] as String?,
        sizeKey: json['sizeKey'] as String?,
      );

  final String id;
  final String name;
  final String templateId;
  final String? eventOverlayId;
  final Map<String, String> customColors;
  final String? fontFamily;
  final String? sizeKey;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'templateId': templateId,
        'eventOverlayId': eventOverlayId,
        'customColors': customColors,
        'fontFamily': fontFamily,
        'sizeKey': sizeKey,
      };
}

