import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/coding_log.dart';
import '../../data/models/portfolio_project.dart';
import '../../data/models/github_models.dart';
import '../../data/services/github_service.dart';

class PortfolioState {
  final List<CodingLog> codingLogs;
  final List<PortfolioProject> projects;
  final bool isLoading;
  final List<Repository> repositories;
  final List<Commit> recentCommits;

  PortfolioState({
    required this.codingLogs,
    required this.projects,
    this.isLoading = false,
    this.repositories = const [],
    this.recentCommits = const [],
  });

  String get todayCodingTime {
    final today = DateTime.now();
    final todayLog = codingLogs.firstWhere(
      (log) => log.date.day == today.day && 
               log.date.month == today.month &&
               log.date.year == today.year,
      orElse: () => CodingLog(
        date: today,
        codingMinutes: 0,
        commitCount: 0,
        commitMessages: [],
      ),
    );
    return '오늘 ${todayLog.formattedCodingTime} 코딩함 ${todayLog.rating}';
  }

  int get incompleteProjectCount => 
      projects.where((p) => p.status != ProjectStatus.completed).length;
}

class PortfolioViewModel extends Cubit<PortfolioState> {
  final GitHubService _gitHubService = GitHubService();
  
  PortfolioViewModel() : super(PortfolioState(
    codingLogs: [],
    projects: [],
  ));

  Future<void> loadGitHubData(String username) async {
    emit(PortfolioState(
      codingLogs: state.codingLogs,
      projects: state.projects,
      isLoading: true,
    ));

    try {
      final repositories = await _gitHubService.getUserRepositories(username);
      final recentCommits = await _gitHubService.getRecentCommits(
        username,
        repositories.first.name, // 첫 번째 레포지토리의 커밋을 가져옴
      );

      // 커밋 데이터를 기반으로 코딩 로그 생성
      final logs = _generateCodingLogs(recentCommits);

      emit(PortfolioState(
        codingLogs: logs,
        projects: _generateProjects(repositories),
        repositories: repositories,
        recentCommits: recentCommits,
        isLoading: false,
      ));
    } catch (e) {
      // 에러 처리
      emit(PortfolioState(
        codingLogs: state.codingLogs,
        projects: state.projects,
        isLoading: false,
      ));
    }
  }

  List<CodingLog> _generateCodingLogs(List<Commit> commits) {
    // 커밋 시간을 기반으로 코딩 시간 추정
    final Map<DateTime, List<Commit>> commitsByDate = {};
    
    for (var commit in commits) {
      final date = DateTime(
        commit.date.year,
        commit.date.month,
        commit.date.day,
      );
      
      commitsByDate.putIfAbsent(date, () => []).add(commit);
    }

    return commitsByDate.entries.map((entry) {
      final commits = entry.value;
      // 커밋당 평균 30분의 코딩 시간으로 가정
      final codingMinutes = commits.length * 30;
      
      return CodingLog(
        date: entry.key,
        codingMinutes: codingMinutes,
        commitCount: commits.length,
        commitMessages: commits.map((c) => c.message).toList(),
      );
    }).toList();
  }

  List<PortfolioProject> _generateProjects(List<Repository> repositories) {
    return repositories.map((repo) => PortfolioProject(
      title: repo.name,
      description: repo.description,
      startDate: DateTime.now().subtract(const Duration(days: 30)), // 예시
      status: ProjectStatus.inProgress,
      completionPercentage: 70, // 예시
    )).toList();
  }
} 