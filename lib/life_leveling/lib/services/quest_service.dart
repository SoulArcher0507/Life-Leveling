import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_leveling/models/quest_model.dart';

class QuestService {
  // Singleton per poter chiamare QuestService() ovunque
  static final QuestService _instance = QuestService._internal();
  factory QuestService() => _instance;
  QuestService._internal();

  // Chiave usata in SharedPreferences
  static const String _prefsKey = 'quests_data';

  // Lista interna di quest. Tutte le pagine useranno questa come fonte dati.
  final List<QuestData> _allQuests = [];

  // GETTER pubblico: fornisce copia (o riferimento) della lista
  // Se preferisci, puoi restituire una List immodificabile
  List<QuestData> get allQuests => _allQuests;

  /// Inizializza il servizio, caricando le quest da SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);

    if (jsonString != null && jsonString.isNotEmpty) {
      final List decoded = json.decode(jsonString);
      // Convertiamo ogni mappa nel nostro modello QuestData
      _allQuests.clear();
      for (var item in decoded) {
        _allQuests.add(QuestData.fromJson(item));
      }
    }
  }

  /// Aggiunge una quest e salva su SharedPreferences
  Future<void> addQuest(QuestData quest) async {
    _allQuests.add(quest);
    await _saveToPrefs();
  }

  /// Rimuove una quest (se serve)
  Future<void> removeQuest(QuestData quest) async {
    _allQuests.remove(quest);
    await _saveToPrefs();
  }

  /// Aggiorna una quest esistente (se serve)
  Future<void> updateQuest(QuestData oldQuest, QuestData newQuest) async {
    final index = _allQuests.indexOf(oldQuest);
    if (index != -1) {
      _allQuests[index] = newQuest;
      await _saveToPrefs();
    }
  }

  /// Salva la lista su SharedPreferences (in formato JSON)
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final listMap = _allQuests.map((q) => q.toJson()).toList();
    final jsonString = json.encode(listMap);
    await prefs.setString(_prefsKey, jsonString);
  }
}
