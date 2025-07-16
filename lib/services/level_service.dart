import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_leveling/models/class_model.dart';
import 'package:life_leveling/classes/example_classes.dart';

class LevelService {
  static final LevelService _instance = LevelService._internal();
  factory LevelService() => _instance;
  LevelService._internal();

  static const String _prefsKey = 'level_data';

  int _level = 1;
  double _xp = 0;
  int _classIndex = 0;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final data = json.decode(jsonString);
      _level = data['level'] ?? 1;
      _xp = (data['xp'] ?? 0).toDouble();
      _classIndex = data['classIndex'] ?? 0;
    }
  }

  int get level => _level;
  double get xp => _xp;
  LevelClass get currentClass => exampleClasses[_classIndex];
  double get requiredXp => _requiredXpForLevel(_level);

  Future<void> addXp(double amount) async {
    _xp += amount;
    while (_xp >= requiredXp) {
      _xp -= requiredXp;
      _level++;
      _checkClassUpgrade();
    }
    await _save();
  }

  double _requiredXpForLevel(int lvl) {
    const double baseXp = 100;
    const double growth = 1.5;
    return baseXp * pow(growth, lvl - 1);
  }

  void _checkClassUpgrade() {
    if (_classIndex + 1 < exampleClasses.length) {
      final nextClass = exampleClasses[_classIndex + 1];
      if (_level >= nextClass.requiredLevel) {
        _classIndex++;
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode({
      'level': _level,
      'xp': _xp,
      'classIndex': _classIndex,
    });
    await prefs.setString(_prefsKey, data);
  }
}
