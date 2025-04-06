import 'package:flutter/material.dart';
// import 'package:life_leveling/pages/quests/quests_page.dart';
// import 'package:life_leveling/pages/quests/quest_info_page.dart';
// import 'package:life_leveling/models/quest_model.dart';
// import 'package:life_leveling/models/user_model.dart';

/*
  Questa pagina mostra la Dashboard, con:
  - Informazioni sull'utente (livello, XP, classe, abilità...).
  - Lista delle quest ad alta priorità (scadenze prossime).
  - Lista delle quest giornaliere.
*/

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Esempio di dati utente segnaposto
    final String userName = 'John Doe';
    final int currentLevel = 5;
    final double currentXP = 120.0;
    final double requiredXP = 200.0;
    final String userClass = 'Shadow Monarch'; // Esempio stile "Solo Leveling"
    final String userAbilities = 'Dominion of Shadows, Enhanced Strength...';

    // Esempio di Quest ad alta priorità (segnaposto)
    final List<Map<String, String>> highPriorityQuests = [
      {
        'title': 'Progetto Universitario',
        'deadline': '2025-05-10',
      },
      {
        'title': 'Refactoring App Flutter',
        'deadline': '2025-05-15',
      },
    ];

    // Esempio di Quest giornaliere (segnaposto)
    final List<Map<String, String>> dailyQuests = [
      {
        'title': 'Workout mattutino',
        'deadline': 'Ogni giorno',
      },
      {
        'title': 'Lavare i denti',
        'deadline': 'Ogni giorno',
      },
    ];

    return SingleChildScrollView(
      // SingleChildScrollView per gestire overflow se i contenuti superano l’altezza dello schermo
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Nome Utente, Livello e Barra XP ---
            _buildUserHeader(
              userName: userName,
              currentLevel: currentLevel,
              currentXP: currentXP,
              requiredXP: requiredXP,
              userClass: userClass,
              userAbilities: userAbilities,
              context: context,
            ),
            const SizedBox(height: 24.0),

            // --- Quest ad alta priorità ---
            Text(
              'Quest ad Alta Priorità',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8.0),
            _buildQuestList(
              quests: highPriorityQuests,
              onQuestTap: (quest) {
                // Esempio di azione quando clicchi su una quest ad alta priorità
                // - Potresti aprire la sezione Quests con un filtro
                // - Oppure direttamente la pagina info di quella quest
                // Per esempio, con named routes:
                /*
                Navigator.pushNamed(
                  context, 
                  '/quest_info',
                  arguments: quest, // Passi i dati della quest
                );
                */
              },
            ),
            const SizedBox(height: 24.0),

            // --- Quest Giornaliere ---
            Text(
              'Quest Giornaliere',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8.0),
            _buildQuestList(
              quests: dailyQuests,
              onQuestTap: (quest) {
                // Stesso discorso di sopra
                // Esempio:
                /*
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestInfoPage(questData: quest),
                  ),
                );
                */
              },
            ),
          ],
        ),
      ),
    );
  }

  // Funzione helper per costruire l'header utente
  Widget _buildUserHeader({
    required String userName,
    required int currentLevel,
    required double currentXP,
    required double requiredXP,
    required String userClass,
    required String userAbilities,
    required BuildContext context,
  }) {
    // Calcolo percentuale di XP per la barra
    final double xpPercentage = (currentXP / requiredXP).clamp(0.0, 1.0);

    return InkWell(
      // Se l'utente clicca sulla sezione "header",
      // potrebbe aprire una pagina con i dettagli del livello, classe e abilità
      onTap: () {
        // Esempio di navigazione ad una pagina "Dettagli Livello"
        /*
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LivelloDettagliPage(
              level: currentLevel,
              xp: currentXP,
              requiredXp: requiredXP,
              className: userClass,
              abilities: userAbilities,
            ),
          ),
        );
        */
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
              // Barra dell'esperienza
              LinearProgressIndicator(
                value: xpPercentage,
                minHeight: 8.0,
                backgroundColor: Colors.grey[300],
                // Colore principale, poi potrai usare un tuo tema "Solo Leveling"
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 8.0),
              // Testo XP attuale / XP necessario
              Text(
                '${currentXP.toInt()} / ${requiredXP.toInt()} XP',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8.0),
              // Dettagli sul "ruolo/classe" e abilità
              Text(
                'Classe: $userClass',
                style: const TextStyle(fontWeight: FontWeight.bold),
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

  // Funzione helper per costruire una lista di quest (schematica)
  Widget _buildQuestList({
    required List<Map<String, String>> quests,
    required Function(Map<String, String> quest) onQuestTap,
  }) {
    // Ritorna una colonna di Card, ognuna rappresenta una quest
    return Column(
      children: quests.map((quest) {
        return InkWell(
          onTap: () => onQuestTap(quest),
          child: Card(
            elevation: 2.0,
            child: ListTile(
              title: Text(quest['title'] ?? 'Quest Sconosciuta'),
              subtitle: Text('Scadenza: ${quest['deadline'] ?? 'N/A'}'),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        );
      }).toList(),
    );
  }
}
