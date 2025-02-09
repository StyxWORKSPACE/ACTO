import '../services/github_service.dart';
import '../models/github_models.dart';

class GithubRepository {
  final GitHubService _githubService;

  GithubRepository({GitHubService? githubService}) 
    : _githubService = githubService ?? GitHubService();

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