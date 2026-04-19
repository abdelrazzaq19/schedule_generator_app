import 'package:flutter/material.dart';
import '../models/schedule_item_model.dart';

class ScheduleItemCard extends StatelessWidget {
  final ScheduleItem item;
  const ScheduleItemCard({super.key, required this.item});

  bool get _isBreak => item.taskId == 'break';

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time
        SizedBox(
          width: 65,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.startTime,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(item.endTime,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Timeline
        Column(
          children: [
            const SizedBox(height: 18),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isBreak
                    ? Colors.brown.shade300
                    : const Color(0xFF6C63FF),
              ),
            ),
            Container(width: 2, height: 64, color: Colors.grey.shade200),
          ],
        ),
        const SizedBox(width: 12),

        // Content card
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isBreak ? Colors.brown.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isBreak
                    ? Colors.brown.shade100
                    : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_isBreak ? '☕' : '📌',
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.taskTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _isBreak
                              ? Colors.brown.shade700
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(item.notes,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}