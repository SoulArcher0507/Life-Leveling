import 'package:flutter/material.dart';
import 'package:life_leveling/widgets/custom_bottom_navigation_bar.dart';
import 'package:life_leveling/pages/dashboard/dashboard_page.dart';

import 'package:life_leveling/pages/quests/quests_page.dart';
import 'package:life_leveling/pages/settings/settings_page.dart';
// import 'package:tuo_progetto/pages/progetti/progetti_page.dart';
// import 'package:tuo_progetto/pages/grafici/grafici_page.dart';

class MyHomePage extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const MyHomePage({
    Key? key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // _currentIndex indica quale sezione è selezionata nella BottomNavigationBar
  int _currentIndex = 0;

  // Eventuale lista di titoli per l'AppBar
  final List<String> _titles = [
    'Dashboard',
    'Progetti',
    'Quests',
    'Grafici',
  ];

  // Lista di pagine corrispondenti alle sezioni.
  // Assicurati di creare e importare le tue vere pagine.
  final List<Widget> _pages = [
    const DashboardPage(),
    // ProgettiPage(),
    const QuestsPage(),

    // GraficiPage(),

    Center(child: Text('Progetti Page Placeholder')),
    Center(child: Text('Quests Page Placeholder')),
    Center(child: Text('Grafici Page Placeholder')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar che mostra il titolo della sezione corrente
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    currentThemeMode: widget.currentThemeMode,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      // Corpo della pagina -> widget corrispondente all’indice selezionato
      body: _pages[_currentIndex],

      // BottomNavigationBar per passare tra le 4 sezioni
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
        setState(() {
          _currentIndex = index;
          });
        },
      ),

    );
  }
}
