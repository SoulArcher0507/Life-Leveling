import 'package:flutter/material.dart';
import 'package:life_leveling/widgets/custom_bottom_navigation_bar.dart';
// import 'package:tuo_progetto/pages/dashboard/dashboard_page.dart';
// import 'package:tuo_progetto/pages/progetti/progetti_page.dart';
// import 'package:tuo_progetto/pages/quests/quests_page.dart';
// import 'package:tuo_progetto/pages/grafici/grafici_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

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
  final List<Widget> _pages = const [
    // DashboardPage(),
    // ProgettiPage(),
    // QuestsPage(),
    // GraficiPage(),
    // Per ora metto segnaposto
    Center(child: Text('Dashboard Page Placeholder')),
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
              // Se hai definito la SettingsPage come route, naviga così:
              // Navigator.pushNamed(context, '/settings');
              // Altrimenti, naviga a un widget inline:
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const SettingsPage()),
              // );
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
