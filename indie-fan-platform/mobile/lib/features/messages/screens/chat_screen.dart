import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/animations.dart';
import '../../../services/demo_data_service.dart';
import '../providers/messages_provider.dart';
import '../models/message_model.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatRoomId;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  bool _showSendButton = false;
  ChatRoom? _chatRoom;

  @override
  void initState() {
    super.initState();

    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _sendButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeOutBack),
    );

    _messageController.addListener(_onTextChanged);

    // 채팅방 정보 가져오기
    _chatRoom = DemoDataService.demoChatRooms
        .where((room) => room.id == widget.chatRoomId)
        .firstOrNull;

    Future.microtask(() {
      ref.read(messagesProvider(widget.chatRoomId).notifier).loadMessages();
      ref.read(chatRoomsProvider.notifier).markAsRead(widget.chatRoomId);
    });
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _showSendButton) {
      setState(() => _showSendButton = hasText);
      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    await ref
        .read(messagesProvider(widget.chatRoomId).notifier)
        .sendReply(text);

    // 스크롤 to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider(widget.chatRoomId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 메시지 리스트
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final showDate = index == 0 ||
                          !_isSameDay(
                            state.messages[index - 1].createdAt,
                            message.createdAt,
                          );

                      return Column(
                        children: [
                          if (showDate) _DateDivider(date: message.createdAt),
                          StaggeredListItem(
                            index: index,
                            baseDelay: Duration.zero,
                            itemDelay: const Duration(milliseconds: 30),
                            child: MessageBubble(
                              message: message,
                              artistImage: _chatRoom?.artistImage,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // 입력창
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Hero(
            tag: 'artist_${_chatRoom?.artistId ?? ''}',
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: _chatRoom?.artistImage ?? '',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 40,
                  height: 40,
                  color: AppColors.shimmerBase,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 40,
                  height: 40,
                  color: AppColors.shimmerBase,
                  child: const Icon(Icons.person, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chatRoom?.artistName ?? '',
                  style: AppTextStyles.labelLarge,
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '온라인',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.online,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: 더보기 메뉴
          },
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    final canReply = _chatRoom?.canReply ?? false;
    final remainingReplies = _chatRoom?.remainingReplies ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 답장 가능 횟수
            if (canReply)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: AppColors.primary.withOpacity(0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '이 메시지에 $remainingReplies번 더 답장할 수 있어요',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // 입력 필드
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 텍스트 입력
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              maxLines: null,
                              maxLength: 100,
                              enabled: canReply,
                              decoration: InputDecoration(
                                hintText: canReply
                                    ? '메시지를 입력하세요...'
                                    : '답장 횟수를 모두 사용했어요',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                counterText: '',
                              ),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 전송 버튼
                  const SizedBox(width: 8),
                  ScaleTransition(
                    scale: _sendButtonAnimation,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: _showSendButton
                            ? AppColors.primaryGradient
                            : null,
                        color: _showSendButton ? null : AppColors.divider,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _showSendButton && canReply
                            ? _sendMessage
                            : null,
                        icon: Icon(
                          Icons.send_rounded,
                          color: _showSendButton
                              ? Colors.white
                              : AppColors.textTertiary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;

  const _DateDivider({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.divider)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(date),
              style: AppTextStyles.caption,
            ),
          ),
          Expanded(child: Divider(color: AppColors.divider)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return '오늘';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return '어제';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }
}
