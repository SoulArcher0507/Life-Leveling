import 'package:flutter/material.dart';
import 'package:life_leveling/models/project_models.dart';

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
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedWorkspace,
          labelType: NavigationRailLabelType.all,
          onDestinationSelected: (index) {
            setState(() => _selectedWorkspace = index);
          },
          destinations: [
            for (final ws in _workspaces)
              NavigationRailDestination(
                icon: const Icon(Icons.workspaces_outline),
                label: Text(ws.name),
              ),
          ],
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

  Future<void> _showAddBoardDialog(Workspace workspace) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Board'),
        content: TextField(
          controller: controller,
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
                  name: controller.text,
                  columns: ['Status', 'Due'],
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
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Group'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Group name'),
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
                  name: controller.text,
                  color: Colors.grey,
                  items: [],
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

  Future<void> _showAddTaskDialog(Board board, BoardGroup group) async {
    final titleController = TextEditingController();
    final statusController = TextEditingController();
    final dueController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: statusController,
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
                  values: [statusController.text, dueController.text],
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
