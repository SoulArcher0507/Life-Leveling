import 'package:flutter/material.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/services/fatigue_service.dart';
import 'package:life_leveling/services/level_service.dart';
import 'package:life_leveling/services/stats_service.dart';
import 'package:life_leveling/pages/quests/edit_quest_page.dart';
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
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Complete',
            onPressed: () async {
              // Completa la quest: aggiunge fatica, esperienza e aggiorna statistiche
              await FatigueService().addFatigue(quest.fatigue);
              await LevelService().addXp(quest.xp.toDouble());
              await StatsService().recordQuestCompleted(
                  xp: quest.xp.toDouble(), fatigue: quest.fatigue);
              await QuestService().removeQuest(quest);
              Navigator.of(context).pop(true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () async {
              // Elimina la quest senza completarla
              await QuestService().removeQuest(quest);
              Navigator.of(context).pop(true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () async {
              // Open the edit quest page and wait for result.  If the
              // quest was modified (result == true) refresh the state by
              // popping with true so the parent list updates.
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditQuestPage(quest: quest),
                ),
              );
              if (result == true) {
                // Indicate to the caller that an update occurred
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Title'),
                  subtitle: Text(quest.title),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Due'),
                  subtitle: Text(
                      "${DateFormat('dd/MM/yyyy').format(quest.deadline)}${quest.deadline.hour != 0 || quest.deadline.minute != 0 ? ' ${DateFormat('HH:mm').format(quest.deadline)}' : ''}"),
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('XP'),
                  subtitle: Text('${quest.xp}'),
                ),
                ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: const Text('Difficulty'),
                  subtitle: Text('${quest.fatigue}'),
                ),
                if (quest.notes.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.notes),
                    title: const Text('Notes'),
                    subtitle: Text(quest.notes),
                  ),
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('Daily'),
                  subtitle: Text(quest.isDaily ? 'Yes' : 'No'),
                ),
                ListTile(
                  leading: const Icon(Icons.loop),
                  title: const Text('Weekly Repeat'),
                  subtitle: Text(quest.repeatedWeekly ? 'Yes' : 'No'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
