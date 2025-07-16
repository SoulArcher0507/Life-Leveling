import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyStats {
  final DateTime date;
  int questsCompleted;
  double xpGained;
  int fatigue;

  DailyStats({
    required this.date,
    this.questsCompleted = 0,
    this.xpGained = 0,
    this.fatigue = 0,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] as String),
      questsCompleted: json['questsCompleted'] ?? 0,
      xpGained: (json['xpGained'] ?? 0).toDouble(),
      fatigue: json['fatigue'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'questsCompleted': questsCompleted,
      'xpGained': xpGained,
      'fatigue': fatigue,
    };
  }
}

class StatsService {
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  static const String _prefsKey = 'daily_stats';

  final Map<String, DailyStats> _stats = {};

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List decoded = json.decode(jsonString);
      _stats.clear();
      for (var item in decoded) {
        final stat = DailyStats.fromJson(item);
        _stats[_dateKey(stat.date)] = stat;
      }
    }
  }

  String _dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.toIso8601String();
  }

  DailyStats _getStatsFor(DateTime date) {
    final key = _dateKey(date);
    if (!_stats.containsKey(key)) {
      _stats[key] = DailyStats(date: DateTime(date.year, date.month, date.day));
    }
    return _stats[key]!;
  }

  DailyStats getStats(DateTime date) {
    final key = _dateKey(date);
    return _stats[key] ?? DailyStats(date: DateTime(date.year, date.month, date.day));
  }

  Future<void> recordQuestCompleted({required double xp, required int fatigue}) async {
    final now = DateTime.now();
    final stat = _getStatsFor(now);
    stat.questsCompleted += 1;
    stat.xpGained += xp;
    stat.fatigue += fatigue;
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _stats.values.map((s) => s.toJson()).toList();
    await prefs.setString(_prefsKey, json.encode(data));
  }
}
