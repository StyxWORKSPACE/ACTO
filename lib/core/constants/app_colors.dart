import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF007AFF);      // iOS 스타일 파란색
  static const Color secondary = Color(0xFF5856D6);    // 보조 액센트 색상

  // Background Colors
  static const Color background = Color(0xFFF5F7FA);   // 메인 배경색
  static const Color container_background = Color(0xFFF5F7FA); // 다크 컨테이너 배경

  // Text Colors
  static const Color text = Color(0xFF2B2B2B);         // 기본 텍스트
  static const Color text_secondary = Color(0xFF6B7280); // 보조 텍스트

  // Status Colors
  static const Color success = Color(0xFF34C759);      // 성공 상태
  static const Color error = Color(0xFFFF3B30);        // 에러 상태
  static const Color warning = Color(0xFFFF9500);      // 경고 상태

  // Neutral Colors
  static const Color grey = Color(0xFF8E8E93);         // 기본 회색
  static const Color grey_light = Color(0xFFE5E5EA);   // 밝은 회색
  static const Color grey_dark = Color(0xFF3A3A3C);    // 어두운 회색

  // Gradient Colors
  static const List<Color> primary_gradient = [
    Color(0xFF007AFF),
    Color(0xFF5856D6),
  ];
}