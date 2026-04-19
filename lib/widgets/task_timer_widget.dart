import 'dart:async';
import 'package:Schedule_generator_app/core/theme.dart';
import 'package:flutter/material.dart';

class TaskTimerWidget extends StatefulWidget {
  final String taskTitle;
  final int durationMinutes;
  final VoidCallback? onComplete;

  const TaskTimerWidget({
    super.key,
    required this.taskTitle,
    required this.durationMinutes,
    this.onComplete,
  });

  @override
  State<TaskTimerWidget> createState() => _TaskTimerWidgetState();
}

class _TaskTimerWidgetState extends State<TaskTimerWidget>
    with SingleTickerProviderStateMixin {
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinished = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.durationMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isFinished) return;
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _isRunning = false;
            _isFinished = true;
            _timer?.cancel();
            widget.onComplete?.call();
          }
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _isFinished = false;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress =>
      _totalSeconds > 0 ? 1 - (_remainingSeconds / _totalSeconds) : 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final cardColor = isDark ? AppTheme.cardDark : Colors.white;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    final color = _isFinished
        ? const Color(0xFF22C55E)
        : (_isRunning ? AppTheme.primary : AppTheme.info);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isRunning ? color.withOpacity(0.4) : borderColor,
          width: _isRunning ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isRunning
                ? color.withOpacity(0.15)
                : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: _isRunning ? 16 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isFinished
                      ? Icons.check_circle_rounded
                      : Icons.timer_rounded,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isFinished ? 'Selesai! 🎉' : widget.taskTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Reset button
              if (!_isFinished)
                GestureDetector(
                  onTap: _reset,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.borderDark
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 14,
                      color: textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress arc + time display
          SizedBox(
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: _progress,
                    backgroundColor:
                        isDark ? AppTheme.borderDark : const Color(0xFFF3F4F6),
                    color: color,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _isFinished ? color : textPrimary,
                        letterSpacing: -1,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      '${widget.durationMinutes}m task',
                      style: TextStyle(
                        fontSize: 10,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Control buttons
          if (!_isFinished)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _toggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isRunning
                            ? AppTheme.danger.withOpacity(0.1)
                            : color,
                        borderRadius: BorderRadius.circular(12),
                        border: _isRunning
                            ? Border.all(
                                color: AppTheme.danger.withOpacity(0.3))
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 18,
                            color: _isRunning ? AppTheme.danger : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isRunning ? 'Pause' : 'Mulai',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color:
                                  _isRunning ? AppTheme.danger : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF22C55E).withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 16, color: Color(0xFF22C55E)),
                  SizedBox(width: 6),
                  Text(
                    'Task Selesai!',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
