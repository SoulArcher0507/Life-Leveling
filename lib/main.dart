import 'package:flutter/material.dart';
// import 'package:tuo_progetto/theme/solo_leveling_theme.dart'; 
// (Quando avrai creato il file del tema, scommenta e usa il tuo tema personalizzato)

// import 'package:tuo_progetto/routes/app_routes.dart'; 
// (Quando avrai creato il file delle rotte, scommenta questa importazione)

void main() {
  // La funzione main è il punto di ingresso dell'app: richiama runApp
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // MyApp è il widget root dell'applicazione
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Qui costruiamo il MaterialApp, il "contenitore" di base dell'app
    return MaterialApp(
      // debugShowCheckedModeBanner serve a nascondere il banner "DEBUG" in alto a destra
      debugShowCheckedModeBanner: false,

      // Se hai già creato un tema in solo_leveling_theme.dart, qui potresti usare:
      // theme: SoloLevelingTheme.lightTheme, 
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        // Per iniziare, usiamo un theme basico, poi lo personalizzi con il tuo file 'solo_leveling_theme.dart'
      ),

      // initialRoute definisce la prima pagina che l'app aprirà
      // In futuro, puoi usare "AppRoutes.dashboard" o simili
      initialRoute: '/',

      // Le route dell'app. In un progetto più grande le estraiamo in app_routes.dart
      routes: {
        '/': (context) => const HomePage(),
        // '/dashboard': (context) => const DashboardPage(),
        // '/progetti': (context) => const ProgettiPage(),
        // etc...
      },
    );
  }
}

class HomePage extends StatelessWidget {
  // Questa pagina è solo un placeholder: sostituiscila con la Dashboard
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Semplice scaffold con un AppBar e un testo al centro
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
