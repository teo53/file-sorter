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
import '../features/seisan/screens/seisan_list_screen.dart';
import '../features/seisan/screens/seisan_detail_screen.dart';
import '../features/seisan/screens/seisan_request_screen.dart';
import '../features/seisan/screens/seisan_open_screen.dart';
import '../features/seisan/screens/seisan_queue_screen.dart';
import '../features/seisan/screens/seisan_respond_screen.dart';
import '../features/seisan/providers/seisan_provider.dart';
import '../features/stories/screens/story_viewer_screen.dart';
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

          // 정산 목록
          GoRoute(
            path: AppRoutes.seisan,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SeisanListScreen(),
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
          final artistId = state.pathParameters['id'];
          if (artistId == null) {
            return const Scaffold(
              body: Center(child: Text('잘못된 접근입니다')),
            );
          }
          return ArtistDetailScreen(artistId: artistId);
        },
      ),

      // 채팅 (쉘 밖)
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final chatRoomId = state.pathParameters['id'];
          if (chatRoomId == null) {
            return const Scaffold(
              body: Center(child: Text('잘못된 접근입니다')),
            );
          }
          return ChatScreen(chatRoomId: chatRoomId);
        },
      ),

      // 정산 요청 (쉘 밖)
      GoRoute(
        path: AppRoutes.seisanRequest,
        builder: (context, state) => const SeisanRequestScreen(),
      ),

      // 정산 상세 (쉘 밖)
      GoRoute(
        path: AppRoutes.seisanDetail,
        builder: (context, state) {
          final seisanId = state.pathParameters['id'];
          if (seisanId == null) {
            return const Scaffold(
              body: Center(child: Text('잘못된 접근입니다')),
            );
          }
          return SeisanDetailScreen(seisanId: seisanId);
        },
      ),

      // 정산 열기 (개봉식 연출, 쉘 밖)
      GoRoute(
        path: AppRoutes.seisanOpen,
        builder: (context, state) {
          final seisanId = state.pathParameters['id'];
          if (seisanId == null) {
            return const Scaffold(
              body: Center(child: Text('잘못된 접근입니다')),
            );
          }
          return Consumer(
            builder: (context, ref, _) {
              final seisanState = ref.watch(seisanProvider);
              final request = ref.read(seisanProvider.notifier).getRequestById(seisanId);

              if (request == null) {
                return const Scaffold(
                  body: Center(child: Text('정산 요청을 찾을 수 없습니다')),
                );
              }

              return SeisanOpenScreen(
                idolName: request.artistName,
                idolImageUrl: request.artistImage,
                responseText: request.responseText ?? '',
                hasHeartEffect: request.responseText?.contains(RegExp(r'[❤️💕💗💖🥰😍]')) ?? false,
                voiceUrl: request.voiceUrl,
              );
            },
          );
        },
      ),

      // 정산 대기 큐 (아이돌용, 쉘 밖)
      GoRoute(
        path: AppRoutes.seisanQueue,
        builder: (context, state) => const SeisanQueueScreen(),
      ),

      // 정산 응답 작성 (아이돌용, 쉘 밖)
      GoRoute(
        path: AppRoutes.seisanRespond,
        builder: (context, state) {
          final requestId = state.pathParameters['id'];
          if (requestId == null) {
            return const Scaffold(
              body: Center(child: Text('잘못된 접근입니다')),
            );
          }
          return SeisanRespondScreen(requestId: requestId);
        },
      ),

      // 스토리 뷰어 (쉘 밖, 풀스크린)
      GoRoute(
        path: AppRoutes.stories,
        builder: (context, state) {
          final artistId = state.pathParameters['artistId'];
          if (artistId == null) {
            return const Scaffold(
              body: Center(child: Text('잘못된 접근입니다')),
            );
          }
          return StoryViewerScreen(artistId: artistId);
        },
      ),
    ],
  );
});
