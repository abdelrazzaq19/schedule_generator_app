import 'package:flutter/material.dart';
import 'package:Schedule_generator_app/core/theme.dart';
import 'package:Schedule_generator_app/main.dart';
import 'package:Schedule_generator_app/models/app_settings_model.dart';
import 'package:Schedule_generator_app/services/storage_service.dart';


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
          backgroundColor: AppTheme.primary,
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = ScheduleAIApp.of(context);
    final isAppDark = appState?.isDark ?? false;

    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final cardColor = isDark ? AppTheme.cardDark : Colors.white;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance
          _GroupLabel('Tampilan', textSecondary: textSecondary),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            children: [
              _ToggleRow(
                icon: isAppDark
                    ? Icons.nights_stay_rounded
                    : Icons.wb_sunny_rounded,
                title: 'Dark Mode',
                subtitle: isAppDark ? 'Tema gelap aktif' : 'Tema terang aktif',
                value: isAppDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onChanged: (_) => appState?.toggleTheme(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Work hours
          _GroupLabel('Jam Kerja', textSecondary: textSecondary),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            children: [
              _TimeRow(
                icon: Icons.wb_twilight_rounded,
                title: 'Jam Mulai',
                time: _settings.workStartTime,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => _pickTime(true),
              ),
              Divider(height: 1, color: borderColor, indent: 52),
              _TimeRow(
                icon: Icons.dark_mode_outlined,
                title: 'Jam Selesai',
                time: _settings.workEndTime,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => _pickTime(false),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Break settings
          _GroupLabel('Pengaturan Break', textSecondary: textSecondary),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            children: [
              _StepperRow(
                icon: Icons.coffee_rounded,
                title: 'Durasi Break',
                value: _settings.breakDuration,
                unit: 'menit',
                min: 5,
                max: 60,
                step: 5,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                borderColor: borderColor,
                onChanged: (v) => setState(
                    () => _settings = _settings.copyWith(breakDuration: v)),
              ),
              Divider(height: 1, color: borderColor, indent: 52),
              _StepperRow(
                icon: Icons.timer_outlined,
                title: 'Break setiap',
                value: _settings.breakInterval,
                unit: 'jam',
                min: 1,
                max: 4,
                step: 1,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                borderColor: borderColor,
                onChanged: (v) => setState(
                    () => _settings = _settings.copyWith(breakInterval: v)),
              ),
            ],
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : const Text('Simpan Settings'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  final Color textSecondary;
  const _GroupLabel(this.text, {required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final List<Widget> children;

  const _SettingsCard({
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color textPrimary;
  final Color textSecondary;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textPrimary)),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _TimeRow({
    required this.icon,
    required this.title,
    required this.time,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppTheme.accent),
            ),
            const SizedBox(width: 14),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textPrimary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(time,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.primary,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final String unit;
  final int min;
  final int max;
  final int step;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final ValueChanged<int> onChanged;

  const _StepperRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textPrimary)),
          const Spacer(),
          // Stepper
          Row(
            children: [
              _StepBtn(
                icon: Icons.remove_rounded,
                enabled: value > min,
                borderColor: borderColor,
                onTap: value > min ? () => onChanged(value - step) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$value $unit',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: textPrimary,
                  ),
                ),
              ),
              _StepBtn(
                icon: Icons.add_rounded,
                enabled: value < max,
                borderColor: borderColor,
                onTap: value < max ? () => onChanged(value + step) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color borderColor;
  final VoidCallback? onTap;

  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppTheme.primary : borderColor,
        ),
      ),
    );
  }
}
