import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/artists/screens/artist_detail_screen.dart';
import '../features/artists/screens/artists_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/messages/screens/chat_screen.dart';
import '../features/messages/screens/messages_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'app_routes.dart';
import 'main_shell.dart';

/// 라우터 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isLogin = state.matchedLocation == AppRoutes.login;
      final isAuthenticated = authState.status == AuthStatus.authenticated;

      // 온보딩 중이면 그대로
      if (isOnboarding) return null;

      // 인증되지 않았으면 로그인으로
      if (!isAuthenticated && !isLogin) {
        return AppRoutes.login;
      }

      // 인증되었는데 로그인 페이지면 홈으로
      if (isAuthenticated && isLogin) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // 온보딩
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 로그인
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // 메인 쉘 (BottomNavigationBar)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // 홈
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),

          // 아티스트 목록
          GoRoute(
            path: AppRoutes.artists,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ArtistsScreen(),
            ),
          ),

          // 메시지 목록
          GoRoute(
            path: AppRoutes.messages,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MessagesScreen(),
            ),
          ),

          // 프로필
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // 아티스트 상세 (쉘 밖)
      GoRoute(
        path: AppRoutes.artistDetail,
        builder: (context, state) {
          final artistId = state.pathParameters['id']!;
          return ArtistDetailScreen(artistId: artistId);
        },
      ),

      // 채팅 (쉘 밖)
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final chatRoomId = state.pathParameters['id']!;
          return ChatScreen(chatRoomId: chatRoomId);
        },
      ),
    ],
  );
});
