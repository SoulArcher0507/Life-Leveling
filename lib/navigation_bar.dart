import 'package:flutter/material.dart';

class NavigationDrawer extends StatelessWidget {
  final Function(int) onItemSelected;

  const NavigationDrawer({Key? key, required this.onItemSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => onItemSelected(0),
          ),
          ListTile(
            leading: Icon(Icons.task),
            title: Text('Tasks'),
            onTap: () => onItemSelected(1),
          ),
          ListTile(
            leading: Icon(Icons.note),
            title: Text('Memos'),
            onTap: () => onItemSelected(2),
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Graphs'),
            onTap: () => onItemSelected(3),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => onItemSelected(4),
          ),
        ],
      ),
    );
  }
}

