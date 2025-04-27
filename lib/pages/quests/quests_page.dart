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

    final xpPresets = {
      'Facile': 10,
      'Media': 25,
      'Difficile': 50,
      'Molto Difficile': 100,
    };
    String selectedXpPreset = 'Personalizzato';

    List<bool> selectedWeekDays = List.filled(7, false);
    final weekDayLabels = ['Lun','Mar','Mer','Gio','Ven','Sab','Dom'];
    DateTime? repeatUntil;

    DateTime? selectedDeadline;
    DateTimeRange? selectedDateRange;

    // AlertDialog
    return showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setState) {
            return AlertDialog(
              title: const Text('Crea Nuova Quest'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Giornaliera'),
                          selected: userIsDaily,
                          onSelected: (sel) => setState(() => userIsDaily = true),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Alta Priorità'),
                          selected: !userIsDaily,
                          onSelected: (sel) => setState(() => userIsDaily = false),
                        ),
                      ],
                    ),
                    
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Titolo Quest'),
                    ),
                    
                    
                    const SizedBox(height: 16),

                    Row(  // XP con preset + personalizzato
                      children: [
                        // Dropdown dei preset
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: selectedXpPreset,
                            decoration: const InputDecoration(labelText: 'Preset XP'),
                            items: [
                              ...xpPresets.keys.map((k) =>
                                DropdownMenuItem(value: k, child: Text('$k (${xpPresets[k]})'))
                              ),
                              const DropdownMenuItem(value: 'Personalizzato', child: Text('Personalizzato')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                selectedXpPreset = val!;
                                if (xpPresets.containsKey(val)) {
                                  xpController.text = xpPresets[val]!.toString();
                                } else {
                                  xpController.clear();
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Campo per personalizzare/visualizzare XP
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: xpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'XP'),
                          ),
                        ),
                      ],
                    ),



                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Note'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                      ],
                    ),

                    const SizedBox(height: 16),
                    // *** PICKER DATA / DATE RANGE ***
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userIsDaily ? 'Intervallo date' : 'Scadenza'),            // << RIGA AGGIUNTA
                        TextButton(
                          onPressed: () async {
                            if (userIsDaily) {
                              final range = await showDateRangePicker(
                                context: ctx2,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                initialDateRange: selectedDateRange,
                              );
                              if (range != null) {
                                setState(() => selectedDateRange = range);            // << RIGA AGGIUNTA
                              }
                            } else {
                              final date = await showDatePicker(
                                context: ctx2,
                                initialDate: selectedDeadline ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => selectedDeadline = date);              // << RIGA AGGIUNTA
                              }
                            }
                          },
                          child: Text(
                            userIsDaily
                                ? (selectedDateRange == null
                                    ? 'Scegli date'
                                    : '${DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)}')
                                : (selectedDeadline == null
                                    ? 'Scegli data'
                                    : DateFormat('dd/MM/yyyy').format(selectedDeadline!)),
                          ),
                        ),
                      ],
                    ),
                    // *** END PICKER ***




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
                      // scelgo la data da passare al modello
                      final deadlineToUse = userIsDaily
                          ? (selectedDateRange?.start ?? DateTime.now())           
                          : (selectedDeadline ?? DateTime.now());

                      final newQuest = QuestData(
                        title: newTitle,
                        deadline: DateTime.now(),
                        isDaily: userIsDaily,
                        xp: newXp,
                        notes: newNotes,
                      );

                      // Aggiunta al QuestService, invece di _allQuests
                      await QuestService().addQuest(newQuest);

                      Navigator.of(ctx2).pop();
                      setState(() {});  // ricarica la lista
                    } else {
                      // ...
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }



  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

