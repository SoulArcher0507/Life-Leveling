// dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:life_leveling/models/models.dart';

class DashboardPage extends StatelessWidget {
  final User user;
  final List<Quest> quests;

  const DashboardPage({
    Key? key,
    required this.user,
    required this.quests,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtra le quest
    List<Quest> highPriorityQuests = quests.where((q) => q.isHighPriority).toList();
    List<Quest> dailyQuests = quests.where((q) => q.isDaily).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserCard(context),
          SizedBox(height: 20),
          
          // Quest ad alta priorità
          _buildSectionHeader(
            context, 
            title: "Quest ad alta priorità",
            onTap: () {
              // Vai alla sezione Quests e filtra su "alta priorità"
              // Per esempio, potresti cambiare l'index del BottomNavigationBar
              // Oppure usare un Navigator.push a una pagina Quests
            },
          ),
          _buildQuestList(context, highPriorityQuests),

          SizedBox(height: 20),

          // Quest giornaliere
          _buildSectionHeader(
            context,
            title: "Quest giornaliere",
            onTap: () {
              // Vai alla sezione Quests e filtra su "giornaliere"
            },
          ),
          _buildQuestList(context, dailyQuests),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    double progress = user.currentExp / user.expToLevelUp;
    if (progress > 1.0) progress = 1.0; // Non superare il 100%

    return GestureDetector(
      onTap: () {
        // Apri pagina con i dettagli del livello e abilità
      },
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                "Classe: ${user.userClass}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text("Livello: ${user.level}"),
              SizedBox(height: 8),

              // Barra dell'esperienza
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
              SizedBox(height: 8),
              Text(
                "${user.currentExp}/${user.expToLevelUp} EXP",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
          ),
          Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildQuestList(BuildContext context, List<Quest> questList) {
    if (questList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "Nessuna quest disponibile",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: questList.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final quest = questList[index];
        return Card(
          child: ListTile(
            title: Text(quest.title),
            subtitle: Text(
              "Scadenza: ${quest.dueDate.toLocal()}".split(' ')[0],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/questDetail', arguments: quest);
            },
          ),
        );
      },
    );
  }
}
