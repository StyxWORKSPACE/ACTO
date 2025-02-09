import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/github_models.dart';
import '../../core/config/app_config.dart';

class GitHubService {
  final String _baseUrl = 'https://api.github.com';
  final String _token = AppConfig.githubToken;
  
  Future<List<CommitActivity>> getCommitActivity(String owner, String repo) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/stats/commit_activity'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((week) => CommitActivity.fromJson(week)).toList();
    } else {
      throw Exception('Failed to load commit activity');
    }
  }

  Future<List<Repository>> getUserRepositories(String username) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$username/repos'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((repo) => Repository.fromJson(repo)).toList();
    } else {
      throw Exception('Failed to load repositories');
    }
  }

  Future<List<Commit>> getRecentCommits(String owner, String repo) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/commits'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((commit) => Commit.fromJson(commit)).toList();
    } else {
      throw Exception('Failed to load commits');
    }
  }

  Future<RepositoryDetails> getRepositoryDetails(String owner, String repo) async {
    // 이슈, PR, 마일스톤 등의 정보를 가져옴
    final issuesResponse = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/issues?state=all'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    final milestonesResponse = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/milestones'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    final commitsResponse = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/commits'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (issuesResponse.statusCode == 200 && 
        milestonesResponse.statusCode == 200 && 
        commitsResponse.statusCode == 200) {
      final issues = json.decode(issuesResponse.body) as List;
      final milestones = json.decode(milestonesResponse.body) as List;
      final commits = json.decode(commitsResponse.body) as List;

      return RepositoryDetails(
        totalIssues: issues.length,
        closedIssues: issues.where((i) => i['state'] == 'closed').length,
        totalMilestones: milestones.length,
        completedMilestones: milestones.where((m) => m['state'] == 'closed').length,
        commitCount: commits.length,
      );
    } else {
      throw Exception('Failed to load repository details');
    }
  }
} 