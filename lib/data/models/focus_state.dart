class FocusHistoryState {
  final DateTime date;
  final int focusSeconds;
  final int completedSessions;
  final bool isActive;

  FocusHistoryState({
    required this.date,
    this.focusSeconds = 0,
    this.completedSessions = 0,
    this.isActive = false,
  });

  int get totalMinutes => focusSeconds ~/ 60;
  int get totalHours => focusSeconds ~/ 3600;

  FocusHistoryState copyWith({
    DateTime? date,
    int? focusSeconds,
    int? completedSessions,
    bool? isActive,
  }) {
    return FocusHistoryState(
      date: date ?? this.date,
      focusSeconds: focusSeconds ?? this.focusSeconds,
      completedSessions: completedSessions ?? this.completedSessions,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'focusSeconds': focusSeconds,
    'completedSessions': completedSessions,
    'isActive': isActive,
  };

  factory FocusHistoryState.fromJson(Map<String, dynamic> json) {
    return FocusHistoryState(
      date: DateTime.parse(json['date']),
      focusSeconds: json['focusSeconds'],
      completedSessions: json['completedSessions'],
      isActive: json['isActive'],
    );
  }
} 