// quest_detail_page.dart
import 'package:flutter/material.dart';
import 'package:life_leveling/models/models.dart';

class QuestDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quest = ModalRoute.of(context)?.settings.arguments as Quest?;
    if (quest == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Dettaglio Quest")),
        body: Center(child: Text("Nessuna quest selezionata.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Dettaglio Quest"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quest.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text("Scadenza: ${quest.dueDate.toLocal()}".split(' ')[0]),
            SizedBox(height: 8),
            Text("Descrizione: ${quest.description}"),
            SizedBox(height: 16),
            Text("Alta priorità: ${quest.isHighPriority ? "Sì" : "No"}"),
            Text("Quest giornaliera: ${quest.isDaily ? "Sì" : "No"}"),
            // Aggiungi qui eventuali tasti per completare la quest,
            // assegnare penalità, aggiungere note, ecc.
          ],
        ),
      ),
    );
  }
}
