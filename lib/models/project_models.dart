import 'package:flutter/material.dart';
import 'quest_model.dart';

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

  /// Serialises the workspace into a JSON‑serialisable map.  Folders and
  /// boards are recursively serialised.
  Map<String, dynamic> toJson() => {
        'name': name,
        'folders': folders.map((f) => f.toJson()).toList(),
        'boards': boards.map((b) => b.toJson()).toList(),
      };

  /// Creates a [Workspace] from the provided JSON map.
  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      name: json['name'] as String,
      folders: (json['folders'] as List<dynamic>?)
          ?.map((e) => WorkspaceFolder.fromJson(e as Map<String, dynamic>))
          .toList(),
      boards: (json['boards'] as List<dynamic>?)
          ?.map((e) => Board.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'subFolders': subFolders.map((f) => f.toJson()).toList(),
        'boards': boards.map((b) => b.toJson()).toList(),
      };

  factory WorkspaceFolder.fromJson(Map<String, dynamic> json) {
    return WorkspaceFolder(
      name: json['name'] as String,
      subFolders: (json['subFolders'] as List<dynamic>?)
          ?.map((e) => WorkspaceFolder.fromJson(e as Map<String, dynamic>))
          .toList(),
      boards: (json['boards'] as List<dynamic>?)
          ?.map((e) => Board.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'columns': columns,
        'groups': groups.map((g) => g.toJson()).toList(),
      };

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      name: json['name'] as String,
      columns: (json['columns'] as List<dynamic>?)?.cast<String>(),
      groups: (json['groups'] as List<dynamic>?)
          ?.map((e) => BoardGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color.value,
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory BoardGroup.fromJson(Map<String, dynamic> json) {
    return BoardGroup(
      name: json['name'] as String,
      color: Color(json['color'] as int),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => BoardItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BoardItem {
  final String title;
  final int xp;
  final int fatigue;
  final List<String> values;
  final List<BoardItem> subItems;
  final QuestData? quest;

  BoardItem({
    required this.title,
    this.xp = 0,
    this.fatigue = 0,
    this.quest,
    List<String>? values,
    List<BoardItem>? subItems,
  })  : values = List<String>.from(values ?? <String>[]),
        subItems = List<BoardItem>.from(subItems ?? <BoardItem>[]);

  Map<String, dynamic> toJson() => {
        'title': title,
        'xp': xp,
        'fatigue': fatigue,
        'values': values,
        'subItems': subItems.map((i) => i.toJson()).toList(),
        // Serialize the quest if present
        'quest': quest != null ? quest!.toJson() : null,
      };

  factory BoardItem.fromJson(Map<String, dynamic> json) {
    return BoardItem(
      title: json['title'] as String,
      xp: json['xp'] ?? 0,
      fatigue: json['fatigue'] ?? 0,
      values: (json['values'] as List<dynamic>?)?.cast<String>(),
      subItems: (json['subItems'] as List<dynamic>?)
          ?.map((e) => BoardItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      quest: json['quest'] != null
          ? QuestData.fromJson(json['quest'] as Map<String, dynamic>)
          : null,
    );
  }
}
