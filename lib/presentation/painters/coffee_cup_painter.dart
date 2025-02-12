import 'package:flutter/material.dart';
import 'dart:math' as math;

class CoffeeCupPainter extends CustomPainter {
  final double progress; // 1.0 → 0.0 (가득 참 → 비워짐)
  final Color coffeeColor;
  final Color cupColor;

  CoffeeCupPainter({
    required this.progress,
    this.coffeeColor = const Color(0xFF6F4E37),
    this.cupColor = const Color(0xFFEFD3C6),
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawShadow(canvas, size);
    _drawSaucer(canvas, size);
    _drawCupBody(canvas, size);
    _drawHandle(canvas, size);
    _drawCoffeeLiquid(canvas, size);
    _drawCupDetails(canvas, size);
    _drawFoam(canvas, size);
    if (progress < 0.95) _drawSteam(canvas, size, progress);
  }

  void _drawShadow(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.95),
        width: size.width * 0.8,
        height: size.height * 0.1,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
  }

  void _drawSaucer(Canvas canvas, Size size) {
    final saucerPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.96,
        size.width * 0.9, size.height * 0.9,
      )
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.84,
        size.width * 0.1, size.height * 0.9,
      );

    canvas.drawPath(
      saucerPath,
      Paint()
        ..color = cupColor
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          colors: [cupColor, cupColor.withOpacity(0.9)],
          stops: const [0.7, 1.0],
        ).createShader(Rect.fromLTRB(0, size.height * 0.84, size.width, size.height * 0.96)),
    );
  }

  void _drawCupBody(Canvas canvas, Size size) {
    final cupPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.15)
      ..cubicTo(
        size.width * 0.18, size.height * 0.3,
        size.width * 0.2, size.height * 0.7,
        size.width * 0.3, size.height * 0.85,
      )
      ..cubicTo(
        size.width * 0.4, size.height * 0.95,
        size.width * 0.6, size.height * 0.95,
        size.width * 0.7, size.height * 0.85,
      )
      ..cubicTo(
        size.width * 0.8, size.height * 0.7,
        size.width * 0.82, size.height * 0.3,
        size.width * 0.75, size.height * 0.15,
      )
      ..close();

    // 컵 외곽선
    canvas.drawPath(
      cupPath,
      Paint()
        ..color = cupColor
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          colors: [cupColor, cupColor.withOpacity(0.8)],
          stops: const [0.6, 1.0],
        ).createShader(Rect.fromLTRB(0, 0, size.width, size.height)),
    );

    // 컵 내부 반사광
    canvas.drawPath(
      cupPath,
      Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _drawHandle(Canvas canvas, Size size) {
    final handlePath = Path()
      ..moveTo(size.width * 0.72, size.height * 0.35)
      ..cubicTo(
        size.width * 0.85, size.height * 0.3,
        size.width * 0.95, size.height * 0.45,
        size.width * 0.85, size.height * 0.6,
      )
      ..cubicTo(
        size.width * 0.78, size.height * 0.7,
        size.width * 0.7, size.height * 0.65,
        size.width * 0.68, size.height * 0.55,
      );

    canvas.drawPath(
      handlePath,
      Paint()
        ..color = cupColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawCoffeeLiquid(Canvas canvas, Size size) {
    if (progress <= 1.0) {
      final coffeePath = Path();
      final coffeeHeight = size.height * 0.25 + (size.height * 0.45 * (1.0 - progress));
      
      coffeePath.moveTo(size.width * 0.28, coffeeHeight);
      coffeePath.quadraticBezierTo(
        size.width * 0.5,
        coffeeHeight - size.height * 0.015,
        size.width * 0.72,
        coffeeHeight,
      );
      coffeePath.quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.85,
        size.width * 0.65,
        size.height * 0.88,
      );
      coffeePath.lineTo(size.width * 0.35, size.height * 0.88);
      coffeePath.quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.85,
        size.width * 0.28,
        coffeeHeight,
      );

      if (progress <= 0.3) {
        _drawSteam(canvas, size, progress);
      }

      // 커피 본체
      canvas.drawPath(
        coffeePath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              coffeeColor.withOpacity(0.95),
              coffeeColor.withOpacity(0.8),
              coffeeColor.withOpacity(0.6),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromLTRB(0, coffeeHeight, size.width, size.height * 0.8))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // 크레마 층
      canvas.drawPath(
        coffeePath,
        Paint()
          ..shader = LinearGradient(
            colors: [const Color(0xFFCDB7A5), const Color(0xFFB89B84)],
            stops: const [0.3, 1.0],
          ).createShader(Rect.fromLTRB(0, coffeeHeight - 10, size.width, coffeeHeight + 10))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
  }

  void _drawFoam(Canvas canvas, Size size) {
    if (progress < 0.98) {
      final rand = math.Random();
      for (int i = 0; i < 15; i++) {
        final x = size.width * 0.3 + rand.nextDouble() * size.width * 0.4;
        final y = size.height * 0.25 + rand.nextDouble() * size.height * 0.1;
        canvas.drawCircle(
          Offset(x, y),
          rand.nextDouble() * 3 + 2,
          Paint()
            ..color = Colors.white.withOpacity(rand.nextDouble() * 0.4 + 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }
  }

  void _drawCupDetails(Canvas canvas, Size size) {
    // 골드 림 디테일
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.25, size.height * 0.12,
        size.width * 0.5, size.height * 0.06,
      ),
      math.pi * 0.1,
      math.pi * 0.8,
      false,
      Paint()
        ..color = const Color(0xFFD5D5D5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 광택 효과
    final highlightPath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.15,
        size.width * 0.6, size.height * 0.2,
      )
      ..lineTo(size.width * 0.55, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.25,
        size.width * 0.45, size.height * 0.3,
      )
      ..close();

    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawSteam(Canvas canvas, Size size, double progress) {
    final steamPaint = Paint()
      ..color = cupColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final path = Path();
      final startX = size.width * (0.35 + i * 0.15);
      path.moveTo(startX, size.height * 0.1);
      path.quadraticBezierTo(
        startX + (i == 0 ? -20 : i == 1 ? 0 : 20),
        size.height * 0.0,
        startX + (i - 1) * 30,
        size.height * -0.1,
      );
      canvas.drawPath(path, steamPaint);
    }
  }

  @override
  bool shouldRepaint(CoffeeCupPainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.coffeeColor != coffeeColor ||
          oldDelegate.cupColor != cupColor;
}