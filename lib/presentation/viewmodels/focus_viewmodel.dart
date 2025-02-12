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
  static const int defaultDuration = 25 * 60;
  final BuildContext context;
  
  // 테스트를 위한 배속 설정 (기본값 1)
  // 예: 2.0 = 2배속, 5.0 = 5배속
  static const double timeMultiplier = 1.0;
  
  FocusViewModel(this.context) : super(FocusState());

  void startFocusMode() {
    if (state.status == FocusStatus.initial) {
      // 초기 상태에서만 새로운 타이머 시작
      emit(FocusState(status: FocusStatus.running, remainingSeconds: defaultDuration));
    } else {
      // 일시정지 상태에서는 현재 남은 시간으로 계속 진행
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
    final elapsedSeconds = defaultDuration - state.remainingSeconds;
    if (elapsedSeconds > 0) {
      context.read<PortfolioViewModel>().updatePomodoroTime(elapsedSeconds);
    }
    
    emit(FocusState(
      status: FocusStatus.paused,
      remainingSeconds: state.remainingSeconds,
    ));
    _timer?.cancel();
  }

  void resetTimer() {
    _timer?.cancel();
    emit(FocusState(
      status: FocusStatus.initial,
      remainingSeconds: defaultDuration,
    ));
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
    _timer?.cancel();
    return super.close();
  }
} 