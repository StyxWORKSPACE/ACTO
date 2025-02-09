import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/coding_log.dart';
import '../../data/models/portfolio_project.dart';
import '../../data/models/github_models.dart';
import '../../data/services/github_service.dart';
import '../../data/repositories/portfolio_repository.dart';
import 'portfolio_state.dart';

class PortfolioViewModel extends Cubit<PortfolioState> {
  final PortfolioRepository portfolioRepository;
  final GitHubService gitHubService;
  
  PortfolioViewModel({
    required this.portfolioRepository,
    required this.gitHubService,
  }) : super(const PortfolioState());

  Future<void> loadGitHubData(String username) async {
    emit(state.copyWith(
      isLoading: true,
    ));

    try {
      final repositories = await gitHubService.getUserRepositories(username);
      
      final projectDetails = await Future.wait(
        repositories.map((repo) async {
          final details = await gitHubService.getRepositoryDetails(username, repo.name);
          final commits = await gitHubService.getRecentCommits(username, repo.name);
          return (repo, details, commits);
        }),
      );

      final projects = projectDetails.map((entry) {
        final (repo, details, commits) = entry;
        final startDate = commits.isNotEmpty ? commits.last.date : repo.updatedAt;

        return PortfolioProject(
          title: repo.name,
          description: repo.description,
          startDate: startDate,
          status: _determineProjectStatus(details),
          completionPercentage: details.calculateCompletionPercentage(),
        );
      }).toList();

      final projectCommits = Map.fromEntries(
        projectDetails.map((entry) => MapEntry(entry.$1.name, entry.$3))
      );

      emit(state.copyWith(
        codingLogs: _generateCodingLogs(projectDetails.map((e) => e.$3).expand((commits) => commits).toList()),
        projects: projects,
        repositories: repositories,
        projectCommits: projectCommits,
        isLoading: false,
      ));
    } catch (e) {
      print('Error loading GitHub data: $e');
      emit(state.copyWith(
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

  ProjectStatus _determineProjectStatus(RepositoryDetails details) {
    final completionPercentage = details.calculateCompletionPercentage();
    
    if (completionPercentage >= 100) {
      return ProjectStatus.completed;
    } else if (details.closedIssues > 0 || details.commitCount > 0) {
      return ProjectStatus.inProgress;
    } else {
      return ProjectStatus.delayed;
    }
  }

  int get todayCommitCount {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day); // 오늘 시작 시간
    final todayEnd = todayStart.add(const Duration(days: 1)); // 내일 시작 시간

    final count = state.projectCommits.values
        .expand((commits) => commits)
        .where((commit) =>
            commit.date.isAfter(todayStart) && commit.date.isBefore(todayEnd))
        .length;

    return count;
  }

  void updatePomodoroTime(int seconds) {
    emit(state.copyWith(
      pomodoroSeconds: state.pomodoroSeconds + seconds,
    ));
  }

  void setPomodoroTime(int totalSeconds) {
    emit(state.copyWith(
      pomodoroSeconds: totalSeconds,
    ));
  }
} 