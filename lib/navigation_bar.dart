import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          actions: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: (){
                scaffoldKey.currentState!.openDrawer();
              },
            )
          ],
        ),
    );
  }
}