import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../main.dart';
import '../models/app_settings_model.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = StorageService();
  AppSettings _settings = const AppSettings();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _storage.loadSettings();
    setState(() => _settings = s);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _storage.saveSettings(_settings);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Settings tersimpan!'),
            backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final time = isStart ? _settings.workStartTime : _settings.workEndTime;
    final parts = time.split(':');
    final initial =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final str =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() => _settings = isStart
          ? _settings.copyWith(workStartTime: str)
          : _settings.copyWith(workEndTime: str));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ScheduleAIApp.of(context);
    final isDark = appState?.isDark ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Dark Mode ---
          _SectionLabel('Tampilan'),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              subtitle: Text(isDark ? 'Tema gelap aktif' : 'Tema terang aktif'),
              value: isDark,
              activeColor: AppTheme.primary,
              onChanged: (_) => appState?.toggleTheme(),
            ),
          ),
          const SizedBox(height: 16),

          // --- Jam Kerja ---
          _SectionLabel('Jam Kerja'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.wb_sunny_outlined),
                  title: const Text('Mulai'),
                  trailing: Text(_settings.workStartTime,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _pickTime(true),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.nights_stay_outlined),
                  title: const Text('Selesai'),
                  trailing: Text(_settings.workEndTime,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _pickTime(false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- Break ---
          _SectionLabel('Pengaturan Break'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.coffee_outlined),
                  title: const Text('Durasi Break'),
                  trailing: _StepperWidget(
                    value: _settings.breakDuration,
                    unit: 'min',
                    min: 5,
                    max: 60,
                    step: 5,
                    onChanged: (v) => setState(
                        () => _settings = _settings.copyWith(breakDuration: v)),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Break Setiap'),
                  trailing: _StepperWidget(
                    value: _settings.breakInterval,
                    unit: 'jam',
                    min: 1,
                    max: 4,
                    step: 1,
                    onChanged: (v) => setState(
                        () => _settings = _settings.copyWith(breakInterval: v)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Simpan Settings'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
              letterSpacing: 0.5)),
    );
  }
}

class _StepperWidget extends StatelessWidget {
  final int value, min, max, step;
  final String unit;
  final ValueChanged<int> onChanged;

  const _StepperWidget({
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > min ? () => onChanged(value - step) : null,
          iconSize: 20,
        ),
        Text('$value $unit',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < max ? () => onChanged(value + step) : null,
          iconSize: 20,
        ),
      ],
    );
  }
}
