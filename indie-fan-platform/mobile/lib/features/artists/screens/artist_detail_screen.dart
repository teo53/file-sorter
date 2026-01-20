import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/artists_provider.dart';
import '../models/artist_model.dart';

class ArtistDetailScreen extends ConsumerWidget {
  final String artistId;

  const ArtistDetailScreen({
    super.key,
    required this.artistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = ref.watch(artistByIdProvider(artistId));

    if (artist == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('아티스트를 찾을 수 없습니다'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 커버 이미지 앱바
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: artist.coverImage ?? artist.profileImage ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.shimmerBase,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  // 그라데이션 오버레이
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // 아티스트 정보
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 프로필 이미지
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: artist.profileImage ?? '',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 80,
                                height: 80,
                                color: AppColors.shimmerBase,
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 80,
                                height: 80,
                                color: AppColors.shimmerBase,
                                child: const Icon(Icons.person),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(artist.category),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getCategoryName(artist.category),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                artist.stageName,
                                style: AppTextStyles.h2.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 컨텐츠
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 통계
                  Row(
                    children: [
                      _StatItem(
                        label: '구독자',
                        value: '${artist.subscriberCount}명',
                      ),
                      const SizedBox(width: 24),
                      _StatItem(
                        label: '월 구독료',
                        value: artist.formattedPrice,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 소개
                  Text(
                    '소개',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      artist.bio ?? '아직 소개가 없습니다.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SNS 링크
                  if (_hasSocialLinks(artist)) ...[
                    Text(
                      'SNS',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        if (artist.twitterUrl != null)
                          _SocialButton(
                            icon: Icons.alternate_email,
                            label: 'Twitter',
                            onTap: () => _launchUrl(artist.twitterUrl!),
                          ),
                        if (artist.instagramUrl != null)
                          _SocialButton(
                            icon: Icons.camera_alt_outlined,
                            label: 'Instagram',
                            onTap: () => _launchUrl(artist.instagramUrl!),
                          ),
                        if (artist.youtubeUrl != null)
                          _SocialButton(
                            icon: Icons.play_circle_outline,
                            label: 'YouTube',
                            onTap: () => _launchUrl(artist.youtubeUrl!),
                          ),
                        if (artist.tiktokUrl != null)
                          _SocialButton(
                            icon: Icons.music_note,
                            label: 'TikTok',
                            onTap: () => _launchUrl(artist.tiktokUrl!),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 구독 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: artist.isSubscribed
                        ? OutlinedButton(
                            onPressed: () {
                              _showUnsubscribeDialog(context, ref, artist);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  '구독 중',
                                  style: AppTextStyles.button.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              _showSubscribeDialog(context, ref, artist);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              '${artist.formattedPrice}으로 구독하기',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasSocialLinks(Artist artist) {
    return artist.twitterUrl != null ||
        artist.instagramUrl != null ||
        artist.youtubeUrl != null ||
        artist.tiktokUrl != null;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'IDOL':
        return AppColors.idol;
      case 'MAID':
        return AppColors.maid;
      case 'COSPLAYER':
        return AppColors.cosplayer;
      case 'STREAMER':
        return AppColors.streamer;
      default:
        return AppColors.other;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'IDOL':
        return '아이돌';
      case 'MAID':
        return '메이드';
      case 'COSPLAYER':
        return '코스어';
      case 'STREAMER':
        return '스트리머';
      default:
        return '기타';
    }
  }

  void _showSubscribeDialog(BuildContext context, WidgetRef ref, Artist artist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독하기'),
        content: Text(
          '${artist.stageName}님을 ${artist.formattedPrice}에 구독하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(artistsProvider.notifier).toggleSubscription(artist.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${artist.stageName}님을 구독했습니다!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('구독하기'),
          ),
        ],
      ),
    );
  }

  void _showUnsubscribeDialog(BuildContext context, WidgetRef ref, Artist artist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독 취소'),
        content: Text(
          '${artist.stageName}님의 구독을 취소하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(artistsProvider.notifier).toggleSubscription(artist.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${artist.stageName}님의 구독을 취소했습니다.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('구독 취소'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
