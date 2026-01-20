import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/artist_model.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;

  const ArtistCard({
    super.key,
    required this.artist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: artist.profileImage ?? '',
                      width: double.infinity,
                      height: double.infinity,
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
                  // 카테고리 뱃지
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(artist.category),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getCategoryName(artist.category),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  // 구독 중 표시
                  if (artist.isSubscribed)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 정보
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.stageName,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artist.bio ?? '',
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          artist.formattedSubscriberCount,
                          style: AppTextStyles.labelSmall,
                        ),
                        const Spacer(),
                        Text(
                          artist.formattedPrice,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
