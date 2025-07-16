import 'package:flutter/material.dart';
import 'package:life_leveling/pages/home/home_page.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/services/theme_service.dart';
import 'package:life_leveling/services/fatigue_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await QuestService().init();
  await FatigueService().init();
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: MyHomePage(
        currentThemeMode: _themeMode,
        onThemeChanged: _updateTheme,
      ),
    );
  }
}
