import 'package:acto/presentation/viewmodels/portfolio_viewmodel.dart';
import 'package:acto/presentation/views/portfolio/portfolio_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'data/repositories/portfolio_repository.dart';
import 'data/services/github_service.dart';
import 'data/services/local_storage_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Flutter 바인딩 초기화
  
  // LocalStorageService 초기화
  final localStorageService = LocalStorageService();
  final initialPomodoroTime = await localStorageService.loadPomodoroTime();
  
  runApp(MyApp(
    initialPomodoroTime: initialPomodoroTime,
    localStorageService: localStorageService,
  ));
}

class MyApp extends StatelessWidget {
  final int initialPomodoroTime;
  final LocalStorageService localStorageService;

  const MyApp({
    super.key,
    required this.initialPomodoroTime,
    required this.localStorageService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PortfolioViewModel(
        portfolioRepository: PortfolioRepository(),
        gitHubService: GitHubService(
          token: AppConfig.githubToken,
          username: AppConfig.githubUsername,
        ),
        localStorageService: localStorageService,
        initialPomodoroTime: initialPomodoroTime,
      )..loadGitHubData(AppConfig.githubUsername),
      child: MaterialApp(
        title: 'Acto',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const PortfolioView(),
      ),
    );
  }
} 