import 'package:android_app/graph_page.dart';
import 'package:android_app/home_page.dart';
import 'package:android_app/memo_page.dart';
import 'package:android_app/navigation_bar.dart' as custom_nav;
import 'package:android_app/settings_page.dart';
import 'package:android_app/task_page.dart';
import 'package:flutter/material.dart';
import 'navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const MyHomePage(title: ""),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// barra laterale
class _MyHomePageState extends State<MyHomePage> {
  final int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    TaskPage(),
    MemoPage(),
    GraphPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const Home(), // Usa il widget Home con il Drawer
    );
  }
}
