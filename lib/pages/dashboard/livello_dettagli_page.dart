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

  const LivelloDettagliPage({
    Key? key,
    required this.userName,
    required this.currentLevel,
    required this.currentXP,
    required this.requiredXP,
    required this.userClass,
    required this.userAbilities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double xpPercentage = (currentXP / requiredXP).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Livello'),
        // L'icona "freccia indietro" appare automaticamente
        // se non la nascondi, e chiude la pagina col pop()
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$userName - Livello $currentLevel',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8.0),

            // Barra XP
            LinearProgressIndicator(
              value: xpPercentage,
              minHeight: 8.0,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8.0),

            Text(
              '${currentXP.toInt()} / ${requiredXP.toInt()} XP',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),

            // Info Classe
            Text(
              'Classe: $userClass',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Abilità: $userAbilities',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // Spazio per ulteriori dettagli
            const SizedBox(height: 16.0),
            const Divider(),

            Text(
              'Dettagli Addizionali',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              // Puoi aggiungere più dati o farlo dinamico
              'Qui puoi inserire ulteriori statistiche, descrizioni narrative, progressi storici del livello, ecc.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
