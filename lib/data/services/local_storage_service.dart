import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _projectProgressKey = 'project_progress';
  static const String _pomodoroTimeKey = 'pomodoro_time';
  static const String _lastPomodoroDateKey = 'last_pomodoro_date';
  static const String _pomodoroHistoryKey = 'pomodoro_history';

  // 프로젝트 진행률 저장
  Future<void> saveProjectProgress(Map<String, int> progressMap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_projectProgressKey, jsonEncode(progressMap));
  }

  // 프로젝트 진행률 불러오기
  Future<Map<String, int>> loadProjectProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final String? progressJson = prefs.getString(_projectProgressKey);
    if (progressJson == null) return {};
    
    return Map<String, int>.from(jsonDecode(progressJson));
  }

  // 포모도로 시간 저장
  Future<void> savePomodoroTime(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // 현재 날짜의 포모도로 시간 저장
    await prefs.setInt(_pomodoroTimeKey, seconds);
    await prefs.setString(_lastPomodoroDateKey, today);
    
    // 히스토리에도 저장
    final history = await loadPomodoroHistory();
    history[today] = seconds;
    await prefs.setString(_pomodoroHistoryKey, jsonEncode(history));
    
    print('Saved pomodoro time: $seconds seconds for date: $today');
  }

  // 포모도로 시간 불러오기
  Future<int> loadPomodoroTime() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_lastPomodoroDateKey);
    final savedSeconds = prefs.getInt(_pomodoroTimeKey) ?? 0;

    print('Loading pomodoro time - Last date: $lastDate, Today: $today, Saved seconds: $savedSeconds');

    if (lastDate != today) {
      print('New day detected, resetting pomodoro time');
      await prefs.setInt(_pomodoroTimeKey, 0);
      await prefs.setString(_lastPomodoroDateKey, today);
      return 0;
    }

    return savedSeconds;
  }

  // 포모도로 히스토리 불러오기
  Future<Map<String, int>> loadPomodoroHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_pomodoroHistoryKey);
    if (historyJson == null) return {};
    
    return Map<String, int>.from(jsonDecode(historyJson));
  }
} 