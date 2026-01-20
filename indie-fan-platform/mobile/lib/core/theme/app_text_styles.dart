import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  // Chat
  static const TextStyle chatMessage = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle chatTime = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  // Button
  static const TextStyle button = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );
}
