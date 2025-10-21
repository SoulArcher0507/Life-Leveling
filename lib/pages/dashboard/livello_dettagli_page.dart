import 'package:flutter/material.dart';

/*
  Pagina con i dettagli del livello, classe e abilità dell'utente.
  Cliccabile dalla DashboardPage quando premi sul livello.
*/

class LivelloDettagliPage extends StatelessWidget {
  final String userName;
  final int currentLevel;
  final double currentXP;
  final double requiredXP;
  final String userClass;
  final String userAbilities;
  final int dailyFatigue;

  const LivelloDettagliPage({
    Key? key,
    required this.userName,
    required this.currentLevel,
    required this.currentXP,
    required this.requiredXP,
    required this.userClass,
    required this.userAbilities,
    required this.dailyFatigue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double xpPercentage = (currentXP / requiredXP).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Details'),
        // L'icona "freccia indietro" appare automaticamente
        // se non la nascondi, e chiude la pagina col pop()
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$userName - Level $currentLevel',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8.0),

            // XP bar
            LinearProgressIndicator(
              value: xpPercentage,
              minHeight: 8.0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8.0),

            Text(
              '${currentXP.toInt()} / ${requiredXP.toInt()} XP',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),

            // Info Classe
            Text(
              'Class: $userClass',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Abilities: $userAbilities',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4.0),
            Text(
              "Today's fatigue: $dailyFatigue/100",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dailyFatigue > 100
                        ? Colors.red
                        : dailyFatigue > 50
                            ? Colors.orange
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  ),
            ),

            // Spazio per ulteriori dettagli
            const SizedBox(height: 16.0),
            const Divider(),

            Text(
              'Additional Details',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              // Add more data or make it dynamic
              'Here you can include additional statistics, narrative descriptions, historical progress of the level, etc.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
