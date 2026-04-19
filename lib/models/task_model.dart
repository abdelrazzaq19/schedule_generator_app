class Task {
  final String id;
  final String title;
  final int duration; // in minutes
  final int priority; // 1=Low, 2=Medium, 3=High
  final DateTime? deadline;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.duration,
    required this.priority,
    this.deadline,
    this.isCompleted = false,
  });

  String get priorityLabel => ['', 'Low', 'Medium', 'High'][priority];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'duration': duration,
        'priority': priority,
        'deadline': deadline?.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        duration: json['duration'],
        priority: json['priority'],
        deadline:
            json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
        isCompleted: json['isCompleted'] ?? false,
      );

  Task copyWith({
    String? id,
    String? title,
    int? duration,
    int? priority,
    DateTime? deadline,
    bool? isCompleted,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        duration: duration ?? this.duration,
        priority: priority ?? this.priority,
        deadline: deadline ?? this.deadline,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}