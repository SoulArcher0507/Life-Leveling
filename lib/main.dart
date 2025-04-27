import 'package:flutter/material.dart';
// import 'package:tuo_progetto/theme/solo_leveling_theme.dart';
// import 'package:life_leveling/routes/app_routes.dart';
// import 'package:tuo_progetto/pages/settings/settings_page.dart';
import 'package:life_leveling/pages/home/home_page.dart';
import 'package:life_leveling/services/quest_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await QuestService().init();

  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Rimuove il banner "debug" nell'angolo
      debugShowCheckedModeBanner: false,


      // theme: SoloLevelingTheme.lightTheme,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: const MyHomePage(),

    );
  }
}
