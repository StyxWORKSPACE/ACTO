import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:acto/core/config/app_config.dart';
import 'package:acto/data/services/test_data_service.dart';
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
        actions: [
          // 개발자 모드에서만 표시
          if (AppConfig().developerModeEnabled)
            IconButton(
              icon: const Icon(Icons.developer_mode),
              onPressed: () => _showDeveloperMenu(context),
              tooltip: '개발자 메뉴',
            ),
        ],
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
                    '집중 시간: ${hours}시간 ${minutes}분 ${seconds%60}초',
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

  void _showDeveloperMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                '개발자 메뉴',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('테스트 데이터 추가'),
              onTap: () {
                Navigator.pop(context);
                _showAddTimeDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('랜덤 테스트 데이터 생성'),
              onTap: () {
                Navigator.pop(context);
                _generateRandomTestData(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('모든 데이터 초기화'),
              onTap: () {
                Navigator.pop(context);
                _showResetConfirmDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 테스트용 시간 추가 다이얼로그
  void _showAddTimeDialog(BuildContext context) {
    final dateController = TextEditingController(
      text: DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0]
    );
    final minutesController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테스트: 날짜별 시간 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: '날짜 (YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minutesController,
              decoration: const InputDecoration(
                labelText: '추가할 시간 (분)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final dateString = dateController.text.trim();
              final minutes = int.tryParse(minutesController.text.trim()) ?? 0;
              
              if (dateString.isNotEmpty && minutes > 0) {
                // TestDataService 사용
                final testDataService = TestDataService(
                  context.read<PortfolioViewModel>().localStorageService
                );
                testDataService.addTimeForDate(dateString, minutes).then((_) {
                  // 히스토리 다시 로드
                  context.read<PortfolioViewModel>().loadPomodoroHistory();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _generateRandomTestData(BuildContext context) {
    final testDataService = TestDataService(
      context.read<PortfolioViewModel>().localStorageService
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('랜덤 테스트 데이터 생성 중...'))
    );
    
    testDataService.generateTestData().then((_) {
      // 히스토리 다시 로드
      context.read<PortfolioViewModel>().loadPomodoroHistory();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('랜덤 테스트 데이터 생성 완료'))
      );
    });
  }

  // 데이터 초기화 확인 다이얼로그
  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text('모든 집중 시간 기록이 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<PortfolioViewModel>().resetAllData();
              Navigator.pop(context);
            },
            child: const Text('초기화'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}

// 유틸리티 클래스에 추가
class TimeFormatter {
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  static String formatDurationText(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    return '$hours시간 $minutes분 $secs초';
  }
} 