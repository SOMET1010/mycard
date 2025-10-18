import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeManager extends StatefulWidget {

  const ThemeManager({
    super.key,
    required this.child,
    this.initialThemeMode = ThemeMode.system,
  });
  final Widget child;
  final ThemeMode initialThemeMode;

  static ThemeManagerState of(BuildContext context) => context.findAncestorStateOfType<ThemeManagerState>()!;

  @override
  ThemeManagerState createState() => ThemeManagerState();
}

class ThemeManagerState extends State<ThemeManager> {
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) => Theme(
      data: _themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: widget.child,
    );
}

class AppTheme {
  // Palette complète (voir palette.md)
  static const Color burntSienna = Color(0xFFE28742); // --burnt-sienna
  static const Color deepSapphire = Color(0xFF0E4274); // --deep-sapphire
  static const Color halfBaked = Color(0xFF8DC5D2); // --half-baked
  static const Color eternity = Color(0xFF21130D); // --eternity
  static const Color burntUmber = Color(0xFF873E23); // --burnt-umber
  static const Color easternBlue = Color(0xFF1E81B0); // --eastern-blue
  static const Color tacao = Color(0xFFEAB676); // --tacao
  static const Color greenWhite = Color(0xFFEEEEE4); // --green-white

  // Couleurs principales
  static const Color primaryColor = burntSienna;
  static const Color secondaryColor = tacao;
  static const Color accentColor = eternity;
  static const Color backgroundColor = greenWhite;
  static const Color surfaceColor = Color(0xFFF7F4EF);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFFB8C00);

  // Thème clair
  static ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: accentColor,
        onError: Colors.white,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: accentColor,
        ),
        displayMedium: GoogleFonts.manrope(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: accentColor,
        ),
        displaySmall: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: accentColor,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: accentColor,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: accentColor,
        ),
        headlineSmall: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: accentColor,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: accentColor,
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: accentColor,
        ),
        titleSmall: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: accentColor,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: accentColor,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: accentColor,
        ),
        bodySmall: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF6B5E56),
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelMedium: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelSmall: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: accentColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Card theme
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: surfaceColor,
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: primaryColor),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // teinte pêche légère pour se rapprocher de la maquette
        fillColor: const Color(0xFFF4E9E1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE7D9CF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE7D9CF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE7D9CF),
        thickness: 1,
        space: 1,
      ),
    );

  // Thème sombre
  static ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFEAB676),
        secondary: Color(0xFFB98C5E),
        surface: Color(0xFF1E1A17),
        error: Color(0xFFF87171),
        onPrimary: Color(0xFF14110F),
        onSecondary: Color(0xFF14110F),
        onSurface: Color(0xFFF4EDE7),
        onError: Color(0xFF14110F),
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF8FAFC),
        ),
        displayMedium: GoogleFonts.manrope(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF8FAFC),
        ),
        displaySmall: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF8FAFC),
        ),
        headlineLarge: GoogleFonts.manrope(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF8FAFC),
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF8FAFC),
        ),
        headlineSmall: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF8FAFC),
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF8FAFC),
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF8FAFC),
        ),
        titleSmall: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF8FAFC),
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFF8FAFC),
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFF8FAFC),
        ),
        bodySmall: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF94A3B8),
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
        labelMedium: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
        labelSmall: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1A17),
        foregroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Card theme
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: Color(0xFF1E1A17),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEAB676),
          foregroundColor: const Color(0xFF14110F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEAB676),
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Color(0xFFEAB676)),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF60A5FA),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF231F1C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3A332E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3A332E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAB676)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF87171)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF87171)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A332E),
        thickness: 1,
        space: 1,
      ),
    );
}
