import 'package:flutter/material.dart';
import 'package:life_leveling/pages/home/home_page.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/services/theme_service.dart';
import 'package:life_leveling/services/fatigue_service.dart';
import 'package:life_leveling/services/level_service.dart';
import 'package:life_leveling/services/stats_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await QuestService().init();
  await FatigueService().init();
  await LevelService().init();
  await StatsService().init();
  final themeMode = await ThemeService().getThemeMode();

  runApp(MyApp(initialThemeMode: themeMode));
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const MyApp({super.key, required this.initialThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void _updateTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
    ThemeService().saveThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    //
    // Solo Leveling–inspired dark theme.  This palette takes cues from the
    // glowing blue holographic panels seen in the anime.  Deep navy
    // backgrounds provide contrast for neon accents, while cards are
    // outlined with a thin cyan border and a subtle glow.  Text is light
    // coloured for optimal readability against the dark background.
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF021227),
      cardColor: const Color(0xFF051F3E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00B8FF),
        secondary: Color(0xFF00B8FF),
        background: Color(0xFF021227),
        surface: Color(0xFF051F3E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF051F3E),
        elevation: 2,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF051F3E),
        selectedItemColor: Color(0xFF00B8FF),
        unselectedItemColor: Colors.grey,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF051F3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF00B8FF), width: 1),
        ),
        // removed const to avoid calling methods on constant color
        shadowColor: Color(0xFF00B8FF).withOpacity(0.2), // CHANGED
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF051F3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        contentTextStyle: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF021E42),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF00B8FF), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF00B8FF), width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
        bodySmall: TextStyle(fontSize: 14, color: Colors.white60),
      ),
    );

    // Solo Leveling–inspired light theme.  Light mode retains the same
    // futuristic feel but uses pale blues and whites for backgrounds and
    // panels.  Accent colours mirror the dark theme, giving the UI a
    // consistent identity across modes.
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF2F9FF),
      cardColor: const Color(0xFFE9F5FF),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0085CC),
        secondary: Color(0xFF0085CC),
        background: Color(0xFFF2F9FF),
        surface: Color(0xFFE9F5FF),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE9F5FF),
        elevation: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFE9F5FF),
        selectedItemColor: Color(0xFF0085CC),
        unselectedItemColor: Colors.grey,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFE9F5FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF0085CC), width: 1),
        ),
        // removed const to avoid calling methods on constant color
        shadowColor: Color(0xFF0085CC).withOpacity(0.15), // CHANGED
        elevation: 2,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFE9F5FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        contentTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE9F5FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF0085CC), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF0085CC), width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.black38),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        bodySmall: TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: MyHomePage(
        currentThemeMode: _themeMode,
        onThemeChanged: _updateTheme,
      ),
    );
  }
}
