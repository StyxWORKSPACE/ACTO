class DailyTimeRepository {
  int _todayFocusedTime = 0;
  
  int getTodayFocusedTime() => _todayFocusedTime;
  void updateFocusedTime(int minutes) => _todayFocusedTime = minutes;
} 