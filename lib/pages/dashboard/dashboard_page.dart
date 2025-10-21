import 'package:flutter/material.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/pages/quests/quests_page.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/pages/dashboard/livello_dettagli_page.dart';
import 'package:life_leveling/pages/quests/quest_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/services/fatigue_service.dart';
import 'package:life_leveling/services/level_service.dart';
import 'package:life_leveling/services/stats_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Dati utente
  final String userName = 'Corrado Enea Crevatin';
  DateTime _statsDate = DateTime.now();

  bool _isOverdue(QuestData quest) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final questDate =
        DateTime(quest.deadline.year, quest.deadline.month, quest.deadline.day);
    return questDate.isBefore(today);
  }

  /// Returns true if two dates share the same calendar day (year, month, day).
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  

  @override
  Widget build(BuildContext context) {
    // Retrieve all quests from service
    final allQuests = QuestService().allQuests;

    // Filter quests by the selected `_statsDate`. A quest appears in the
    // dashboard lists only if its deadline falls on the same day as
    // `_statsDate`. Daily quests use their deadline date even if they
    // repeat weekly.
    List<QuestData> highPriorityQuests = allQuests
        .where((q) => !q.isDaily && _isSameDay(q.deadline, _statsDate))
        .toList();
    List<QuestData> dailyQuests = allQuests
        .where((q) => q.isDaily && _isSameDay(q.deadline, _statsDate))
        .toList();

    // Sort by deadline within the day
    highPriorityQuests.sort((a, b) => a.deadline.compareTo(b.deadline));
    dailyQuests.sort((a, b) => a.deadline.compareTo(b.deadline));

    // Limit to top three for dashboard preview
    final top3HighPriority = highPriorityQuests.length > 3
        ? highPriorityQuests.sublist(0, 3)
        : highPriorityQuests;
    final top3Daily = dailyQuests.length > 3
        ? dailyQuests.sublist(0, 3)
        : dailyQuests;

    final levelService = LevelService();
    final currentLevel = levelService.level;
    final currentXP = levelService.xp;
    final requiredXP = levelService.requiredXp;
    final userClass = levelService.currentClass.name;
    final userAbilities = levelService.currentClass.abilities.join(', ');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Sommario e statistiche giornaliere ---
            _buildSummaryStatsCard(
              context: context,
              userName: userName,
              currentLevel: currentLevel,
              currentXP: currentXP,
              requiredXP: requiredXP,
              userClass: userClass,
              userAbilities: userAbilities,
            ),
            const SizedBox(height: 24.0),

            // --- Box Quest ad Alta Priorità ---
            _buildDashboardCard(
              onTap: () {
                // When tapping the high priority box, navigate to the
                // filtered quests page for the currently selected date.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestsPage(
                      questType: QuestType.highPriority,
                      initialDate: _statsDate,
                    ),
                  ),
                );
              },

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'High Priority Quests',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8.0),
                  _buildQuestList(
                    quests: top3HighPriority,
                    onQuestTap: (quest) {
                      // Clic su una singola quest
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // --- Box Quest Giornaliere ---
            _buildDashboardCard(
              onTap: () {
                // Navigate to daily quests page for the currently selected date.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestsPage(
                      questType: QuestType.daily,
                      initialDate: _statsDate,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Quests',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8.0),
                  _buildQuestList(
                    quests: top3Daily,
                    onQuestTap: (quest) {
                      // Clic su una singola quest
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper per costruire un "box" in stile Card con lo stesso design
  /// Se `onTap` è non nullo, avvolgiamo il Card in un InkWell, così l'intero box è cliccabile.
  Widget _buildDashboardCard({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4.0,
      clipBehavior: Clip.antiAlias, // consente di avere la ripple effect su tutto il card se cliccato
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSummaryStatsCard({
    required BuildContext context,
    required String userName,
    required int currentLevel,
    required double currentXP,
    required double requiredXP,
    required String userClass,
    required String userAbilities,
  }) {
    final stats = StatsService().getStats(_statsDate);
    return _buildDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _statsDate = _statsDate.subtract(const Duration(days: 1));
                  });
                },
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(_statsDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    _statsDate = _statsDate.add(const Duration(days: 1));
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildUserHeader(
            context: context,
            userName: userName,
            currentLevel: currentLevel,
            currentXP: currentXP,
            requiredXP: requiredXP,
            userClass: userClass,
            userAbilities: userAbilities,
            dailyFatigue: stats.fatigue,
          ),
          const SizedBox(height: 16),
          Text(
            'Quests completed: ${stats.questsCompleted}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'XP gained: ${stats.xpGained.toInt()}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Fatigue: ${stats.fatigue}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          // Display the current streak and freeze status.  The streak
          // increments when at least 60% of the daily XP goal is met and
          // resets otherwise (unless a freeze is available).  Completing all
          // quests grants a freeze for the next day.
          Text(
            'Streak: ${StatsService().currentStreak} day${StatsService().currentStreak == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Streak freeze: ${StatsService().hasStreakFreeze ? 'Available' : 'None'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // ----- Header con livello, XP, classe, abilità -----
  Widget _buildUserHeader({
    required BuildContext context,
    required String userName,
    required int currentLevel,
    required double currentXP,
    required double requiredXP,
    required String userClass,
    required String userAbilities,
    required int dailyFatigue,
  }) {
    final double xpPercentage = (currentXP / requiredXP).clamp(0.0, 1.0);

    return InkWell(
      // Se vuoi rendere l'header cliccabile anche separatamente dal card, aggiungi onTap qui
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LivelloDettagliPage(
              userName: userName,
              currentLevel: currentLevel,
              currentXP: currentXP,
              requiredXP: requiredXP,
              userClass: userClass,
              userAbilities: userAbilities,
              dailyFatigue: dailyFatigue,
            ),
          ),
        );

      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome e livello
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                userName,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Level $currentLevel',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // XP bar
          LinearProgressIndicator(
            value: xpPercentage,
            minHeight: 8.0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8.0),

          // XP numeric
          Text(
            '${currentXP.toInt()} / ${requiredXP.toInt()} XP',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8.0),

          // Classe e abilità
          Text(
            'Class: $userClass',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Abilities: $userAbilities',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4.0),
          Text(
            "Today's fatigue: $dailyFatigue/100",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dailyFatigue > 100
                      ? Colors.red
                      : dailyFatigue > 50
                          ? Colors.orange
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
          ),
        ],
      ),
    );
  }

  // ----- Lista di quest (max 3 in Dashboard) -----
  Widget _buildQuestList({
  required List<QuestData> quests,
  required Function(QuestData quest) onQuestTap,
}) {
    if (quests.isEmpty) {
      return Text(
        'No quests found for this day',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

  return Column(
      children: quests.map((quest) {
        return InkWell(
          onTap: () async {
            final deleted = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuestDetailsPage(quest: quest),
              ),
            );
            if (deleted == true) setState(() {});
          },
          child: Card(
            elevation: 2.0,
            child: ListTile(
              title: Text(
                quest.title,
                style: TextStyle(color: _isOverdue(quest) ? Colors.red : null),
              ),
              subtitle: quest.isDaily
                  ? Text(
                      'Daily',
                      style:
                          TextStyle(color: _isOverdue(quest) ? Colors.red : null),
                    )
                  : Text(
                      "Due: ${DateFormat('dd/MM/yyyy').format(quest.deadline)}${quest.deadline.hour != 0 || quest.deadline.minute != 0 ? ' ${DateFormat('HH:mm').format(quest.deadline)}' : ''}",
                      style:
                          TextStyle(color: _isOverdue(quest) ? Colors.red : null),
                    ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        );
      }).toList(),
    );
  }
}
