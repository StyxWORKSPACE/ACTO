class PomodoroState {
  final DateTime date;
  final int completedPomodoros;
  final bool isActive;

  PomodoroState({
    required this.date,
    this.completedPomodoros = 0,
    this.isActive = false,
  });

  int get totalMinutes => completedPomodoros * 25;

  PomodoroState copyWith({
    DateTime? date,
    int? completedPomodoros,
    bool? isActive,
  }) {
    return PomodoroState(
      date: date ?? this.date,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      isActive: isActive ?? this.isActive,
    );
  }
} 