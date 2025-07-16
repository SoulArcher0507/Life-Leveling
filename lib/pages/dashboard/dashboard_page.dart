import 'package:flutter/material.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/pages/quests/quests_page.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/pages/dashboard/livello_dettagli_page.dart';
import 'package:life_leveling/pages/quests/quest_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/services/fatigue_service.dart';
import 'package:life_leveling/services/level_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Dati utente
  final String userName = 'Corrado Enea Crevatin';

  bool _isOverdue(QuestData quest) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final questDate =
        DateTime(quest.deadline.year, quest.deadline.month, quest.deadline.day);
    return questDate.isBefore(today);
  }

  

  @override
  Widget build(BuildContext context) {
    // Elenco delle quest dal servizio
    final allQuests = QuestService().allQuests;

    // Separiamo le quest in alta priorità vs giornaliere
    final highPriorityQuests = allQuests.where((q) => !q.isDaily).toList();
    final dailyQuests = allQuests.where((q) => q.isDaily).toList();

    // Ordiniamo
    highPriorityQuests.sort((a, b) => a.deadline.compareTo(b.deadline));
    dailyQuests.sort((a, b) => a.deadline.compareTo(b.deadline));

    // Mostriamo 3 e 3
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
            // --- Box Livello/XP Utente ---
            _buildDashboardCard(
              // Per uniformare lo stile, usiamo Card con Padding
              child: _buildUserHeader(
                context: context,
                userName: userName,
                currentLevel: currentLevel,
                currentXP: currentXP,
                requiredXP: requiredXP,
                userClass: userClass,
                userAbilities: userAbilities,
                dailyFatigue: FatigueService().fatigue,
              ),
            ),
            const SizedBox(height: 24.0),

            // --- Box Quest ad Alta Priorità ---
            _buildDashboardCard(
              onTap: () {
                // Clic sull'intero box
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestsPage(
                      questType: QuestType.highPriority,
                    ),
                  ),
                );
              },

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quest ad Alta Priorità',
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestsPage(
                      questType: QuestType.daily,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quest Giornaliere',
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
      clipBehavior: Clip
          .antiAlias, // consente di avere la ripple effect su tutto il card se cliccato
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
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
                'Livello $currentLevel',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // Barra XP
          LinearProgressIndicator(
            value: xpPercentage,
            minHeight: 8.0,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
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
            'Classe: $userClass',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Abilità: $userAbilities',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Fatica odierna: $dailyFatigue/100',
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
        'Nessuna quest trovata per questo giorno',
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
                      'Giornaliera',
                      style:
                          TextStyle(color: _isOverdue(quest) ? Colors.red : null),
                    )
                  : Text(
                      "Scadenza: ${DateFormat('dd/MM/yyyy').format(quest.deadline)}${quest.deadline.hour != 0 || quest.deadline.minute != 0 ? ' ${DateFormat('HH:mm').format(quest.deadline)}' : ''}",
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
