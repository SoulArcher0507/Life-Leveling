// models.dart
class User {
  final String name;
  final int level;
  final double currentExp;
  final double expToLevelUp;
  final String userClass; // es. "Mago", "Guerriero", ecc.

  User({
    required this.name,
    required this.level,
    required this.currentExp,
    required this.expToLevelUp,
    required this.userClass,
  });
}

class Quest {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isDaily;
  final bool isHighPriority;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isDaily = false,
    this.isHighPriority = false,
  });
}
