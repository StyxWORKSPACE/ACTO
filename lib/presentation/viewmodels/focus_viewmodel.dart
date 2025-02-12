import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'portfolio_viewmodel.dart';

class FocusState {
  final FocusStatus status;
  final int remainingSeconds;

  FocusState({
    this.status = FocusStatus.initial,
    this.remainingSeconds = 25 * 60,  // 기본값을 25분으로 설정
  });

  String get remainingTime {
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

enum FocusStatus { initial, running, paused, completed }

class FocusViewModel extends Cubit<FocusState> {
  Timer? _timer;
  Timer? _dateCheckTimer;
  static const int defaultDuration = 25 * 60;
  final BuildContext context;
  DateTime _currentDate = DateTime.now();
  int _lastSavedSeconds = 0;  // 마지막으로 저장된 시간 추적
  
  // 테스트를 위한 배속 설정 (기본값 1)
  // 예: 2.0 = 2배속, 5.0 = 5배속
  static const double timeMultiplier = 1.0;
  
  FocusViewModel(this.context) : super(FocusState()) {
    // 자정이 되는지 체크하는 타이머 시작
    _startDateCheckTimer();
  }

  void _startDateCheckTimer() {
    _dateCheckTimer?.cancel();
    _dateCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.day != _currentDate.day) {
        // 날짜가 변경됨
        _currentDate = now;
        if (state.status == FocusStatus.running) {
          // 진행 중인 포모도로가 있다면 현재까지의 시간을 저장
          final elapsedSeconds = defaultDuration - state.remainingSeconds;
          if (elapsedSeconds > 0) {
            context.read<PortfolioViewModel>().updatePomodoroTime(elapsedSeconds);
          }
        }
        // 새로운 날짜로 초기화
        context.read<PortfolioViewModel>().resetPomodoroTime();
      }
    });
  }

  void startFocusMode() {
    if (state.status == FocusStatus.initial) {
      emit(FocusState(status: FocusStatus.running, remainingSeconds: defaultDuration));
      _lastSavedSeconds = 0;  // 초기화
    } else {
      emit(FocusState(status: FocusStatus.running, remainingSeconds: state.remainingSeconds));
    }
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    // 타이머 간격을 배속에 맞게 조절 (1000ms = 1초)
    final interval = (1000 / timeMultiplier).round();
    
    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (state.remainingSeconds > 0) {
        emit(FocusState(
          status: FocusStatus.running,
          remainingSeconds: state.remainingSeconds - 1,
        ));
      } else {
        _timer?.cancel();
        _handleCompletion();
      }
    });
  }

  void pauseTimer() {
    final currentElapsedSeconds = defaultDuration - state.remainingSeconds;
    final newSeconds = currentElapsedSeconds - _lastSavedSeconds;  // 새로 경과된 시간만 계산
    
    if (newSeconds > 0) {
      context.read<PortfolioViewModel>().updatePomodoroTime(newSeconds);
      _lastSavedSeconds = currentElapsedSeconds;  // 저장된 시간 업데이트
    }
    
    emit(FocusState(
      status: FocusStatus.paused,
      remainingSeconds: state.remainingSeconds,
    ));
    _timer?.cancel();
  }

  void resetTimer() {
    _timer?.cancel();
    _lastSavedSeconds = 0;  // 초기화
    emit(FocusState());
  }

  void _handleCompletion() {
    final elapsedSeconds = defaultDuration - state.remainingSeconds;
    if (elapsedSeconds > 0) {
      context.read<PortfolioViewModel>().updatePomodoroTime(elapsedSeconds);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('집중 시간 완료'),
          content: Text('${(elapsedSeconds / 60).toStringAsFixed(1)}분의 집중 시간이 기록되었습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );

      emit(FocusState(status: FocusStatus.completed));
    }
  }

  @override
  Future<void> close() {
    _dateCheckTimer?.cancel();
    _timer?.cancel();
    return super.close();
  }
} 