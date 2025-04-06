import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_leveling/models/quest_model.dart';

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

  // Aggiunge una quest e salva
  Future<void> addQuest(QuestData quest) async {
    _allQuests.add(quest);
    await _save();
  }

  // Se vuoi rimuovere o aggiornare quest, puoi aggiungere funzioni simili
  // Future<void> removeQuest(QuestData quest) async { ... }

  // Salva la lista su SharedPreferences
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _allQuests.map((q) => q.toJson()).toList();
    final jsonString = json.encode(data);
    await prefs.setString(_prefsKey, jsonString);
  }
}
