import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/services/stats_service.dart';

/// A page that displays charts summarising experience (XP) and fatigue
/// statistics collected by the app.  The charts page provides a weekly
/// overview of XP and fatigue and a monthly breakdown of XP.  Charts are
/// rendered with simple bar graphs built from basic Flutter widgets so
/// that no external charting dependencies are required.
class ChartsPage extends StatelessWidget {
  const ChartsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StatsService statsService = StatsService();
    final DateTime now = DateTime.now();
    // Compute the start of the current week (Monday) and gather stats for 7 days.
    final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final List<DailyStats> weeklyStats = List<DailyStats>.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return statsService.getStats(date);
    });
    // Determine maximum values to scale bar heights.
    final double maxWeeklyXp = weeklyStats.isNotEmpty
        ? weeklyStats.map((s) => s.xpGained).reduce((a, b) => a > b ? a : b)
        : 0;
    final double maxWeeklyFatigue = weeklyStats.isNotEmpty
        ? weeklyStats.map((s) => s.fatigue.toDouble()).reduce((a, b) => a > b ? a : b)
        : 0;

    // Gather stats for the current month.  Use year/month boundaries to
    // calculate the number of days in the month.  Each day has its own
    // DailyStats entry so that days with no activity still appear with
    // zero values.
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final List<DailyStats> monthlyStats = List<DailyStats>.generate(daysInMonth, (index) {
      final date = firstDayOfMonth.add(Duration(days: index));
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
          Text('Weekly XP & Fatigue', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          _buildWeeklyChart(weeklyStats, maxWeeklyXp, maxWeeklyFatigue),
          const SizedBox(height: 24),
          Text('Monthly XP', style: Theme.of(context).textTheme.bodyLarge),
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