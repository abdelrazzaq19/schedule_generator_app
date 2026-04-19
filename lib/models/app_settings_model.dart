class AppSettings {
  final String workStartTime;
  final String workEndTime;
  final int breakDuration;
  final int breakInterval;

  const AppSettings({
    this.workStartTime = '08:00',
    this.workEndTime = '17:00',
    this.breakDuration = 15,
    this.breakInterval = 2,
  });

  Map<String, dynamic> toJson() => {
        'workStartTime': workStartTime,
        'workEndTime': workEndTime,
        'breakDuration': breakDuration,
        'breakInterval': breakInterval,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        workStartTime: json['workStartTime'] ?? '08:00',
        workEndTime: json['workEndTime'] ?? '17:00',
        breakDuration: json['breakDuration'] ?? 15,
        breakInterval: json['breakInterval'] ?? 2,
      );

  AppSettings copyWith({
    String? workStartTime,
    String? workEndTime,
    int? breakDuration,
    int? breakInterval,
  }) =>
      AppSettings(
        workStartTime: workStartTime ?? this.workStartTime,
        workEndTime: workEndTime ?? this.workEndTime,
        breakDuration: breakDuration ?? this.breakDuration,
        breakInterval: breakInterval ?? this.breakInterval,
      );
}