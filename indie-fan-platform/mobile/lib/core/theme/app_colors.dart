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

/// 라이트 테마 색상 팔레트
/// 따뜻하고 화사한 피치-코랄 톤의 디자인 시스템
class LightAppColors {
  LightAppColors._();

  // ============================================
  // Primary Colors (피치-코랄)
  // ============================================
  static const Color primary = Color(0xFFFF8264);
  static const Color primaryLight = Color(0xFFFFB59E);
  static const Color primaryDark = Color(0xFFE76A4C);

  // ============================================
  // Secondary Colors (웜 옐로우)
  // ============================================
  static const Color secondary = Color(0xFFFFD9A5);
  static const Color secondaryLight = Color(0xFFFFEBD3);
  static const Color secondaryDark = Color(0xFFF4C17A);

  // ============================================
  // Accent Colors (민트 그린)
  // ============================================
  static const Color accent = Color(0xFF00BFA6);
  static const Color accentLight = Color(0xFF56D6C7);
  static const Color accentDark = Color(0xFF009E8D);

  // ============================================
  // Background Colors (라이트 테마)
  // ============================================
  static const Color background = Color(0xFFFFF9F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF5E9E3);
  static const Color inputBackground = Color(0xFFFFF5EF);

  // ============================================
  // Neutral Colors
  // ============================================
  static const Color neutral = Color(0xFFEFEFF2);
  static const Color neutralLight = Color(0xFFF8F8FA);
  static const Color neutralDark = Color(0xFFE0E0E5);

  // ============================================
  // Text Colors
  // ============================================
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF6A6A6A);
  static const Color textTertiary = Color(0xFFA0A0A0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============================================
  // Status Colors
  // ============================================
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error = Color(0xFFFF453A);
  static const Color info = Color(0xFF007AFF);

  // ============================================
  // Chat Bubble Colors
  // ============================================
  static const Color artistBubble = Color(0xFFFF8264);
  static const Color fanBubble = Color(0xFFF5E9E3);
  static const Color artistBubbleText = Color(0xFFFFFFFF);
  static const Color fanBubbleText = Color(0xFF2D2D2D);

  // ============================================
  // Category Colors
  // ============================================
  static const Color idol = Color(0xFFFF8264);
  static const Color maid = Color(0xFFFFB8D0);
  static const Color cosplayer = Color(0xFFB388FF);
  static const Color streamer = Color(0xFF64B5F6);
  static const Color other = Color(0xFF90A4AE);

  // ============================================
  // Misc
  // ============================================
  static const Color divider = Color(0xFFEAE0DA);
  static const Color shimmerBase = Color(0xFFF5E9E3);
  static const Color shimmerHighlight = Color(0xFFFFF5EF);
  static const Color online = Color(0xFF34C759);
  static const Color offline = Color(0xFFA0A0A0);

  // ============================================
  // Gradients
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x33FFF9F4)],
  );

  static const LinearGradient storyRingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB59E), Color(0xFFFFD9A5), Color(0xFF56D6C7)],
    stops: [0.0, 0.5, 1.0],
  );

  // Seisan 특별 그라데이션
  static const LinearGradient seisanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF9F4),
      Color(0xFFF5E9E3),
    ],
  );

  // 글로우 효과용 색상
  static Color primaryGlow = primary.withOpacity(0.2);
  static Color secondaryGlow = secondary.withOpacity(0.2);
  static Color accentGlow = accent.withOpacity(0.2);
}
