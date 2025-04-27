import 'package:flutter/material.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/pages/quests/quest_detail_page.dart';

class QuestsPage extends StatefulWidget {
  final QuestType? questType;
  const QuestsPage({Key? key, this.questType}) : super(key: key);

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  // 7 giorni in italiano
  final List<String> _daysOfWeek = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

  late DateTime _mondayOfCurrentWeek;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    int weekday = now.weekday; // lun=1 ... dom=7
    _mondayOfCurrentWeek = now.subtract(Duration(days: weekday - 1));
    _selectedDayIndex = weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    // Se widget.questType != null, logica filtrata
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
      // Altrimenti, vista settimanale
      return _buildWeeklyScaffold(context);
    }
  }

  // ---------------------------------------------
  // 1) Filtrata
  // ---------------------------------------------
  Widget _buildFilteredScaffold({
    required BuildContext context,
    required String title,
    required bool isDaily,
  }) {
    // PRIMA: final filteredQuests = _allQuests.where(...)
    // ORA: usiamo QuestService().allQuests
    final filteredQuests =
        QuestService().allQuests.where((q) => q.isDaily == isDaily).toList();

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
                  : Text('Scadenza: ...'),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showCreateQuestDialog(context, isDaily: isDaily);
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  

  // ---------------------------------------------
  // 2) Vista settimanale
  // ---------------------------------------------
  Widget _buildWeeklyScaffold(BuildContext context) {
    final selectedDate = _mondayOfCurrentWeek.add(Duration(days: _selectedDayIndex));

    // Filtriamo le quest ad alta priorità
    final highPriorityQuests = QuestService().allQuests
      .where((q) => !q.isDaily)
      .toList()
    ..sort((a, b) => a.deadline.compareTo(b.deadline));

    // Filtriamo le quest giornaliere
    final dailyQuests = QuestService().allQuests
      .where((q) => q.isDaily)
      .toList()
    ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le Tue Quests (settimanale)'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _mondayOfCurrentWeek = _mondayOfCurrentWeek.subtract(const Duration(days: 7));  
                      _selectedDayIndex = 0;                                                           
                    });
                  },
                ),
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _mondayOfCurrentWeek,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        // ricavo il Lunedì della settimana scelta
                        _mondayOfCurrentWeek = picked.subtract(Duration(days: picked.weekday - 1));  
                        _selectedDayIndex = 0;                                                         
                      });
                    }
                  },
                  child: Text(
                    DateFormat('MMMM yyyy').format(_mondayOfCurrentWeek),                        
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _mondayOfCurrentWeek = _mondayOfCurrentWeek.add(const Duration(days: 7));    
                      _selectedDayIndex = 0;                                                         
                    });
                  },
                ),
              ],
            ),
          ),
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
        onPressed: () async {
          await _showCreateQuestDialog(context, isDaily: null);
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
// da importare pacchetto esterno per calendario
  Widget _buildDaysOfWeekRow() {
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
            width: 40,
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
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuestDetailsPage(quest: quest),
                          ),
                        );
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
  // Creazione di una NUOVA quest
  // -----------------------------------------
  Future<void> _showCreateQuestDialog(BuildContext context, {bool? isDaily}) async {
    final titleController = TextEditingController();
    final xpController = TextEditingController();
    final notesController = TextEditingController();
    bool repeatedWeekly = false;
    bool userIsDaily = isDaily ?? false;

    // Mostriamo lo stesso AlertDialog di prima
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Crea Nuova Quest'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titolo Quest'),
                ),
                TextField(
                  controller: xpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'XP da Assegnare'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Note'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
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
              onPressed: () async {
                final newTitle = titleController.text.trim();
                final newXp = int.tryParse(xpController.text.trim()) ?? 0;
                final newNotes = notesController.text.trim();

                if (newTitle.isNotEmpty) {
                  final newQuest = QuestData(
                    title: newTitle,
                    deadline: DateTime.now(),
                    isDaily: userIsDaily,
                    xp: newXp,
                    notes: newNotes,
                  );

                  // Aggiunta al QuestService, invece di _allQuests
                  await QuestService().addQuest(newQuest);

                  Navigator.of(ctx).pop();
                  setState(() {});
                } else {
                  // ...
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

