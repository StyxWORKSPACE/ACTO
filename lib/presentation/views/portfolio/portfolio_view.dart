import 'package:acto/data/models/portfolio_project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodels/portfolio_viewmodel.dart';
import '../../../data/models/github_models.dart';
import '../../../presentation/views/portfolio/project_detail_view.dart';

class PortfolioView extends StatelessWidget {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PortfolioViewModel()..loadGitHubData('StyxWORKSPACE'),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('개발 현황'),
        ),
        body: BlocBuilder<PortfolioViewModel, PortfolioState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 오늘의 코딩 시간
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 개발 활동',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.todayCodingTime,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 프로젝트 현황
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '포트폴리오 현황',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (state.incompleteProjectCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '미완성 ${state.incompleteProjectCount}개',
                                  style: TextStyle(
                                    color: Colors.red[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...state.projects.map((project) {
                          final repository = state.repositories.firstWhere(
                            (r) => r.name == project.title,
                            orElse: () => Repository(
                              name: project.title,
                              description: project.description,
                              language: 'Unknown',
                              stars: 0,
                              updatedAt: DateTime.now(),
                              isPrivate: false,
                            ),
                          );
                          final commits = state.projectCommits[project.title] ?? [];
                          
                          return ProjectCard(
                            project: project,
                            repository: repository,
                            commits: commits,
                          );
                        }),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailView(
                project: project,
                repository: repository,
                commits: commits,
              ),
            ),
          );
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