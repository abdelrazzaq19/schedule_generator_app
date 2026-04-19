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
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8, top: 2),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            'ScheduleAI',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          'AI-powered daily planner',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: textSecondary,
                            letterSpacing: 0.1,
                          ),
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
                            builder: (_) => const SettingsScreen()),
                      );
                      _loadData();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Hero card ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _HeroCard(
                pendingCount: pendingCount,
                completedCount: completedCount,
                total: _tasks.length,
                isGenerating: _isGenerating,
                isDark: isDark,
                onGenerate: _generateSchedule,
              ),
            ),

            const SizedBox(height: 28),

            // ── Task list header ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Tasks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_tasks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_tasks.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (_tasks.isNotEmpty)
                    GestureDetector(
                      onTap: _addTask,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded,
                                size: 14, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            const Text(
                              'Tambah',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Task list ───────────────────────────────────
            Expanded(
              child: _tasks.isEmpty
                  ? _EmptyState(isDark: isDark, onAdd: _addTask)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
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
      floatingActionButton: _tasks.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _addTask,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, size: 26),
            ),
    );
  }
}

// ── Icon Button ──────────────────────────────────────────

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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

// ── Hero Card ──────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final int pendingCount;
  final int completedCount;
  final int total;
  final bool isGenerating;
  final bool isDark;
  final VoidCallback onGenerate;

  const _HeroCard({
    required this.pendingCount,
    required this.completedCount,
    required this.total,
    required this.isGenerating,
    required this.isDark,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completedCount / total;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C896), Color(0xFF00A87E), Color(0xFF008F6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -4,
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
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.auto_awesome_rounded,
                              size: 11, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'AI SCHEDULER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$pendingCount',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -3,
                              height: 0.95,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pendingCount == 1 ? 'task pending' : 'tasks pending',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13.5,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Generate button
              GestureDetector(
                onTap: isGenerating ? null : onGenerate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.primary,
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.auto_awesome_rounded,
                                size: 20, color: AppTheme.primary),
                            SizedBox(height: 6),
                            Text(
                              'Generate',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 20),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$completedCount dari $total selesai',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: Colors.white,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAdd;

  const _EmptyState({required this.isDark, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 28,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai tambahkan task dan biarkan AI mengaturkan jadwal harimu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah Task Pertama'),
            ),
          ],
        ),
      ),
    );
  }
}
