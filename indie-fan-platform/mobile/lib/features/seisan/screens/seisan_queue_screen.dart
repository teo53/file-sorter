import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/formatters.dart';
import '../models/seisan_model.dart';
import '../providers/seisan_provider.dart';

/// 아이돌용: 정산 대기 큐 화면
class SeisanQueueScreen extends ConsumerStatefulWidget {
  const SeisanQueueScreen({super.key});

  @override
  ConsumerState<SeisanQueueScreen> createState() => _SeisanQueueScreenState();
}

class _SeisanQueueScreenState extends ConsumerState<SeisanQueueScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(seisanProvider.notifier).loadPendingQueue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seisanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '정산 응답 대기',
          style: AppTextStyles.labelLarge,
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            )
          : state.pendingQueue.isEmpty
              ? _EmptyState()
              : CustomScrollView(
                  slivers: [
                    // 상단 안내
                    SliverToBoxAdapter(
                      child: FadeSlideTransition(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withOpacity(0.1),
                                  AppColors.accent.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${state.pendingQueue.length}',
                                      style: AppTextStyles.h4.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '대기 중인 정산',
                                        style: AppTextStyles.labelMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '팬들이 기다리고 있어요!',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 정산 카드 리스트
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final request = state.pendingQueue[index];
                            return StaggeredListItem(
                              index: index,
                              baseDelay: const Duration(milliseconds: 100),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _QueueCard(
                                  request: request,
                                  onRespond: () {
                                    context.push('/seisan/respond/${request.id}');
                                  },
                                ),
                              ),
                            );
                          },
                          childCount: state.pendingQueue.length,
                        ),
                      ),
                    ),

                    // 하단 여백
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final SeisanRequest request;
  final VoidCallback onRespond;

  const _QueueCard({
    required this.request,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단: 팬 정보 + 금액
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 팬 이미지
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: request.fanProfileImage,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.shimmerBase,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.shimmerBase,
                      child: const Icon(Icons.person, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 팬 닉네임 + 시간
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.fanNickname,
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.createdAt.formatRelative(),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                // 금액 배지
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.amount.formatKRW(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 요청 메시지
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              request.requestMessage,
              style: AppTextStyles.bodySmall.copyWith(
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 하단: 제한 정보 + 응답 버튼
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 텍스트 제한
                _InfoBadge(
                  icon: Icons.text_fields,
                  label: '최대 ${request.textLimit}자',
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                // 음성 옵션
                if (request.hasVoiceOption)
                  _InfoBadge(
                    icon: Icons.mic,
                    label: '음성 포함',
                    color: AppColors.secondary,
                  ),
                const Spacer(),
                // 응답 버튼
                ScaleOnTap(
                  onTap: onRespond,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '응답하기',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeSlideTransition(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 40,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '대기 중인 정산이 없어요',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '모든 정산에 응답했어요!\n새로운 정산이 오면 알려드릴게요.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
