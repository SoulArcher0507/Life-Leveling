import 'package:flutter/material.dart';
import 'package:life_leveling/models/quest_model.dart';

class QuestsPage extends StatefulWidget {
  final QuestType? questType;
  const QuestsPage({Key? key, this.questType}) : super(key: key);

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  // 7 giorni in italiano
  final List<String> _daysOfWeek = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

  // Per la logica "settimanale"
  late DateTime _mondayOfCurrentWeek;
  int _selectedDayIndex = 0;

  // Esempio di quest
  final List<QuestData> _allQuests = [
    QuestData(
      title: 'Preparare Documento Tesina',
      deadline: DateTime(2025, 5, 22),
      isDaily: false,
      xp: 50,
      notes: '',
    ),
    QuestData(
      title: 'Refactoring Progetto Flutter',
      deadline: DateTime(2025, 5, 24),
      isDaily: false,
      xp: 30,
      notes: '',
    ),
    // Quest giornaliere
    QuestData(
      title: 'Workout',
      deadline: DateTime.now(),
      isDaily: true,
      xp: 10,
      notes: '30 minuti di stretching e corsa',
    ),
    QuestData(
      title: 'Fare i Denti',
      deadline: DateTime.now(),
      isDaily: true,
      xp: 5,
      notes: 'Mattina, dopo pranzo, sera',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Se stiamo usando questType per la logica "vecchia"
    // (highPriority/daily), non serve calcolare i giorni.
    // Altrimenti, calcoliamo la settimana.
    final now = DateTime.now();
    int weekday = now.weekday; // lun=1, mar=2 ... dom=7
    _mondayOfCurrentWeek = now.subtract(Duration(days: weekday - 1));
    _selectedDayIndex = weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    // Se widget.questType != null, usiamo la logica "filtrata".
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
      // Altrimenti, visuale settimanale
      return _buildWeeklyScaffold(context);
    }
  }

  // ---------------------------------------------
  // 1) Se questType != null => logica "filtrata"
  // ---------------------------------------------
  Widget _buildFilteredScaffold({
    required BuildContext context,
    required String title,
    required bool isDaily,
  }) {
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
            child: ListTile(
              title: Text(quest.title),
              subtitle: quest.isDaily
                  ? const Text('Quest Giornaliera')
                  : Text('Scadenza: ...'), // Per brevità
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateQuestDialog(context, isDaily: isDaily),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------------------------------------------
  // 2) Se questType == null => vista settimanale
  // ---------------------------------------------
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
          // RIGA unica con i 7 giorni
          _buildDaysOfWeekRow(),

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
        // Non sappiamo se l'utente vuole creare una quest daily o highPriority in questa vista.
        // Possiamo mostrare un pop-up che chiede se daily o no.
        onPressed: () => _showCreateQuestDialog(context, isDaily: null),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---- ROW con 7 "pulsanti" (senza scorrimento) ----
  Widget _buildDaysOfWeekRow() {
    // Calcola le date effettive
    final List<Widget> dayWidgets = [];
    for (int i = 0; i < 7; i++) {
      final dayDate = _mondayOfCurrentWeek.add(Duration(days: i));
      final dayNumber = dayDate.day;
      final dayName = _daysOfWeek[i];

      final isSelected = i == _selectedDayIndex;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDayIndex = i;
            });
          },
          child: Container(
            width: 40, // Larghezza fissa per ogni giorno (adjust se serve)
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                ),
                Text(
                  '$dayNumber',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: dayWidgets,
      ),
    );
  }

  // ---- Sezione di quest (card) ----
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
                    elevation: 2.0,
                    child: ListTile(
                      title: Text(quest.title),
                      subtitle: Text(
                        quest.isDaily
                            ? 'Quest Giornaliera'
                            : 'Scadenza: ${quest.deadline.toLocal()}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Apri info quest
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------
  // Funzione per creare una NUOVA quest
  // -----------------------------------------
  void _showCreateQuestDialog(BuildContext context, {bool? isDaily}) {
    // userTitle, userXp, userNotes, userIsDaily, userDeadline
    final titleController = TextEditingController();
    final xpController = TextEditingController();
    final notesController = TextEditingController();
    bool repeatedWeekly = false; // flag per "ripeti settimanalmente"

    // Se isDaily != null, lo usiamo per inizializzare userIsDaily
    bool userIsDaily = isDaily ?? false;

    // Mostriamo un dialog / bottom sheet con un form
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Crea Nuova Quest'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Campo titolo
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titolo Quest'),
                ),
                // Campo xp
                TextField(
                  controller: xpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'XP da Assegnare'),
                ),
                // Campo note (multiline)
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Note'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                // Switch giornaliera / alta priorità
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('È Giornaliera?'),
                    Switch(
                      value: userIsDaily,
                      onChanged: (val) {
                        setState(() {
                          userIsDaily = val;
                        });
                      },
                    ),
                  ],
                ),
                // Switch ripeti settimanalmente
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ripeti settimanalmente?'),
                    Switch(
                      value: repeatedWeekly,
                      onChanged: (val) {
                        setState(() {
                          repeatedWeekly = val;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('ANNULLA'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('CREA'),
              onPressed: () {
                final newTitle = titleController.text.trim();
                final newXp = int.tryParse(xpController.text.trim()) ?? 0;
                final newNotes = notesController.text.trim();

                if (newTitle.isNotEmpty) {
                  // Creiamo la quest
                  final newQuest = QuestData(
                    title: newTitle,
                    deadline: DateTime.now(), // Se isDaily, la scadenza non è importante
                    isDaily: userIsDaily,
                    xp: newXp,
                    notes: newNotes,
                  );

                  setState(() {
                    _allQuests.add(newQuest);
                  });

                  // TODO: se repeatedWeekly == true, potresti salvare un'altra flag
                  // e rigenerare la quest ogni settimana, logica da implementare

                  Navigator.of(ctx).pop();
                } else {
                  // Mostra un messaggio di errore, se vuoi
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
