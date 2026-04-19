import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/task_model.dart';
import '../models/app_settings_model.dart';
import '../services/storage_service.dart';
import '../services/groq_service.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'schedule_screen.dart';
import 'settings_screen.dart';
import 'saved_schedules_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  final _groq = GroqService();

  List<Task> _tasks = [];
  AppSettings _settings = const AppSettings();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await _storage.loadTasks();
    final settings = await _storage.loadSettings();
    setState(() {
      _tasks = tasks;
      _settings = settings;
    });
  }

  Future<void> _addTask() async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    if (result != null) {
      setState(() => _tasks.add(result));
      await _storage.saveTasks(_tasks);
    }
  }

  Future<void> _editTask(int index) async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => AddTaskScreen(task: _tasks[index])),
    );
    if (result != null) {
      setState(() => _tasks[index] = result);
      await _storage.saveTasks(_tasks);
    }
  }

  Future<void> _deleteTask(int index) async {
    setState(() => _tasks.removeAt(index));
    await _storage.saveTasks(_tasks);
  }

  Future<void> _generateSchedule() async {
    if (_tasks.where((t) => !t.isCompleted).isEmpty) {
      _showSnackBar('Tidak ada task pending untuk dijadwalkan.');
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final schedule =
          await _groq.generateSchedule(tasks: _tasks, settings: _settings);
      await _storage.saveSchedule(schedule);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ScheduleScreen(schedule: schedule)),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _tasks.where((t) => !t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JadwalKoe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Jadwal Tersimpan',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SavedSchedulesScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
              _loadData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary + Generate Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFF9C88FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today's Tasks",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('$pendingCount pending',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateSchedule,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: Text(_isGenerating ? 'Generating...' : 'Generate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Task list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text('Tasks',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${_tasks.length} total',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('Belum ada task',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Tap + untuk menambah task pertama',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _tasks.length,
                    itemBuilder: (_, i) => TaskCard(
                      task: _tasks[i],
                      onEdit: () => _editTask(i),
                      onDelete: () => _deleteTask(i),
                      onToggleComplete: () {
                        setState(() =>
                            _tasks[i].isCompleted = !_tasks[i].isCompleted);
                        _storage.saveTasks(_tasks);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
