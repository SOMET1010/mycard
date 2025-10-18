/// Configuration des boxes Hive pour l'application
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:mycard/core/constants.dart';
import 'package:mycard/data/models/business_card.dart';
import 'package:mycard/data/models/card_template.dart';
import 'package:mycard/data/models/event_overlay.dart';

/// Gestionnaire des boxes Hive
class HiveBoxes {
  /// Box pour les cartes de visite
  static Future<Box<BusinessCard>> get cardsBox async =>
      Hive.openBox<BusinessCard>(AppConstants.cardsBoxName);

  /// Box pour les paramètres de l'application
  static Future<Box> get settingsBox async =>
      Hive.openBox(AppConstants.settingsBoxName);

  /// Box pour les templates (cache local)
  static Future<Box<CardTemplate>> get templatesBox async =>
      Hive.openBox<CardTemplate>('templates');

  /// Box pour les événements (cache local)
  static Future<Box<EventOverlay>> get eventsBox async =>
      Hive.openBox<EventOverlay>('events');

  /// Initialise toutes les boxes nécessaires
  static Future<void> initializeAllBoxes() async {
    await cardsBox;
    await settingsBox;
    // Les caches templates/events sont optionnels et nécessitent des adapters.
    // On ne les ouvre pas par défaut pour éviter des erreurs si les adapters ne sont pas présents.
  }

  /// Ferme toutes les boxes ouvertes
  static Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  /// Nettoie toutes les boxes
  static Future<void> clearAllBoxes() async {
    await (await cardsBox).clear();
    await (await settingsBox).clear();
    await (await templatesBox).clear();
    await (await eventsBox).clear();
  }

  /// Vérifie si une box existe et est ouverte
  static bool isBoxOpen(String boxName) => Hive.isBoxOpen(boxName);

  /// Obtient une box par son nom
  static Future<Box?> getBox(String boxName) async {
    if (isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return null;
  }
}
