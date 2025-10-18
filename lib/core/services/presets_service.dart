/// Service local pour sauvegarder/charger des presets utilisateur
library;

import 'dart:convert';

import 'package:mycard/data/models/card_preset.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresetsService {
  static const _prefsKey = 'user_card_presets';

  /// Récupère la liste des presets
  static Future<List<CardPreset>> getPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => CardPreset.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sauvegarde (ajoute/remplace) un preset
  static Future<void> savePreset(CardPreset preset) async {
    final presets = await getPresets();
    final existingIndex = presets.indexWhere((p) => p.id == preset.id);
    if (existingIndex >= 0) {
      presets[existingIndex] = preset;
    } else {
      presets.add(preset);
    }
    await _persist(presets);
  }

  /// Supprime un preset par ID
  static Future<void> deletePreset(String id) async {
    final presets = await getPresets();
    presets.removeWhere((p) => p.id == id);
    await _persist(presets);
  }

  static Future<void> _persist(List<CardPreset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final list = presets.map((p) => p.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(list));
  }
}
