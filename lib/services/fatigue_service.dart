import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FatigueService {
  static final FatigueService _instance = FatigueService._internal();
  factory FatigueService() => _instance;
  FatigueService._internal();

  static const String _prefsKey = 'daily_fatigue';

  int _fatigue = 0;
  DateTime _date = DateTime.now();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final data = json.decode(jsonString);
      _fatigue = data['value'] ?? 0;
      _date = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();
    }
    _resetIfNeeded();
    await _save();
  }

  int get fatigue {
    _resetIfNeeded();
    return _fatigue;
  }

  Future<void> addFatigue(int value) async {
    _resetIfNeeded();
    _fatigue += value;
    await _save();
  }

  void _resetIfNeeded() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_date.year != today.year || _date.month != today.month || _date.day != today.day) {
      _date = today;
      _fatigue = 0;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode({'date': _date.toIso8601String(), 'value': _fatigue});
    await prefs.setString(_prefsKey, data);
  }
}
