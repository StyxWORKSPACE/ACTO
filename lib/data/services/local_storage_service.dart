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
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // 현재 히스토리 불러오기
      Map<String, int> history = await loadPomodoroHistory();
      
      // 오늘의 시간 업데이트
      history[today] = seconds;
      
      // 저장
      await prefs.setInt(_pomodoroTimeKey, seconds);
      await prefs.setString(_lastPomodoroDateKey, today);
      await prefs.setString(_pomodoroHistoryKey, jsonEncode(history));
      
      print('Saved pomodoro time: $seconds seconds for date: $today');
      print('Updated history: $history');  // 디버깅용
    } catch (e) {
      print('Error saving pomodoro time: $e');
    }
  }

  // 포모도로 시간 불러오기
  Future<int> loadPomodoroTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString(_lastPomodoroDateKey);
      
      if (lastDate != today) {
        print('New day detected, resetting pomodoro time');
        await prefs.setInt(_pomodoroTimeKey, 0);
        await prefs.setString(_lastPomodoroDateKey, today);
        return 0;
      }

      final savedSeconds = prefs.getInt(_pomodoroTimeKey) ?? 0;
      print('Loaded pomodoro time: $savedSeconds seconds for today');
      return savedSeconds;
    } catch (e) {
      print('Error loading pomodoro time: $e');
      return 0;
    }
  }

  // 포모도로 히스토리 불러오기
  Future<Map<String, int>> loadPomodoroHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_pomodoroHistoryKey);
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      Map<String, int> history;
      if (historyJson == null || historyJson.isEmpty) {
        history = {};
      } else {
        try {
          history = Map<String, int>.from(jsonDecode(historyJson));
        } catch (e) {
          print('Error parsing history JSON: $e');
          history = {};
        }
      }

      // 오늘의 시간이 없으면 현재 포모도로 시간으로 초기화
      if (!history.containsKey(today)) {
        final todaySeconds = prefs.getInt(_pomodoroTimeKey) ?? 0;
        if (todaySeconds > 0) {
          history[today] = todaySeconds;
          await prefs.setString(_pomodoroHistoryKey, jsonEncode(history));
        }
      }

      print('Loaded history: $history');  // 디버깅용
      return history;
    } catch (e) {
      print('Error loading pomodoro history: $e');
      return {};
    }
  }

  // 저장소 초기화 (디버깅용)
  Future<void> clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Storage cleared');
    } catch (e) {
      print('Error clearing storage: $e');
    }
  }
} 