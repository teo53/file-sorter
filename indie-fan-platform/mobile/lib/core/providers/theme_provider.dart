import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 테마 모드 상태 관리 Provider
/// 다크/라이트 테마 전환을 제어한다
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  /// 라이트 모드로 전환
  void setLightMode() {
    state = ThemeMode.light;
  }

  /// 다크 모드로 전환
  void setDarkMode() {
    state = ThemeMode.dark;
  }

  /// 시스템 설정 따르기
  void setSystemMode() {
    state = ThemeMode.system;
  }

  /// 테마 토글 (light ↔ dark)
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  /// 특정 모드로 설정
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  /// 현재 다크 모드인지 확인
  bool get isDarkMode => state == ThemeMode.dark;

  /// 현재 라이트 모드인지 확인
  bool get isLightMode => state == ThemeMode.light;

  /// 현재 시스템 모드인지 확인
  bool get isSystemMode => state == ThemeMode.system;
}
