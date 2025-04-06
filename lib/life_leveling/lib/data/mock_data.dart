import 'package:life_leveling/models/models.dart';

User mockUser = User(
  name: "Sung Jin-Woo",
  level: 12,
  currentExp: 245.0,
  expToLevelUp: 300.0,
  userClass: "Shadow Monarch",
);

// Esempio di quest
final List<Quest> mockQuests = [
  Quest(
    id: "q1",
    title: "Scrivere relazione",
    description: "Scrivere la relazione per il progetto Flutter",
    dueDate: DateTime.now().add(Duration(days: 1)), // scade domani
    isDaily: false,
    isHighPriority: true,
  ),
  Quest(
    id: "q2",
    title: "Lavarsi i denti",
    description: "Almeno 3 volte al giorno",
    dueDate: DateTime.now(),
    isDaily: true,
    isHighPriority: false,
  ),
  Quest(
    id: "q3",
    title: "Allenamento",
    description: "1 ora di workout",
    dueDate: DateTime.now(),
    isDaily: true,
    isHighPriority: false,
  ),
  Quest(
    id: "q4",
    title: "Studiare Flutter",
    description: "Approfondire lo state management",
    dueDate: DateTime.now().add(Duration(days: 2)),
    isDaily: false,
    isHighPriority: true,
  ),
];
