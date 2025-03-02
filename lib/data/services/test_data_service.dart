import 'dart:math';
import 'package:acto/data/services/local_storage_service.dart';

class TestDataService {
  final LocalStorageService storageService;
  
  TestDataService(this.storageService);
  
  // 테스트 데이터 생성
  Future<void> generateTestData() async {
    final now = DateTime.now();
    print('테스트 데이터 생성 시작: ${now.toIso8601String()}');
    
    // 지난 7일간의 데이터 생성
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString = date.toIso8601String().split('T')[0];
      
      // 랜덤 시간 (30분~3시간)
      final minutes = 30 + Random().nextInt(150);
      final seconds = minutes * 60;
      
      print('날짜: $dateString, 추가할 시간: $minutes분 ($seconds초)');
      await storageService.addPomodoroTimeForDate(dateString, seconds);
    }
    
    print('테스트 데이터 생성 완료');
    
    // 생성된 데이터 확인
    final history = await storageService.loadPomodoroHistory();
    print('생성된 히스토리: $history');
  }
  
  // 특정 날짜에 데이터 추가
  Future<void> addTimeForDate(String dateString, int minutes) async {
    await storageService.addPomodoroTimeForDate(dateString, minutes * 60);
  }
} 