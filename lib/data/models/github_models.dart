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