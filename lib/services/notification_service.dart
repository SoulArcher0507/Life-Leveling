import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/models/quest_model.dart';

/// A service responsible for scheduling local notifications for the day's
/// quests.  It schedules a morning summary, a midday reminder and hourly
/// urgent reminders in the evening.  The service must be initialised before
/// use and uses the `timezone` package to ensure notifications fire at the
/// correct local time.
class NotificationService {
  // Singleton boilerplate
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialise the notification plugin and time zone data.  This method
  /// should be called once, ideally at app start.  Calling it multiple
  /// times has no effect.
  Future<void> init() async {
    if (_initialized) return;
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
    // Set the location to Europe/Rome to respect the user's timezone
    tz.setLocalLocation(tz.getLocation('Europe/Rome'));
    _initialized = true;
  }

  /// Schedule the morning, midday and evening notifications for the current
  /// day.  Existing notifications are cancelled prior to scheduling new
  /// ones.  This method should be invoked whenever the set of quests
  /// changes so that notifications remain up to date.
  Future<void> scheduleDailyNotifications() async {
    await init();
    // Cancel previous notifications to avoid duplicates
    await _flutterLocalNotificationsPlugin.cancelAll();

    final List<QuestData> todayQuests = _getQuestsForDate(DateTime.now());
    // Morning summary at 08:00
    await _scheduleNotification(
      id: 1,
      hour: 8,
      minute: 0,
      title: 'Today\'s quests',
      body: _buildQuestBody(todayQuests),
      channelId: 'morning_channel',
      channelName: 'Morning Notifications',
      importance: Importance.high,
    );

    // Midday reminder at 14:00 listing incomplete quests
    await _scheduleNotification(
      id: 2,
      hour: 14,
      minute: 0,
      title: 'Remaining quests',
      body: _buildQuestBody(todayQuests),
      channelId: 'midday_channel',
      channelName: 'Midday Notifications',
      importance: Importance.high,
    );

    // Hourly urgent reminders from 20:00 to 23:00 for any quests left
    for (int h = 20; h <= 23; h++) {
      final id = 100 + h; // unique id for each hour
      await _scheduleNotification(
        id: id,
        hour: h,
        minute: 0,
        title: 'Urgent quests remaining',
        body: _buildQuestBody(todayQuests),
        channelId: 'urgent_channel',
        channelName: 'Urgent Notifications',
        importance: Importance.max,
      );
    }
  }

  /// Schedules an individual notification at the specified hour/minute of the
  /// current day.  The body and title can be customised.  Notifications
  /// scheduled in the past will be delivered the next day.
  Future<void> _scheduleNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    Importance importance = Importance.defaultImportance,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // If the scheduled time has already passed for today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notifications for quests',
      importance: importance,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
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