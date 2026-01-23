import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/layout_constants.dart';

/// 스토리 썸네일 위젯
/// 홈 화면 상단의 스토리 레일에서 사용
class StoryThumbnail extends StatelessWidget {
  final String artistName;
  final String imageUrl;
  final bool hasNewStory;
  final VoidCallback onTap;

  const StoryThumbnail({
    super.key,
    required this.artistName,
    required this.imageUrl,
    required this.hasNewStory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: LayoutConstants.storyThumbnailSize + 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 프로필 이미지 + 링 테두리
            Container(
              width: LayoutConstants.storyThumbnailSize,
              height: LayoutConstants.storyThumbnailSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasNewStory
                    ? AppColors.storyRingGradient
                    : null,
                border: hasNewStory
                    ? null
                    : Border.all(
                        color: AppColors.textTertiary,
                        width: LayoutConstants.storyRingWidth,
                      ),
              ),
              padding: EdgeInsets.all(LayoutConstants.storyRingWidth),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.shimmerBase,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.shimmerBase,
                      child: Icon(
                        Icons.person,
                        size: 24,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // 아티스트 이름
            Text(
              artistName,
              style: AppTextStyles.caption.copyWith(
                color: hasNewStory
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: hasNewStory ? FontWeight.w500 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 스토리 레일 위젯
/// 홈 화면에서 수평 스크롤 스토리 목록을 표시
class StoryRail extends StatelessWidget {
  final List<StoryThumbnailData> stories;
  final Function(String artistId) onStoryTap;

  const StoryRail({
    super.key,
    required this.stories,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: LayoutConstants.storyThumbnailSize + 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: LayoutConstants.screenPaddingHorizontal,
        itemCount: stories.length,
        separatorBuilder: (_, __) => SizedBox(width: LayoutConstants.storySpacing),
        itemBuilder: (context, index) {
          final story = stories[index];
          return StoryThumbnail(
            artistName: story.artistName,
            imageUrl: story.imageUrl,
            hasNewStory: story.hasNewStory,
            onTap: () => onStoryTap(story.artistId),
          );
        },
      ),
    );
  }
}

/// 스토리 썸네일 데이터
class StoryThumbnailData {
  final String artistId;
  final String artistName;
  final String imageUrl;
  final bool hasNewStory;

  const StoryThumbnailData({
    required this.artistId,
    required this.artistName,
    required this.imageUrl,
    required this.hasNewStory,
  });
}
