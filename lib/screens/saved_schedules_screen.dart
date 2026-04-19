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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_border_rounded,
                          size: 38,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Belum ada jadwal tersimpan',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -0.3,
                          )),
                      const SizedBox(height: 6),
                      Text('Generate lalu simpan jadwal pertama Anda',
                          style: TextStyle(fontSize: 13, color: textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _schedules.length,
                  itemBuilder: (_, i) {
                    final s = _schedules[i];
                    final dateStr =
                        DateFormat('d MMM yyyy · HH:mm').format(s.savedAt);
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => _ScheduleDetailScreen(saved: s)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: textPrimary,
                                        letterSpacing: -0.2,
                                      )),
                                  const SizedBox(height: 3),
                                  Text(
                                    '$dateStr  ·  ${s.items.length} item',
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: AppTheme.danger, size: 18),
                              onPressed: () => _delete(s),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

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
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppTheme.accent.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bookmark_rounded,
                      color: AppTheme.accent, size: 15),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(saved.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: textPrimary,
                        )),
                    Text('Disimpan: $dateStr',
                        style: TextStyle(fontSize: 11, color: textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              itemCount: saved.items.length,
              itemBuilder: (_, i) => ScheduleItemCard(item: saved.items[i]),
            ),
          ),
        ],
      ),
    );
  }
}
