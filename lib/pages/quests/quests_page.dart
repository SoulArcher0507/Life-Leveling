import 'package:flutter/material.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/pages/quests/quest_detail_page.dart';
import 'package:life_leveling/pages/quests/new_quest_page.dart';

class QuestsPage extends StatefulWidget {
  final QuestType? questType;
  const QuestsPage({Key? key, this.questType}) : super(key: key);

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {

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
        QuestService().allQuests.where((q) => q.isDaily == isDaily).toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));

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
              title: Text(
                quest.title,
                style:
                    TextStyle(color: _isOverdue(quest) ? Colors.red : null),
              ),
              subtitle: quest.isDaily
                  ? Text('Quest Giornaliera',
                      style:
                          TextStyle(color: _isOverdue(quest) ? Colors.red : null))
                  : Text(
                      "Scadenza: ${DateFormat('dd/MM/yyyy').format(quest.deadline)}${quest.deadline.hour != 0 || quest.deadline.minute != 0 ? ' ${DateFormat('HH:mm').format(quest.deadline)}' : ''}",
                      style:
                          TextStyle(color: _isOverdue(quest) ? Colors.red : null),
                    ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final deleted = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuestDetailsPage(quest: quest),
                  ),
                );
                if (deleted == true) setState(() {});
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _openCreateQuestPage(context, isDaily: isDaily);
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

    // Filtriamo le quest ad alta priorità per il giorno selezionato
    final highPriorityQuests = QuestService().allQuests
        .where((q) => !q.isDaily && isSameDay(q.deadline, selectedDate))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    // Filtriamo le quest giornaliere per il giorno selezionato
    final dailyQuests = QuestService().allQuests
        .where((q) => q.isDaily && isSameDay(q.deadline, selectedDate))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildDayNavigationRow(),
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
          await _openCreateQuestPage(context, isDaily: null);
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
// da importare pacchetto esterno per calendario
  Widget _buildDayNavigationRow() {
    final selectedDate =
        _mondayOfCurrentWeek.add(Duration(days: _selectedDayIndex));
    final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _changeDay(-1);
            });
          },
        ),
        TextButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                _mondayOfCurrentWeek =
                    picked.subtract(Duration(days: picked.weekday - 1));
                _selectedDayIndex = picked.weekday - 1;
              });
            }
          },
          child: Text(
            formattedDate,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            setState(() {
              _changeDay(1);
            });
          },
        ),
      ],
    );
  }

  void _changeDay(int delta) {
    final currentDate =
        _mondayOfCurrentWeek.add(Duration(days: _selectedDayIndex));
    final newDate = currentDate.add(Duration(days: delta));
    _mondayOfCurrentWeek =
        newDate.subtract(Duration(days: newDate.weekday - 1));
    _selectedDayIndex = newDate.weekday - 1;
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
                      title: Text(
                        quest.title,
                        style:
                            TextStyle(color: _isOverdue(quest) ? Colors.red : null),
                      ),
                      subtitle: Text(
                        quest.isDaily
                            ? 'Quest Giornaliera'
                            : "Scadenza: ${DateFormat('dd/MM/yyyy').format(quest.deadline)}${quest.deadline.hour != 0 || quest.deadline.minute != 0 ? ' ${DateFormat('HH:mm').format(quest.deadline)}' : ''}",
                        style:
                            TextStyle(color: _isOverdue(quest) ? Colors.red : null),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        final deleted = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuestDetailsPage(quest: quest),
                          ),
                        );
                        if (deleted == true) setState(() {});
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
  // Apertura pagina di creazione nuova quest
  // -----------------------------------------
  Future<void> _openCreateQuestPage(BuildContext context, {bool? isDaily}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewQuestPage(defaultIsDaily: isDaily),
      ),
    );
  }





  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isOverdue(QuestData q) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final questDate = DateTime(q.deadline.year, q.deadline.month, q.deadline.day);
    return questDate.isBefore(today);
  }
}

