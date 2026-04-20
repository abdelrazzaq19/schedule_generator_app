import 'package:Schedule_generator_app/screens/daily_summary_screen.dart';
import 'package:Schedule_generator_app/widgets/filter_sort_sheet.dart';
import 'package:Schedule_generator_app/widgets/task_search_bar.dart';
import 'package:Schedule_generator_app/widgets/task_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _showStats = false;
  bool _isReordering = false;
  bool _showSearch = false;
  String _searchQuery = '';
  TaskFilter _activeFilter = TaskFilter.all;
  TaskSort _activeSort = TaskSort.none;

  // Bulk selection
  bool _isBulkMode = false;
  final Set<String> _selectedIds = {};

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
    final task = _tasks[index];
    setState(() => _tasks.removeAt(index));
    await _storage.saveTasks(_tasks);
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${task.title}" dihapus'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppTheme.primary,
            onPressed: () {
              setState(() => _tasks.insert(index, task));
              _storage.saveTasks(_tasks);
            },
          ),
        ),
      );
    }
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

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
    _storage.saveTasks(_tasks);
  }

  // ── Bulk actions ─────────────────────────────────────

  void _toggleBulkMode() {
    setState(() {
      _isBulkMode = !_isBulkMode;
      _selectedIds.clear();
      if (_isBulkMode) {
        _isReordering = false;
        _showSearch = false;
        _searchQuery = '';
      }
    });
  }

  void _toggleSelect(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      final displayed = _displayedTasks;
      if (_selectedIds.length == displayed.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(displayed.map((t) => t.id));
      }
    });
  }

  Future<void> _bulkDelete() async {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;
    final removed = _tasks.where((t) => _selectedIds.contains(t.id)).toList();
    setState(() {
      _tasks.removeWhere((t) => _selectedIds.contains(t.id));
      _selectedIds.clear();
      _isBulkMode = false;
    });
    await _storage.saveTasks(_tasks);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count task dihapus'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppTheme.primary,
            onPressed: () {
              setState(() => _tasks.addAll(removed));
              _storage.saveTasks(_tasks);
            },
          ),
        ),
      );
    }
  }

  Future<void> _bulkComplete(bool complete) async {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;
    setState(() {
      for (final t in _tasks) {
        if (_selectedIds.contains(t.id)) t.isCompleted = complete;
      }
      _selectedIds.clear();
      _isBulkMode = false;
    });
    await _storage.saveTasks(_tasks);
    _showSnackBar('$count task ditandai ${complete ? "selesai" : "pending"}');
  }

  // ── Filter & Search ──────────────────────────────────

  List<Task> get _displayedTasks {
    List<Task> result = List.from(_tasks);
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
              (t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    switch (_activeFilter) {
      case TaskFilter.pending:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilter.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.highPriority:
        result = result.where((t) => t.priority == 3).toList();
        break;
      case TaskFilter.withDeadline:
        result = result.where((t) => t.deadline != null).toList();
        break;
      case TaskFilter.all:
        break;
    }
    switch (_activeSort) {
      case TaskSort.priorityDesc:
        result.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case TaskSort.priorityAsc:
        result.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case TaskSort.durationAsc:
        result.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case TaskSort.durationDesc:
        result.sort((a, b) => b.duration.compareTo(a.duration));
        break;
      case TaskSort.deadlineAsc:
        result.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
      case TaskSort.none:
        break;
    }
    return result;
  }

  bool get _hasActiveFilter =>
      _activeFilter != TaskFilter.all || _activeSort != TaskSort.none;

  void _openFilterSort() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSortSheet(
        currentFilter: _activeFilter,
        currentSort: _activeSort,
        onApply: (filter, sort) {
          setState(() {
            _activeFilter = filter;
            _activeSort = sort;
          });
        },
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
    final displayedTasks = _displayedTasks;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              child: Row(
                children: [
                  // Title — tap untuk summary
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DailySummaryScreen(tasks: _tasks)),
                    ),
                    child: Column(
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
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Row(
                            children: [
                              Text(
                                'Tap untuk ringkasan harian',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.chevron_right_rounded,
                                  size: 12, color: textSecondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Action icons (hanya muncul jika ada tasks) ──
                  if (_tasks.isNotEmpty) ...[
                    _IconBtn(
                      icon: Icons.search_rounded,
                      isDark: isDark,
                      isActive: _showSearch,
                      onTap: () => setState(() {
                        _showSearch = !_showSearch;
                        if (!_showSearch) _searchQuery = '';
                        _isBulkMode = false;
                        _isReordering = false;
                      }),
                    ),
                    const SizedBox(width: 5),
                    _IconBtn(
                      icon: _hasActiveFilter
                          ? Icons.filter_alt_rounded
                          : Icons.filter_alt_outlined,
                      isDark: isDark,
                      isActive: _hasActiveFilter,
                      onTap: _openFilterSort,
                    ),
                    const SizedBox(width: 5),
                    _IconBtn(
                      icon: Icons.bar_chart_rounded,
                      isDark: isDark,
                      isActive: _showStats,
                      onTap: () => setState(() => _showStats = !_showStats),
                    ),
                    const SizedBox(width: 5),
                  ],

                  // ── More menu: history + settings digabung ──
                  _MoreMenuBtn(
                    isDark: isDark,
                    onHistory: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SavedSchedulesScreen()),
                    ),
                    onSettings: () async {
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

            const SizedBox(height: 16),

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

            // ── Stats card ─────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _showStats && _tasks.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: TaskStatsCard(tasks: _tasks),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 14),

            // ── Search bar ─────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _showSearch
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                      child: TaskSearchBar(
                        value: _searchQuery,
                        onChanged: (q) => setState(() => _searchQuery = q),
                        onClear: () => setState(() => _searchQuery = ''),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // ── Task list header ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    _isBulkMode ? 'Pilih Task' : 'Tasks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _isBulkMode ? AppTheme.accent : textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_tasks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            (_isBulkMode ? AppTheme.accent : AppTheme.primary)
                                .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isBulkMode
                            ? '${_selectedIds.length} dipilih'
                            : '${displayedTasks.length}${displayedTasks.length != _tasks.length ? '/${_tasks.length}' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color:
                              _isBulkMode ? AppTheme.accent : AppTheme.primary,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (_isBulkMode) ...[
                    GestureDetector(
                      onTap: _selectAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _selectedIds.length == displayedTasks.length
                              ? 'Batal Semua'
                              : 'Pilih Semua',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.info,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _toggleBulkMode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.danger,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    if (_tasks.length > 1 &&
                        !_showSearch &&
                        !_hasActiveFilter) ...[
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isReordering = !_isReordering),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: _isReordering
                                ? AppTheme.accent.withOpacity(0.15)
                                : AppTheme.primary.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: _isReordering
                                ? Border.all(
                                    color: AppTheme.accent.withOpacity(0.3))
                                : null,
                          ),
                          child: Icon(
                            Icons.swap_vert_rounded,
                            size: 15,
                            color: _isReordering
                                ? AppTheme.accent
                                : AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (_tasks.isNotEmpty) ...[
                      GestureDetector(
                        onTap: _toggleBulkMode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.checklist_rounded,
                            size: 15,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (!_isReordering && _tasks.isNotEmpty)
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
                            children: const [
                              Icon(Icons.add_rounded,
                                  size: 14, color: AppTheme.primary),
                              SizedBox(width: 4),
                              Text(
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
                ],
              ),
            ),

            // Hints & active filter indicator
            if (_isReordering)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 5, 24, 0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 11, color: textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      'Tahan dan seret untuk ubah urutan',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),

            if (_hasActiveFilter)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 5, 24, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.filter_alt_rounded,
                              size: 10, color: AppTheme.info),
                          const SizedBox(width: 4),
                          Text(
                            _activeFilter != TaskFilter.all
                                ? _activeFilter.label
                                : _activeSort.label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() {
                        _activeFilter = TaskFilter.all;
                        _activeSort = TaskSort.none;
                      }),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 11,
                          color: textSecondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_searchQuery.isNotEmpty && displayedTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                child: Text(
                  'Tidak ada task dengan kata "$_searchQuery"',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ),

            const SizedBox(height: 8),

            // ── Task list ───────────────────────────────────
            Expanded(
              child: _tasks.isEmpty
                  ? _EmptyState(isDark: isDark, onAdd: _addTask)
                  : _isReordering && !_hasActiveFilter
                      ? ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          itemCount: displayedTasks.length,
                          onReorder: _onReorder,
                          proxyDecorator: (child, index, animation) => Material(
                            color: Colors.transparent,
                            child: child,
                          ),
                          itemBuilder: (_, i) {
                            final task = displayedTasks[i];
                            final realIndex =
                                _tasks.indexWhere((t) => t.id == task.id);
                            return KeyedSubtree(
                              key: ValueKey(task.id),
                              child: Stack(
                                children: [
                                  TaskCard(
                                    task: task,
                                    onEdit: () => _editTask(realIndex),
                                    onDelete: () => _deleteTask(realIndex),
                                    onToggleComplete: () {
                                      setState(() =>
                                          task.isCompleted = !task.isCompleted);
                                      _storage.saveTasks(_tasks);
                                    },
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 0,
                                    bottom: 12,
                                    child: Icon(
                                      Icons.drag_handle_rounded,
                                      size: 18,
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                              .withOpacity(0.4)
                                          : AppTheme.textSecondaryLight
                                              .withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          itemCount: displayedTasks.length,
                          itemBuilder: (_, i) {
                            final task = displayedTasks[i];
                            final realIndex =
                                _tasks.indexWhere((t) => t.id == task.id);
                            final isSelected = _selectedIds.contains(task.id);

                            if (_isBulkMode) {
                              return _BulkTaskItem(
                                key: ValueKey(task.id),
                                task: task,
                                isSelected: isSelected,
                                isDark: isDark,
                                onTap: () => _toggleSelect(task.id),
                              );
                            }

                            return _SwipeToDismissTask(
                              key: ValueKey(task.id),
                              task: task,
                              isDark: isDark,
                              onEdit: () => _editTask(realIndex),
                              onDelete: () => _deleteTask(realIndex),
                              onToggleComplete: () {
                                setState(
                                    () => task.isCompleted = !task.isCompleted);
                                _storage.saveTasks(_tasks);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),

      // ── Bulk action bar ──────────────────────────────
      bottomNavigationBar: _isBulkMode && _selectedIds.isNotEmpty
          ? _BulkActionBar(
              count: _selectedIds.length,
              isDark: isDark,
              onDelete: _bulkDelete,
              onComplete: () => _bulkComplete(true),
              onUncomplete: () => _bulkComplete(false),
            )
          : null,

      floatingActionButton: _tasks.isEmpty || _isReordering || _isBulkMode
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

// ── More Menu Button ─────────────────────────────────────
// Menggabungkan tombol History & Settings menjadi satu popup menu
// agar tidak overflow di header

class _MoreMenuBtn extends StatelessWidget {
  final bool isDark;
  final VoidCallback onHistory;
  final VoidCallback onSettings;

  const _MoreMenuBtn({
    required this.isDark,
    required this.onHistory,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final cardColor = isDark ? AppTheme.cardDark : Colors.white;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.more_vert_rounded, size: 17, color: iconColor),
      ),
      color: cardColor,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (value) {
        if (value == 'history') onHistory();
        if (value == 'settings') onSettings();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'history',
          height: 46,
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.history_rounded,
                    size: 16, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Jadwal Tersimpan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          height: 46,
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.tune_rounded,
                    size: 16, color: AppTheme.info),
              ),
              const SizedBox(width: 10),
              Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Bulk task item ────────────────────────────────────────

class _BulkTaskItem extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _BulkTaskItem({
    super.key,
    required this.task,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppTheme.cardDark : Colors.white;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.08) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : borderColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${task.priorityLabel} · ${task.duration}m',
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            if (task.isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Bulk action bar ──────────────────────────────────────

class _BulkActionBar extends StatelessWidget {
  final int count;
  final bool isDark;
  final VoidCallback onDelete;
  final VoidCallback onComplete;
  final VoidCallback onUncomplete;

  const _BulkActionBar({
    required this.count,
    required this.isDark,
    required this.onDelete,
    required this.onComplete,
    required this.onUncomplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count task dipilih',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Selesai',
                  color: const Color(0xFF22C55E),
                  onTap: onComplete,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.radio_button_unchecked_rounded,
                  label: 'Pending',
                  color: AppTheme.info,
                  onTap: onUncomplete,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.delete_outline_rounded,
                  label: 'Hapus',
                  color: AppTheme.danger,
                  onTap: onDelete,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Swipe to dismiss wrapper ─────────────────────────────

class _SwipeToDismissTask extends StatelessWidget {
  final Task task;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;

  const _SwipeToDismissTask({
    super.key,
    required this.task,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        onDelete();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.danger.withOpacity(0.3), width: 1),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded,
                color: AppTheme.danger, size: 22),
            SizedBox(height: 4),
            Text(
              'Hapus',
              style: TextStyle(
                  color: AppTheme.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      child: TaskCard(
        task: task,
        onEdit: onEdit,
        onDelete: onDelete,
        onToggleComplete: onToggleComplete,
      ),
    );
  }
}

// ── Icon Button ──────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool isActive;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary.withOpacity(0.12)
              : (isDark ? AppTheme.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isActive
                ? AppTheme.primary.withOpacity(0.3)
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive
              ? AppTheme.primary
              : (isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight),
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
      padding: const EdgeInsets.all(20),
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
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                    const SizedBox(height: 10),
                    Text(
                      '$pendingCount',
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -3,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pendingCount == 1 ? 'task pending' : 'tasks pending',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: isGenerating ? null : onGenerate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
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
                            SizedBox(height: 5),
                            Text(
                              'Generate',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 14),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.2),
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check_rounded,
                    size: 30, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 24),
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
