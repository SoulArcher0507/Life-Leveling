import 'package:flutter/material.dart';
// import 'package:tuo_progetto/theme/solo_leveling_theme.dart';
// import 'package:life_leveling/routes/app_routes.dart';
// import 'package:tuo_progetto/pages/settings/settings_page.dart';
import 'package:life_leveling/pages/home/home_page.dart';
import 'package:life_leveling/services/quest_service.dart';

/*
  main.dart è il punto di ingresso dell’app.
  Gestisce il MaterialApp, il tema e la home iniziale.
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carichiamo i dati delle quest prima di avviare l'app
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

      // Un esempio di titolo dell’app (facoltativo)
      title: 'Solo Leveling App',

      // Se hai creato un tema dedicato in solo_leveling_theme.dart, puoi sostituire ThemeData con il tuo:
      // theme: SoloLevelingTheme.lightTheme,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // Puoi usare named routes oppure impostare una home "fissa".
      // Se preferisci le rotte, abilita e definisci routes: AppRoutes.getRoutes(),
      // e usa initialRoute: AppRoutes.dashboard, ad esempio.
      home: const MyHomePage(),

      // Esempio di rotte, se vuoi usare named routes in futuro:
      // routes: {
      //   '/settings': (context) => const SettingsPage(),
      // },
    );
  }
}
