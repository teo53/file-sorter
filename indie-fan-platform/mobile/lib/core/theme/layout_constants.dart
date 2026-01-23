import 'package:flutter/material.dart';

/// 레이아웃 상수 정의
/// 8pt 베이스라인 그리드 시스템
class LayoutConstants {
  LayoutConstants._();

  // ============================================
  // Spacing (8pt baseline)
  // ============================================
  static const double spacing = 8.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ============================================
  // Border Radius
  // ============================================
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double chipRadius = 24.0;
  static const double inputRadius = 12.0;
  static const double thumbnailRadius = 8.0;
  static const double avatarRadius = 100.0; // 원형

  // ============================================
  // Screen Padding
  // ============================================
  static const EdgeInsets screenPadding = EdgeInsets.all(16);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  // ============================================
  // Grid
  // ============================================
  static const int gridCrossAxisCount = 2;
  static const double gridMainAxisSpacing = 16.0;
  static const double gridCrossAxisSpacing = 16.0;
  static const double gridChildAspectRatio = 0.7; // 카드 비율 (세로 길게)

  // ============================================
  // Story
  // ============================================
  static const double storyThumbnailSize = 68.0;
  static const double storyRingWidth = 3.0;
  static const double storySpacing = 12.0;

  // ============================================
  // Avatar
  // ============================================
  static const double avatarSizeXs = 24.0;
  static const double avatarSizeSm = 32.0;
  static const double avatarSizeMd = 48.0;
  static const double avatarSizeLg = 64.0;
  static const double avatarSizeXl = 96.0;

  // ============================================
  // Button
  // ============================================
  static const double buttonHeight = 48.0;
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightLg = 56.0;

  // ============================================
  // Icon
  // ============================================
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;

  // ============================================
  // Animation Duration
  // ============================================
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  // ============================================
  // Shadow (다크 테마용 글로우 효과)
  // ============================================
  static List<BoxShadow> cardShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> subtleShadow = [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
}
