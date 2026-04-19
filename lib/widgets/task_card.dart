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
        const Color(0xFF4CAF79),
        AppTheme.accent,
        AppTheme.danger,
      ][task.priority];

  String get _priorityEmoji => ['', '↓', '→', '↑'][task.priority];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? AppTheme.primary.withOpacity(0.3)
              : borderColor,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onToggleComplete,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? AppTheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted ? AppTheme.primary : borderColor,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 13)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

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
                        color: task.isCompleted ? textSecondary : textPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: textSecondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Priority badge
                        _Badge(
                          label: '$_priorityEmoji ${task.priorityLabel}',
                          color: _priorityColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        // Duration badge
                        _Badge(
                          label: '${task.duration}m',
                          color: textSecondary,
                          isDark: isDark,
                          isNeutral: true,
                        ),
                        if (task.deadline != null) ...[
                          const SizedBox(width: 8),
                          _Badge(
                            label: DateFormat('d MMM').format(task.deadline!),
                            color: AppTheme.accent,
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 18, color: textSecondary),
                iconSize: 18,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                elevation: 4,
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 16, color: textSecondary),
                      const SizedBox(width: 10),
                      Text('Edit',
                          style: TextStyle(fontSize: 14, color: textPrimary)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_outline,
                          size: 16, color: AppTheme.danger),
                      const SizedBox(width: 10),
                      const Text('Hapus',
                          style:
                              TextStyle(fontSize: 14, color: AppTheme.danger)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  final bool isNeutral;

  const _Badge({
    required this.label,
    required this.color,
    required this.isDark,
    this.isNeutral = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNeutral
            ? (isDark ? AppTheme.borderDark : const Color(0xFFEEF1EC))
            : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isNeutral
              ? (isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight)
              : color,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
