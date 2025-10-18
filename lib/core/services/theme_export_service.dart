/// Service d'export multi-formats pour les thèmes
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum ExportFormat {
  json, // JSON format
  css, // CSS variables
  xml, // XML format
  yaml, // YAML format
  scss, // SCSS variables
  flutter, // Flutter theme code
  tailwind, // Tailwind CSS config
  materialDesign, // Material Design tokens
  ios, // iOS Swift colors
  android, // Android XML colors
  figma, // Figma variables
  sketch, // Sketch palette
  adobeXd, // Adobe XD assets
  svg, // SVG pattern
  png, // PNG preview
  pdf, // PDF documentation
}

class ExportSettings {
  const ExportSettings({
    required this.format,
    this.fileName,
    this.includePreview = true,
    this.includeDocumentation = true,
    this.includeTokens = true,
    this.includeCodeExamples = false,
    this.customOptions = const {},
  });
  final ExportFormat format;
  final String? fileName;
  final bool includePreview;
  final bool includeDocumentation;
  final bool includeTokens;
  final bool includeCodeExamples;
  final Map<String, dynamic> customOptions;
}

class ThemeExportResult {
  const ThemeExportResult({
    required this.success,
    this.filePath,
    this.data,
    this.errorMessage,
    required this.format,
    this.fileSize = 0,
    required this.exportedAt,
  });
  final bool success;
  final String? filePath;
  final Uint8List? data;
  final String? errorMessage;
  final ExportFormat format;
  final int fileSize;
  final DateTime exportedAt;
}

class ThemeExportService {
  ThemeExportService._();
  static final ThemeExportService instance = ThemeExportService._();

  /// Exporte une palette de couleurs en JSON dans le dossier documents
  Future<String> exportColorPalette(List<Color> palette) async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(dir.path, 'mycard_exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final filePath = p.join(
      exportDir.path,
      'palette_${DateTime.now().millisecondsSinceEpoch}.json',
    );

    final hexColors = palette.map(_colorToHex).toList();

    final payload = {
      'type': 'palette',
      'exportedAt': DateTime.now().toIso8601String(),
      'colors': hexColors,
    };

