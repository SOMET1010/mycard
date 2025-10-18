import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mycard/app/router.dart';
import 'package:mycard/app/theme.dart';
import 'package:mycard/data/local/hive_adapters.dart';
import 'package:mycard/data/local/hive_boxes.dart';
import 'package:mycard/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialisation du stockage local
  await Hive.initFlutter();
  await registerHiveAdapters();
  // Ouvre les boxes essentielles en amont (évite les ouvertures paresseuses)
  await HiveBoxes.initializeAllBoxes();
  // Firebase - Initialisation robuste (évite l'erreur [core/duplicate-app])
  try {
    if (kIsWeb) {
      // Sur le Web, on doit fournir les options explicitement
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // Sur Android/iOS/macOS, l'auto-init native peut déjà créer l'app par défaut
      // Cette ligne récupère (ou crée si besoin) l'app sans provoquer de doublon
      await Firebase.initializeApp();
    }
  } on FirebaseException catch (e) {
    // Ignore l'erreur de doublon si l'app existe déjà
    if (e.code != 'duplicate-app') {
      debugPrint('Erreur Firebase: [${e.code}] ${e.message}');
    }
  } catch (e) {
    debugPrint('Firebase non initialisé: ${e.toString()}');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ThemeManager(
    initialThemeMode: ThemeMode.system,
    child: MaterialApp.router(
      title: 'MyCard',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Localization
      supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Routing
      routerConfig: ref.watch(routerProvider),

      // Debug banner
      debugShowCheckedModeBanner: false,
    ),
  );
}
