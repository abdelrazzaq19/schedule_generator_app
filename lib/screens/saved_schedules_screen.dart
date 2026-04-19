import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../widgets/schedule_item_card.dart';

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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: Text('Jadwal "${s.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _storage.deleteSavedSchedule(s.id);
    _load();
  }

  void _viewDetail(SavedSchedule s) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ScheduleDetailScreen(saved: s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Tersimpan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Belum ada jadwal tersimpan',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Generate jadwal lalu tekan "Simpan Jadwal"',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _schedules.length,
                  itemBuilder: (_, i) {
                    final s = _schedules[i];
                    final dateStr = DateFormat('dd MMM yyyy, HH:mm')
                        .format(s.savedAt);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20),
                        ),
                        title: Text(s.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '$dateStr  •  ${s.items.length} item',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _delete(s),
                        ),
                        onTap: () => _viewDetail(s),
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
    final dateStr =
        DateFormat('EEEE, dd MMMM yyyy').format(saved.savedAt);

    return Scaffold(
      appBar: AppBar(title: Text(saved.name)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Row(
              children: [
                Icon(Icons.bookmark,
                    color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(saved.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    Text('Disimpan: $dateStr',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: saved.items.length,
              itemBuilder: (_, i) =>
                  ScheduleItemCard(item: saved.items[i]),
            ),
          ),
        ],
      ),
    );
  }
}
