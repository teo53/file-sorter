import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../artists/providers/artists_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../messages/providers/messages_provider.dart';
import '../providers/subscriptions_provider.dart';
import '../widgets/subscription_card.dart';
import '../widgets/recent_message_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 데이터 로드
    Future.microtask(() {
      ref.read(subscriptionsProvider.notifier).loadSubscriptions();
      ref.read(artistsProvider.notifier).loadArtists();
      ref.read(chatRoomsProvider.notifier).loadChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final subscriptions = ref.watch(activeSubscriptionsProvider);
    final chatRooms = ref.watch(chatRoomsProvider).chatRooms;
    final isLoading = ref.watch(subscriptionsProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '안녕하세요,',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user?.nickname ?? '팬'}님',
                            style: AppTextStyles.h2,
                          ),
                        ],
                      ),
                    ),
                    // 알림 아이콘
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        color: AppColors.textPrimary,
                        onPressed: () {
                          // TODO: 알림 화면
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 구독 중인 아티스트 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '구독 중인 아티스트',
                      style: AppTextStyles.h4,
                    ),
                    Text(
                      '${subscriptions.length}명',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 구독 카드 리스트 (가로 스크롤)
            SliverToBoxAdapter(
              child: isLoading
                  ? const SizedBox(
                      height: 180,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    )
                  : subscriptions.isEmpty
                      ? _EmptySubscriptions(
                          onExplore: () => context.go('/artists'),
                        )
                      : SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: subscriptions.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: SubscriptionCard(
                                  subscription: subscriptions[index],
                                  onTap: () {
                                    final artistId = subscriptions[index].artistId;
                                    context.push('/artists/$artistId');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),

            // 최근 메시지 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '최근 메시지',
                      style: AppTextStyles.h4,
                    ),
                    TextButton(
                      onPressed: () => context.go('/messages'),
                      child: Text(
                        '전체보기',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 최근 메시지 리스트
            chatRooms.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '아직 메시지가 없어요',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= chatRooms.length) return null;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RecentMessageCard(
                              chatRoom: chatRooms[index],
                              onTap: () {
                                context.push('/messages/${chatRooms[index].id}');
                              },
                            ),
                          );
                        },
                        childCount: chatRooms.length > 3 ? 3 : chatRooms.length,
                      ),
                    ),
                  ),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySubscriptions extends StatelessWidget {
  final VoidCallback onExplore;

  const _EmptySubscriptions({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            '아직 구독 중인 아티스트가 없어요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onExplore,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('아티스트 둘러보기'),
          ),
        ],
      ),
    );
  }
}
