import 'package:flutter/material.dart';

class Workspace {
  final String name;
  final List<WorkspaceFolder> folders;
  final List<Board> boards;

  Workspace({
    required this.name,
    List<WorkspaceFolder>? folders,
    List<Board>? boards,
  })  : folders = List<WorkspaceFolder>.from(folders ?? <WorkspaceFolder>[]),
        boards = List<Board>.from(boards ?? <Board>[]);
}

class WorkspaceFolder {
  final String name;
  final List<WorkspaceFolder> subFolders;
  final List<Board> boards;

  WorkspaceFolder({
    required this.name,
    List<WorkspaceFolder>? subFolders,
    List<Board>? boards,
  })  : subFolders =
            List<WorkspaceFolder>.from(subFolders ?? <WorkspaceFolder>[]),
        boards = List<Board>.from(boards ?? <Board>[]);
}

class Board {
  final String name;
  final List<String> columns;
  final List<BoardGroup> groups;

  Board({
    required this.name,
    List<String>? columns,
    List<BoardGroup>? groups,
  })  : columns = List<String>.from(columns ?? <String>[]),
        groups = List<BoardGroup>.from(groups ?? <BoardGroup>[]);
}

class BoardGroup {
  final String name;
  final Color color;
  final List<BoardItem> items;

  BoardGroup({
    required this.name,
    required this.color,
    List<BoardItem>? items,
  }) : items = List<BoardItem>.from(items ?? <BoardItem>[]);
}

class BoardItem {
  final String title;
  final int xp;
  final int fatigue;
  final List<String> values;
  final List<BoardItem> subItems;

  BoardItem({
    required this.title,
    this.xp = 0,
    this.fatigue = 0,
    List<String>? values,
    List<BoardItem>? subItems,
  })  : values = List<String>.from(values ?? <String>[]),
        subItems = List<BoardItem>.from(subItems ?? <BoardItem>[]);
}
