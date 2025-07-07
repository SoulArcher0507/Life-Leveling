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

  // Aggiungiamo i nuovi campi:
  final int xp;              // punti esperienza assegnati alla quest
  final String notes;        // note aggiuntive
  final bool repeatedWeekly; // se la quest si ripete settimanalmente
  final int fatigue;         // difficoltà della quest (0-100)

  QuestData({
    required this.title,
    required this.deadline,
    required this.isDaily,

    required this.xp,
    required this.notes,
    this.repeatedWeekly = false, // default = false
    this.fatigue = 0,
  });

// Converte un QuestData in Map<String, dynamic> (per JSON)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'deadline': deadline.toIso8601String(),
      'isDaily': isDaily,
      'xp': xp,
      'notes': notes,
      'repeatedWeekly': repeatedWeekly,
      'fatigue': fatigue,
    };
  }

  // Ricostruisce un QuestData da JSON
  factory QuestData.fromJson(Map<String, dynamic> json) {
    return QuestData(
      title: json['title'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      isDaily: json['isDaily'] as bool,
      xp: json['xp'] as int,
      notes: json['notes'] as String,
      repeatedWeekly: json['repeatedWeekly'] as bool,
      fatigue: (json['fatigue'] ?? 0) as int,
    );
  }

}


