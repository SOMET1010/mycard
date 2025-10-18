import 'package:flutter/material.dart';

/// Utilitaires pour les conversions DPI et les dimensions physiques
class DPIUtils {
  static const int standardDPI = 300;

  /// Convertit les millimètres en pixels à 300 DPI
  static double mmToPx(double mm) {
    final inches = mm * 0.0393701;
    return inches * standardDPI;
  }

  /// Convertit les pixels en millimètres à 300 DPI
  static double pxToMm(double px) {
    final inches = px / standardDPI;
    return inches / 0.0393701;
  }

  /// Convertit les pixels d'un DPI à un autre
  static double convertDPI(double pixels, int fromDPI, int toDPI) =>
      (pixels * toDPI) / fromDPI;

  /// Calcule la taille d'une image pour un format d'impression
  static Size getPrintSize(double widthPx, double heightPx, int targetDPI) {
    final widthInch = widthPx / standardDPI;
    final heightInch = heightPx / standardDPI;

    final targetWidthPx = widthInch * targetDPI;
    final targetHeightPx = heightInch * targetDPI;

    return Size(targetWidthPx, targetHeightPx);
  }

  /// Vérifie si une résolution est suffisante pour l'impression
  static bool isPrintResolution(double widthPx, double heightPx) {
    final widthInch = widthPx / standardDPI;
    final heightInch = heightPx / standardDPI;

    // Minimum 150 DPI pour une impression acceptable
    const minDPI = 150;
    final currentDPI = widthPx / widthInch;

    return currentDPI >= minDPI;
  }
}

/// Extension pour les opérations DPI sur les nombres
extension DPIExtensions on num {
  double get mm => DPIUtils.mmToPx(toDouble());
  double get toMm => DPIUtils.pxToMm(toDouble());
}
