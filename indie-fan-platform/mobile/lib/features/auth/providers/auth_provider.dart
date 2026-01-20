import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/demo_data_service.dart';
import '../models/user_model.dart';

/// 인증 상태
enum AuthStatus { initial, authenticated, unauthenticated }

/// 인증 상태 모델
class AuthState {
  final AuthStatus status;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 인증 상태 관리 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// 데모용 자동 로그인
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    // 시뮬레이션: 로딩 딜레이
    await Future.delayed(const Duration(milliseconds: 800));

    // 데모: 항상 인증된 상태로 시작 (온보딩 완료 후)
    state = AuthState(
      status: AuthStatus.authenticated,
      user: DemoDataService.demoUser,
      isLoading: false,
    );
  }

  /// 소셜 로그인
  Future<void> signInWithKakao() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    state = AuthState(
      status: AuthStatus.authenticated,
      user: DemoDataService.demoUser,
      isLoading: false,
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    state = AuthState(
      status: AuthStatus.authenticated,
      user: DemoDataService.demoUser,
      isLoading: false,
    );
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    state = AuthState(
      status: AuthStatus.authenticated,
      user: DemoDataService.demoUser,
      isLoading: false,
    );
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));

    state = const AuthState(
      status: AuthStatus.unauthenticated,
      isLoading: false,
    );
  }

  /// 프로필 업데이트
  void updateProfile({String? nickname, String? profileImage}) {
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(
          nickname: nickname,
          profileImage: profileImage,
        ),
      );
    }
  }
}

/// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// 현재 사용자 Provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// 인증 상태 Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});
