import 'package:acto/presentation/viewmodels/portfolio_viewmodel.dart';
import 'package:acto/presentation/views/portfolio/portfolio_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'data/repositories/portfolio_repository.dart';
import 'data/services/github_service.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PortfolioViewModel(
        portfolioRepository: PortfolioRepository(),
        gitHubService: GitHubService(
          token: AppConfig.githubToken,
          username: AppConfig.githubUsername,
        ),
      )..loadGitHubData(AppConfig.githubUsername),
      child: MaterialApp(
        title: 'Acto',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const PortfolioView(),
      ),
    );
  }
} 