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

  int get incompleteProjectCount => projects.where((p) => p.status != ProjectStatus.completed).length;

  PortfolioState({
    this.projects = const [],
    this.repositories = const [],
    this.projectCommits = const {},
    this.codingLogs = const [],
    this.isLoading = true,
    this.error,
  });

  PortfolioState copyWith({
    List<PortfolioProject>? projects,
    List<Repository>? repositories,
    Map<String, List<Commit>>? projectCommits,
    List<CodingLog>? codingLogs,
    bool? isLoading,
    String? error,
  }) {
    return PortfolioState(
      projects: projects ?? this.projects,
      repositories: repositories ?? this.repositories,
      projectCommits: projectCommits ?? this.projectCommits,
      codingLogs: codingLogs ?? this.codingLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  CodingLog get todayCodingTime {
    final now = DateTime.now();
    return codingLogs.firstWhere(
      (log) => log.date.year == now.year && 
               log.date.month == now.month && 
               log.date.day == now.day,
      orElse: () => CodingLog(
        date: now,
        codingMinutes: 0,
        additionalMinutes: 0,
        commitCount: 0,
        commitMessages: [],
      ),
    );
  }
} 