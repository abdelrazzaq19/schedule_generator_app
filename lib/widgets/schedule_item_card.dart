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
        ? (isDark ? AppTheme.accent.withOpacity(0.07) : const Color(0xFFFFFBF0))
        : (isDark ? AppTheme.cardDark : Colors.white);

    final cardBorder = _isBreak
        ? AppTheme.accent.withOpacity(isDark ? 0.25 : 0.2)
        : borderColor;

    // Calculate duration display
    final start = _parseTime(item.startTime);
    final end = _parseTime(item.endTime);
    final durationMin =
        end != null && start != null ? end.difference(start).inMinutes : 0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Time column ────────────────────────────────
          SizedBox(
            width: 54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 14),
                Text(
                  item.startTime,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.endTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // ── Timeline ───────────────────────────────────
          Column(
            children: [
              const SizedBox(height: 17),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        dotColor.withOpacity(0.5),
                        isDark
                            ? AppTheme.borderDark.withOpacity(0.2)
                            : AppTheme.borderLight.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // ── Content card ───────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: dotColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isBreak
                                    ? Icons.coffee_rounded
                                    : Icons.bolt_rounded,
                                size: 11,
                                color: dotColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isBreak ? 'BREAK' : 'TASK',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: dotColor,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Duration pill
                        if (durationMin > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.borderDark
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              _formatDuration(durationMin),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.taskTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.notes,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseTime(String time) {
    try {
      final parts = time.split(':');
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, int.parse(parts[0]),
          int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h${m}m';
  }
}
