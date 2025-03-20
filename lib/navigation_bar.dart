import 'package:flutter/material.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({Key? key}) : super(key: key);

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  bool _isExpanded = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: _isExpanded,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
      ),
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.checklist),
          label: Text('Task'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.add_alert),
          label: Text('Promemoria'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.auto_graph),
          label: Text('Grafico'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Impostazioni'),
        ),
      ],
    );
  }
}
