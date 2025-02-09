import 'package:flutter/material.dart';
import 'package:acto/core/constants/app_colors.dart';
import 'package:acto/presentation/views/home/home_view.dart';

class ActoApp extends StatelessWidget {
  const ActoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACTO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          background: AppColors.background,
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      home: const HomeView(),
    );
  }
} 