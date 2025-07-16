import 'package:flutter/material.dart';

class Workspace {
  final String name;
  final List<WorkspaceFolder> folders;
  final List<Board> boards;

  Workspace({
    required this.name,
    this.folders = const [],
    this.boards = const [],
  });
}

class WorkspaceFolder {
  final String name;
  final List<WorkspaceFolder> subFolders;
  final List<Board> boards;

  WorkspaceFolder({
    required this.name,
    this.subFolders = const [],
    this.boards = const [],
  });
}

class Board {
  final String name;
  final List<String> columns;
  final List<BoardGroup> groups;

  Board({
    required this.name,
    this.columns = const [],
    this.groups = const [],
  });
}

class BoardGroup {
  final String name;
  final Color color;
  final List<BoardItem> items;

  BoardGroup({
    required this.name,
    required this.color,
    this.items = const [],
  });
}

class BoardItem {
  final String title;
  final List<String> values;
  final List<BoardItem> subItems;

  BoardItem({
    required this.title,
    this.values = const [],
    this.subItems = const [],
  });
}
