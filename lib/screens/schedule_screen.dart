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
          content: Text('Jadwal berhasil disimpan!'),
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
          // Info banner
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: AppTheme.primary, size: 16),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dioptimalkan oleh AI',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: textPrimary,
                        )),
                    Text(today,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        )),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${schedule.length} item',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: schedule.isEmpty
                ? Center(
                    child: Text('Tidak ada jadwal.',
                        style: TextStyle(color: textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
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
        elevation: 4,
        icon: const Icon(Icons.bookmark_add_rounded),
        label: const Text('Simpan Jadwal',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }
}
