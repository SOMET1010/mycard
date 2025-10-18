/// Adapters Hive pour la sérialisation des modèles
library;

import 'package:hive/hive.dart';
import 'package:mycard/data/models/business_card.dart';

/// Enregistre tous les adapters Hive
Future<void> registerHiveAdapters() async {
  // Adapter pour BusinessCard (généré/manuel dans business_card.g.dart)
  if (!Hive.isAdapterRegistered(HiveTypeIds.businessCard)) {
    Hive.registerAdapter(BusinessCardAdapter());
  }
}

/// Type ID pour les adapters Hive
class HiveTypeIds {
  static const int businessCard = 0;
}