    await File(filePath).writeAsString(json.encode(payload));
    return filePath;
  }

  /// Exporte un thème dans différents formats
  static Future<ThemeExportResult> exportTheme(
    EventThemeCustomization theme, {
    required ExportSettings settings,
  }) async {
    try {
      switch (settings.format) {
        case ExportFormat.json:
          return await _exportAsJson(theme, settings);
        case ExportFormat.css:
          return await _exportAsCss(theme, settings);
        case ExportFormat.xml:
          return await _exportAsXml(theme, settings);
        case ExportFormat.yaml:
          return await _exportAsYaml(theme, settings);
        case ExportFormat.scss:
          return await _exportAsScss(theme, settings);
        case ExportFormat.flutter:
          return await _exportAsFlutter(theme, settings);
        case ExportFormat.tailwind:
          return await _exportAsTailwind(theme, settings);
        case ExportFormat.materialDesign:
          return await _exportAsMaterialDesign(theme, settings);
        case ExportFormat.ios:
          return await _exportAsIos(theme, settings);
        case ExportFormat.android:
          return await _exportAsAndroid(theme, settings);
        case ExportFormat.figma:
          return await _exportAsFigma(theme, settings);
        case ExportFormat.sketch:
          return await _exportAsSketch(theme, settings);
        case ExportFormat.adobeXd:
          return await _exportAsAdobeXd(theme, settings);
        case ExportFormat.svg:
          return await _exportAsSvg(theme, settings);
        case ExportFormat.png:
          return await _exportAsPng(theme, settings);
        case ExportFormat.pdf:
          return await _exportAsPdf(theme, settings);
      }
    } catch (e) {
      return ThemeExportResult(
        success: false,
        errorMessage: 'Erreur lors de l\'export: $e',
        format: settings.format,
        exportedAt: DateTime.now(),
      );
    }
  }

  /// Exporte en batch plusieurs thèmes
  static Future<List<ThemeExportResult>> exportBatch(
    List<EventThemeCustomization> themes, {
    required ExportSettings settings,
  }) async {
    final results = <ThemeExportResult>[];

    for (var i = 0; i < themes.length; i++) {
      final theme = themes[i];
      final batchSettings = ExportSettings(
        format: settings.format,
        fileName: settings.fileName != null ? '${settings.fileName}_$i' : null,
        includePreview: settings.includePreview,
        includeDocumentation: settings.includeDocumentation,
        includeTokens: settings.includeTokens,
        includeCodeExamples: settings.includeCodeExamples,
        customOptions: settings.customOptions,
      );

      final result = await exportTheme(theme, settings: batchSettings);
      results.add(result);
    }

    return results;
  }

  /// Génère un aperçu du thème
  static Future<Uint8List?> generateThemePreview(
    EventThemeCustomization theme, {
    int width = 800,
    int height = 600,
  }) async {
    // Simuler la génération d'aperçu
    // En réalité, utiliserait un package de rendu d'image
    final previewData = Uint8List.fromList([
      // PNG header (simulation)
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      // Image data (simulation)
      ...List.filled(width * height * 4, 0),
    ]);

    return previewData;
  }

  /// Valide un format d'export
  static bool validateExportFormat(ExportFormat format) =>
      ExportFormat.values.contains(format);

  /// Récupère les métadonnées d'export
  static Map<String, dynamic> getExportMetadata(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) => {
    'theme': {
      'id': theme.templateId,
      'colors': {
        'primary': theme.primaryColor.value,
        'secondary': theme.secondaryColor.value,
        'background': theme.backgroundColor.value,
        'text': theme.textColor.value,
      },
      'typography': {
        'fontFamily': theme.fontFamily,
        'titleSize': theme.titleFontSize,
        'bodySize': theme.bodyFontSize,
      },
      'layout': {
        'borderRadius': theme.borderRadius,
        'padding': theme.cardPadding,
        'shadowOpacity': theme.shadowOpacity,
      },
    },
    'export': {
      'format': settings.format.name,
      'includePreview': settings.includePreview,
      'includeDocumentation': settings.includeDocumentation,
      'includeTokens': settings.includeTokens,
      'customOptions': settings.customOptions,
    },
    'timestamp': DateTime.now().toIso8601String(),
    'version': '1.0.0',
  };

  // Méthodes d'export privées

  static Future<ThemeExportResult> _exportAsJson(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final jsonData = {
      'theme': theme.toJson(),
      'metadata': getExportMetadata(theme, settings),
      'tokens': _generateTokens(theme),
    };

    if (settings.includeDocumentation) {
      jsonData['documentation'] = _generateDocumentation(theme);
    }

    if (settings.includeCodeExamples) {
      jsonData['examples'] = _generateCodeExamples(theme);
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    final data = Uint8List.fromList(utf8.encode(jsonString));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.json,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsCss(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('/* Theme Export - ${DateTime.now()} */');
    buffer.writeln('/* Generated by MyCard Theme Exporter */\n');

    // CSS Variables
    buffer.writeln(':root {');
    buffer.writeln('  --primary-color: ${_colorToHex(theme.primaryColor)};');
    buffer.writeln(
      '  --secondary-color: ${_colorToHex(theme.secondaryColor)};',
    );
    buffer.writeln(
      '  --background-color: ${_colorToHex(theme.backgroundColor)};',
    );
    buffer.writeln('  --text-color: ${_colorToHex(theme.textColor)};');

    if (theme.accentColor != null) {
      buffer.writeln('  --accent-color: ${_colorToHex(theme.accentColor!)};');
    }

    buffer.writeln('  --border-radius: ${theme.borderRadius}px;');
    buffer.writeln('  --card-padding: ${theme.cardPadding}px;');
    buffer.writeln('  --shadow-opacity: ${theme.shadowOpacity};');
    buffer.writeln('  --title-font-size: ${theme.titleFontSize}px;');
    buffer.writeln('  --body-font-size: ${theme.bodyFontSize}px;');

    if (theme.fontFamily != null) {
      buffer.writeln('  --font-family: "${theme.fontFamily}";');
    }

    buffer.writeln('}\n');

    // Component classes
    if (settings.includeTokens) {
      buffer.writeln('.theme-card {');
      buffer.writeln('  background-color: var(--background-color);');
      buffer.writeln('  color: var(--text-color);');
      buffer.writeln('  border-radius: var(--border-radius);');
      buffer.writeln('  padding: var(--card-padding);');
      buffer.writeln(
        '  box-shadow: 0 4px 6px rgba(0, 0, 0, var(--shadow-opacity));',
      );
      buffer.writeln('}\n');

      buffer.writeln('.theme-button-primary {');
      buffer.writeln('  background-color: var(--primary-color);');
      buffer.writeln('  color: var(--background-color);');
      buffer.writeln('  border: none;');
      buffer.writeln('  padding: 12px 24px;');
      buffer.writeln('  border-radius: var(--border-radius);');
      buffer.writeln('  font-size: var(--body-font-size);');
      buffer.writeln('}\n');
    }

    // Documentation
    if (settings.includeDocumentation) {
      buffer.writeln('/*');
      buffer.writeln(' Documentation:');
      buffer.writeln(' - Use CSS variables for consistent theming');
      buffer.writeln(' - Primary color for main actions and highlights');
      buffer.writeln(' - Secondary color for supporting elements');
      buffer.writeln(' - Apply theme classes to components');
      buffer.writeln('*/');
    }

    final data = Uint8List.fromList(utf8.encode(buffer.toString()));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.css,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsScss(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final buffer = StringBuffer();

    // SCSS Variables
    buffer.writeln('// Theme Variables');
    buffer.writeln('\$primary-color: ${_colorToHex(theme.primaryColor)};');
    buffer.writeln('\$secondary-color: ${_colorToHex(theme.secondaryColor)};');
    buffer.writeln(
      '\$background-color: ${_colorToHex(theme.backgroundColor)};',
    );
    buffer.writeln('\$text-color: ${_colorToHex(theme.textColor)};');
    buffer.writeln('\$border-radius: ${theme.borderRadius}px;');
    buffer.writeln('\$card-padding: ${theme.cardPadding}px;');
    buffer.writeln('\$shadow-opacity: ${theme.shadowOpacity};');
    buffer.writeln('\$title-font-size: ${theme.titleFontSize}px;');
    buffer.writeln('\$body-font-size: ${theme.bodyFontSize}px;');

    if (theme.fontFamily != null) {
      buffer.writeln('\$font-family: "${theme.fontFamily}";');
    }

    // SCSS Mixins
    if (settings.includeTokens) {
      buffer.writeln('\n// Theme Mixins');
      buffer.writeln('@mixin theme-card {');
      buffer.writeln('  background-color: \$background-color;');
      buffer.writeln('  color: \$text-color;');
      buffer.writeln('  border-radius: \$border-radius;');
      buffer.writeln('  padding: \$card-padding;');
      buffer.writeln(
        '  box-shadow: 0 4px 6px rgba(0, 0, 0, \$shadow-opacity);',
      );
      buffer.writeln('}\n');

      buffer.writeln('@mixin theme-button-primary {');
      buffer.writeln('  background-color: \$primary-color;');
      buffer.writeln('  color: \$background-color;');
      buffer.writeln('  border: none;');
      buffer.writeln('  padding: 12px 24px;');
      buffer.writeln('  border-radius: \$border-radius;');
      buffer.writeln('  font-size: \$body-font-size;');
      buffer.writeln('  transition: all 0.3s ease;');
      buffer.writeln('}');
    }

    final data = Uint8List.fromList(utf8.encode(buffer.toString()));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.scss,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsFlutter(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final buffer = StringBuffer();

    // Flutter Theme Data
    buffer.writeln('import \'package:flutter/material.dart\';\n');

    buffer.writeln('class CustomTheme {');
    buffer.writeln('  static const ThemeData lightTheme = ThemeData(');
    buffer.writeln('    useMaterial3: true,');
    buffer.writeln('    colorScheme: ColorScheme.fromSeed(');
    buffer.writeln(
      '      seedColor: ${_colorToFlutterColor(theme.primaryColor)},',
    );
    buffer.writeln('      brightness: Brightness.light,');
    buffer.writeln('    ),');
    buffer.writeln('    appBarTheme: AppBarTheme(');
    buffer.writeln(
      '      backgroundColor: ${_colorToFlutterColor(theme.primaryColor)},',
    );
    buffer.writeln(
      '      foregroundColor: ${_colorToFlutterColor(theme.textColor)},',
    );
    buffer.writeln('      elevation: 4,');
    buffer.writeln('    ),');
    buffer.writeln('    cardTheme: CardTheme(');
    buffer.writeln(
      '      color: ${_colorToFlutterColor(theme.backgroundColor)},',
    );
    buffer.writeln('      elevation: 4,');
    buffer.writeln('      shape: RoundedRectangleBorder(');
    buffer.writeln(
      '        borderRadius: BorderRadius.circular(${theme.borderRadius}),',
    );
    buffer.writeln('      ),');
    buffer.writeln('    ),');
    buffer.writeln('    elevatedButtonTheme: ElevatedButtonThemeData(');
    buffer.writeln('      style: ElevatedButton.styleFrom(');
    buffer.writeln(
      '        backgroundColor: ${_colorToFlutterColor(theme.primaryColor)},',
    );
    buffer.writeln(
      '        foregroundColor: ${_colorToFlutterColor(theme.textColor)},',
    );
    buffer.writeln(
      '        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),',
    );
    buffer.writeln('        shape: RoundedRectangleBorder(');
    buffer.writeln(
      '          borderRadius: BorderRadius.circular(${theme.borderRadius}),',
    );
    buffer.writeln('        ),');
    buffer.writeln('      ),');
    buffer.writeln('    ),');

    if (theme.fontFamily != null) {
      buffer.writeln('    fontFamily: \'${theme.fontFamily}\',');
    }

    buffer.writeln('    textTheme: TextTheme(');
    buffer.writeln('      headlineLarge: TextStyle(');
    buffer.writeln('        fontSize: ${theme.titleFontSize},');
    buffer.writeln('        color: ${_colorToFlutterColor(theme.textColor)},');
    buffer.writeln('        fontWeight: FontWeight.bold,');
    buffer.writeln('      ),');
    buffer.writeln('      bodyLarge: TextStyle(');
    buffer.writeln('        fontSize: ${theme.bodyFontSize},');
    buffer.writeln('        color: ${_colorToFlutterColor(theme.textColor)},');
    buffer.writeln('      ),');
    buffer.writeln('    ),');
    buffer.writeln('  );');
    buffer.writeln('}\n');

    // Custom colors
    if (settings.includeTokens) {
      buffer.writeln('class ThemeColors {');
      buffer.writeln(
        '  static const Color primary = ${_colorToFlutterColor(theme.primaryColor)};',
      );
      buffer.writeln(
        '  static const Color secondary = ${_colorToFlutterColor(theme.secondaryColor)};',
      );
      buffer.writeln(
        '  static const Color background = ${_colorToFlutterColor(theme.backgroundColor)};',
      );
      buffer.writeln(
        '  static const Color text = ${_colorToFlutterColor(theme.textColor)};',
      );
      buffer.writeln('}\n');
    }

    final data = Uint8List.fromList(utf8.encode(buffer.toString()));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.flutter,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsTailwind(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final buffer = StringBuffer();

    // Tailwind Config
    buffer.writeln('/** @type {import(\'tailwindcss\').Config} */');
    buffer.writeln('module.exports = {');
    buffer.writeln('  content: [');
    buffer.writeln('    "./src/**/*.{js,jsx,ts,tsx}",');
    buffer.writeln('    "./app/**/*.{js,jsx,ts,tsx}",');
    buffer.writeln('    "./pages/**/*.{js,jsx,ts,tsx}",');
    buffer.writeln('  ],');
    buffer.writeln('  theme: {');
    buffer.writeln('    extend: {');
    buffer.writeln('      colors: {');
    buffer.writeln('        primary: \'${_colorToHex(theme.primaryColor)}\',');
    buffer.writeln(
      '        secondary: \'${_colorToHex(theme.secondaryColor)}\',',
    );
    buffer.writeln(
      '        background: \'${_colorToHex(theme.backgroundColor)}\',',
    );
    buffer.writeln('        text: \'${_colorToHex(theme.textColor)}\',');
    buffer.writeln('      },');
    buffer.writeln('      borderRadius: {');
    buffer.writeln('        \'theme\': \'${theme.borderRadius}px\',');
    buffer.writeln('      },');
    buffer.writeln('      padding: {');
    buffer.writeln('        \'card\': \'${theme.cardPadding}px\',');
    buffer.writeln('      },');
    buffer.writeln('      fontSize: {');
    buffer.writeln('        \'title\': \'${theme.titleFontSize}px\',');
    buffer.writeln('        \'body\': \'${theme.bodyFontSize}px\',');
    buffer.writeln('      },');

    if (theme.fontFamily != null) {
      buffer.writeln('      fontFamily: {');
      buffer.writeln('        \'theme\': [\'${theme.fontFamily}\'],');
      buffer.writeln('      },');
    }

    buffer.writeln('      boxShadow: {');
    buffer.writeln(
      '        \'theme\': \'0 4px 6px rgba(0, 0, 0, ${theme.shadowOpacity})\',',
    );
    buffer.writeln('      },');
    buffer.writeln('    },');
    buffer.writeln('  },');
    buffer.writeln('  plugins: [],');
    buffer.writeln('};');

    final data = Uint8List.fromList(utf8.encode(buffer.toString()));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.tailwind,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsAndroid(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final buffer = StringBuffer();

    // XML Resources
    buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
    buffer.writeln('<resources>\n');

    // Primary Colors
    buffer.writeln('    <!-- Primary Colors -->');
    buffer.writeln(
      '    <color name="primaryColor">${_colorToHex(theme.primaryColor)}</color>',
    );
    buffer.writeln(
      '    <color name="primaryVariant">${_colorToHex(theme.primaryColor)}</color>',
    );
    buffer.writeln(
      '    <color name="onPrimary">${_colorToHex(theme.textColor)}</color>\n',
    );

    // Secondary Colors
    buffer.writeln('    <!-- Secondary Colors -->');
    buffer.writeln(
      '    <color name="secondaryColor">${_colorToHex(theme.secondaryColor)}</color>',
    );
    buffer.writeln(
      '    <color name="secondaryVariant">${_colorToHex(theme.secondaryColor)}</color>',
    );
    buffer.writeln(
      '    <color name="onSecondary">${_colorToHex(theme.textColor)}</color>\n',
    );

    // Background Colors
    buffer.writeln('    <!-- Background Colors -->');
    buffer.writeln(
      '    <color name="backgroundColor">${_colorToHex(theme.backgroundColor)}</color>',
    );
    buffer.writeln(
      '    <color name="surfaceColor">${_colorToHex(theme.backgroundColor)}</color>',
    );
    buffer.writeln(
      '    <color name="onBackground">${_colorToHex(theme.textColor)}</color>',
    );
    buffer.writeln(
      '    <color name="onSurface">${_colorToHex(theme.textColor)}</color>\n',
    );

    // Dimensions
    if (settings.includeTokens) {
      buffer.writeln('    <!-- Dimensions -->');
      buffer.writeln(
        '    <dimen name="borderRadius">${theme.borderRadius}dp</dimen>',
      );
      buffer.writeln(
        '    <dimen name="cardPadding">${theme.cardPadding}dp</dimen>',
      );
      buffer.writeln(
        '    <dimen name="titleSize">${theme.titleFontSize}sp</dimen>',
      );
      buffer.writeln(
        '    <dimen name="bodySize">${theme.bodyFontSize}sp</dimen>\n',
      );
    }

    buffer.writeln('</resources>');

    final data = Uint8List.fromList(utf8.encode(buffer.toString()));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.android,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsIos(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final buffer = Stopwatch()..start();

    // Swift Color Extensions
    buffer.writeln('import UIKit\n');

    buffer.writeln('extension UIColor {');
    buffer.writeln('    // Theme Colors\n');
    buffer.writeln('    @nonobjc class var primary: UIColor {');
    buffer.writeln(
      '        return UIColor(red: ${theme.primaryColor.red / 255.0}, ',
    );
    buffer.writeln(
      '                           green: ${theme.primaryColor.green / 255.0}, ',
    );
    buffer.writeln(
      '                            blue: ${theme.primaryColor.blue / 255.0}, ',
    );
    buffer.writeln(
      '                           alpha: ${theme.primaryColor.alpha / 255.0})',
    );
    buffer.writeln('    }\n');

    buffer.writeln('    @nonobjc class var secondary: UIColor {');
    buffer.writeln(
      '        return UIColor(red: ${theme.secondaryColor.red / 255.0}, ',
    );
    buffer.writeln(
      '                           green: ${theme.secondaryColor.green / 255.0}, ',
    );
    buffer.writeln(
      '                            blue: ${theme.secondaryColor.blue / 255.0}, ',
    );
    buffer.writeln(
      '                           alpha: ${theme.secondaryColor.alpha / 255.0})',
    );
    buffer.writeln('    }\n');

    buffer.writeln('    @nonobjc class var background: UIColor {');
    buffer.writeln(
      '        return UIColor(red: ${theme.backgroundColor.red / 255.0}, ',
    );
    buffer.writeln(
      '                           green: ${theme.backgroundColor.green / 255.0}, ',
    );
    buffer.writeln(
      '                            blue: ${theme.backgroundColor.blue / 255.0}, ',
    );
    buffer.writeln(
      '                           alpha: ${theme.backgroundColor.alpha / 255.0})',
    );
    buffer.writeln('    }\n');

    buffer.writeln('    @nonobjc class var text: UIColor {');
    buffer.writeln(
      '        return UIColor(red: ${theme.textColor.red / 255.0}, ',
    );
    buffer.writeln(
      '                           green: ${theme.textColor.green / 255.0}, ',
    );
    buffer.writeln(
      '                            blue: ${theme.textColor.blue / 255.0}, ',
    );
    buffer.writeln(
      '                           alpha: ${theme.textColor.alpha / 255.0})',
    );
    buffer.writeln('    }');
    buffer.writeln('}\n');

    // Theme Configuration
    if (settings.includeTokens) {
      buffer.writeln('struct ThemeConfiguration {');
      buffer.writeln(
        '    static let cornerRadius: CGFloat = ${theme.borderRadius}',
      );
      buffer.writeln(
        '    static let cardPadding: CGFloat = ${theme.cardPadding}',
      );
      buffer.writeln(
        '    static let titleFontSize: CGFloat = ${theme.titleFontSize}',
      );
      buffer.writeln(
        '    static let bodyFontSize: CGFloat = ${theme.bodyFontSize}',
      );

      if (theme.fontFamily != null) {
        buffer.writeln(
          '    static let fontFamily: String = "${theme.fontFamily}"',
        );
      }

      buffer.writeln('}\n');

      buffer.writeln('extension UIView {');
      buffer.writeln('    func applyThemeStyle() {');
      buffer.writeln(
        '        layer.cornerRadius = ThemeConfiguration.cornerRadius',
      );
      buffer.writeln('        layer.shadowColor = UIColor.black.cgColor');
      buffer.writeln(
        '        layer.shadowOpacity = Float(${theme.shadowOpacity})',
      );
      buffer.writeln(
        '        layer.shadowOffset = CGSize(width: 0, height: 4)',
      );
      buffer.writeln('        layer.shadowRadius = 8');
      buffer.writeln('    }');
      buffer.writeln('}');
    }

    final data = Uint8List.fromList(utf8.encode(buffer.toString()));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.ios,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsXml(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final buffer = StringBuffer();

    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<theme>');
    buffer.writeln('  <metadata>');
    buffer.writeln('    <name>${settings.fileName ?? 'Custom Theme'}</name>');
    buffer.writeln(
      '    <created>${DateTime.now().toIso8601String()}</created>',
    );
    buffer.writeln('    <version>1.0</version>');
    buffer.writeln('  </metadata>');
    buffer.writeln('  <colors>');
    buffer.writeln('    <primary>');
    buffer.writeln('      <red>${theme.primaryColor.red}</red>');
    buffer.writeln('      <green>${theme.primaryColor.green}</green>');
    buffer.writeln('      <blue>${theme.primaryColor.blue}</blue>');
    buffer.writeln('      <alpha>${theme.primaryColor.alpha}</alpha>');
    buffer.writeln('    </primary>');
    buffer.writeln('    <secondary>');
    buffer.writeln('      <red>${theme.secondaryColor.red}</red>');
    buffer.writeln('      <green>${theme.secondaryColor.green}</green>');
    buffer.writeln('      <blue>${theme.secondaryColor.blue}</blue>');
    buffer.writeln('      <alpha>${theme.secondaryColor.alpha}</alpha>');
    buffer.writeln('    </secondary>');
    buffer.writeln('    <background>');
    buffer.writeln('      <red>${theme.backgroundColor.red}</red>');
    buffer.writeln('      <green>${theme.backgroundColor.green}</green>');
    buffer.writeln('      <blue>${theme.backgroundColor.blue}</blue>');
    buffer.writeln('      <alpha>${theme.backgroundColor.alpha}</alpha>');
    buffer.writeln('    </background>');
    buffer.writeln('    <text>');
    buffer.writeln('      <red>${theme.textColor.red}</red>');
    buffer.writeln('      <green>${theme.textColor.green}</green>');
    buffer.writeln('      <blue>${theme.textColor.blue}</blue>');
    buffer.writeln('      <alpha>${theme.textColor.alpha}</alpha>');
    buffer.writeln('    </text>');
    buffer.writeln('  </colors>');
    buffer.writeln('  <typography>');
    if (theme.fontFamily != null) {
      buffer.writeln('    <fontFamily>${theme.fontFamily}</fontFamily>');
    }
    buffer.writeln('    <titleSize>${theme.titleFontSize}</titleSize>');
    buffer.writeln('    <bodySize>${theme.bodyFontSize}</bodySize>');
    buffer.writeln('  </typography>');
    buffer.writeln('  <layout>');
    buffer.writeln('    <borderRadius>${theme.borderRadius}</borderRadius>');
    buffer.writeln('    <cardPadding>${theme.cardPadding}</cardPadding>');
    buffer.writeln('    <shadowOpacity>${theme.shadowOpacity}</shadowOpacity>');
    buffer.writeln('  </layout>');
    buffer.writeln('</theme>');

    final data = Uint8List.fromList(utf8.encode(buffer.toString()));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.xml,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsYaml(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final buffer = StringBuffer();

    buffer.writeln('# Theme Configuration');
    buffer.writeln('name: "${settings.fileName ?? 'Custom Theme'}"');
    buffer.writeln('version: "1.0"');
    buffer.writeln('created: "${DateTime.now().toIso8601String()}"\n');

    buffer.writeln('colors:');
    buffer.writeln('  primary: "${_colorToHex(theme.primaryColor)}"');
    buffer.writeln('  secondary: "${_colorToHex(theme.secondaryColor)}"');
    buffer.writeln('  background: "${_colorToHex(theme.backgroundColor)}"');
    buffer.writeln('  text: "${_colorToHex(theme.textColor)}"\n');

    buffer.writeln('typography:');
    if (theme.fontFamily != null) {
      buffer.writeln('  fontFamily: "${theme.fontFamily}"');
    }
    buffer.writeln('  titleSize: ${theme.titleFontSize}');
    buffer.writeln('  bodySize: ${theme.bodyFontSize}\n');

    buffer.writeln('layout:');
    buffer.writeln('  borderRadius: ${theme.borderRadius}');
    buffer.writeln('  cardPadding: ${theme.cardPadding}');
    buffer.writeln('  shadowOpacity: ${theme.shadowOpacity}\n');

    if (settings.includeTokens) {
      buffer.writeln('tokens:');
      buffer.writeln('  primary-color: var(--primary-color)');
      buffer.writeln('  secondary-color: var(--secondary-color)');
      buffer.writeln('  background-color: var(--background-color)');
      buffer.writeln('  text-color: var(--text-color)');
    }

    final data = Uint8List.fromList(utf8.encode(buffer.toString()));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.yaml,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  // Autres formats (simplifiés pour la démonstration)

  static Future<ThemeExportResult> _exportAsMaterialDesign(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final tokens = _generateMaterialDesignTokens(theme);
    final data = Uint8List.fromList(utf8.encode(json.encode(tokens)));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.materialDesign,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsFigma(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final figmaData = _generateFigmaVariables(theme);
    final data = Uint8List.fromList(utf8.encode(json.encode(figmaData)));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.figma,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsSketch(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final sketchData = _generateSketchPalette(theme);
    final data = Uint8List.fromList(utf8.encode(json.encode(sketchData)));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.sketch,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsAdobeXd(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final xdData = _generateAdobeXdAssets(theme);
    final data = Uint8List.fromList(utf8.encode(json.encode(xdData)));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.adobeXd,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsSvg(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final svgContent = _generateSvgPattern(theme);
    final data = Uint8List.fromList(utf8.encode(svgContent));

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.svg,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsPng(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final previewData = await generateThemePreview(theme);
    if (previewData == null) {
      return ThemeExportResult(
        success: false,
        errorMessage: 'Impossible de générer l\'aperçu PNG',
        format: ExportFormat.png,
        exportedAt: DateTime.now(),
      );
    }

    return ThemeExportResult(
      success: true,
      data: previewData,
      format: ExportFormat.png,
      fileSize: previewData.length,
      exportedAt: DateTime.now(),
    );
  }

  static Future<ThemeExportResult> _exportAsPdf(
    EventThemeCustomization theme,
    ExportSettings settings,
  ) async {
    final pdfContent = _generatePdfDocumentation(theme);
    final data = Uint8List.fromList(pdfContent);

    return ThemeExportResult(
      success: true,
      data: data,
      format: ExportFormat.pdf,
      fileSize: data.length,
      exportedAt: DateTime.now(),
    );
  }

  // Utilitaires

  static String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  static String _colorToFlutterColor(Color color) =>
      'Color(0xFF${color.value.toRadixString(16).substring(2).toUpperCase()})';

  static Map<String, dynamic> _generateTokens(EventThemeCustomization theme) =>
      {
        'colors': {
          'primary': _colorToHex(theme.primaryColor),
          'secondary': _colorToHex(theme.secondaryColor),
          'background': _colorToHex(theme.backgroundColor),
          'text': _colorToHex(theme.textColor),
        },
        'spacing': {
          'borderRadius': theme.borderRadius,
          'cardPadding': theme.cardPadding,
        },
        'typography': {
          'titleSize': theme.titleFontSize,
          'bodySize': theme.bodyFontSize,
          'fontFamily': theme.fontFamily,
        },
      };

  static Map<String, dynamic> _generateDocumentation(
    EventThemeCustomization theme,
  ) => {
    'description': 'Thème personnalisé généré par MyCard',
    'usage': 'Utilisez ces tokens pour maintenir la cohérence visuelle',
    'guidelines': [
      'Utiliser la couleur primaire pour les éléments principaux',
      'La couleur secondaire complète la couleur primaire',
      'Maintenir un contraste suffisant pour l\'accessibilité',
    ],
  };

  static List<String> _generateCodeExamples(EventThemeCustomization theme) => [
    'button: background-color: var(--primary-color);',
    'card: border-radius: var(--border-radius);',
    'text: color: var(--text-color);',
  ];

  static Map<String, dynamic> _generateMaterialDesignTokens(
    EventThemeCustomization theme,
  ) => {
    'color': {
      'primary': _colorToHex(theme.primaryColor),
      'secondary': _colorToHex(theme.secondaryColor),
      'background': _colorToHex(theme.backgroundColor),
      'surface': _colorToHex(theme.backgroundColor),
      'onPrimary': _colorToHex(theme.textColor),
      'onSecondary': _colorToHex(theme.textColor),
      'onBackground': _colorToHex(theme.textColor),
      'onSurface': _colorToHex(theme.textColor),
    },
    'shape': {
      'borderRadius': {
        'small': theme.borderRadius * 0.5,
        'medium': theme.borderRadius,
        'large': theme.borderRadius * 1.5,
      },
    },
  };

  static Map<String, dynamic> _generateFigmaVariables(
    EventThemeCustomization theme,
  ) => {
    'variables': {
      'primary': _colorToHex(theme.primaryColor),
      'secondary': _colorToHex(theme.secondaryColor),
      'background': _colorToHex(theme.backgroundColor),
      'text': _colorToHex(theme.textColor),
    },
    'collections': [
      {
        'name': 'Colors',
        'modes': [
          {
            'name': 'Light',
            'variables': ['primary', 'secondary', 'background', 'text'],
          },
        ],
      },
    ],
  };

  static Map<String, dynamic> _generateSketchPalette(
    EventThemeCustomization theme,
  ) => {
    'colors': [
      {'name': 'Primary', 'color': _colorToHex(theme.primaryColor)},
      {'name': 'Secondary', 'color': _colorToHex(theme.secondaryColor)},
      {'name': 'Background', 'color': _colorToHex(theme.backgroundColor)},
      {'name': 'Text', 'color': _colorToHex(theme.textColor)},
    ],
    'swatches': [
      {
        'name': 'Theme Colors',
        'colors': [
          _colorToHex(theme.primaryColor),
          _colorToHex(theme.secondaryColor),
          _colorToHex(theme.backgroundColor),
          _colorToHex(theme.textColor),
        ],
      },
    ],
  };

  static Map<String, dynamic> _generateAdobeXdAssets(
    EventThemeCustomization theme,
  ) => {
    'assets': [
      {
        'name': 'Primary Color',
        'type': 'color',
        'value': _colorToHex(theme.primaryColor),
      },
      {
        'name': 'Secondary Color',
        'type': 'color',
        'value': _colorToHex(theme.secondaryColor),
      },
    ],
    'components': [
      {
        'name': 'Theme Card',
        'properties': {
          'fill': _colorToHex(theme.backgroundColor),
          'stroke': _colorToHex(theme.primaryColor),
          'cornerRadius': theme.borderRadius,
        },
      },
    ],
  };

  static String _generateSvgPattern(EventThemeCustomization theme) =>
      '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <pattern id="themePattern" x="0" y="0" width="20" height="20" patternUnits="userSpaceOnUse">
      <circle cx="10" cy="10" r="2" fill="${_colorToHex(theme.primaryColor)}" opacity="0.3"/>
      <rect x="0" y="0" width="10" height="10" fill="${_colorToHex(theme.secondaryColor)}" opacity="0.2"/>
      <rect x="10" y="10" width="10" height="10" fill="${_colorToHex(theme.secondaryColor)}" opacity="0.2"/>
    </pattern>
  </defs>
  <rect width="200" height="200" fill="${_colorToHex(theme.backgroundColor)}"/>
  <rect width="200" height="200" fill="url(#themePattern)"/>
  <rect x="50" y="50" width="100" height="100" rx="${theme.borderRadius}"
        fill="${_colorToHex(theme.primaryColor)}" opacity="0.8"/>
  <text x="100" y="105" text-anchor="middle" fill="${_colorToHex(theme.textColor)}"
        font-family="${theme.fontFamily ?? 'Arial'}" font-size="${theme.bodyFontSize}">
    Theme
  </text>
</svg>''';

  static List<int> _generatePdfDocumentation(EventThemeCustomization theme) {
    // Simuler la génération PDF (en réalité, utiliserait un package PDF)
    final content =
        'Theme Documentation\n\nColors:\nPrimary: ${_colorToHex(theme.primaryColor)}\n'
        'Secondary: ${_colorToHex(theme.secondaryColor)}\n'
        'Background: ${_colorToHex(theme.backgroundColor)}\n'
        'Text: ${_colorToHex(theme.textColor)}\n\n'
        'Typography:\nTitle Size: ${theme.titleFontSize}px\n'
        'Body Size: ${theme.bodyFontSize}px\n'
        'Font: ${theme.fontFamily ?? 'Default'}\n\n'
        'Layout:\nBorder Radius: ${theme.borderRadius}px\n'
        'Card Padding: ${theme.cardPadding}px\n'
        'Shadow Opacity: ${theme.shadowOpacity}';

    return utf8.encode(content);
  }

  /// Récupère la liste des formats supportés
  static List<ExportFormat> getSupportedFormats() => ExportFormat.values;

  /// Valide les données avant export
  static bool validateThemeData(EventThemeCustomization theme) =>
      theme.primaryColor != null &&
      theme.secondaryColor != null &&
      theme.backgroundColor != null &&
      theme.textColor != null;

  /// Obtient des suggestions de format basées sur le contexte
  static List<ExportFormat> getRecommendedFormats(String? platform) {
    switch (platform?.toLowerCase()) {
      case 'flutter':
      case 'dart':
        return [ExportFormat.flutter, ExportFormat.json];
      case 'web':
      case 'html':
      case 'css':
        return [
          ExportFormat.css,
          ExportFormat.scss,
          ExportFormat.tailwind,
          ExportFormat.json,
        ];
      case 'android':
        return [ExportFormat.android, ExportFormat.xml, ExportFormat.json];
      case 'ios':
      case 'swift':
        return [ExportFormat.ios, ExportFormat.json];
      case 'design':
      case 'figma':
        return [ExportFormat.figma, ExportFormat.sketch, ExportFormat.adobeXd];
      default:
        return [ExportFormat.json, ExportFormat.css, ExportFormat.flutter];
    }
  }
}
