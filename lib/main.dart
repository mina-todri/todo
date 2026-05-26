import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/task.dart';
import 'theme/app_colors.dart';
import 'widgets/bottom_sheets/task_editor.dart';
import 'widgets/stat_widgets.dart';
import 'widgets/task_tile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZenTask', // A more "human" name
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        fontFamily: 'Inter', // Suggesting a common professional font
      ),
      home: const TasksScreen(),
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Task> _tasks = [];
  FilterMode _filter = FilterMode.all;
  String _searchQuery = '';
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDemoData();
  }

  void _loadDemoData() {
    final now = DateTime.now();
    _tasks.addAll([
      Task(
        id: '1',
        title: 'Design System Update',
        note: 'Update the primary color palette and component tokens',
        priority: Priority.high,
        createdAt: now,
      ),
      Task(
        id: '2',
        title: 'Weekly Team Sync',
        note: 'Prepare the progress report for the Q3 goals',
        priority: Priority.medium,
        createdAt: now,
      ),
      Task(
        id: '3',
        title: 'Buy Groceries',
        note: 'Milk, Eggs, Bread, and Coffee beans',
        priority: Priority.low,
        createdAt: now,
      ),
      Task(
        id: '4',
        title: 'Gym Session',
        note: 'Leg day focus',
        isDone: true,
        priority: Priority.medium,
        createdAt: now,
      ),
      Task(
        id: '5',
        title: 'Call the Bank',
        priority: Priority.high,
        createdAt: now,
      ),
    ]);
  }

  // --- Getters ---

  int get _doneCount => _tasks.where((t) => t.isDone).length;
  int get _activeCount => _tasks.where((t) => !t.isDone).length;
  double get _progress => _tasks.isEmpty ? 0 : _doneCount / _tasks.length;

  List<Task> get _filteredTasks {
    var list = _tasks.where((t) {
      if (_filter == FilterMode.active && t.isDone) return false;
      if (_filter == FilterMode.done && !t.isDone) return false;
      if (_searchQuery.isNotEmpty &&
          !t.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      return a.priority.index.compareTo(b.priority.index);
    });

    return list;
  }

  // --- Actions ---

  void _handleToggle(String id) {
    setState(() {
      final i = _tasks.indexWhere((t) => t.id == id);
      if (i != -1) _tasks[i].isDone = !_tasks[i].isDone;
    });
    HapticFeedback.lightImpact();
  }

  void _handleDelete(String id) {
    setState(() => _tasks.removeWhere((t) => t.id == id));
    HapticFeedback.mediumImpact();
  }

  void _clearCompleted() {
    setState(() => _tasks.removeWhere((t) => t.isDone));
    HapticFeedback.mediumImpact();
  }

  void _upsertTask({Task? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskEditor(
        existing: existing,
        onSave: (title, note, priority) {
          setState(() {
            if (existing != null) {
              final i = _tasks.indexWhere((t) => t.id == existing.id);
              if (i != -1) {
                _tasks[i] = existing.copyWith(
                  title: title,
                  note: note,
                  priority: priority,
                );
              }
            } else {
              _tasks.add(Task(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                note: note,
                priority: priority,
              ));
            }
          });
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildProgressSection(),
            _buildStatsGrid(),
            _buildFilterTabs(),
            if (_showSearch) _buildSearchField(),
            const SizedBox(height: 8),
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'My Tasks',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ActionIconBtn(
            icon: _showSearch ? Icons.close : Icons.search,
            onTap: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          const SizedBox(width: 8),
          if (_doneCount > 0)
            ActionIconBtn(
              icon: Icons.delete_sweep_outlined,
              onTap: _clearCompleted,
              tooltip: 'Clear completed',
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tasks.isEmpty ? 'No tasks' : '$_doneCount of ${_tasks.length} done',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          StatChip(label: 'Active', count: _activeCount, color: AppColors.primary),
          const SizedBox(width: 10),
          StatChip(label: 'Done', count: _doneCount, color: AppColors.success),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: FilterMode.values.map((mode) {
          final isSelected = _filter == mode;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(mode.name.toUpperCase()),
              selected: isSelected,
              onSelected: (_) => setState(() => _filter = mode),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final filtered = _filteredTasks;
    if (_tasks.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final task = filtered[i];
        return TaskTile(
          task: task,
          onToggle: () => _handleToggle(task.id),
          onDelete: () => _handleDelete(task.id),
          onEdit: () => _upsertTask(existing: task),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => _upsertTask(),
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
