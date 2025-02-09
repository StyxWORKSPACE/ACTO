import 'package:flutter_bloc/flutter_bloc.dart';

class HomeViewModel extends Cubit<HomeState> {
  HomeViewModel() : super(HomeInitial());

  void startFocusMode() {
    // 25분 타이머 시작 로직
    emit(HomeFocusMode());
  }

  void completeTask() {
    // 태스크 완료 및 보상 지급 로직
    emit(HomeTaskCompleted());
  }
}

abstract class HomeState {}
class HomeInitial extends HomeState {}
class HomeFocusMode extends HomeState {}
class HomeTaskCompleted extends HomeState {} 