import 'package:flutter/material.dart';
import '../models/schedule_item_model.dart';
import '../core/theme.dart';

class ScheduleItemCard extends StatelessWidget {
  final ScheduleItem item;
  const ScheduleItemCard({super.key, required this.item});

  bool get _isBreak => item.taskId == 'break';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    final dotColor = _isBreak ? AppTheme.accent : AppTheme.primary;
    final cardBg = _isBreak
        ? (isDark
            ? AppTheme.accent.withOpacity(0.08)
            : AppTheme.accent.withOpacity(0.06))
        : (isDark ? AppTheme.cardDark : Colors.white);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time column
          SizedBox(
            width: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 13),
                Text(
                  item.startTime,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.endTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Timeline column
          Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: 1.5,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        dotColor.withOpacity(0.4),
                        borderColor.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      _isBreak ? AppTheme.accent.withOpacity(0.2) : borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: dotColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isBreak ? 'BREAK' : 'TASK',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: dotColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.taskTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.notes,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
