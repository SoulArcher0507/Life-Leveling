import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  
  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<Home> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.blueAccent),
          title: Text("Prova"),
        ),
          drawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text('Drawer Header'),
                ),
                ListTile(
                  title: const Text('Dashboard'),
                  leading: Icon(Icons.home),
                  onTap: () {
                    HomePage();
                  },
                ),
                ListTile(
                  title: const Text('Item 2'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),
              ],
            ),
          )
        );
  }
}

