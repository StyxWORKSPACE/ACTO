class CommitActivity {
  final int total;
  final List<int> days;
  final int week;

  CommitActivity({
    required this.total,
    required this.days,
    required this.week,
  });

  factory CommitActivity.fromJson(Map<String, dynamic> json) {
    return CommitActivity(
      total: json['total'],
      days: List<int>.from(json['days']),
      week: json['week'],
    );
  }
}

class Repository {
  final String name;
  final String description;
  final String language;
  final int stars;
  final DateTime updatedAt;
  final bool isPrivate;

  Repository({
    required this.name,
    required this.description,
    required this.language,
    required this.stars,
    required this.updatedAt,
    required this.isPrivate,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      name: json['name'],
      description: json['description'] ?? '',
      language: json['language'] ?? 'Unknown',
      stars: json['stargazers_count'],
      updatedAt: DateTime.parse(json['updated_at']),
      isPrivate: json['private'],
    );
  }
}

class Commit {
  final String sha;
  final String message;
  final String author;
  final DateTime date;

  Commit({
    required this.sha,
    required this.message,
    required this.author,
    required this.date,
  });

  factory Commit.fromJson(Map<String, dynamic> json) {
    return Commit(
      sha: json['sha'],
      message: json['commit']['message'],
      author: json['commit']['author']['name'],
      date: DateTime.parse(json['commit']['author']['date']),
    );
  }
}

class RepositoryDetails {
  final int totalIssues;
  final int closedIssues;
  final int totalMilestones;
  final int completedMilestones;
  final int commitCount;

  RepositoryDetails({
    required this.totalIssues,
    required this.closedIssues,
    required this.totalMilestones,
    required this.completedMilestones,
    required this.commitCount,
  });

  int calculateCompletionPercentage() {
    int percentage = 0;
    int totalFactors = 0;

    // 이슈 진행률 (40%)
    if (totalIssues > 0) {
      percentage += ((closedIssues / totalIssues) * 40).round();
      totalFactors += 40;
    }

    // 마일스톤 진행률 (40%)
    if (totalMilestones > 0) {
      percentage += ((completedMilestones / totalMilestones) * 40).round();
      totalFactors += 40;
    }

    // 커밋 기여도 (20%)
    if (commitCount > 0) {
      // 주간 평균 커밋 수를 기준으로 계산
      int weeklyCommitGoal = 10; // 목표 주간 커밋 수
      int weeksSinceStart = 1; // 프로젝트 시작부터 경과된 주 수
      double commitRate = (commitCount / (weeksSinceStart * weeklyCommitGoal)).clamp(0.0, 1.0);
      percentage += (commitRate * 20).round();
      totalFactors += 20;
    }

    // 측정 가능한 요소가 없는 경우 기본값 반환
    if (totalFactors == 0) return 0;

    // 실제 측정된 요소들의 비율로 조정
    return (percentage * 100 / totalFactors).round();
  }
} 