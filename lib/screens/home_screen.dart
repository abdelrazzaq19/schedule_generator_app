import 'package:flutter/material.dart';
import 'package:Schedule_generator_app/core/theme.dart';
import 'package:Schedule_generator_app/models/app_settings_model.dart';
import 'package:Schedule_generator_app/models/task_model.dart';
import 'package:Schedule_generator_app/screens/schedule_screen.dart';
import 'package:Schedule_generator_app/screens/settings_screen.dart';
import 'package:Schedule_generator_app/services/groq_service.dart';
import 'package:Schedule_generator_app/services/storage_service.dart';
import 'package:Schedule_generator_app/widgets/task_card.dart';

import 'add_task_screen.dart';
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
          MaterialPageRoute(builder: (_) => ScheduleScreen(schedule: schedule)),
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
        backgroundColor: isError ? AppTheme.danger : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingCount = _tasks.where((t) => !t.isCompleted).length;
    final completedCount = _tasks.where((t) => t.isCompleted).length;

    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ScheduleAI',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      Text(
                        'AI Schedule Generator',
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _IconBtn(
                    icon: Icons.history_rounded,
                    isDark: isDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SavedSchedulesScreen()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(
                    icon: Icons.tune_rounded,
                    isDark: isDark,
                    onTap: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()));
                      _loadData();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Hero stats + generate card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _HeroCard(
                pendingCount: pendingCount,
                completedCount: completedCount,
                total: _tasks.length,
                isGenerating: _isGenerating,
                onGenerate: _generateSchedule,
              ),
            ),

            const SizedBox(height: 24),

            // Task list header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Tasks',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_tasks.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Task list
            Expanded(
              child: _tasks.isEmpty
                  ? _EmptyState(isDark: isDark, onAdd: _addTask)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color:
              isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int pendingCount;
  final int completedCount;
  final int total;
  final bool isGenerating;
  final VoidCallback onGenerate;

  const _HeroCard({
    required this.pendingCount,
    required this.completedCount,
    required this.total,
    required this.isGenerating,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completedCount / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C896), Color(0xFF00A87E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pendingCount',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'tasks pending',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: isGenerating ? null : onGenerate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.primary,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.auto_awesome_rounded,
                                size: 16, color: AppTheme.primary),
                            SizedBox(width: 6),
                            Text(
                              'Generate',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          if (total > 0) ...[
            Row(
              children: [
                Text(
                  '$completedCount/$total selesai',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.25),
                color: Colors.white,
                minHeight: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAdd;

  const _EmptyState({required this.isDark, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 38,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada task',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + untuk mulai menambahkan task',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tambah Task'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
