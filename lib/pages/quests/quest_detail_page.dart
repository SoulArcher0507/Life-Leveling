import 'package:flutter/material.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/services/fatigue_service.dart';
import 'package:life_leveling/services/level_service.dart';
import 'package:life_leveling/services/stats_service.dart';
import 'package:intl/intl.dart';

class QuestDetailsPage extends StatelessWidget {
  final QuestData quest;
  const QuestDetailsPage({Key? key, required this.quest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quest.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              await FatigueService().addFatigue(quest.fatigue);
              await LevelService().addXp(quest.xp.toDouble());
              await StatsService()
                  .recordQuestCompleted(xp: quest.xp.toDouble(), fatigue: quest.fatigue);
              await QuestService().removeQuest(quest);
              Navigator.of(context).pop(true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // elimina e torna indietro
              await QuestService().removeQuest(quest);
              Navigator.of(context).pop(true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: apri dialog di modifica
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titolo: ${quest.title}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              "Scadenza: ${DateFormat('dd/MM/yyyy').format(quest.deadline)}${quest.deadline.hour != 0 || quest.deadline.minute != 0 ? ' ${DateFormat('HH:mm').format(quest.deadline)}' : ''}",
            ),
            const SizedBox(height: 8),
            Text('XP: ${quest.xp}'),
            const SizedBox(height: 8),
            Text('Fatigue: ${quest.fatigue}'),
            const SizedBox(height: 8),
            Text('Note: ${quest.notes}'),
            const SizedBox(height: 8),
            Text('Giorn.: ${quest.isDaily ? "Sì" : "No"}'),
            const SizedBox(height: 8),
            Text('Ripeti settimanale: ${quest.repeatedWeekly ? "Sì" : "No"}'),
          ],
        ),
      ),
    );
  }
}
