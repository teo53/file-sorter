import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF5541D7);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF7675);
  static const Color secondaryLight = Color(0xFFFFADAD);

  // Accent Colors
  static const Color accent = Color(0xFF00CEC9);
  static const Color accentLight = Color(0xFF81ECEC);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF1F3F5);

  // Dark Mode
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFD63031);
  static const Color info = Color(0xFF0984E3);

  // Chat Bubble Colors
  static const Color artistBubble = Color(0xFF6C5CE7);
  static const Color fanBubble = Color(0xFFE8E8E8);
  static const Color artistBubbleText = Color(0xFFFFFFFF);
  static const Color fanBubbleText = Color(0xFF2D3436);

  // Category Colors
  static const Color idol = Color(0xFFFF6B81);
  static const Color maid = Color(0xFFFFB8D0);
  static const Color cosplayer = Color(0xFF9B59B6);
  static const Color streamer = Color(0xFF3498DB);
  static const Color other = Color(0xFF95A5A6);

  // Misc
  static const Color divider = Color(0xFFE9ECEF);
  static const Color shimmerBase = Color(0xFFE8E8E8);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color online = Color(0xFF00B894);
  static const Color offline = Color(0xFFB2BEC3);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF8B7CF7)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x99000000)],
  );
}
