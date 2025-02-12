import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../viewmodels/portfolio_state.dart';
import '../viewmodels/portfolio_viewmodel.dart';

class PomodoroHistoryView extends StatelessWidget {
  const PomodoroHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioViewModel, PortfolioState>(
      builder: (context, state) {
        final sortedDates = state.pomodoroHistory.keys.toList()
          ..sort((a, b) => b.compareTo(a));  // 최신 날짜순

        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final seconds = state.pomodoroHistory[date] ?? 0;
            final hours = seconds ~/ 3600;
            final minutes = (seconds % 3600) ~/ 60;

            return ListTile(
              title: Text(date),
              subtitle: Text('$hours시간 $minutes분'),
              trailing: const Icon(Icons.access_time),
            );
          },
        );
      },
    );
  }
} 