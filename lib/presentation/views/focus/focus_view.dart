import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodels/focus_viewmodel.dart';

class FocusView extends StatelessWidget {
  const FocusView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FocusViewModel(context),
      child: Scaffold(
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
                              width: 250,
                              height: 250,
                              child: CircularProgressIndicator(
                                value: state.remainingSeconds / (25 * 60),
                                strokeWidth: 8,
                                backgroundColor: Colors.grey[300],
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.remainingTime,
                                  style: const TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  state.status == FocusStatus.running
                                      ? '탭하여 일시정지'
                                      : '탭하여 시작',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
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
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('리셋'),
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
    );
  }
} 