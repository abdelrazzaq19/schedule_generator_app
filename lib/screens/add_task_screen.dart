import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/task_model.dart';

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
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.task == null ? 'Add Task' : 'Edit Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g., Write project report',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // Duration Slider
              Row(
                children: [
                  const Text('Duration',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text('$_duration min',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary)),
                ],
              ),
              Slider(
                value: _duration.toDouble(),
                min: 15,
                max: 240,
                divisions: 15,
                label: '$_duration min',
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _duration = v.round()),
              ),
              const SizedBox(height: 8),

              // Priority
              const Text('Priority',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _PriorityChip(
                      label: 'Low',
                      value: 1,
                      color: Colors.green,
                      selected: _priority == 1,
                      onTap: () => setState(() => _priority = 1)),
                  const SizedBox(width: 8),
                  _PriorityChip(
                      label: 'Medium',
                      value: 2,
                      color: Colors.orange,
                      selected: _priority == 2,
                      onTap: () => setState(() => _priority = 2)),
                  const SizedBox(width: 8),
                  _PriorityChip(
                      label: 'High',
                      value: 3,
                      color: Colors.red,
                      selected: _priority == 3,
                      onTap: () => setState(() => _priority = 3)),
                ],
              ),
              const SizedBox(height: 24),

              // Deadline
              const Text('Deadline (Optional)',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickDeadline,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_deadline != null
                        ? DateFormat('dd MMM yyyy').format(_deadline!)
                        : 'Set Deadline'),
                  ),
                  if (_deadline != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () => setState(() => _deadline = null),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                      widget.task == null ? 'Add Task' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.value,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.grey.shade100,
          border: Border.all(
              color: selected ? color : Colors.grey.shade300,
              width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : Colors.grey.shade600,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}