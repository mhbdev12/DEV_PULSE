// lib/main.dart
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'widgets/app_open_ad_wrapper.dart';
import 'services/notification_service.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Notifications safely
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }

  // Initialize Google Mobile Ads SDK safely
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('AdMob initialization error: $e');
  }

  // Initialize Hive safely
  try {
    await Hive.initFlutter();
    await Hive.openBox('pulseBox');
  } catch (e) {
    debugPrint('Hive initialization error: $e');
  }

  runApp(const ProviderScope(child: DevPulseApp()));
}

class DevPulseApp extends ConsumerWidget {
  const DevPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return AppOpenAdWrapper(
      child: MaterialApp(
        title: 'Dev Pulse',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,

        // ☀️ Comprehensive Light Theme
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF1F5F9),
          primaryColor: const Color(0xFF0097A7),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0097A7),
            secondary: Color(0xFF00C853),
            surface: Colors.white,
            onSurface: Color(0xFF0F172A),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF0F172A),
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF0F172A)),
            bodyMedium: TextStyle(color: Color(0xFF475569)),
            titleLarge: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
          ),
          useMaterial3: true,
        ),

        // 🌙 Comprehensive Dark Theme
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0D14),
          primaryColor: const Color(0xFF00E5FF),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            secondary: Color(0xFF00E676),
            surface: Color(0xFF131823),
            onSurface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF131823),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF131823),
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
            titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          useMaterial3: true,
        ),

        home: const HomeScreen(),
      ),
    );
  }
}