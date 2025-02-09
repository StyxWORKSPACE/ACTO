class FocusSession {
  final int duration;  // 분 단위
  final DateTime startTime;
  bool isCompleted;
  
  FocusSession({
    this.duration = 25,
    required this.startTime,
    this.isCompleted = false,
  });
} 