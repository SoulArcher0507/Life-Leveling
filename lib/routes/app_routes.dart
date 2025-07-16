import 'package:flutter/material.dart';
// import 'package:life_leveling/pages/dashboard/dashboard_page.dart';
import 'package:life_leveling/pages/progetti/progetti_page.dart';
import 'package:life_leveling/pages/quests/quests_page.dart';
// import 'package:tuo_progetto/pages/grafici/grafici_page.dart';
// import 'package:tuo_progetto/pages/settings/settings_page.dart';
// etc...

class AppRoutes {
  // Definiamo le stringhe che identificano le rotte, così evitiamo di scrivere
  // manualmente le stringhe e rischiare errori di digitazione.
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String progetti = '/progetti';
  static const String quests = '/quests';
  static const String grafici = '/grafici';
  static const String settings = '/settings';

  // Restituisce la mappa delle rotte per il MaterialApp
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      
      quests: (context) => const QuestsPage(),
      // dashboard: (context) => const DashboardPage(),
      progetti: (context) => const ProgettiPage(),
      // grafici: (context) => const GraficiPage(),
      // settings: (context) => const SettingsPage(),
    };
  }
}

// Esempio di HomePage, se non l’hai già definita altrove
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: const Center(
        child: Text(
          'Benvenuto nella tua app stile Solo Leveling!',
        ),
      ),
    );
  }
}
