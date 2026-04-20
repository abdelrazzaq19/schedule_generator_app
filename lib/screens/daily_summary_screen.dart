import 'package:Schedule_generator_app/core/theme.dart';
import 'package:Schedule_generator_app/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailySummaryScreen extends StatelessWidget {
  final List<Task> tasks;

  const DailySummaryScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final cardColor = isDark ? AppTheme.cardDark : Colors.white;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;
    final progress = total == 0 ? 0.0 : completed / total;

    final highDone =
        tasks.where((t) => t.priority == 3 && t.isCompleted).length;
    final highTotal = tasks.where((t) => t.priority == 3).length;
    final medDone = tasks.where((t) => t.priority == 2 && t.isCompleted).length;
    final medTotal = tasks.where((t) => t.priority == 2).length;
    final lowDone = tasks.where((t) => t.priority == 1 && t.isCompleted).length;
    final lowTotal = tasks.where((t) => t.priority == 1).length;

    final completedMinutes =
        tasks.where((t) => t.isCompleted).fold(0, (s, t) => s + t.duration);
    final remainingMinutes =
        tasks.where((t) => !t.isCompleted).fold(0, (s, t) => s + t.duration);

    final overdueCount = tasks
        .where((t) =>
            !t.isCompleted &&
            t.deadline != null &&
            t.deadline!.isBefore(DateTime.now()))
        .length;

    final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    String motivationText;
    if (progress == 0) {
      motivationText = 'Ayo mulai kerjakan task hari ini! 💪';
    } else if (progress < 0.3) {
      motivationText = 'Sudah mulai! Teruskan semangat! 🔥';
    } else if (progress < 0.6) {
      motivationText = 'Bagus! Kamu sudah di jalur yang benar! ⚡';
    } else if (progress < 1.0) {
      motivationText = 'Hampir selesai! Tetap fokus! 🎯';
    } else {
      motivationText = 'Luar biasa! Semua task selesai hari ini! 🎉';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Harian'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          // Date header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 13, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  today,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Motivation card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00C896),
                  Color(0xFF00A87E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
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
                Text(
                  motivationText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _BigStat(
                        value: '$completed',
                        label: 'Selesai',
                        icon: Icons.check_circle_rounded),
                    const SizedBox(width: 16),
                    _BigStat(
                        value: '$pending',
                        label: 'Pending',
                        icon: Icons.pending_actions_rounded),
                    const SizedBox(width: 16),
                    _BigStat(
                        value: '$total',
                        label: 'Total',
                        icon: Icons.list_rounded),
                  ],
                ),
                const SizedBox(height: 14),
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Progress hari ini',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
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
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        color: Colors.white,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Time stats
          Row(
            children: [
              Expanded(
                child: _TimeCard(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Waktu Selesai',
                  value: _formatMinutes(completedMinutes),
                  color: const Color(0xFF22C55E),
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeCard(
                  icon: Icons.schedule_rounded,
                  label: 'Waktu Tersisa',
                  value: _formatMinutes(remainingMinutes),
                  color: AppTheme.primary,
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ),
            ],
          ),

          if (overdueCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.danger.withOpacity(0.25), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.danger, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$overdueCount task melewati deadline!',
                      style: const TextStyle(
                        color: AppTheme.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Priority breakdown
          Text(
            'BREAKDOWN PRIORITAS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          if (highTotal > 0)
            _PriorityRow(
              label: 'Prioritas Tinggi',
              done: highDone,
              total: highTotal,
              color: AppTheme.danger,
              icon: Icons.arrow_upward_rounded,
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
            ),
          if (highTotal > 0) const SizedBox(height: 10),

          if (medTotal > 0)
            _PriorityRow(
              label: 'Prioritas Sedang',
              done: medDone,
              total: medTotal,
              color: AppTheme.accent,
              icon: Icons.remove_rounded,
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
            ),
          if (medTotal > 0) const SizedBox(height: 10),

          if (lowTotal > 0)
            _PriorityRow(
              label: 'Prioritas Rendah',
              done: lowDone,
              total: lowTotal,
              color: const Color(0xFF22C55E),
              icon: Icons.arrow_downward_rounded,
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
            ),

          if (total == 0) ...[
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 48, color: textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada task',
                    style: TextStyle(
                        color: textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes == 0) return '0m';
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}j' : '${h}j ${m}m';
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _BigStat(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;

  const _TimeCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final String label;
  final int done;
  final int total;
  final Color color;
  final IconData icon;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;

  const _PriorityRow({
    required this.label,
    required this.done,
    required this.total,
    required this.color,
    required this.icon,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 13, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$done / $total',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  isDark ? AppTheme.borderDark : const Color(0xFFF3F4F6),
              color: color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).round()}% selesai',
              style: TextStyle(
                fontSize: 10.5,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
