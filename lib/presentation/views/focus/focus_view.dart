import 'package:acto/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../painters/coffee_cup_painter.dart';
import '../../viewmodels/focus_viewmodel.dart';

class FocusView extends StatelessWidget {
  const FocusView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FocusViewModel(context),
      child: Container(
        color: AppColors.container_background,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: BlocBuilder<FocusViewModel, FocusState>(
              builder: (context, state) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: GestureDetector(
                          onTap: () {
                            if (state.status == FocusStatus.initial ||
                                state.status == FocusStatus.paused) {
                              context.read<FocusViewModel>().startFocusMode();
                            } else if (state.status == FocusStatus.running) {
                              context.read<FocusViewModel>().pauseTimer();
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,  // 화면 전체 너비로 변경
                                height: MediaQuery.of(context).size.width, // 정사각형 유지
                                child: Padding(
                                  padding: const EdgeInsets.all(30),  // 패딩도 증가
                                  child: CustomPaint(
                                    painter: CoffeeCupPainter(
                                      progress: state.status == FocusStatus.initial ? 
                                          1.0 :
                                          (state.remainingSeconds) / (25 * 60),
                                      coffeeColor: const Color(0xFF8B6B4A),
                                      cupColor: const Color(0xFFDCDCDC),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.remainingTime,
                                    style: const TextStyle(
                                      fontSize: 64, // 폰트 크기 증가
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C3E50).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      state.status == FocusStatus.initial
                                          ? '탭하여 시작'
                                          : state.status == FocusStatus.running
                                              ? '탭하여 일시정지'
                                              : '탭하여 계속하기',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 48, // 버튼의 고정된 높이
                        child: state.status != FocusStatus.initial
                            ? ElevatedButton(
                                onPressed: () =>
                                    context.read<FocusViewModel>().resetTimer(),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: const Color(0xFFF5F6F8),
                                  backgroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  '리셋',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,),
                                ),
                              )
                            : const SizedBox(width: 88), // 리셋 버튼과 동일한 너비
                      ),
                      if (state.status == FocusStatus.completed)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: const Text(
                            '집중 시간 완료!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
