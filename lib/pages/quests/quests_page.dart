import 'package:flutter/material.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/pages/quests/quest_detail_page.dart';
import 'package:life_leveling/pages/quests/new_quest_page.dart';

class QuestsPage extends StatefulWidget {
  /// Optional quest type to show only high priority or daily quests. If null,
  /// the page displays a weekly calendar view.
  final QuestType? questType;

  /// The date to display when the page is first opened.  If provided from
  /// another screen (such as the dashboard), the list of quests will be
  /// filtered to this day.  Defaults to [DateTime.now()].
  final DateTime? initialDate;

  const QuestsPage({Key? key, this.questType, this.initialDate}) : super(key: key);

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  /// The Monday of the week currently displayed in the weekly view.
  late DateTime _mondayOfCurrentWeek;
  /// Index of the selected day in the weekly view (0 = Monday).
  int _selectedDayIndex = 0;

  /// The currently selected date used in the filtered view.  This is
  /// initialised from [widget.initialDate] if provided.
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    // Determine the initial date: provided by the widget or default to now.
    final initDate = widget.initialDate ?? DateTime.now();
    _currentDate = DateTime(initDate.year, initDate.month, initDate.day);
    // Compute Monday of the week containing the initial date and set
    // selectedDayIndex accordingly.  This supports deep linking from the
    // dashboard into a particular day of the weekly view.
    int weekday = initDate.weekday; // Monday = 1 .. Sunday = 7
    _mondayOfCurrentWeek = initDate.subtract(Duration(days: weekday - 1));
    _selectedDayIndex = weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    // Se widget.questType != null, logica filtrata
    if (widget.questType == QuestType.highPriority) {
      return _buildFilteredScaffold(
        context: context,
        // English title for high priority quests
        title: 'High Priority Quests',
        isDaily: false,
      );
    } else if (widget.questType == QuestType.daily) {
      return _buildFilteredScaffold(
        context: context,
        title: 'Daily Quests',
        isDaily: true,
      );
    } else {
      // Otherwise, weekly view
      return _buildWeeklyScaffold(context);
    }
  }

  // ---------------------------------------------
  // 1) Filtered view (high priority or daily) for a specific date
  // ---------------------------------------------
  Widget _buildFilteredScaffold({
    required BuildContext context,
    required String title,
    required bool isDaily,
  }) {
    // Filter quests by type and the currently selected date. Only quests whose
    // deadline matches `_currentDate` are displayed.  Daily quests repeat
    // every day, so we use their deadline date as the starting reference.
    final filteredQuests = QuestService()
        .allQuests
        .where((q) => q.isDaily == isDaily && isSameDay(q.deadline, _currentDate))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          // Date navigation row for filtered views
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _currentDate = _currentDate.subtract(const Duration(days: 1));
                    });
                  },
                ),
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _currentDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _currentDate = DateTime(picked.year, picked.month, picked.day);
                      });
                    }
                  },
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_currentDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _currentDate = _currentDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredQuests.isEmpty
                ? Center(
                    child: Text(
                      'No quests found for this day',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredQuests.length,
                    itemBuilder: (context, index) {
                      final quest = filteredQuests[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            quest.title,
                            style: TextStyle(
                              color: _isOverdue(quest) ? Colors.red : null,
                            ),
                          ),
                          subtitle: quest.isDaily
                              ? Text(
                                  'Daily',
                                  style: TextStyle(
                                      color:
                                          _isOverdue(quest) ? Colors.red : null),
                                )
                              : Text(
                                  "Due: ${DateFormat('dd/MM/yyyy').format(quest.deadline)}${quest.deadline.hour != 0 || quest.deadline.minute != 0 ? ' ${DateFormat('HH:mm').format(quest.deadline)}' : ''}",
                                  style: TextStyle(
                                      color:
                                          _isOverdue(quest) ? Colors.red : null),
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
          ),
        ],
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
                      title: 'High Priority Quests',
                      quests: highPriorityQuests,
                      context: context,
                    ),
                    const SizedBox(height: 16),
                    _buildQuestSection(
                      title: 'Daily Quests',
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
                'No quests found for this day',
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
                            ? 'Daily'
                            : "Due: ${DateFormat('dd/MM/yyyy').format(quest.deadline)}${quest.deadline.hour != 0 || quest.deadline.minute != 0 ? ' ${DateFormat('HH:mm').format(quest.deadline)}' : ''}",
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

