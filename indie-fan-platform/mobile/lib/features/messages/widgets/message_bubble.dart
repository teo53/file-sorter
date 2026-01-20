import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String? artistImage;

  const MessageBubble({
    super.key,
    required this.message,
    this.artistImage,
  });

  @override
  Widget build(BuildContext context) {
    final isArtist = message.isFromArtist;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isArtist ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 아티스트 프로필 (왼쪽)
          if (isArtist) ...[
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: artistImage ?? '',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 36,
                  height: 36,
                  color: AppColors.shimmerBase,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 36,
                  height: 36,
                  color: AppColors.shimmerBase,
                  child: const Icon(Icons.person, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 메시지 버블
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isArtist ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                // 이미지 메시지
                if (message.type == MessageType.image)
                  _ImageBubble(
                    imageUrl: message.mediaUrl ?? message.content,
                    isArtist: isArtist,
                  )
                // 텍스트 메시지
                else
                  _TextBubble(
                    text: message.content,
                    isArtist: isArtist,
                  ),

                const SizedBox(height: 4),

                // 시간 & 읽음 표시
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isArtist && !message.isRead)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '1',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Text(
                      _formatTime(message.createdAt),
                      style: AppTextStyles.chatTime,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 팬 메시지 오른쪽 여백
          if (!isArtist) const SizedBox(width: 44),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $displayHour:$minute';
  }
}

class _TextBubble extends StatelessWidget {
  final String text;
  final bool isArtist;

  const _TextBubble({
    super.key,
    required this.text,
    required this.isArtist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isArtist ? AppColors.artistBubble : AppColors.fanBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isArtist ? 4 : 20),
          bottomRight: Radius.circular(isArtist ? 20 : 4),
        ),
        boxShadow: [
          BoxShadow(
            color: (isArtist ? AppColors.primary : Colors.black)
                .withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTextStyles.chatMessage.copyWith(
          color: isArtist ? AppColors.artistBubbleText : AppColors.fanBubbleText,
        ),
      ),
    );
  }
}

class _ImageBubble extends StatelessWidget {
  final String imageUrl;
  final bool isArtist;

  const _ImageBubble({
    super.key,
    required this.imageUrl,
    required this.isArtist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
        maxHeight: 250,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isArtist ? 4 : 20),
          bottomRight: Radius.circular(isArtist ? 20 : 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isArtist ? 4 : 20),
          bottomRight: Radius.circular(isArtist ? 20 : 4),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 200,
            height: 150,
            color: AppColors.shimmerBase,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 150,
            color: AppColors.shimmerBase,
            child: const Icon(
              Icons.broken_image,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
