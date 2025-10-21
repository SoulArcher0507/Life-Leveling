import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/models/quest_model.dart';

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

  // Keys used to persist the streak information.  The streak counts how
  // many consecutive days the user has reached at least 60% of their daily
  // XP goal.  A streak freeze allows the user to miss one day without
  // resetting the streak.  We also store the last date the streak was
  // evaluated to ensure the logic runs only once per day.
  static const String _streakKey = 'current_streak';
  static const String _freezeKey = 'has_streak_freeze';
  static const String _lastUpdateKey = 'last_update_date';

  final Map<String, DailyStats> _stats = {};

  int _currentStreak = 0;
  bool _hasStreakFreeze = false;
  DateTime? _lastUpdateDate;

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

    // Load streak state from preferences.  If keys are missing,
    // initialise to defaults.
    _currentStreak = prefs.getInt(_streakKey) ?? 0;
    _hasStreakFreeze = prefs.getBool(_freezeKey) ?? false;
    final lastDateStr = prefs.getString(_lastUpdateKey);
    if (lastDateStr != null) {
      _lastUpdateDate = DateTime.tryParse(lastDateStr);
    }

    // Evaluate the streak if the last update date is not today.  This
    // ensures streak evaluation happens at most once per day, typically
    // when the app starts.  Evaluation considers the previous day's
    // performance relative to the total XP goal.
    await _updateStreakIfNeeded();
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

  /// Returns the current streak count.  The streak increases when the user
  /// reaches at least 60% of the total XP goal for a given day.  If the
  /// user completes all quests (100% of XP goal) they earn a streak freeze.
  int get currentStreak => _currentStreak;

  /// Returns true if the user currently holds a streak freeze.  A freeze
  /// allows the user to miss one day without resetting their streak.  When
  /// used, the freeze resets to false.
  bool get hasStreakFreeze => _hasStreakFreeze;

  /// Evaluates the streak state if the last update date is before today.
  /// This method computes the user's performance for the previous day,
  /// compares it against the total XP for quests due that day, and updates
  /// the streak and freeze accordingly.  The logic is as follows:
  ///  - If the user gained at least 60% of the total XP goal yesterday, the
  ///    streak increments.  Otherwise the streak resets to zero unless a
  ///    freeze is available, in which case the freeze is consumed and the
  ///    streak remains unchanged.
  ///  - If the user completed all quests yesterday (100% of XP goal), they
  ///    receive a freeze for the next evaluation cycle.
  Future<void> _updateStreakIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);
    // If last update date is today, skip evaluation.
    if (_lastUpdateDate != null && _isSameDay(_lastUpdateDate!, todayDate)) {
      return;
    }

    // Evaluate yesterday's performance.  Only evaluate if there were quests
    // scheduled for yesterday to avoid affecting the streak on days with no
    // quests.
    final DateTime yesterdayDate = todayDate.subtract(const Duration(days: 1));
    final double totalXpGoal = _computeTotalXpForDate(yesterdayDate);
    final double gainedXp = getStats(yesterdayDate).xpGained;

    if (totalXpGoal > 0) {
      final double completionRatio = gainedXp / totalXpGoal;
      final bool reachedSixtyPercent = completionRatio >= 0.6;
      final bool completedAll = completionRatio >= 1.0;
      if (reachedSixtyPercent) {
        _currentStreak += 1;
      } else {
        if (_hasStreakFreeze) {
          // Use the freeze to maintain the streak
          _hasStreakFreeze = false;
        } else {
          _currentStreak = 0;
        }
      }
      if (completedAll) {
        _hasStreakFreeze = true;
      }
    }

    // Update the last update date to today and persist state.
    _lastUpdateDate = todayDate;
    await prefs.setInt(_streakKey, _currentStreak);
    await prefs.setBool(_freezeKey, _hasStreakFreeze);
    await prefs.setString(_lastUpdateKey, todayDate.toIso8601String());
    // Persist stats changes as well so xp/fatigue are stored.
    await _save();
  }

  /// Computes the total XP goal for all quests due on the given [date].  This
  /// helper sums the XP of both daily and high priority quests whose
  /// deadline falls on the specified day.  It uses the QuestService's
  /// internal list of quests.
  double _computeTotalXpForDate(DateTime date) {
    // Avoid circular import issues by using a late import.  QuestService is
    // only referenced here at runtime when needed.
    final quests = QuestService().allQuests;
    final List<QuestData> due = quests
        .where((q) => _isSameDay(q.deadline, date))
        .toList();
    double sum = 0;
    for (final q in due) {
      sum += q.xp.toDouble();
    }
    return sum;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
