import 'package:flutter/material.dart';
import 'package:Schedule_generator_app/core/theme.dart';
import 'package:Schedule_generator_app/models/schedule_item_model.dart';
import 'package:Schedule_generator_app/screens/saved_schedules_screen.dart';
import 'package:Schedule_generator_app/services/storage_service.dart';
import 'package:Schedule_generator_app/widgets/schedule_item_card.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ScheduleScreen extends StatelessWidget {
  final List<ScheduleItem> schedule;
  const ScheduleScreen({super.key, required this.schedule});

  Future<void> _saveSchedule(BuildContext context) async {
    final nameController = TextEditingController(
      text: 'Jadwal ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Simpan Jadwal',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: TextField(
          controller: nameController,
          style: TextStyle(
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight),
          decoration: InputDecoration(
            labelText: 'Nama jadwal',
            hintText: 'Contoh: Jadwal Senin',
            prefixIcon: const Icon(Icons.bookmark_rounded,
                size: 18, color: AppTheme.primary),
            filled: true,
            fillColor: isDark ? AppTheme.surfaceDark : AppTheme.bgLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: TextStyle(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    final saved = SavedSchedule(
      id: const Uuid().v4(),
      name: name,
      savedAt: DateTime.now(),
      items: schedule,
    );

    await StorageService().addSavedSchedule(saved);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil disimpan! 🎉'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    // Calculate task vs break count
    final taskCount = schedule.where((s) => s.taskId != 'break').length;
    final breakCount = schedule.where((s) => s.taskId == 'break').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Hari Ini'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded, size: 22),
            onPressed: () => _saveSchedule(context),
            tooltip: 'Simpan Jadwal',
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedSchedulesScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info banner ──────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(isDark ? 0.12 : 0.08),
                  AppTheme.primaryDark.withOpacity(isDark ? 0.06 : 0.04),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primary.withOpacity(isDark ? 0.25 : 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: AppTheme.primary, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dioptimalkan oleh AI',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        today,
                        style: TextStyle(fontSize: 12.5, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatPill(
                        value: '$taskCount',
                        label: 'task',
                        color: AppTheme.primary),
                    const SizedBox(height: 4),
                    _StatPill(
                        value: '$breakCount',
                        label: 'break',
                        color: AppTheme.accent),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: schedule.isEmpty
                ? Center(
                    child: Text('Tidak ada jadwal.',
                        style: TextStyle(color: textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: schedule.length,
                    itemBuilder: (_, i) => ScheduleItemCard(item: schedule[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _saveSchedule(context),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.bookmark_add_rounded, size: 20),
        label: const Text('Simpan Jadwal',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatPill(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
