import 'package:flutter/material.dart';

class Destination {
  const Destination(this.icon, this.label);
  final IconData icon;
  final String label;
}

const List<Destination> destinations = <Destination>[
  Destination(Icons.home, 'HomePage'),
  Destination(Icons.task, 'Tasks'),
  Destination(Icons.alarm, 'Memo'),
  Destination(Icons.auto_graph, 'Grafico'),
];
