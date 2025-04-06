// lib/pages/quests/quests_page.dart

import 'package:flutter/material.dart';
import 'package:life_leveling/models/quest_model.dart';

/// Pagina che mostra TUTTE le quest di un determinato tipo (daily o highPriority).
class QuestsPage extends StatelessWidget {
  final QuestType questType;

  const QuestsPage({
    Key? key,
    required this.questType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1) Recupera tutte le quest (in un’app reale, potresti usare un Service o un DB)
    final allQuests = _getAllQuests();

    // 2) Filtra in base a questType
    final filteredQuests = questType == QuestType.daily
        ? allQuests.where((q) => q.isDaily).toList()
        : allQuests.where((q) => !q.isDaily).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          questType == QuestType.daily
              ? 'Tutte le Quest Giornaliere'
              : 'Tutte le Quest ad Alta Priorità',
        ),
      ),
      // 3) Mostriamo la lista di quest
      body: ListView.builder(
        itemCount: filteredQuests.length,
        itemBuilder: (context, index) {
          final quest = filteredQuests[index];
          return Card(
            child: ListTile(
              title: Text(quest.title),
              subtitle: quest.isDaily
                  ? const Text('Giornaliera')
                  : Text('Scadenza: ${quest.deadline.toLocal()}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Se vuoi aprire una pagina di dettaglio:
                // Navigator.push(context, MaterialPageRoute(
                //   builder: (_) => QuestInfoPage(quest: quest),
                // ));
              },
            ),
          );
        },
      ),
    );
  }

  /// Per esempio, potresti qui richiamare un service o passare i dati dal costruttore
  /// In questa demo uso dati hardcoded come nella dashboard
  List<QuestData> _getAllQuests() {
    return [
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
  }
}
