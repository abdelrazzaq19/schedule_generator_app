import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../models/app_settings_model.dart';
import '../models/schedule_item_model.dart';

class StorageService {
  static const _tasksKey = 'tasks';
  static const _settingsKey = 'settings';
  static const _scheduleKey = 'last_schedule';
  static const _savedSchedulesKey = 'saved_schedules';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_tasksKey);
    if (str == null) return [];
    return (json.decode(str) as List).map((e) => Task.fromJson(e)).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _tasksKey, json.encode(tasks.map((t) => t.toJson()).toList()));
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_settingsKey);
    if (str == null) return const AppSettings();
    return AppSettings.fromJson(json.decode(str));
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, json.encode(settings.toJson()));
  }

  Future<List<ScheduleItem>> loadLastSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_scheduleKey);
    if (str == null) return [];
    return (json.decode(str) as List)
        .map((e) => ScheduleItem.fromJson(e))
        .toList();
  }

  Future<void> saveSchedule(List<ScheduleItem> schedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _scheduleKey, json.encode(schedule.map((s) => s.toJson()).toList()));
  }

  // --- Saved Schedules (dengan nama & tanggal) ---

  Future<List<SavedSchedule>> loadSavedSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_savedSchedulesKey);
    if (str == null) return [];
    return (json.decode(str) as List)
        .map((e) => SavedSchedule.fromJson(e))
        .toList();
  }

  Future<void> addSavedSchedule(SavedSchedule saved) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadSavedSchedules();
    list.insert(0, saved); // terbaru di atas
    await prefs.setString(
        _savedSchedulesKey, json.encode(list.map((s) => s.toJson()).toList()));
  }

  Future<void> deleteSavedSchedule(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadSavedSchedules();
    list.removeWhere((s) => s.id == id);
    await prefs.setString(
        _savedSchedulesKey, json.encode(list.map((s) => s.toJson()).toList()));
  }
}

class SavedSchedule {
  final String id;
  final String name;
  final DateTime savedAt;
  final List<ScheduleItem> items;

  SavedSchedule({
    required this.id,
    required this.name,
    required this.savedAt,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'savedAt': savedAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory SavedSchedule.fromJson(Map<String, dynamic> json) => SavedSchedule(
        id: json['id'],
        name: json['name'],
        savedAt: DateTime.parse(json['savedAt']),
        items: (json['items'] as List)
            .map((e) => ScheduleItem.fromJson(e))
            .toList(),
      );
}
