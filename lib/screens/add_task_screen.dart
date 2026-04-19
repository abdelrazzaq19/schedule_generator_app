import 'package:Schedule_generator_app/core/theme.dart';
import 'package:Schedule_generator_app/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late int _duration;
  late int _priority;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _duration = widget.task?.duration ?? 30;
    _priority = widget.task?.priority ?? 2;
    _deadline = widget.task?.deadline;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Task(
        id: widget.task?.id ?? const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        duration: _duration,
        priority: _priority,
        deadline: _deadline,
        isCompleted: widget.task?.isCompleted ?? false,
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
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
        title: Text(widget.task == null ? 'Tambah Task' : 'Edit Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            // ── Task Name ──────────────────────────────────
            _SectionLabel('Nama Task', textSecondary: textSecondary),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: 'Contoh: Buat laporan mingguan',
                prefixIcon: Icon(Icons.task_alt_rounded,
                    size: 18, color: AppTheme.primary),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama task harus diisi'
                  : null,
            ),

            const SizedBox(height: 28),

            // ── Duration ───────────────────────────────────
            _SectionLabel('Durasi', textSecondary: textSecondary),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.timer_outlined,
                            size: 16, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Estimasi waktu',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _formatDuration(_duration),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 5,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 18),
                    ),
                    child: Slider(
                      value: _duration.toDouble(),
                      min: 15,
                      max: 240,
                      divisions: 15,
                      onChanged: (v) => setState(() => _duration = v.round()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Text('15m',
                            style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                                fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text('4 jam',
                            style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Priority ───────────────────────────────────
            _SectionLabel('Prioritas', textSecondary: textSecondary),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PriorityCard(
                    label: 'Rendah',
                    icon: Icons.arrow_downward_rounded,
                    value: 1,
                    color: const Color(0xFF22C55E),
                    selected: _priority == 1,
                    isDark: isDark,
                    onTap: () => setState(() => _priority = 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PriorityCard(
                    label: 'Sedang',
                    icon: Icons.remove_rounded,
                    value: 2,
                    color: AppTheme.accent,
                    selected: _priority == 2,
                    isDark: isDark,
                    onTap: () => setState(() => _priority = 2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PriorityCard(
                    label: 'Tinggi',
                    icon: Icons.arrow_upward_rounded,
                    value: 3,
                    color: AppTheme.danger,
                    selected: _priority == 3,
                    isDark: isDark,
                    onTap: () => setState(() => _priority = 3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Deadline ───────────────────────────────────
            _SectionLabel('Deadline', textSecondary: textSecondary),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.event_rounded,
                          size: 16, color: AppTheme.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _deadline != null
                            ? DateFormat('EEEE, dd MMMM yyyy')
                                .format(_deadline!)
                            : 'Pilih tanggal deadline (opsional)',
                        style: TextStyle(
                          color:
                              _deadline != null ? textPrimary : textSecondary,
                          fontSize: 14,
                          fontWeight: _deadline != null
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 14, color: AppTheme.danger),
                        ),
                      )
                    else
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: textSecondary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ── Submit button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(
                    widget.task == null ? 'Tambah Task' : 'Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes menit';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h jam' : '$h jam $m menit';
  }
}

// ── Section Label ────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color textSecondary;
  const _SectionLabel(this.text, {required this.textSecondary});

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

// ── Priority Card ────────────────────────────────────────

class _PriorityCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final Color color;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _PriorityCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppTheme.cardDark : Colors.white;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : borderColor,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? color.withOpacity(0.15)
                    : (isDark ? AppTheme.borderDark : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected ? color : textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? color : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
