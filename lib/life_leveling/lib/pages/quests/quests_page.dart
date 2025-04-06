import 'package:flutter/material.dart';
import 'package:life_leveling/models/quest_model.dart';

class QuestsPage extends StatefulWidget {
  // Aggiungiamo l'enum opzionale: se != null, usiamo la logica "vecchia" (filtrata)
  // se == null, mostriamo la logica a giorni della settimana.
  final QuestType? questType;

  const QuestsPage({
    Key? key,
    this.questType,
  }) : super(key: key);

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  // ---- Sezione per la LOGICA "NUOVA" (giorni della settimana) ----
  final List<String> _daysOfWeek = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

  late DateTime _mondayOfCurrentWeek;
  int _selectedDayIndex = 0;

  // Esempio di quest generiche
  final List<QuestData> _allQuests = [
    // Quest ad alta priorità
    QuestData(
      title: 'Preparare Documento Tesina',
      deadline: DateTime(2025, 5, 22),
      isDaily: false,
    ),
    QuestData(
      title: 'Refactoring Progetto Flutter',
      deadline: DateTime(2025, 5, 24),
      isDaily: false,
    ),
    // Quest giornaliere
    QuestData(
      title: 'Workout',
      deadline: DateTime.now(),
      isDaily: true,
    ),
    QuestData(
      title: 'Fare i Denti',
      deadline: DateTime.now(),
      isDaily: true,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Calcolo del lunedì corrente (per la logica "giorni della settimana")
    final now = DateTime.now();
    int weekday = now.weekday; // lun=1, mar=2 ... dom=7
    _mondayOfCurrentWeek = now.subtract(Duration(days: weekday - 1));
    _selectedDayIndex = weekday - 1; // Se lunedì => 0, martedì => 1, ecc.
  }

  @override
  Widget build(BuildContext context) {
    // Se widget.questType != null, allora usiamo la LOGICA VECCHIA (filtrata).
    if (widget.questType == QuestType.highPriority) {
      return _buildFilteredScaffold(
        context: context,
        title: 'Quest ad Alta Priorità',
        isDaily: false,
      );
    } else if (widget.questType == QuestType.daily) {
      return _buildFilteredScaffold(
        context: context,
        title: 'Quest Giornaliere',
        isDaily: true,
      );
    } else {
      // Altrimenti, se questType è null,
      // usiamo la NUOVA LOGICA (giorni della settimana in alto).
      return _buildWeeklyScaffold(context);
    }
  }

  // -------------------------------------------------------
  // 1) LOGICA "VECCHIA": quando questType != null
  // -------------------------------------------------------
  Widget _buildFilteredScaffold({
    required BuildContext context,
    required String title,
    required bool isDaily,
  }) {
    // Filtriamo in base a isDaily
    final filteredQuests = _allQuests.where((q) => q.isDaily == isDaily).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: filteredQuests.length,
        itemBuilder: (context, index) {
          final quest = filteredQuests[index];
          return Card(
            elevation: 2.0,
            child: ListTile(
              title: Text(quest.title),
              subtitle: quest.isDaily
                  ? const Text('Quest Giornaliera')
                  : Text('Scadenza: ${quest.deadline.toLocal()}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Apri dettagli quest se vuoi
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aggiungi nuova quest
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // -------------------------------------------------------
  // 2) LOGICA "NUOVA": quando questType == null
  // -------------------------------------------------------
  Widget _buildWeeklyScaffold(BuildContext context) {
    final selectedDate = _mondayOfCurrentWeek.add(Duration(days: _selectedDayIndex));

    // Filtriamo le quest ad alta priorità per "selectedDate"
    final highPriorityQuests = _allQuests.where((q) {
      if (q.isDaily) return false;
      return isSameDay(q.deadline, selectedDate);
    }).toList();

    // Filtriamo le quest giornaliere
    final dailyQuests = _allQuests.where((q) => q.isDaily).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le Tue Quests (settimanale)'),
      ),
      body: Column(
        children: [
          // barra orizzontale con i 7 giorni
          _buildDaysOfWeekSelector(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Data selezionata: ${selectedDate.toLocal()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildQuestSection(
                      title: 'Quest ad Alta Priorità',
                      quests: highPriorityQuests,
                      context: context,
                    ),
                    const SizedBox(height: 16),
                    _buildQuestSection(
                      title: 'Quest Giornaliere',
                      quests: dailyQuests,
                      context: context,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aggiunta quest
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDaysOfWeekSelector() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final dayDate = _mondayOfCurrentWeek.add(Duration(days: index));
          final dayNumber = dayDate.day;
          // giorni in italiano
          final daysOfWeek = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
          final dayName = daysOfWeek[index];

          final isSelected = index == _selectedDayIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$dayName $dayNumber',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestSection({
    required String title,
    required List<QuestData> quests,
    required BuildContext context,
  }) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8.0),
            if (quests.isEmpty)
              Text(
                'Nessuna quest trovata per questo giorno',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Column(
                children: quests.map((quest) {
                  return Card(
                    child: ListTile(
                      title: Text(quest.title),
                      subtitle: quest.isDaily
                          ? const Text('Quest Giornaliera')
                          : Text('Scadenza: ${quest.deadline.toLocal()}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Dettagli quest
                      },
                    ),
                  );
                }).toList(),
              )
          ],
        ),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
