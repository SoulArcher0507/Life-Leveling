import 'package:flutter/material.dart';
import 'package:life_leveling/models/project_models.dart';
import 'package:life_leveling/services/project_service.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/pages/quests/quest_detail_page.dart';

// Possible states for a task. We define them explicitly rather than
// including an empty string. These are translated into English.
const List<String> kTaskStatusOptions = [
  'To Do',         // task to be started
  'In progress',   // task currently being worked on
  'Blocked',       // task that has encountered an impediment
  'Completed',     // task finished
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
  // Maintain a list of workspaces obtained from the ProjectService.  We
  // initialise it to an empty list to avoid null accesses while the
  // asynchronous initialisation completes.
  List<Workspace> _workspaces = [];
  int _selectedWorkspace = 0;

  void _toggleTaskStatus(BoardItem item) {
    final currentIndex = kTaskStatusOptions.indexOf(item.values.first);
    final nextIndex = (currentIndex + 1) % kTaskStatusOptions.length;
    setState(() {
      item.values[0] = kTaskStatusOptions[nextIndex];
    });
    // Persist status change
    ProjectService().save();
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
      // Persist removal
      ProjectService().save();
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
    // Initialise the project service.  If no data exists on disk, use
    // the sample data as a starting point.  Once initialised,
    // _workspaces references the service's list so that changes persist.
    final sample = _createSampleData();
    ProjectService().init(sampleData: sample).then((_) {
      setState(() {
        _workspaces = ProjectService().workspaces;
        // Ensure a valid selected workspace index
        if (_selectedWorkspace >= _workspaces.length) {
          _selectedWorkspace = _workspaces.isEmpty ? 0 : _workspaces.length - 1;
        }
      });
    });
  }

  /// Rimuove un board dal workspace corrente o da qualsiasi cartella
  /// ricorsivamente. Dopo la rimozione il widget viene aggiornato.
  void _removeBoard(Board board) {
    final workspace = _workspaces[_selectedWorkspace];
    setState(() {
      // Remove board from top level or subfolders
      if (workspace.boards.remove(board)) {
        // removed
      } else {
        bool removed = false;
        void removeFromFolder(WorkspaceFolder folder) {
          if (folder.boards.remove(board)) {
            removed = true;
            return;
          }
          for (final sub in folder.subFolders) {
            if (!removed) removeFromFolder(sub);
          }
        }
        for (final folder in workspace.folders) {
          if (!removed) removeFromFolder(folder);
        }
      }
    });
    // Persist changes
    ProjectService().save();
  }

  @override
  Widget build(BuildContext context) {
    // If no workspace data has been loaded yet, show a placeholder that
    // prompts the user to create a new workspace.  This prevents a
    // RangeError when accessing an empty list.
    if (_workspaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No workspaces found.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showAddWorkspaceDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Workspace'),
            ),
          ],
        ),
      );
    }

    // At least one workspace is available; display the selected workspace's
    // boards and folders.  Compute the current workspace based on
    // _selectedWorkspace index.
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
                label: const Text('New Workspace'),
              ),
              const SizedBox(width: 8),
              // Delete workspace button.  Only enabled when there is at least one workspace
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete Workspace',
                onPressed: () async {
                  final ws = _workspaces[_selectedWorkspace];
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Workspace'),
                      content: Text(
                          'Are you sure you want to delete the workspace "${ws.name}"? This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    // Remove the workspace via the project service to
                    // persist changes.  The local list _workspaces is a
                    // reference to the service's list, so no separate
                    // removal is needed.
                    await ProjectService().removeWorkspace(ws);
                    setState(() {
                      // Adjust the selected index if the last item was removed
                      if (_selectedWorkspace >= _workspaces.length) {
                        _selectedWorkspace = _workspaces.isEmpty
                            ? 0
                            : _workspaces.length - 1;
                      }
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Display each board in the current workspace
              for (final board in workspace.boards) _buildBoard(board),
              // Display any nested folders (not commonly used in current UI)
              for (final folder in workspace.folders) _buildFolder(folder),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddBoardDialog(workspace),
                icon: const Icon(Icons.add),
                label: const Text('Add Board'),
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
            Row(
              children: [
                // Add Task button.  Adds a task to the default group of this board.
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Task',
                  onPressed: () => _showAddTaskDialog(board),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Board',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Board'),
                        content: Text('Are you sure you want to delete the board "${board.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      _removeBoard(board);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        children: [
          _buildTaskTable(board),
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
                onPressed: () => _showAddTaskDialog(board),
                icon: const Icon(Icons.add, color: Colors.white),
                tooltip: 'Add Task',
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
                          child: Text('Item'),
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

  /// Builds a DataTable that lists all tasks across every group in the
  /// provided [board].  Groups are ignored and their items are flattened
  /// into a single list.  The table uses the board's column definitions to
  /// render each task's status and due date.  An action column allows
  /// adding subtasks.
  Widget _buildTaskTable(Board board) {
    // Flatten items from all groups
    final List<BoardItem> tasks = [];
    for (final g in board.groups) {
      tasks.addAll(g.items);
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final minWidth = kItemColumnWidth + board.columns.length * kValueColumnWidth + kActionsColumnWidth;
    final tableWidth = screenWidth > minWidth ? screenWidth : minWidth;
    final int columnCount = board.columns.length;
    final double valueWidth = (tableWidth - kItemColumnWidth - kActionsColumnWidth) / columnCount;
    return SizedBox(
      width: tableWidth,
      child: DataTable(
        showCheckboxColumn: false,
        columnSpacing: 0,
        columns: [
          const DataColumn(
              label: SizedBox(
            width: kItemColumnWidth,
            child: Text('Item'),
          )),
          ...board.columns.map((c) => DataColumn(
                label: SizedBox(
                  width: valueWidth,
                  child: Text(c),
                ),
              )),
          const DataColumn(
              label: SizedBox(width: kActionsColumnWidth, child: Text(''))),
        ],
        rows: [
          for (final task in tasks) ..._buildItemRows(
            task,
            parentList: tasks,
            columnCount: columnCount,
            valueWidth: valueWidth,
          ),
        ],
      ),
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

    // Action column (add subtask)
    cells.add(
      DataCell(
        SizedBox(
          width: kActionsColumnWidth,
          child: IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Subtask',
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
        title: const Text('New Workspace'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Workspace Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newWs = Workspace(name: nameController.text, boards: []);
              // Persist the new workspace via the project service.  The
              // returned list of workspaces in ProjectService().workspaces
              // already contains the newly added workspace, so we do not
              // re-add it to our local list to avoid duplicates.  We
              // simply update the selected index to the last workspace.
              await ProjectService().addWorkspace(newWs);
              setState(() {
                // _workspaces is a reference to ProjectService().workspaces
                // so it already contains newWs after the call above.
                _selectedWorkspace = _workspaces.length - 1;
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
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
        title: const Text('New Board'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Board Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final board = Board(
                name: nameController.text,
                columns: const ['Status', 'Due'],
                groups: [],
              );
              await ProjectService().addBoard(workspace, board);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddGroupDialog(Board board) async {
    final nameController = TextEditingController();
    Color selectedColor = Colors.grey;
    // Color options with English labels
    const colorOptions = {
      'Grey': Colors.grey,
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Red': Colors.red,
      'Orange': Colors.orange,
      'Purple': Colors.purple,
      'Pink': Colors.pink,
      'Teal': Colors.teal,
    };
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('New Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
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
              child: const Text('Cancel'),
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddTaskDialog(Board board) async {
    final titleController = TextEditingController();
    String selectedStatus = kTaskStatusOptions.first;
    final dueController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
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
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextField(
                controller: dueController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Due'),
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
            child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newItem = BoardItem(
                  title: titleController.text,
                  values: [selectedStatus, dueController.text],
                );
                // Use the project service to add the item to the default group and
                // persist the change.  Afterwards update the UI.
                await ProjectService().addItem(board, newItem);
                if (mounted) {
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
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
          title: const Text('New Subtask'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
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
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextField(
                controller: dueController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Due'),
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  parent.subItems.add(
                    BoardItem(
                      title: titleController.text,
                      values: [selectedStatus, dueController.text],
                    ),
                  );
                });
                // Persist changes to project data
                await ProjectService().save();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    // Map the status to a specific colour. Names are in English.
    switch (status) {
      case 'To Do':
        return Colors.blueGrey;
      case 'In progress':
        return Colors.orange;
      case 'Blocked':
        return Colors.red;
      case 'Completed':
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
    // Create sample tasks for demonstration.  All tasks live in a single
    // default group; groups are not exposed in the UI.
    final task1 = () {
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
        // "In progress" indicates that the task has been started
        values: ['In progress', '2023-12-01'],
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
              // Subtask completed
              values: ['Completed', ''],
              quest: sq,
            );
          }(),
        ],
      );
    }();
    final task2 = () {
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
        // Task blocked
        values: ['Blocked', '2023-11-15'],
        quest: q,
      );
    }();
    final task3 = () {
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
        // Task completed
        values: ['Completed', '2023-10-01'],
        quest: q,
      );
    }();
    final board = Board(
      // Sample board in English for demonstration
      name: 'Sample Board',
      // Default columns in English: Status and Due
      columns: ['Status', 'Due'],
      // Use a single default group to hold all tasks.  Groups are not
      // exposed in the UI, so their name/colour is irrelevant.
      groups: [
        BoardGroup(
          name: 'Default',
          color: Colors.grey,
          items: [task1, task2, task3],
        ),
      ],
    );

    return [
      Workspace(name: 'Main Workspace', boards: [board]),
    ];
  }
}
