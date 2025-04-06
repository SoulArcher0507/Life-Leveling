// lib/models/quest_model.dart

/// Enum per distinguere le tipologie di quest:
///  - highPriority: quest non giornaliere, con scadenza
///  - daily: quest giornaliere/ricorrenti
enum QuestType {
  highPriority,
  daily,
}

/// Modello base per una Quest, con titolo, scadenza, e flag "isDaily".
/// In questo esempio, "isDaily" potresti ricavarlo anche da "questType == QuestType.daily"
/// ma lo manteniamo per continuità con il codice esistente.
class QuestData {
  final String title;
  final DateTime deadline;
  final bool isDaily;

  QuestData({
    required this.title,
    required this.deadline,
    required this.isDaily,
  });
}
