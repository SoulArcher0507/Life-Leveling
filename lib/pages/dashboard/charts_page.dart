import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/services/stats_service.dart';

/// A page that displays charts summarising experience (XP) and fatigue
/// statistics collected by the app.  The charts page provides a weekly
/// overview of XP and fatigue and a monthly breakdown of XP.  Charts are
/// rendered with simple bar graphs built from basic Flutter widgets so
/// that no external charting dependencies are required.
class ChartsPage extends StatefulWidget {
  const ChartsPage({Key? key}) : super(key: key);

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

/// State for [ChartsPage] that allows navigating between weeks and months.  The
/// current week and month can be adjusted using previous/next buttons,
/// re‑rendering the charts accordingly.
class _ChartsPageState extends State<ChartsPage> {
  // Tracks the first day (Monday) of the currently selected week.
  late DateTime _selectedWeekStart;
  // Tracks the first day of the currently selected month.
  late DateTime _selectedMonthStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Initialise the week start to the Monday of the current week.
    _selectedWeekStart = _startOfWeek(now);
    // Initialise the month start to the first day of the current month.
    _selectedMonthStart = DateTime(now.year, now.month, 1);
  }

  /// Returns the Monday of the week containing [date].  Assumes Monday is
  /// the first day of the week.
  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Adjusts the selected week by [offset] weeks.  For example, calling
  /// `_changeWeek(-1)` moves to the previous week; `_changeWeek(1)` moves
  /// forward by one week.
  void _changeWeek(int offset) {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(Duration(days: offset * 7));
    });
  }

  /// Adjusts the selected month by [offset] months.  Passing -1 moves to
  /// the previous month, 1 moves to the next month, etc.  Day of month
  /// always becomes the first of the month.
  void _changeMonth(int offset) {
    final int year = _selectedMonthStart.year;
    final int month = _selectedMonthStart.month;
    final DateTime newMonth = DateTime(year, month + offset, 1);
    setState(() {
      _selectedMonthStart = newMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final StatsService statsService = StatsService();
    // Build weekly stats based on the selected week start.
    final List<DailyStats> weeklyStats = List<DailyStats>.generate(7, (index) {
      final date = _selectedWeekStart.add(Duration(days: index));
      return statsService.getStats(date);
    });
    final double maxWeeklyXp = weeklyStats.isNotEmpty
        ? weeklyStats.map((s) => s.xpGained).reduce((a, b) => a > b ? a : b)
        : 0;
    final double maxWeeklyFatigue = weeklyStats.isNotEmpty
        ? weeklyStats.map((s) => s.fatigue.toDouble()).reduce((a, b) => a > b ? a : b)
        : 0;

    // Build monthly stats based on the selected month.
    final int daysInMonth = DateTime(
            _selectedMonthStart.year, _selectedMonthStart.month + 1, 0)
        .day;
    final List<DailyStats> monthlyStats = List<DailyStats>.generate(daysInMonth, (index) {
      final date = _selectedMonthStart.add(Duration(days: index));
      return statsService.getStats(date);
    });
    final double maxMonthlyXp = monthlyStats.isNotEmpty
        ? monthlyStats.map((s) => s.xpGained).reduce((a, b) => a > b ? a : b)
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with navigation for the weekly chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly XP & Fatigue',
                  style: Theme.of(context).textTheme.bodyLarge),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous week',
                    onPressed: () => _changeWeek(-1),
                  ),
                  Text(
                    _weekRangeLabel(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next week',
                    onPressed: () => _changeWeek(1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildWeeklyChart(weeklyStats, maxWeeklyXp, maxWeeklyFatigue),
          const SizedBox(height: 24),
          // Section header with navigation for the monthly chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly XP', style: Theme.of(context).textTheme.bodyLarge),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous month',
                    onPressed: () => _changeMonth(-1),
                  ),
                  Text(
                    DateFormat.yMMM().format(_selectedMonthStart),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next month',
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMonthlyChart(monthlyStats, maxMonthlyXp),
          const SizedBox(height: 24),
          Text('Quests Completed', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          _buildQuestCompletionChart(weeklyStats),
        ],
      ),
    );
  }

  /// Formats the currently selected week range as "dd MMM - dd MMM".
  String _weekRangeLabel() {
    final DateTime endOfWeek = _selectedWeekStart.add(const Duration(days: 6));
    final DateFormat df = DateFormat.MMMd();
    return '${df.format(_selectedWeekStart)} - ${df.format(endOfWeek)}';
  }

  /// Builds a simple stacked bar chart to compare XP and fatigue for each
  /// day of the current week.  Each day shows a blue bar (XP) on top of
  /// a pink bar (fatigue), scaled relative to the maximum values seen
  /// during the week.  Day names are abbreviated to three letters.
  Widget _buildWeeklyChart(List<DailyStats> stats, double maxXp, double maxFatigue) {
    const double chartHeight = 120;
    return SizedBox(
      height: chartHeight + 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final DailyStats stat in stats)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // XP bar
                  Container(
                    height: maxXp > 0 ? (stat.xpGained / maxXp) * chartHeight : 0,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Fatigue bar
                  Container(
                    height: maxFatigue > 0 ? (stat.fatigue / maxFatigue) * chartHeight : 0,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(DateFormat.E().format(stat.date).substring(0, 3), style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a horizontal bar chart for the current month where each bar
  /// represents the XP gained on that day.  The chart scrolls horizontally
  /// if there are many days in the month.  Days are labelled with the
  /// numeric day of the month.
  Widget _buildMonthlyChart(List<DailyStats> stats, double maxXp) {
    const double chartHeight = 120;
    return SizedBox(
      height: chartHeight + 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stats.length,
        itemBuilder: (context, int index) {
          final DailyStats stat = stats[index];
          final double barHeight = maxXp > 0 ? (stat.xpGained / maxXp) * chartHeight : 0;
          return Container(
            width: 20,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${stat.date.day}', style: const TextStyle(fontSize: 8)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a bar chart showing the number of quests completed for each
  /// day of the current week.  This chart is rendered below the other
  /// charts as a simple representation of how many tasks were finished.
  Widget _buildQuestCompletionChart(List<DailyStats> weeklyStats) {
    const double chartHeight = 100;
    final int maxCompleted = weeklyStats.isNotEmpty
        ? weeklyStats.map((s) => s.questsCompleted).reduce((a, b) => a > b ? a : b)
        : 0;
    return SizedBox(
      height: chartHeight + 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final stat in weeklyStats)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: maxCompleted > 0
                        ? (stat.questsCompleted / maxCompleted) * chartHeight
                        : 0,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(DateFormat.E().format(stat.date).substring(0, 3), style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}