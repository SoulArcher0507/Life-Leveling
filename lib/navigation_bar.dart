import 'package:flutter/material.dart';

class MyNavigationBar extends StatefulWidget {
  final ValueChanged<int> onDestinationSelected;

  const MyNavigationBar({Key? key, required this.onDestinationSelected}) : super(key: key);

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  bool _isExpanded = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1), // Bordo destro
        ),
      ),
      child: Column(
        children: [
          // Pulsante per espandere/ridurre la barra laterale con testo "Menù" a destra
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
                if (_isExpanded)
                  const Text(
                    'Menù',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          // NavigationRail
          Expanded(
            child: NavigationRail(
              extended: _isExpanded,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onDestinationSelected(index); // Notifica il cambio di indice
              },
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
            ),
          ),
        ],
      ),
    );
  }
}