import 'package:Schedule_generator_app/core/theme.dart';
import 'package:Schedule_generator_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;
  runApp(ScheduleAIApp(initialDark: isDark));
}

class ScheduleAIApp extends StatefulWidget {
  final bool initialDark;
  const ScheduleAIApp({super.key, required this.initialDark});

  static _ScheduleAIAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ScheduleAIAppState>();

  @override
  State<ScheduleAIApp> createState() => _ScheduleAIAppState();
}

class _ScheduleAIAppState extends State<ScheduleAIApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialDark;
  }

  void toggleTheme() async {
    setState(() => _isDark = !_isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDark);
  }

  bool get isDark => _isDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JadwalKoe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
