import 'package:flutter/material.dart';
import '../core/theme.dart';

enum TaskFilter { all, pending, completed, highPriority, withDeadline }

enum TaskSort {
  none,
  priorityDesc,
  priorityAsc,
  durationAsc,
  durationDesc,
  deadlineAsc
}

extension TaskFilterLabel on TaskFilter {
  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'Semua';
      case TaskFilter.pending:
        return 'Pending';
      case TaskFilter.completed:
        return 'Selesai';
      case TaskFilter.highPriority:
        return 'Prioritas Tinggi';
      case TaskFilter.withDeadline:
        return 'Ada Deadline';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskFilter.all:
        return Icons.list_rounded;
      case TaskFilter.pending:
        return Icons.pending_actions_rounded;
      case TaskFilter.completed:
        return Icons.check_circle_rounded;
      case TaskFilter.highPriority:
        return Icons.arrow_upward_rounded;
      case TaskFilter.withDeadline:
        return Icons.event_rounded;
    }
  }
}

extension TaskSortLabel on TaskSort {
  String get label {
    switch (this) {
      case TaskSort.none:
        return 'Default';
      case TaskSort.priorityDesc:
        return 'Prioritas ↑';
      case TaskSort.priorityAsc:
        return 'Prioritas ↓';
      case TaskSort.durationAsc:
        return 'Durasi Terpendek';
      case TaskSort.durationDesc:
        return 'Durasi Terpanjang';
      case TaskSort.deadlineAsc:
        return 'Deadline Terdekat';
    }
  }
}

class FilterSortSheet extends StatefulWidget {
  final TaskFilter currentFilter;
  final TaskSort currentSort;
  final Function(TaskFilter, TaskSort) onApply;

  const FilterSortSheet({
    super.key,
    required this.currentFilter,
    required this.currentSort,
    required this.onApply,
  });

  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet> {
  late TaskFilter _filter;
  late TaskSort _sort;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _sort = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.borderDark : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(
            'Filter & Urutkan',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 20),

          // Filter section
          Text(
            'FILTER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TaskFilter.values.map((f) {
              final selected = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary.withOpacity(0.12)
                        : (isDark ? AppTheme.bgDark : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppTheme.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        f.icon,
                        size: 13,
                        color: selected ? AppTheme.primary : textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        f.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? AppTheme.primary : textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Sort section
          Text(
            'URUTKAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TaskSort.values.map((s) {
              final selected = _sort == s;
              return GestureDetector(
                onTap: () => setState(() => _sort = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.info.withOpacity(0.12)
                        : (isDark ? AppTheme.bgDark : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppTheme.info : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppTheme.info : textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Apply button
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filter = TaskFilter.all;
                      _sort = TaskSort.none;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_filter, _sort);
                    Navigator.pop(context);
                  },
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
