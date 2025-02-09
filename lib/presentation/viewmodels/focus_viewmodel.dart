import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

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
  
  FocusViewModel() : super(FocusState());

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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        emit(FocusState(
          status: FocusStatus.running,
          remainingSeconds: state.remainingSeconds - 1,
        ));
      } else {
        _timer?.cancel();
        emit(FocusState(status: FocusStatus.completed));
        _handleCompletion();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    emit(FocusState(
      status: FocusStatus.paused,
      remainingSeconds: state.remainingSeconds,
    ));
  }

  void resetTimer() {
    _timer?.cancel();
    emit(FocusState(
      status: FocusStatus.initial,
      remainingSeconds: defaultDuration,
    ));
  }

  void _handleCompletion() {
    // TODO: 보상 지급 로직 구현
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
} 