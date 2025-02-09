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
} 