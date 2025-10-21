import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/services/notification_service.dart';

class QuestService {
  // Singleton: puoi accedere ovunque con QuestService()
  static final QuestService _instance = QuestService._internal();
  factory QuestService() => _instance;
  QuestService._internal();

  // Chiave per salvare in SharedPreferences
  static const String _prefsKey = 'quests_data';

  // Lista di quest condivisa dall'intera app
  final List<QuestData> _allQuests = [];

  // Getter per la lista
  List<QuestData> get allQuests => _allQuests;

  // Inizializza caricando i dati
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List decoded = json.decode(jsonString);
      _allQuests.clear();
      for (var item in decoded) {
        _allQuests.add(QuestData.fromJson(item));
      }
    }
  }

  // Aggiunge una quest. Se esiste già una quest con lo stesso id,
  // viene sostituita; altrimenti viene aggiunta. In questo modo
  // evitiamo duplicazioni accidentali (ad esempio al riavvio dell'app).
  Future<void> addQuest(QuestData quest) async {
    final existingIndex = _allQuests.indexWhere((q) => q.id == quest.id);
    if (existingIndex != -1) {
      _allQuests[existingIndex] = quest;
    } else {
      _allQuests.add(quest);
    }
    await _save();
    // Reschedule daily notifications to include this new quest
    await NotificationService().scheduleDailyNotifications();
  }

  // Per rimuovere o aggiornare quest, aggiungere funzioni simili
  // Future<void> removeQuest(QuestData quest) async { ... }

  // Salva la lista su SharedPreferences
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _allQuests.map((q) => q.toJson()).toList();
    final jsonString = json.encode(data);
    await prefs.setString(_prefsKey, jsonString);
  }

  /// Rimuove una quest basandosi sul suo id. In questo modo anche se
  /// l'oggetto passato non è lo stesso istanza contenuta nella lista,
  /// la quest corretta verrà rimossa.
  Future<void> removeQuest(QuestData quest) async {
    _allQuests.removeWhere((q) => q.id == quest.id);
    await _save();
    // Update notifications after removing a quest
    await NotificationService().scheduleDailyNotifications();
  }

  /// Aggiorna una quest esistente (sostituisce oldQuest con newQuest)
  Future<void> updateQuest(QuestData oldQuest, QuestData newQuest) async {
    final idx = _allQuests.indexWhere((q) => q.id == oldQuest.id);
    if (idx != -1) {
      _allQuests[idx] = newQuest;
      await _save();
      // Update notifications after modifying a quest
      await NotificationService().scheduleDailyNotifications();
    }
  }
}
// memoria persistente a lungo termine
// tutto in un file, tool esterno per estrarre evenutalmente