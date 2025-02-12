import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircleProgressIndicator extends StatelessWidget {
  final double percentage;
  final double size;
  
  const CircleProgressIndicator({
    super.key,
    required this.percentage,
    this.size = 50,
  });

  Color _getProgressColor(double percentage) {
    if (percentage < 0.3) return Colors.redAccent;
    if (percentage < 0.7) return Colors.orangeAccent;
    if (percentage < 0.9) return Colors.lightBlueAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = _getProgressColor(percentage);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: progressColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: CircleProgressPainter(
              percentage: percentage,
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: progressColor,
              strokeWidth: size * 0.12,
            ),
          ),
          Center(
            child: Text(
              '${(percentage * 100).round()}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: progressColor.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double percentage;
  final Color backgroundColor;
  final Color foregroundColor;
  final double strokeWidth;

  CircleProgressPainter({
    required this.percentage,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;

    // 배경 원
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // 진행도 원
    final progressPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percentage,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.foregroundColor != foregroundColor;
  }
} 