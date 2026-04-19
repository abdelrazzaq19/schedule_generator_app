class ScheduleItem {
  final String taskId;
  final String taskTitle;
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final String notes;

  ScheduleItem({
    required this.taskId,
    required this.taskTitle,
    required this.startTime,
    required this.endTime,
    this.notes = '',
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
        taskId: json['taskId'] ?? '',
        taskTitle: json['taskTitle'] ?? '',
        startTime: json['startTime'] ?? '',
        endTime: json['endTime'] ?? '',
        notes: json['notes'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'taskTitle': taskTitle,
        'startTime': startTime,
        'endTime': endTime,
        'notes': notes,
      };
}