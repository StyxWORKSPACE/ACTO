import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/coding_log.dart';
import '../../data/models/portfolio_project.dart';
import '../../data/models/github_models.dart';
import '../../data/services/github_service.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../data/services/local_storage_service.dart';
import 'portfolio_state.dart';

class PortfolioViewModel extends Cubit<PortfolioState> {
  final PortfolioRepository portfolioRepository;
  final GitHubService gitHubService;
  final LocalStorageService localStorageService;
  
  PortfolioViewModel({
    required this.portfolioRepository,
    required this.gitHubService,
    required this.localStorageService,
    required int initialPomodoroTime,
  }) : super(PortfolioState(pomodoroSeconds: initialPomodoroTime));

  Future<void> loadGitHubData(String username) async {
    emit(state.copyWith(isLoading: true));

    try {
      // 1. 저장된 진행률 로드
      final savedProgress = await localStorageService.loadProjectProgress();

      // 2. GitHub API에서 저장소 정보 가져오기
      final repositories = await gitHubService.getUserRepositories(username);
      
      if (repositories.isEmpty) {
        throw Exception('No GitHub repositories found');
      }

      // 3. 저장된 진행률 적용
      final updatedRepositories = repositories.map((repo) {
        return Repository(
          name: repo.name,
          description: repo.description,
          language: repo.language,
          stars: repo.stars,
          updatedAt: repo.updatedAt,
          isPrivate: repo.isPrivate,
          completionPercentage: savedProgress[repo.name] ?? 0,
        );
      }).toList();

      // 4. 커밋 정보 로드 - 에러 처리 추가
      final projectCommits = <MapEntry<String, List<Commit>>>[];
      for (final repo in updatedRepositories) {
        try {
          final commits = await gitHubService.getRecentCommits(username, repo.name);
          projectCommits.add(MapEntry(repo.name, commits));
        } catch (e) {
          print('Failed to load commits for ${repo.name}: $e');
          projectCommits.add(MapEntry(repo.name, []));  // 빈 커밋 리스트로 대체
        }
      }

      // 5. 상태 업데이트
      emit(state.copyWith(
        repositories: updatedRepositories,
        projectCommits: Map.fromEntries(projectCommits),
        isLoading: false,
      ));
    } catch (e) {
      print('Error loading GitHub data: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
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

  Future<void> updatePomodoroTime(int seconds) async {
    try {
      final newTotal = state.pomodoroSeconds + seconds;
      // 로컬 저장소에 저장
      await localStorageService.savePomodoroTime(newTotal);
      // 상태 업데이트
      emit(state.copyWith(
        pomodoroSeconds: newTotal,
      ));
      print('Updated pomodoro time: $newTotal seconds'); // 디버깅용
    } catch (e) {
      print('Error updating pomodoro time: $e');
    }
  }

  @override
  Future<void> updateProjectProgress(String projectName, int progress) async {
    final List<Repository> updatedRepositories = state.repositories.map((repo) {
      if (repo.name == projectName) {
        return Repository(
          name: repo.name,
          description: repo.description,
          language: repo.language,
          stars: repo.stars,
          updatedAt: repo.updatedAt,
          completionPercentage: progress,
          isPrivate: repo.isPrivate,
        );
      }
      return repo;
    }).toList();

    // 로컬에 진행률 저장
    final progressMap = Map.fromEntries(
      updatedRepositories.map((repo) => MapEntry(repo.name, repo.completionPercentage))
    );
    await localStorageService.saveProjectProgress(progressMap);

    emit(state.copyWith(repositories: updatedRepositories));
  }

  @override
  Future<void> setPomodoroTime(int totalSeconds) async {
    try {
      // 1. 로컬 저장소에 저장
      await localStorageService.savePomodoroTime(totalSeconds);
      
      // 2. 상태 업데이트
      emit(state.copyWith(pomodoroSeconds: totalSeconds));
      
      print('Saved pomodoro time: $totalSeconds seconds'); // 디버깅용
    } catch (e) {
      print('Error saving pomodoro time: $e');
    }
  }

  // 포모도로 시간 증가 메서드 추가
  Future<void> incrementPomodoroTime(int additionalSeconds) async {
    final newTotal = state.pomodoroSeconds + additionalSeconds;
    await setPomodoroTime(newTotal);
  }

  Future<void> loadPomodoroHistory() async {
    final history = await localStorageService.loadPomodoroHistory();
    emit(state.copyWith(pomodoroHistory: history));
  }

  Future<void> resetPomodoroTime() async {
    await localStorageService.savePomodoroTime(0);
    emit(state.copyWith(pomodoroSeconds: 0));
  }
} 