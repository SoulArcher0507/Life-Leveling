// lib/pages/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/pages/quests/quests_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Esempio di dati utente
  final String userName = 'John Doe';
  final int currentLevel = 5;
  final double currentXP = 120.0;
  final double requiredXP = 200.0;
  final String userClass = 'Shadow Monarch';
  final String userAbilities = 'Dominion of Shadows, Enhanced Strength...';

  // Esempio di quest
  // In un progetto reale, potresti recuperarli da un DB / Service.
  final List<QuestData> allQuests = [
    QuestData(
      title: 'Progetto Universitario',
      deadline: DateTime(2025, 5, 10),
      isDaily: false,
    ),
    QuestData(
      title: 'Refactoring App Flutter',
      deadline: DateTime(2025, 5, 15),
      isDaily: false,
    ),
    QuestData(
      title: 'Workout mattutino',
      deadline: DateTime.now(),
      isDaily: true,
    ),
    QuestData(
      title: 'Lavare i denti',
      deadline: DateTime.now(),
      isDaily: true,
    ),
    QuestData(
      title: 'Studiare Inglese',
      deadline: DateTime(2025, 4, 15),
      isDaily: false,
    ),
    QuestData(
      title: 'Pulire la stanza',
      deadline: DateTime.now(),
      isDaily: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 1) Separiamo le quest in highPriority (non giornaliere) e daily (giornaliere)
    final highPriorityQuests = allQuests.where((q) => !q.isDaily).toList();
    final dailyQuests = allQuests.where((q) => q.isDaily).toList();

    // 2) Ordiniamo le highPriority in base alla scadenza
    highPriorityQuests.sort((a, b) => a.deadline.compareTo(b.deadline));
    // Le daily di solito hanno scadenza "oggi" o simile, ma se vuoi puoi ordinarle
    dailyQuests.sort((a, b) => a.deadline.compareTo(b.deadline));

    // 3) Mostriamo solo le prime 3 per la dashboard
    final top3HighPriority = highPriorityQuests.length > 3
        ? highPriorityQuests.sublist(0, 3)
        : highPriorityQuests;

    final top3Daily = dailyQuests.length > 3
        ? dailyQuests.sublist(0, 3)
        : dailyQuests;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header utente: cliccando su livello si aprono dettagli (non mostrato qui) ---
            _buildUserHeader(
              context: context,
              userName: userName,
              currentLevel: currentLevel,
              currentXP: currentXP,
              requiredXP: requiredXP,
              userClass: userClass,
              userAbilities: userAbilities,
            ),
            const SizedBox(height: 24.0),

            // --- Gruppo cliccabile: Quest ad Alta Priorità (solo 3 in dashboard) ---
            InkWell(
              onTap: () {
                // Cliccando il titolo/blocco, apri la pagina Quests con questType = highPriority
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
                      // Se vuoi aprire i dettagli di una specifica quest
                      // Navigator.push(...);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // --- Gruppo cliccabile: Quest Giornaliere (solo 3 in dashboard) ---
            InkWell(
              onTap: () {
                // Cliccando il titolo/blocco, apri la pagina Quests con questType = daily
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
                      // Se vuoi aprire i dettagli di una specifica quest
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

  // Widget helper per l'header dell'utente
  Widget _buildUserHeader({
    required BuildContext context,
    required String userName,
    required int currentLevel,
    required double currentXP,
    required double requiredXP,
    required String userClass,
    required String userAbilities,
  }) {
    final double xpPercentage = (currentXP / requiredXP).clamp(0.0, 1.0);

    return InkWell(
      onTap: () {
        // Apri pagina con dettagli livello (non mostrato in questo snippet)
        // Navigator.push(context, MaterialPageRoute(...));
      },
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper per mostrare la lista di quest (massimo 3 in Dashboard)
  Widget _buildQuestList({
    required List<QuestData> quests,
    required Function(QuestData quest) onQuestTap,
  }) {
    return Column(
      children: quests.map((quest) {
        return InkWell(
          onTap: () => onQuestTap(quest),
          child: Card(
            elevation: 2.0,
            child: ListTile(
              title: Text(quest.title),
              subtitle: quest.isDaily
                  ? const Text('Giornaliera')
                  : Text('Scadenza: ${quest.deadline.toLocal()}'),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        );
      }).toList(),
    );
  }
}
