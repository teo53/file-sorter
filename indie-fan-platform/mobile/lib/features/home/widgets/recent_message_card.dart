import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../messages/models/message_model.dart';

class RecentMessageCard extends StatelessWidget {
  final ChatRoom chatRoom;
  final VoidCallback? onTap;

  const RecentMessageCard({
    super.key,
    required this.chatRoom,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // timeago 한글 설정
    timeago.setLocaleMessages('ko', timeago.KoMessages());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 프로필 이미지
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: chatRoom.artistImage,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.shimmerBase,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.shimmerBase,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                // 온라인 표시
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.online,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // 메시지 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.artistName,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chatRoom.lastMessageAt != null)
                        Text(
                          timeago.format(chatRoom.lastMessageAt!, locale: 'ko'),
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chatRoom.lastMessage ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: chatRoom.unreadCount > 0
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: chatRoom.unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 읽지 않은 메시지 수
            if (chatRoom.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chatRoom.unreadCount > 99
                      ? '99+'
                      : chatRoom.unreadCount.toString(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
