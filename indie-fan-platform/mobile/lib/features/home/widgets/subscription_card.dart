import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final artist = subscription.artist;
    if (artist == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 프로필 이미지
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: artist.profileImage ?? '',
                    width: 140,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.shimmerBase,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.shimmerBase,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textTertiary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                // 구독 기념일 뱃지
                if (subscription.hasAnniversary)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subscription.anniversaryText,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // 일반 D+ 표시
                if (!subscription.hasAnniversary)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        subscription.anniversaryText,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 아티스트 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      artist.stageName,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(artist.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getCategoryName(artist.category),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getCategoryColor(artist.category),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}
