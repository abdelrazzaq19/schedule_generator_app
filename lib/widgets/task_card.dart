import 'package:Schedule_generator_app/core/theme.dart';
import 'package:Schedule_generator_app/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit, onDelete, onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  Color get _priorityColor => [
        Colors.transparent,
        const Color(0xFF22C55E),
        AppTheme.accent,
        AppTheme.danger,
      ][task.priority];

  IconData get _priorityIcon => [
        Icons.circle_outlined,
        Icons.arrow_downward_rounded,
        Icons.remove_rounded,
        Icons.arrow_upward_rounded,
      ][task.priority];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? (isDark
                ? AppTheme.cardDark.withOpacity(0.6)
                : const Color(0xFFFAFAFA))
            : cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? (isDark
                  ? AppTheme.borderDark.withOpacity(0.5)
                  : const Color(0xFFEEEEEE))
              : borderColor,
          width: 1,
        ),
        boxShadow: task.isCompleted
            ? []
            : [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggleComplete,
          splashColor: AppTheme.primary.withOpacity(0.06),
          highlightColor: AppTheme.primary.withOpacity(0.03),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onToggleComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? AppTheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppTheme.primary
                            : (isDark
                                ? AppTheme.borderDark
                                : const Color(0xFFD1D5DB)),
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: task.isCompleted
                              ? textSecondary.withOpacity(0.7)
                              : textPrimary,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: textSecondary,
                          decorationThickness: 1.5,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _PriorityBadge(
                            label: task.priorityLabel,
                            icon: _priorityIcon,
                            color: _priorityColor,
                            isDark: isDark,
                          ),
                          _MetaBadge(
                            icon: Icons.timer_outlined,
                            label: _formatDuration(task.duration),
                            isDark: isDark,
                          ),
                          if (task.deadline != null)
                            _MetaBadge(
                              icon: Icons.event_rounded,
                              label: DateFormat('d MMM').format(task.deadline!),
                              isDark: isDark,
                              color: AppTheme.accent,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Menu
                SizedBox(
                  width: 32,
                  height: 32,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.more_horiz_rounded,
                        size: 18, color: textSecondary),
                    iconSize: 18,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    color: isDark ? AppTheme.cardDarkElevated : Colors.white,
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.15),
                    onSelected: (v) {
                      if (v == 'edit') onEdit();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        height: 44,
                        child: Row(children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit_rounded,
                                size: 14, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 10),
                          Text('Edit',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary)),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        height: 44,
                        child: Row(children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.delete_rounded,
                                size: 14, color: AppTheme.danger),
                          ),
                          const SizedBox(width: 10),
                          const Text('Hapus',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.danger)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class _PriorityBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _PriorityBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  const _MetaBadge({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color;
    final textColor = c ??
        (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight);
    final bgColor = c != null
        ? c.withOpacity(0.1)
        : (isDark ? AppTheme.borderDark : const Color(0xFFF3F4F6));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
