import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodels/portfolio_viewmodel.dart';

class FocusTimer extends StatefulWidget {
  const FocusTimer({super.key});

  @override
  State<FocusTimer> createState() => _FocusTimerState();
}

class _FocusTimerState extends State<FocusTimer> with TickerProviderStateMixin {
  static const int defaultMinutes = 25;
  Timer? _timer;
  int _initialSeconds = defaultMinutes * 60;
  int _secondsRemaining = defaultMinutes * 60;
  bool _isRunning = false;
  late AnimationController _controller;

  double get _elapsedMinutes {
    int elapsedSeconds = _initialSeconds - _secondsRemaining;
    return elapsedSeconds / 60.0;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: defaultMinutes),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _controller.forward(from: 1 - (_secondsRemaining / _initialSeconds));
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _recordTime();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _controller.stop();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    // 진행된 시간이 있다면 기록
    if (_secondsRemaining < _initialSeconds) {
      _recordTime();
    }
    
    _timer?.cancel();
    _controller.reset();
    setState(() {
      _secondsRemaining = _initialSeconds;
      _isRunning = false;
    });
  }

  void _recordTime() {
    if (!mounted) return;
    
    final elapsedMinutes = _elapsedMinutes;
    if (elapsedMinutes <= 0) return;

    final viewModel = context.read<PortfolioViewModel>();
    viewModel.updatePomodoroTime(elapsedMinutes.toInt());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('집중 시간 기록'),
        content: Text(
          '${elapsedMinutes.toStringAsFixed(1)}분의 집중 시간이 기록되었습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '포모도로 타이머',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: 1 - (_secondsRemaining / _initialSeconds),
                          strokeWidth: 12,
                          backgroundColor: const Color(0xFFE9ECEF),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF4F5D75),
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_secondsRemaining),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRunning ? '집중중...' : '시작하기',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.refresh_rounded,
                  onPressed: _resetTimer,
                  backgroundColor: const Color(0xFFE9ECEF),
                  iconColor: const Color(0xFF2D3142),
                ),
                _buildControlButton(
                  icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  backgroundColor: const Color(0xFF4F5D75),
                  iconColor: Colors.white,
                  size: 80,
                ),
                _buildControlButton(
                  icon: Icons.stop_rounded,
                  onPressed: _resetTimer,
                  backgroundColor: const Color(0xFFE9ECEF),
                  iconColor: const Color(0xFF2D3142),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
    double size = 60,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: size * 0.5),
        color: iconColor,
        onPressed: onPressed,
      ),
    );
  }
} 