/// Constantes utilisées dans toute l'application
class AppConstants {
  // Dimensions (en pixels à 300 DPI)
  static const double cardWidth = 900; // 3 inches * 300 DPI
  static const double cardHeight = 540; // 1.8 inches * 300 DPI
  static const double cardAspectRatio = cardWidth / cardHeight;

  // Marges et paddings
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Tailles de police
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 24.0;

  // Rayons de bordure
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;

  // DPI pour l'export
  static const int exportDPI = 300;
  static const double mmToInch = 0.0393701;
  static const double inchToPixel = 300.0; // 300 DPI

  // Formats d'export
  static const List<String> exportFormats = ['png', 'pdf', 'jpg'];

  // Clés de stockage
  static const String cardsBoxName = 'business_cards';
  static const String settingsBoxName = 'app_settings';

  // Routes
  static const String homeRoute = '/';
  static const String templatesRoute = '/templates';
  static const String editorRoute = '/editor';
  static const String galleryRoute = '/gallery';
  static const String exportRoute = '/export';

  // Validation
  static const int maxNameLength = 50;
  static const int maxTitleLength = 100;
  static const int maxCompanyLength = 100;
  static const int maxEmailLength = 100;
  static const int maxPhoneLength = 20;
  static const int maxWebsiteLength = 200;
}
