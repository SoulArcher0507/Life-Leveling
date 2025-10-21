import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:life_leveling/models/project_models.dart';

/// A service responsible for persisting and managing the project/workspace
/// hierarchy used in the Projects page.  The data model consists of
/// Workspaces containing Boards, which in turn contain Groups of items.
/// Although groups remain in the model for compatibility, the UI can
/// choose to ignore them and present items directly.  All modifications
/// (adding/removing workspaces, boards and items) should call [save]
/// afterwards to persist changes.
class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  static const String _prefsKey = 'project_data';

  final List<Workspace> _workspaces = [];

  List<Workspace> get workspaces => _workspaces;

  /// Loads workspaces from shared preferences.  If no data is found,
  /// [sampleData] can be used to populate an initial set of workspaces.
  Future<void> init({List<Workspace>? sampleData}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List decoded = json.decode(jsonString);
      _workspaces.clear();
      for (final item in decoded) {
        _workspaces.add(Workspace.fromJson(item as Map<String, dynamic>));
      }
    } else if (sampleData != null) {
      _workspaces
        ..clear()
        ..addAll(sampleData);
      await save();
    }
  }

  /// Persists the current workspace hierarchy to SharedPreferences.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _workspaces.map((w) => w.toJson()).toList();
    await prefs.setString(_prefsKey, json.encode(data));
  }

  /// Adds a new workspace to the list.
  Future<void> addWorkspace(Workspace workspace) async {
    _workspaces.add(workspace);
    await save();
  }

  /// Removes the specified workspace and persists the change.
  Future<void> removeWorkspace(Workspace workspace) async {
    _workspaces.remove(workspace);
    await save();
  }

  /// Adds a board to the given workspace and persists the change.
  Future<void> addBoard(Workspace workspace, Board board) async {
    workspace.boards.add(board);
    await save();
  }

  /// Removes a board from the given workspace and persists the change.
  Future<void> removeBoard(Workspace workspace, Board board) async {
    workspace.boards.remove(board);
    await save();
  }

  /// Adds an item to the specified group within a board.  If the board
  /// contains no groups, a default group will be created.
  Future<void> addItem(Board board, BoardItem item, {BoardGroup? group}) async {
    BoardGroup target;
    if (board.groups.isEmpty) {
      target = BoardGroup(name: 'Default', color: Colors.grey);
      board.groups.add(target);
    } else {
      target = group ?? board.groups.first;
    }
    target.items.add(item);
    await save();
  }

  /// Removes an item from its group and persists.
  Future<void> removeItem(Board board, BoardItem item) async {
    for (final group in board.groups) {
      if (group.items.remove(item)) {
        break;
      }
    }
    await save();
  }

  /// Updates an existing item (identified by reference) with new values.
  Future<void> updateItem(Board board, BoardItem oldItem, BoardItem newItem) async {
    for (final group in board.groups) {
      final idx = group.items.indexOf(oldItem);
      if (idx != -1) {
        group.items[idx] = newItem;
        break;
      }
    }
    await save();
  }
}