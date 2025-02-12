import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodels/portfolio_viewmodel.dart';
import '../../viewmodels/portfolio_state.dart';
import '../../../core/constants/app_colors.dart';

class FocusHistoryView extends StatelessWidget {
  const FocusHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('집중 시간 기록'),
        backgroundColor: AppColors.background,
      ),
      body: BlocBuilder<PortfolioViewModel, PortfolioState>(
        builder: (context, state) {
          final sortedDates = state.pomodoroHistory.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          if (sortedDates.isEmpty) {
            return const Center(
              child: Text(
                '아직 기록이 없습니다',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final seconds = state.pomodoroHistory[date] ?? 0;
              final hours = seconds ~/ 3600;
              final minutes = (seconds % 3600) ~/ 60;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '집중 시간: ${hours}시간 ${minutes}분',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  trailing: _buildRating(hours),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRating(int hours) {
    if (hours >= 5) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber),
          Icon(Icons.star, color: Colors.amber),
          Icon(Icons.star, color: Colors.amber),
        ],
      );
    } else if (hours >= 3) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber),
          Icon(Icons.star, color: Colors.amber),
        ],
      );
    } else {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber),
        ],
      );
    }
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
} 