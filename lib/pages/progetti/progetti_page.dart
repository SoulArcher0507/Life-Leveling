import 'package:flutter/material.dart';
import 'package:life_leveling/models/project_models.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/pages/quests/quest_detail_page.dart';

// Possibili stati di una attività. Invece di avere una stringa vuota come
// primo elemento (che risultava in uno stato "senza titolo"), definiamo
// esplicitamente i quattro stati utilizzati nell'app. I nomi sono
// tradotti in italiano per coerenza con l'interfaccia utente.
const List<String> kTaskStatusOptions = [
  'Da fare',         // attività da iniziare
  'In corso',        // attività attualmente in lavorazione
  'Bloccata',        // attività che ha incontrato un impedimento
  'Completata',      // attività terminata
];

const double kItemColumnWidth = 200;
const double kValueColumnWidth = 120;
const double kActionsColumnWidth = 60;

class ProgettiPage extends StatefulWidget {
  const ProgettiPage({Key? key}) : super(key: key);

  @override
  State<ProgettiPage> createState() => _ProgettiPageState();
}

class _ProgettiPageState extends State<ProgettiPage> {
  late List<Workspace> _workspaces;
  int _selectedWorkspace = 0;

  void _toggleTaskStatus(BoardItem item) {
    final currentIndex = kTaskStatusOptions.indexOf(item.values.first);
    final nextIndex = (currentIndex + 1) % kTaskStatusOptions.length;
    setState(() {
      item.values[0] = kTaskStatusOptions[nextIndex];
    });
  }

