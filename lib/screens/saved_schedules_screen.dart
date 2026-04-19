import 'package:flutter/material.dart';
import 'package:Schedule_generator_app/core/theme.dart';
import 'package:Schedule_generator_app/services/storage_service.dart';
import 'package:Schedule_generator_app/widgets/schedule_item_card.dart';
import 'package:intl/intl.dart';

class SavedSchedulesScreen extends StatefulWidget {
  const SavedSchedulesScreen({super.key});

  @override
  State<SavedSchedulesScreen> createState() => _SavedSchedulesScreenState();
}

class _SavedSchedulesScreenState extends State<SavedSchedulesScreen> {
  final _storage = StorageService();
  List<SavedSchedule> _schedules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _storage.loadSavedSchedules();
    setState(() {
      _schedules = list;
      _loading = false;
    });
  }

  Future<void> _delete(SavedSchedule s) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Jadwal?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text(
          '"${s.name}" akan dihapus permanen.',
          style: TextStyle(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: TextStyle(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _storage.deleteSavedSchedule(s.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final cardColor = isDark ? AppTheme.cardDark : Colors.white;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Tersimpan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _schedules.isEmpty
              ? _EmptyState(isDark: isDark)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  itemCount: _schedules.length,
                  itemBuilder: (_, i) {
                    final s = _schedules[i];
                    final dateStr =
                        DateFormat('d MMM yyyy · HH:mm').format(s.savedAt);
                    return _ScheduleListItem(
                      schedule: s,
                      dateStr: dateStr,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => _ScheduleDetailScreen(saved: s)),
                      ),
                      onDelete: () => _delete(s),
                    );
                  },
                ),
    );
  }
}

// ── Schedule List Item ───────────────────────────────────

class _ScheduleListItem extends StatelessWidget {
  final SavedSchedule schedule;
  final String dateStr;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ScheduleListItem({
    required this.schedule,
    required this.dateStr,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final taskCount = schedule.items.where((i) => i.taskId != 'break').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 11, color: textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$taskCount tasks',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete button
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.danger, size: 17),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

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
              child: const Center(
                child: Icon(
                  Icons.bookmark_border_rounded,
                  size: 38,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada jadwal tersimpan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate dan simpan jadwal pertama Anda untuk melihatnya di sini',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 13.5, color: textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Schedule Detail Screen ───────────────────────────────

class _ScheduleDetailScreen extends StatelessWidget {
  final SavedSchedule saved;
  const _ScheduleDetailScreen({required this.saved});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(saved.savedAt);
    final taskCount = saved.items.where((i) => i.taskId != 'break').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(saved.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Info bar
          Container(
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(isDark ? 0.08 : 0.07),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppTheme.accent.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.bookmark_rounded,
                      color: AppTheme.accent, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        saved.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Disimpan: $dateStr',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$taskCount tasks',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              itemCount: saved.items.length,
              itemBuilder: (_, i) => ScheduleItemCard(item: saved.items[i]),
            ),
          ),
        ],
      ),
    );
  }
}
