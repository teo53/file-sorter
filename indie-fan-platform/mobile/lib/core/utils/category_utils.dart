import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 아티스트 카테고리 유틸리티
///
/// 사용법:
/// ```dart
/// import 'package:pipo/core/utils/category_utils.dart';
///
/// final color = CategoryUtils.getColor('IDOL');
/// final name = CategoryUtils.getDisplayName('IDOL');
/// ```
class CategoryUtils {
  CategoryUtils._();

  /// 카테고리별 색상 반환
  static Color getColor(String category) {
    return switch (category.toUpperCase()) {
      'IDOL' => AppColors.idol,
      'MAID' => AppColors.maid,
      'COSPLAYER' => AppColors.cosplayer,
      'STREAMER' => AppColors.streamer,
      _ => AppColors.other,
    };
  }

  /// 카테고리별 표시 이름 반환
  static String getDisplayName(String category) {
    return switch (category.toUpperCase()) {
      'IDOL' => '아이돌',
      'MAID' => '메이드',
      'COSPLAYER' => '코스플레이어',
      'STREAMER' => '스트리머',
      _ => '기타',
    };
  }

  /// 카테고리별 아이콘 반환
  static IconData getIcon(String category) {
    return switch (category.toUpperCase()) {
      'IDOL' => Icons.star,
      'MAID' => Icons.favorite,
      'COSPLAYER' => Icons.camera_alt,
      'STREAMER' => Icons.videocam,
      _ => Icons.person,
    };
  }

  /// 모든 카테고리 목록
  static const List<String> allCategories = [
    'IDOL',
    'MAID',
    'COSPLAYER',
    'STREAMER',
    'OTHER',
  ];
}
