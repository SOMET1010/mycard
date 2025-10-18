/// Repository pour la gestion des cartes de visite
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mycard/core/constants.dart';
import 'package:mycard/data/models/business_card.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:uuid/uuid.dart';

class CardsRepository {
  late final Box<BusinessCard> _cardsBox;
  final Uuid _uuid = const Uuid();
  bool _isInitialized = false;

  /// Vérifie si le repository est initialisé
  bool get isInitialized => _isInitialized;

  /// Initialise le repository
  Future<void> init() async {
    _cardsBox = await Hive.openBox<BusinessCard>(AppConstants.cardsBoxName);
    _isInitialized = true;
  }

  /// Crée une nouvelle carte
  Future<BusinessCard> createCard({
    required String firstName,
    required String lastName,
    required String title,
    required String phone,
    required String email,
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
  }) async {
    final card = BusinessCard(
      id: _uuid.v4(),
      firstName: firstName,
      lastName: lastName,
      title: title,
      phone: phone,
      email: email,
      company: company,
      website: website,
      address: address,
      city: city,
      postalCode: postalCode,
      country: country,
      notes: notes,
      templateId: templateId ?? CardTemplate.predefinedTemplates.first.id,
      eventOverlayId: eventOverlayId,
      customColors: customColors,
      logoPath: logoPath,
      backNotes: backNotes,
      backServices: backServices,
      backOpeningHours: backOpeningHours,
      backSocialLinks: backSocialLinks,
    );

    await _cardsBox.put(card.id, card);
    return card;
  }

  /// Met à jour une carte existante
  Future<BusinessCard> updateCard(BusinessCard card) async {
    final updatedCard = card.copyWith(updatedAt: DateTime.now());
    await _cardsBox.put(card.id, updatedCard);
    return updatedCard;
  }

  /// Supprime une carte
  Future<void> deleteCard(String id) async {
    await _cardsBox.delete(id);
  }

  /// Récupère une carte par son ID
  BusinessCard? getCardById(String id) => _cardsBox.get(id);

  /// Récupère toutes les cartes
  List<BusinessCard> getAllCards() => _cardsBox.values.toList();

  /// Listenable pour reconstruire l'UI quand les cartes changent
  ValueListenable<Box<BusinessCard>> get listenable => _cardsBox.listenable();

  /// Récupère les cartes triées par date de création
  List<BusinessCard> getCardsSortedByDate({bool descending = true}) {
    final cards = getAllCards();
    cards.sort(
      (a, b) => descending
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt),
    );
    return cards;
  }

  /// Récupère les cartes triées par nom
  List<BusinessCard> getCardsSortedByName({bool ascending = true}) {
    final cards = getAllCards();
    cards.sort(
      (a, b) => ascending
          ? a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase())
          : b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()),
    );
    return cards;
  }

  /// Recherche des cartes par nom, entreprise ou email
  List<BusinessCard> searchCards(String query) {
    if (query.isEmpty) return getAllCards();

    final lowerQuery = query.toLowerCase();
    return getAllCards()
        .where(
          (card) =>
              card.fullName.toLowerCase().contains(lowerQuery) ||
              (card.company?.toLowerCase().contains(lowerQuery) ?? false) ||
              card.email.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Filtre les cartes par template
  List<BusinessCard> getCardsByTemplate(String templateId) =>
      getAllCards().where((card) => card.templateId == templateId).toList();

  /// Filtre les cartes par événement
  List<BusinessCard> getCardsByEvent(String eventId) =>
      getAllCards().where((card) => card.eventOverlayId == eventId).toList();

  /// Compte le nombre total de cartes
  int get cardsCount => _cardsBox.length;

  /// Vérifie si une carte existe
  bool cardExists(String id) => _cardsBox.containsKey(id);

  /// Sauvegarde les cartes (Hive gère la persistance automatiquement)
  Future<void> saveAll() async {
    await _cardsBox.compact();
  }

  /// Exporte toutes les cartes au format JSON
  String exportAllToJson() {
    final cards = getAllCards();
    final jsonList = cards.map((card) => card.toJson()).toList();
    return jsonEncode({
      'cards': jsonList,
      'exportedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Importe des cartes depuis un JSON
  Future<List<BusinessCard>> importFromJson(String jsonString) async {
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      if (jsonMap.containsKey('cards')) {
        final List<dynamic> cardsJson = jsonMap['cards'];
        final importedCards = <BusinessCard>[];

        for (final cardJson in cardsJson) {
          final card = BusinessCard.fromJson(cardJson);
          // Générer un nouvel ID pour éviter les conflits
          final newCard = BusinessCard(
            id: _uuid.v4(),
            firstName: card.firstName,
            lastName: card.lastName,
            title: card.title,
            phone: card.phone,
            email: card.email,
            company: card.company,
            website: card.website,
            address: card.address,
            city: card.city,
            postalCode: card.postalCode,
            country: card.country,
            notes: card.notes,
            templateId: card.templateId,
            eventOverlayId: card.eventOverlayId,
            customColors: card.customColors,
            logoPath: card.logoPath,
            backNotes: card.backNotes,
            backServices: card.backServices,
            backOpeningHours: card.backOpeningHours,
            backSocialLinks: card.backSocialLinks,
            createdAt: card.createdAt,
            updatedAt: card.updatedAt,
          );
          await _cardsBox.put(newCard.id, newCard);
          importedCards.add(newCard);
        }

        return importedCards;
      }

      return [];
    } catch (e) {
      debugPrint('Erreur lors de l\'import: $e');
      return [];
    }
  }

  /// Ferme le repository
  Future<void> close() async {
    await _cardsBox.close();
  }
}
