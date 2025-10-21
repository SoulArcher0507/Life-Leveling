import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/services/quest_service.dart';

class NewQuestPage extends StatefulWidget {
  final bool? defaultIsDaily;
  const NewQuestPage({Key? key, this.defaultIsDaily}) : super(key: key);

  @override
  State<NewQuestPage> createState() => _NewQuestPageState();
}

class _NewQuestPageState extends State<NewQuestPage> {
  final titleController = TextEditingController();
  final xpController = TextEditingController();
  final notesController = TextEditingController();

  bool userIsDaily = false;
  bool repeatedWeekly = false;

  final xpPresets = {
    'Facile': 10,
    'Media': 25,
    'Difficile': 50,
    'Molto Difficile': 100,
  };

  String selectedXpPreset = 'Personalizzato';

  List<bool> selectedWeekDays = List.filled(7, false);
  final weekDayLabels = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
  DateTime? repeatUntil;

  DateTime? selectedDeadline;
  TimeOfDay? selectedDeadlineTime;

  int fatigue = 0;

  @override
  void initState() {
    super.initState();
    userIsDaily = widget.defaultIsDaily ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Nuova Quest'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titolo Quest'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedXpPreset,
                    decoration: const InputDecoration(labelText: 'Preset XP'),
                    items: [
                      ...xpPresets.keys.map((k) => DropdownMenuItem(
                          value: k, child: Text('$k (${xpPresets[k]})'))),
                      const DropdownMenuItem(
                          value: 'Personalizzato', child: Text('Personalizzato')),
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
            const SizedBox(height: 16),
            Text('Difficoltà: $fatigue'),
            Slider(
              value: fatigue.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: '$fatigue',
              onChanged: (v) => setState(() => fatigue = v.round()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (userIsDaily) ...[
              Wrap(
                spacing: 4,
                children: List.generate(7, (i) {
                  return FilterChip(
                    label: Text(weekDayLabels[i]),
                    selected: selectedWeekDays[i],
                    onSelected: (sel) => setState(() => selectedWeekDays[i] = sel),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ripeti fino a'),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: repeatUntil ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => repeatUntil = picked);
                    },
                    child: Text(
                      repeatUntil == null
                          ? 'Scegli data'
                          : DateFormat('dd/MM/yyyy').format(repeatUntil!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Scadenza'),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDeadline = picked);
                      }
                    },
                    child: Text(
                      selectedDeadline == null
                          ? 'Scegli data'
                          : DateFormat('dd/MM/yyyy').format(selectedDeadline!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ora (opzionale)'),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedDeadlineTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedDeadlineTime = picked);
                      }
                    },
                    child: Text(
                      selectedDeadlineTime == null
                          ? 'Scegli ora'
                          : selectedDeadlineTime!.format(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _createQuest,
                child: const Text('Crea'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createQuest() async {
    final newTitle = titleController.text.trim();
    final newXp = int.tryParse(xpController.text.trim()) ?? 0;
    final newNotes = notesController.text.trim();

    if (newTitle.isEmpty) return;

    if (userIsDaily) {
      final now = DateTime.now();
      // Normalizziamo la data corrente alle 00:00 per le quest giornaliere
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = repeatUntil != null
          ? DateTime(repeatUntil!.year, repeatUntil!.month, repeatUntil!.day)
          : startDate;

      if (selectedWeekDays.any((sel) => sel)) {
        // L'utente ha selezionato dei giorni della settimana: creiamo una quest
        // per ciascun giorno selezionato nel range [startDate, endDate].
        for (var d = startDate;
            !d.isAfter(endDate);
            d = d.add(const Duration(days: 1))) {
          final idx = d.weekday - 1;
          if (selectedWeekDays[idx]) {
            final q = QuestData(
              title: newTitle,
              deadline: d,
              isDaily: true,
              xp: newXp,
              notes: newNotes,
              repeatedWeekly: true,
              fatigue: fatigue,
            );
            await QuestService().addQuest(q);
          }
        }
      } else {
        // Nessun giorno selezionato: creiamo una singola quest giornaliera
        // non ripetuta per la data corrente
        final q = QuestData(
          title: newTitle,
          deadline: startDate,
          isDaily: true,
          xp: newXp,
          notes: newNotes,
          repeatedWeekly: false,
          fatigue: fatigue,
        );
        await QuestService().addQuest(q);
      }
    } else {
      final baseDate = selectedDeadline != null
          ? DateTime(selectedDeadline!.year, selectedDeadline!.month, selectedDeadline!.day)
          : DateTime.now();
      final d = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        selectedDeadlineTime?.hour ?? 0,
        selectedDeadlineTime?.minute ?? 0,
      );
      final q = QuestData(
        title: newTitle,
        deadline: d,
        isDaily: false,
        xp: newXp,
        notes: newNotes,
        fatigue: fatigue,
      );
      await QuestService().addQuest(q);
    }

    Navigator.of(context).pop();
  }
}

