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
          padding: const EdgeInsets.all(20),
          children: [
            // Title input
            _SectionLabel('Nama Task', isDark: isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              style: TextStyle(color: textPrimary, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Contoh: Buat laporan mingguan',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama task harus diisi'
                  : null,
            ),

            const SizedBox(height: 24),

            // Duration
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _SectionLabel('Durasi', isDark: isDark),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_duration menit',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 16),
                    ),
                    child: Slider(
                      value: _duration.toDouble(),
                      min: 15,
                      max: 240,
                      divisions: 15,
                      onChanged: (v) => setState(() => _duration = v.round()),
                    ),
                  ),
                  Row(
                    children: [
                      Text('15m',
                          style: TextStyle(fontSize: 11, color: textSecondary)),
                      const Spacer(),
                      Text('4h',
                          style: TextStyle(fontSize: 11, color: textSecondary)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Priority
            _SectionLabel('Prioritas', isDark: isDark),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PriorityCard(
                    label: 'Rendah',
                    icon: '↓',
                    value: 1,
                    color: const Color(0xFF4CAF79),
                    selected: _priority == 1,
                    isDark: isDark,
                    onTap: () => setState(() => _priority = 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PriorityCard(
                    label: 'Sedang',
                    icon: '→',
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
                    icon: '↑',
                    value: 3,
                    color: AppTheme.danger,
                    selected: _priority == 3,
                    isDark: isDark,
                    onTap: () => setState(() => _priority = 3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Deadline
            _SectionLabel('Deadline', isDark: isDark),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 18, color: textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _deadline != null
                          ? DateFormat('dd MMMM yyyy').format(_deadline!)
                          : 'Pilih tanggal (opsional)',
                      style: TextStyle(
                        color: _deadline != null ? textPrimary : textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: AppTheme.danger),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(
                    widget.task == null ? 'Tambah Task' : 'Simpan Perubahan'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color:
            isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  final String label;
  final String icon;
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(icon,
                style: TextStyle(
                  fontSize: 20,
                  color: selected
                      ? color
                      : (isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight),
                )),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? color
                    : (isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
