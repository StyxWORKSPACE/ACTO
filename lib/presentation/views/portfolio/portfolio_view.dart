import 'package:acto/data/models/portfolio_project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodels/portfolio_viewmodel.dart';
import '../../../data/models/github_models.dart';
import '../../../presentation/views/portfolio/project_detail_view.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../data/services/github_service.dart';
import 'package:http/http.dart' as http;

class PortfolioView extends StatelessWidget {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    final githubService = GitHubService();

    return BlocProvider(
      create: (_) => PortfolioViewModel(
        portfolioRepository: PortfolioRepository(),
        gitHubService: githubService,
      )..loadGitHubData('StyxWORKSPACE'),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('개발 현황'),
          backgroundColor: const Color(0xFF4F5D75),
        ),
        body: BlocBuilder<PortfolioViewModel, PortfolioState>(
      builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final todayCommits = context.read<PortfolioViewModel>().todayCommitCount;
            final pomodoroMinutes = context.read<PortfolioViewModel>().state.pomodoroMinutes;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 오늘의 개발 활동 컨테이너
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4F5D75), Color(0xFF2D3142)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.code_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              '오늘의 개발 활동',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '오늘 ${todayCommits}개의 커밋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '포모도로 시간: ${pomodoroMinutes ~/ 60}시간 ${pomodoroMinutes % 60}분',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 프로젝트 폴더 컨테이너
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4F5D75), Color(0xFF2D3142)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.folder_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              '프로젝트',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (state.repositories.isEmpty)
                          const Center(
                            child: Text(
                              'GitHub 프로젝트가 없습니다',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          ...state.repositories.map((repo) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectDetailView(
                                      project: PortfolioProject(
                                        title: repo.name,
                                        description: repo.description ?? '',
                                        startDate: DateTime.now(),
                                        status: ProjectStatus.inProgress,
                                        completionPercentage: 70,
                                      ),
                                      repository: repo,
                                      commits: state.projectCommits[repo.name] ?? [],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            repo.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '70%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (repo.description?.isNotEmpty ?? false) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        repo.description ?? '',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: 0.7,
                                          child: Container(
                                            height: 4,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF4F5D75), Colors.white],
                                              ),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
              ),
            ],
          ),
                                    const SizedBox(height: 12),
                                    Row(
                  children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            repo.language,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}

class ProjectCard extends StatelessWidget {
  final PortfolioProject project;
  final Repository? repository;
  final List<Commit> commits;

  const ProjectCard({
    super.key,
    required this.project,
    this.repository,
    this.commits = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          if (repository != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailView(
                project: project,
                  repository: repository!,
                commits: commits,
              ),
            ),
          );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('${project.completionPercentage}%'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: project.completionPercentage / 100,
                backgroundColor: Colors.grey[200],
              ),
              if (project.isOverdue)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '마감기한 초과!',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 