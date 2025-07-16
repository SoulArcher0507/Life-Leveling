import 'package:flutter/material.dart';
import 'package:life_leveling/models/project_models.dart';

const List<String> kTaskStatusOptions = [
  'Done',
  'Working on it',
  'Stuck',
];

class ProgettiPage extends StatefulWidget {
  const ProgettiPage({Key? key}) : super(key: key);

  @override
  State<ProgettiPage> createState() => _ProgettiPageState();
}

class _ProgettiPageState extends State<ProgettiPage> {
  late List<Workspace> _workspaces;
  int _selectedWorkspace = 0;

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
          child: DataTable(
            columns: [
              const DataColumn(label: Text('Item')),
              ...board.columns.map((c) => DataColumn(label: Text(c))),
            ],
            rows: [
              for (final item in group.items) ..._buildItemRows(item),
            ],
          ),
        ),
      ],
    );
  }

  List<DataRow> _buildItemRows(BoardItem item, {int indent = 0}) {
    final firstCell = Padding(
      padding: EdgeInsets.only(left: indent * 16.0),
      child: Text(item.title,
          style: indent > 0 ? TextStyle(color: Colors.grey[600]) : null),
    );

    final row = DataRow(
      cells: [
        DataCell(firstCell),
        ...item.values.map((v) => DataCell(Text(v))),
      ],
    );

    final rows = <DataRow>[row];
    for (final sub in item.subItems) {
      rows.addAll(_buildItemRows(sub, indent: indent + 1));
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
    final columnControllers = <TextEditingController>[
      TextEditingController(text: 'Status'),
      TextEditingController(text: 'Due'),
    ];
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Board'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Board name'),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Columns'),
                ),
                ...[
                  for (final controller in columnControllers)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TextField(
                        controller: controller,
                        decoration:
                            const InputDecoration(labelText: 'Column name'),
                      ),
                    ),
                ],
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      columnControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Column'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final columns = columnControllers
                    .map((c) => c.text)
                    .where((t) => t.trim().isNotEmpty)
                    .toList();
                setState(() {
                  workspace.boards.add(Board(
                    name: nameController.text,
                    columns: columns.isEmpty ? ['Status', 'Due'] : columns,
                    groups: [],
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

  Future<void> _showAddGroupDialog(Board board) async {
    final nameController = TextEditingController();
    Color selectedColor = Colors.grey;
    const colorOptions = {
      'Grey': Colors.grey,
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Red': Colors.red,
    };
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                  if (color != null) setState(() => selectedColor = color);
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
        builder: (context, setState) => AlertDialog(
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
                  if (val != null) setState(() => selectedStatus = val);
                },
                items: [
                  for (final status in kTaskStatusOptions)
                    DropdownMenuItem(value: status, child: Text(status)),
                ],
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextField(
                controller: dueController,
                decoration: const InputDecoration(labelText: 'Due'),
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

  List<Workspace> _createSampleData() {
    final board = Board(
      name: 'Example Board',
      columns: ['Status', 'Due'],
      groups: [
        BoardGroup(
          name: 'To Do',
          color: Colors.blue,
          items: [
            BoardItem(
              title: 'Task 1',
              values: ['Working on it', '2023-12-01'],
              subItems: [
                BoardItem(
                  title: 'Subtask 1',
                  values: ['Done', ''],
                ),
              ],
            ),
            BoardItem(
              title: 'Task 2',
              values: ['Stuck', '2023-11-15'],
            ),
          ],
        ),
        BoardGroup(
          name: 'Done',
          color: Colors.green,
          items: [
            BoardItem(
              title: 'Task 3',
              values: ['Done', '2023-10-01'],
            ),
          ],
        ),
      ],
    );

    return [
      Workspace(name: 'Main Workspace', boards: [board]),
    ];
  }
}
