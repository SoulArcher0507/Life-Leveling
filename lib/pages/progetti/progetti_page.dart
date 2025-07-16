import 'package:flutter/material.dart';
import 'package:life_leveling/models/project_models.dart';
import 'package:intl/intl.dart';
import 'package:life_leveling/models/quest_model.dart';
import 'package:life_leveling/services/quest_service.dart';
import 'package:life_leveling/pages/quests/quest_detail_page.dart';

const List<String> kTaskStatusOptions = [
  '',
  'Done',
  'Working on it',
  'Stuck',
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
                label: const Text('New Workspace'),
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
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Group',
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
                        ))),
                const DataColumn(
                    label: SizedBox(width: kActionsColumnWidth, child: Text(''))),
                  ],
                  rows: [
                for (final item in group.items)
                  ..._buildItemRows(
                    item,
                    parentList: group.items,
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

  List<DataRow> _buildItemRows(
    BoardItem item, {
    required List<BoardItem> parentList,
    int indent = 0,
    required double valueWidth,
  }) {
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
    for (int i = 0; i < item.values.length; i++) {
      final value = item.values[i];
      if (i == 0) {
        cells.add(
          DataCell(
            SizedBox(
              width: valueWidth,
              child: InkWell(
                onTap: () => _toggleTaskStatus(item),
                child: _statusChip(value),
              ),
            ),
          ),
        );
      } else {
        cells.add(DataCell(SizedBox(width: valueWidth, child: Text(value))));
      }
    }

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
        (states) => _statusColor(item.values.first).withOpacity(0.2),
      ),
      cells: cells,
    );

    final rows = <DataRow>[row];
    for (final sub in item.subItems) {
      rows.addAll(
        _buildItemRows(
          sub,
          parentList: item.subItems,
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
          decoration: const InputDecoration(labelText: 'Workspace name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _workspaces.add(Workspace(name: nameController.text, boards: []));
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
          decoration: const InputDecoration(labelText: 'Board name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                workspace.boards.add(Board(
                  name: nameController.text,
                  columns: const ['Status', 'Due'],
                  groups: [],
                ));
              });
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
                decoration: const InputDecoration(labelText: 'Group name'),
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

  Future<void> _showAddTaskDialog(Board board, BoardGroup group) async {
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
              onPressed: () {
                setState(() {
                  group.items.add(BoardItem(
                    title: titleController.text,
                    values: [selectedStatus, dueController.text],
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case '':
        return Colors.grey;
      case 'Stuck':
        return Colors.red;
      case 'Done':
        return Colors.green;
      case 'Working on it':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  List<Workspace> _createSampleData() {
    final service = QuestService();
    void maybeAddQuest(QuestData q) {
      final exists = service.allQuests.any(
        (quest) =>
            quest.title == q.title &&
            quest.deadline == q.deadline &&
            quest.isDaily == q.isDaily,
      );
      if (!exists) {
        service.addQuest(q);
      }
    }
    final board = Board(
      name: 'Example Board',
      columns: ['Status', 'Due'],
      groups: [
        BoardGroup(
          name: 'To Do',
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
                values: ['Working on it', '2023-12-01'],
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
                      values: ['Done', ''],
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
                values: ['Stuck', '2023-11-15'],
                quest: q,
              );
            }(),
          ],
        ),
        BoardGroup(
          name: 'Done',
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
                values: ['Done', '2023-10-01'],
                quest: q,
              );
            }(),
          ],
        ),
      ],
    );

    return [
      Workspace(name: 'Main Workspace', boards: [board]),
    ];
  }
}
