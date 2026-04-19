import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/schedule_item_model.dart';
import '../services/storage_service.dart';
import '../widgets/schedule_item_card.dart';
import 'saved_schedules_screen.dart';

class ScheduleScreen extends StatelessWidget {
  final List<ScheduleItem> schedule;
  const ScheduleScreen({super.key, required this.schedule});

  Future<void> _saveSchedule(BuildContext context) async {
    final nameController = TextEditingController(
      text: 'Jadwal ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
    );

    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Simpan Jadwal'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Jadwal',
            hintText: 'Contoh: Jadwal Senin',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
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
          content: Text('✅ Jadwal berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Simpan Jadwal',
            onPressed: () => _saveSchedule(context),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Jadwal Tersimpan',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SavedSchedulesScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI-Optimized Schedule',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(today,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: schedule.isEmpty
                ? const Center(child: Text('Tidak ada jadwal.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: schedule.length,
                    itemBuilder: (_, i) =>
                        ScheduleItemCard(item: schedule[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _saveSchedule(context),
        icon: const Icon(Icons.bookmark_add),
        label: const Text('Simpan Jadwal'),
      ),
    );
  }
}
