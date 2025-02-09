class CodingLog {
  final DateTime date;
  final int codingMinutes;
  final int commitCount;
  final List<String> commitMessages;

  CodingLog({
    required this.date,
    required this.codingMinutes,
    required this.commitCount,
    required this.commitMessages,
  });

  String get formattedCodingTime {
    final hours = codingMinutes ~/ 60;
    final minutes = codingMinutes % 60;
    return '${hours}시간 ${minutes}분';
  }

  String get rating {
    if (codingMinutes >= 300) return '★★★'; // 5시간 이상
    if (codingMinutes >= 180) return '★★';  // 3시간 이상
    return '★';
  }
} 