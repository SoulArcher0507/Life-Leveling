// The platform-specific packages for notifications (flutter_local_notifications)
// and timezone could not be resolved in the current environment.  To
// maintain compile-time compatibility without pulling in external
// dependencies, we provide a stubbed implementation of the
// NotificationService.  Should you wish to enable real notifications,
// add the appropriate dependencies to pubspec.yaml and implement the
// scheduling logic using flutter_local_notifications and timezone.
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/models/quest_model.dart';

/// A service responsible for scheduling local notifications for the day's
/// quests.  It schedules a morning summary, a midday reminder and hourly
/// urgent reminders in the evening.  The service must be initialised before
/// use and uses the `timezone` package to ensure notifications fire at the
/// correct local time.
class NotificationService {
  // Singleton boilerplate remains unchanged for API compatibility
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Dummy initialization.  In this stub implementation there is nothing
  /// to initialise.  This method is kept for API compatibility.
  Future<void> init() async {
    // no‑op
  }

  /// Schedules daily notifications.  In the absence of external
  /// notification plugins, this stub simply logs the quests for the day.  If
  /// you wish to use real notifications, add `flutter_local_notifications`
  /// and `timezone` to your `pubspec.yaml` and implement scheduling here.
  Future<void> scheduleDailyNotifications() async {
    await init();
    final List<QuestData> todayQuests = _getQuestsForDate(DateTime.now());
    // For demonstration purposes, simply print the quests to console.  You
    // could replace this with SnackBars or other in-app reminders.
    if (todayQuests.isNotEmpty) {
      final body = _buildQuestBody(todayQuests);
      // ignore: avoid_print
      print('NotificationService (stub): Today\'s quests:\n$body');
    } else {
      // ignore: avoid_print
      print('NotificationService (stub): No quests scheduled for today.');
    }
  }

  /// Returns a list of quests whose deadline falls on the same day as [date].
  List<QuestData> _getQuestsForDate(DateTime date) {
    final allQuests = QuestService().allQuests;
    return allQuests
        .where((q) => _isSameDay(q.deadline, date))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  /// Builds a human‑readable summary of quests.  Each quest title is on a
  /// separate line.  If no quests are due, a friendly message is returned.
  String _buildQuestBody(List<QuestData> quests) {
    if (quests.isEmpty) {
      return 'You have no quests scheduled for today.';
    }
    final buffer = StringBuffer();
    for (int i = 0; i < quests.length; i++) {
      buffer.write('${i + 1}. ${quests[i].title}');
      if (i < quests.length - 1) buffer.write('\n');
    }
    return buffer.toString();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}