  Future<void> _openQuestDetails(
    BoardItem item,
    List<BoardItem> parentList,
  ) async {
    if (item.quest == null) return;
    final deleted = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestDetailsPage(quest: item.quest!),
      ),
    );
    if (deleted == true) {
      setState(() {
        parentList.remove(item);
      });
    }
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  void initState() {
    super.initState();
    // Preimpostiamo la lista dei workspace a vuota per evitare accessi a
    // variabili non inizializzate nella build(). Il servizio delle
    // quest viene inizializzato in main.dart, quindi qui ci limitiamo
    // a generare i dati di esempio se necessario.
    _workspaces = _createSampleData();
  }

  @override
  Widget build(BuildContext context) {
    final workspace = _workspaces[_selectedWorkspace];
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              DropdownButton<int>(
                value: _selectedWorkspace,
                onChanged: (index) {
                  if (index != null) {
                    setState(() => _selectedWorkspace = index);
                  }
                },
                items: [
                  for (int i = 0; i < _workspaces.length; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(_workspaces[i].name),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddWorkspaceDialog,
                icon: const Icon(Icons.add),
                label: const Text('Nuovo Workspace'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final board in workspace.boards) _buildBoard(board),
              for (final folder in workspace.folders) _buildFolder(folder),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddBoardDialog(workspace),
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi Board'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFolder(WorkspaceFolder folder) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(folder.name),
        children: [
          for (final board in folder.boards) _buildBoard(board),
          for (final sub in folder.subFolders) _buildFolder(sub),
        ],
      ),
    );
  }

  Widget _buildBoard(Board board) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(board.name),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Aggiungi Gruppo',
              onPressed: () => _showAddGroupDialog(board),
            ),
          ],
        ),
        children: [
          for (final group in board.groups) _buildGroup(board, group),
        ],
      ),
    );
  }

  Widget _buildGroup(Board board, BoardGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: group.color,
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                group.name,
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                onPressed: () => _showAddTaskDialog(board, group),
                icon: const Icon(Icons.add, color: Colors.white),
                tooltip: 'Aggiungi Attività',
              )
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Builder(
            builder: (context) {
              final screenWidth = MediaQuery.of(context).size.width;
              final minWidth = kItemColumnWidth +
                  board.columns.length * kValueColumnWidth +
                  kActionsColumnWidth;
              final tableWidth = screenWidth > minWidth ? screenWidth : minWidth;
              final valueWidth =
                  (tableWidth - kItemColumnWidth - kActionsColumnWidth) /
                      board.columns.length;
              final columnCount = board.columns.length;
              return SizedBox(
                width: tableWidth,
                child: DataTable(
                  showCheckboxColumn: false,
                  columnSpacing: 0,
                  columns: [
                    // Colonna per il titolo dell'elemento
                    const DataColumn(
                        label: SizedBox(
                          width: kItemColumnWidth,
                          child: Text('Elemento'),
                        )),
                    // Colonne dinamiche del board (es. Stato, Scadenza)
                ...board.columns.map((c) => DataColumn(
                        label: SizedBox(
                          width: valueWidth,
                          child: Text(c),
                        ))),
                // Colonna vuota per le azioni
                const DataColumn(
                    label: SizedBox(width: kActionsColumnWidth, child: Text(''))),
                  ],
                  rows: [
                for (final item in group.items)
                  ..._buildItemRows(
                    item,
                    parentList: group.items,
                    columnCount: columnCount,
                    valueWidth: valueWidth,
                  ),
              ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Costruisce le righe di una tabella per un elemento e i suoi eventuali
  /// sotto-elementi. Il numero di celle per ogni riga deve corrispondere
  /// esattamente al numero di colonne della DataTable (colonna "Item", una
  /// colonna per ogni valore e la colonna delle azioni). Per evitare
  /// assert di Flutter dovuti a liste di valori più corte o più lunghe,
  /// riceviamo il numero di colonne da generare e generiamo celle vuote
  /// quando necessario.
  List<DataRow> _buildItemRows(
    BoardItem item, {
    required List<BoardItem> parentList,
    required int columnCount,
    int indent = 0,
    required double valueWidth,
  }) {
    // Primo DataCell con il titolo dell'elemento (e icona per indentazione)
    final firstCell = Padding(
      padding: EdgeInsets.only(left: indent * 16.0),
      child: Row(
        children: [
          if (indent > 0)
            const Icon(Icons.subdirectory_arrow_right,
                size: 16, color: Colors.grey),
          if (indent > 0) const SizedBox(width: 4),
          Text(
            item.title,
            style: indent > 0 ? TextStyle(color: Colors.grey[600]) : null,
          ),
        ],
      ),
    );

    final cells = <DataCell>[
      DataCell(
        SizedBox(width: kItemColumnWidth, child: firstCell),
        onTap: () => _openQuestDetails(item, parentList),
      )
    ];
    // Genera una DataCell per ogni colonna definita nel board. Se il numero
    // di valori dell'elemento è inferiore, riempiamo con stringhe vuote.
    for (int i = 0; i < columnCount; i++) {
      final value = i < item.values.length ? item.values[i] : '';
      if (i == 0) {
        // La prima colonna dopo il titolo rappresenta lo stato e consente
        // di ciclarlo al tocco.
        cells.add(
          DataCell(
            SizedBox(
              width: valueWidth,
              child: InkWell(
                onTap: () => _toggleTaskStatus(item),
                child: _statusChip(value.isNotEmpty ? value : kTaskStatusOptions.first),
              ),
            ),
          ),
        );
      } else {
        cells.add(DataCell(SizedBox(width: valueWidth, child: Text(value))));
      }
    }

    // Colonna delle azioni (aggiunta di sotto‑attività)
    cells.add(
      DataCell(
        SizedBox(
          width: kActionsColumnWidth,
          child: IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Aggiungi Sottoattività',
            onPressed: () => _showAddSubtaskDialog(item),
          ),
        ),
      ),
    );

    final row = DataRow(
      color: MaterialStateProperty.resolveWith(
        (states) {
          // se non ci sono valori, usa il colore dello stato iniziale
          final status = (item.values.isNotEmpty ? item.values.first : kTaskStatusOptions.first);
          return _statusColor(status).withOpacity(0.2);
        },
      ),
      cells: cells,
    );

    final rows = <DataRow>[row];
    // Ricorsivamente aggiunge le sotto-righe per le sotto-attività
    for (final sub in item.subItems) {
      rows.addAll(
        _buildItemRows(
          sub,
          parentList: item.subItems,
          columnCount: columnCount,
          indent: indent + 1,
          valueWidth: valueWidth,
        ),
      );
    }
    return rows;
  }

  Future<void> _showAddWorkspaceDialog() async {
    final nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuovo Workspace'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nome Workspace'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _workspaces.add(Workspace(name: nameController.text, boards: []));
                _selectedWorkspace = _workspaces.length - 1;
              });
              Navigator.pop(context);
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddBoardDialog(Workspace workspace) async {
    final nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuovo Board'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nome Board'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                workspace.boards.add(Board(
                  name: nameController.text,
                  // Usa intestazioni italiane per le colonne di default
                  columns: const ['Stato', 'Scadenza'],
                  groups: [],
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddGroupDialog(Board board) async {
    final nameController = TextEditingController();
    Color selectedColor = Colors.grey;
    // Opzioni di colore con etichette italiane
    const colorOptions = {
      'Grigio': Colors.grey,
      'Blu': Colors.blue,
      'Verde': Colors.green,
      'Rosso': Colors.red,
      'Arancione': Colors.orange,
      'Viola': Colors.purple,
      'Rosa': Colors.pink,
      'Turchese': Colors.teal,
    };
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Nuovo Gruppo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome Gruppo'),
              ),
              const SizedBox(height: 8),
              DropdownButton<Color>(
                value: selectedColor,
                onChanged: (color) {
                  if (color != null) setModalState(() => selectedColor = color);
                },
                items: [
                  for (final entry in colorOptions.entries)
                    DropdownMenuItem(
                      value: entry.value,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            color: entry.value,
                            margin: const EdgeInsets.only(right: 8),
                          ),
                          Text(entry.key),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  board.groups.add(BoardGroup(
                    name: nameController.text,
                    color: selectedColor,
                    items: [],
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text('Aggiungi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddTaskDialog(Board board, BoardGroup group) async {
    final titleController = TextEditingController();
    String selectedStatus = kTaskStatusOptions.first;
    final dueController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Nuova Attività'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titolo'),
              ),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedStatus = val);
                },
                items: [
                  for (final status in kTaskStatusOptions)
                    DropdownMenuItem(
                      value: status,
                      child: _statusChip(status),
                    ),
                ],
                decoration: const InputDecoration(labelText: 'Stato'),
              ),
              TextField(
                controller: dueController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Scadenza'),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null) {
                    dueController.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  group.items.add(BoardItem(
                    title: titleController.text,
                    values: [selectedStatus, dueController.text],
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text('Aggiungi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddSubtaskDialog(BoardItem parent) async {
    final titleController = TextEditingController();
    String selectedStatus = kTaskStatusOptions.first;
    final dueController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Nuova Sottoattività'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titolo'),
              ),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedStatus = val);
                },
                items: [
                  for (final status in kTaskStatusOptions)
                    DropdownMenuItem(
                      value: status,
                      child: _statusChip(status),
                    ),
                ],
                decoration: const InputDecoration(labelText: 'Stato'),
              ),
              TextField(
                controller: dueController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Scadenza'),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null) {
                    dueController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  parent.subItems.add(
                    BoardItem(
                      title: titleController.text,
                      values: [selectedStatus, dueController.text],
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Aggiungi'),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    // Mappa lo stato a un colore specifico. I nomi sono in italiano.
    switch (status) {
      case 'Da fare':
        return Colors.blueGrey;
      case 'In corso':
        return Colors.orange;
      case 'Bloccata':
        return Colors.red;
      case 'Completata':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<Workspace> _createSampleData() {
    final service = QuestService();
    void maybeAddQuest(QuestData q) {
      // Aggiunge la quest solo se l'elenco è vuoto. Questo evita che le
      // quest di esempio vengano duplicate ad ogni avvio dell'app. Il
      // controllo sul titolo/data è stato sostituito da id univoco in
      // QuestData, quindi non serve più qui.
      if (service.allQuests.isEmpty) {
        service.addQuest(q);
      }
    }
    final board = Board(
      // Nome tradotto in italiano per coerenza
      name: 'Bacheca di esempio',
      // Colonne di default in italiano: Stato e Scadenza
      columns: ['Stato', 'Scadenza'],
      groups: [
        BoardGroup(
          // Gruppo per le attività da fare
          name: 'Da fare',
          color: Colors.blue,
          items: [
            () {
              final q = QuestData(
                title: 'Task 1',
                deadline: DateTime.parse('2023-12-01'),
                isDaily: false,
                xp: 10,
                notes: '',
                fatigue: 5,
              );
              maybeAddQuest(q);
              return BoardItem(
                title: 'Task 1',
                xp: 10,
                fatigue: 5,
                // Stato "In corso" per indicare che l'attività è stata iniziata
                values: ['In corso', '2023-12-01'],
                quest: q,
                subItems: [
                  () {
                    final sq = QuestData(
                      title: 'Subtask 1',
                      deadline: DateTime.now(),
                      isDaily: false,
                      xp: 5,
                      notes: '',
                      fatigue: 3,
                    );
                    maybeAddQuest(sq);
                    return BoardItem(
                      title: 'Subtask 1',
                      xp: 5,
                      fatigue: 3,
                      // Sotto-attività completata
                      values: ['Completata', ''],
                      quest: sq,
                    );
                  }(),
                ],
              );
            }(),
            () {
              final q = QuestData(
                title: 'Task 2',
                deadline: DateTime.parse('2023-11-15'),
                isDaily: false,
                xp: 15,
                notes: '',
                fatigue: 7,
              );
              maybeAddQuest(q);
              return BoardItem(
                title: 'Task 2',
                xp: 15,
                fatigue: 7,
                // Stato bloccata
                values: ['Bloccata', '2023-11-15'],
                quest: q,
              );
            }(),
          ],
        ),
        BoardGroup(
          // Gruppo per le attività completate
          name: 'Completate',
          color: Colors.green,
          items: [
            () {
              final q = QuestData(
                title: 'Task 3',
                deadline: DateTime.parse('2023-10-01'),
                isDaily: false,
                xp: 20,
                notes: '',
                fatigue: 10,
              );
              maybeAddQuest(q);
              return BoardItem(
                title: 'Task 3',
                xp: 20,
                fatigue: 10,
                // Attività completata
                values: ['Completata', '2023-10-01'],
                quest: q,
              );
            }(),
          ],
        ),
      ],
    );

    return [
      Workspace(name: 'Workspace principale', boards: [board]),
    ];
  }
}
