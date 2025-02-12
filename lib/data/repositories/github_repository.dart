import '../services/github_service.dart';
import '../models/github_models.dart';
import '../../core/config/app_config.dart';

class GithubRepository {
  final GitHubService _githubService;
  final String token;
  final String username;

  GithubRepository({GitHubService? githubService}) 
    : _githubService = githubService ?? GitHubService(
        token: AppConfig.githubToken,
        username: AppConfig.githubUsername,
      ),
      token = AppConfig.githubToken,
      username = AppConfig.githubUsername;

  Future<List<Repository>> getRepositories(String username) async {
    try {
      return await _githubService.getUserRepositories(username);
    } catch (e) {
      print('GitHub Repository Error: $e');
      rethrow;
    }
  }

  Future<List<Commit>> getCommits(String username, String repository) async {
    try {
      return await _githubService.getRecentCommits(username, repository);
    } catch (e) {
      print('GitHub Commits Error: $e');
      rethrow;
    }
  }
} 