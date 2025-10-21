import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/services/quest_service.dart';

/// A page for editing an existing quest.  This form pre‑populates fields
/// based on the provided [quest] and allows the user to modify the title,
/// XP, fatigue, notes and deadline.  When saved, the quest is updated via
/// [QuestService.updateQuest] and this page pops with a `true` result.
class EditQuestPage extends StatefulWidget {
  final QuestData quest;
  const EditQuestPage({Key? key, required this.quest}) : super(key: key);

  @override
  State<EditQuestPage> createState() => _EditQuestPageState();
}

class _EditQuestPageState extends State<EditQuestPage> {
  late TextEditingController titleController;
  late TextEditingController xpController;
  late TextEditingController notesController;

  bool userIsDaily = false;
  DateTime? selectedDeadline;
  TimeOfDay? selectedDeadlineTime;
  int fatigue = 0;

  @override
  void initState() {
    super.initState();
    final q = widget.quest;
    titleController = TextEditingController(text: q.title);
    xpController = TextEditingController(text: q.xp.toString());
    notesController = TextEditingController(text: q.notes);
    userIsDaily = q.isDaily;
    fatigue = q.fatigue;
    if (!q.isDaily) {
      // Extract date and time for high priority quest
      selectedDeadline = DateTime(q.deadline.year, q.deadline.month, q.deadline.day);
      if (q.deadline.hour != 0 || q.deadline.minute != 0) {
        selectedDeadlineTime = TimeOfDay(hour: q.deadline.hour, minute: q.deadline.minute);
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    xpController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Quest'),
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
                  label: const Text('Daily'),
                  selected: userIsDaily,
                  onSelected: (sel) => setState(() => userIsDaily = true),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('High Priority'),
                  selected: !userIsDaily,
                  onSelected: (sel) => setState(() => userIsDaily = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Quest Title'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: xpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'XP'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Difficulty: $fatigue'),
                      Slider(
                        value: fatigue.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: '$fatigue',
                        onChanged: (v) => setState(() => fatigue = v.round()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Date/time pickers shown only for high priority quests
            if (!userIsDaily) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Deadline'),
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
                          ? 'Choose date'
                          : DateFormat('dd/MM/yyyy').format(selectedDeadline!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Time (optional)'),
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
                          ? 'Choose time'
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
                onPressed: _saveQuest,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQuest() async {
    final newTitle = titleController.text.trim();
    final newXp = int.tryParse(xpController.text.trim()) ?? 0;
    final newNotes = notesController.text.trim();
    if (newTitle.isEmpty) return;

    QuestData updated;
    if (userIsDaily) {
      // Keep the original deadline date (date part only) for daily quests
      final DateTime baseDate = DateTime(
        widget.quest.deadline.year,
        widget.quest.deadline.month,
        widget.quest.deadline.day,
      );
      updated = QuestData(
        id: widget.quest.id,
        title: newTitle,
        deadline: baseDate,
        isDaily: true,
        xp: newXp,
        notes: newNotes,
        repeatedWeekly: widget.quest.repeatedWeekly,
        fatigue: fatigue,
      );
    } else {
      // For high priority quests, use the selected date/time if provided
      final DateTime base = selectedDeadline ?? widget.quest.deadline;
      final DateTime d = DateTime(
        base.year,
        base.month,
        base.day,
        selectedDeadlineTime?.hour ?? widget.quest.deadline.hour,
        selectedDeadlineTime?.minute ?? widget.quest.deadline.minute,
      );
      updated = QuestData(
        id: widget.quest.id,
        title: newTitle,
        deadline: d,
        isDaily: false,
        xp: newXp,
        notes: newNotes,
        repeatedWeekly: false,
        fatigue: fatigue,
      );
    }
    await QuestService().updateQuest(widget.quest, updated);
    // Pop with true to indicate that the quest was updated
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
}