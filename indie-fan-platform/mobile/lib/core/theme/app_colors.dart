import 'package:flutter/material.dart';

/// 다크+네온 테마 색상 팔레트
/// 지하아이돌 팬앱에 어울리는 신비로운 분위기의 디자인 시스템
class AppColors {
  AppColors._();

  // ============================================
  // Primary Colors (네온 퍼플)
  // ============================================
  static const Color primary = Color(0xFF805AD5);
  static const Color primaryLight = Color(0xFFA18BF7);
  static const Color primaryDark = Color(0xFF5A32B3);

  // ============================================
  // Secondary Colors (네온 핑크)
  // ============================================
  static const Color secondary = Color(0xFFD6336C);
  static const Color secondaryLight = Color(0xFFFF6B9D);

  // ============================================
  // Accent Colors (청록색)
  // ============================================
  static const Color accent = Color(0xFF2DD4BF);
  static const Color accentLight = Color(0xFF5EEAD4);

  // ============================================
  // Background Colors (다크 테마)
  // ============================================
  static const Color background = Color(0xFF0D0E1A);
  static const Color surface = Color(0xFF1A1C2D);
  static const Color surfaceElevated = Color(0xFF252738);
  static const Color inputBackground = Color(0xFF1E2030);

  // Legacy support (라이트 모드 fallback)
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Deprecated names (backward compatibility)
  static const Color darkBackground = background;
  static const Color darkSurface = surface;

  // ============================================
  // Text Colors
  // ============================================
  static const Color textPrimary = Color(0xFFF2F2F8);
  static const Color textSecondary = Color(0xFFA6A6C1);
  static const Color textTertiary = Color(0xFF5A5B75);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============================================
  // Status Colors
  // ============================================
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ============================================
  // Chat Bubble Colors
  // ============================================
  static const Color artistBubble = Color(0xFF805AD5);
  static const Color fanBubble = Color(0xFF2A2D3E);
  static const Color artistBubbleText = Color(0xFFFFFFFF);
  static const Color fanBubbleText = Color(0xFFF2F2F8);

  // ============================================
  // Category Colors
  // ============================================
  static const Color idol = Color(0xFFFF6B9D);
  static const Color maid = Color(0xFFFFB8D0);
  static const Color cosplayer = Color(0xFFA855F7);
  static const Color streamer = Color(0xFF3B82F6);
  static const Color other = Color(0xFF6B7280);

  // ============================================
  // Misc
  // ============================================
  static const Color divider = Color(0xFF2A2D3E);
  static const Color shimmerBase = Color(0xFF2A2D3E);
  static const Color shimmerHighlight = Color(0xFF3D4055);
  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF5A5B75);

  // ============================================
  // Gradients
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC0D0E1A)],
  );

  static const LinearGradient storyRingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );

  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA18BF7), Color(0xFFD6336C), Color(0xFF2DD4BF)],
    stops: [0.0, 0.5, 1.0],
  );

  // Seisan 특별 그라데이션
  static const LinearGradient seisanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1C2D),
      Color(0xFF252738),
    ],
  );

  // 글로우 효과용 색상
  static Color primaryGlow = primary.withOpacity(0.3);
  static Color secondaryGlow = secondary.withOpacity(0.3);
  static Color accentGlow = accent.withOpacity(0.3);
}
