import '../../data/models/coding_log.dart';
import '../../data/models/portfolio_project.dart';
import '../../data/models/github_models.dart';

class PortfolioState {
  final List<PortfolioProject> projects;
  final List<Repository> repositories;
  final Map<String, List<Commit>> projectCommits;
  final List<CodingLog> codingLogs;
  final bool isLoading;
  final String? error;
  final int pomodoroSeconds;
  final Map<String, int> pomodoroHistory;

  int get incompleteProjectCount => projects.where((p) => p.status != ProjectStatus.completed).length;

  const PortfolioState({
    this.projects = const [],
    this.repositories = const [],
    this.projectCommits = const {},
    this.codingLogs = const [],
    this.isLoading = true,
    this.error,
    this.pomodoroSeconds = 0,
    this.pomodoroHistory = const {},
  });

  CodingLog get todayCodingTime {
    final now = DateTime.now();
    return codingLogs.firstWhere(
      (log) => log.date.year == now.year && 
               log.date.month == now.month && 
               log.date.day == now.day,
      orElse: () => CodingLog(
        date: now,
        codingMinutes: 0,
        commitCount: 0,
        commitMessages: [],
      ),
    );
  }

  int get todayCommitCount {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return projectCommits.values
        .expand((commits) => commits)
        .where((commit) =>
            commit.date.isAfter(todayStart) && commit.date.isBefore(todayEnd))
        .length;
  }

  PortfolioState copyWith({
    List<PortfolioProject>? projects,
    List<Repository>? repositories,
    Map<String, List<Commit>>? projectCommits,
    List<CodingLog>? codingLogs,
    bool? isLoading,
    String? error,
    int? pomodoroSeconds,
    Map<String, int>? pomodoroHistory,
  }) {
    return PortfolioState(
      projects: projects ?? this.projects,
      repositories: repositories ?? this.repositories,
      projectCommits: projectCommits ?? this.projectCommits,
      codingLogs: codingLogs ?? this.codingLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pomodoroSeconds: pomodoroSeconds ?? this.pomodoroSeconds,
      pomodoroHistory: pomodoroHistory ?? this.pomodoroHistory,
    );
  }
} 