import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/animations.dart';
import '../models/seisan_model.dart';
import '../providers/seisan_provider.dart';

/// 아이돌용: 정산 응답 작성 화면
class SeisanRespondScreen extends ConsumerStatefulWidget {
  final String requestId;

  const SeisanRespondScreen({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<SeisanRespondScreen> createState() => _SeisanRespondScreenState();
}

class _SeisanRespondScreenState extends ConsumerState<SeisanRespondScreen> {
  final TextEditingController _responseController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasVoiceUploaded = false;

  SeisanRequest? get _request {
    final state = ref.watch(seisanProvider);
    return state.pendingQueue.where((r) => r.id == widget.requestId).firstOrNull;
  }

  int get _remainingChars {
    final limit = _request?.textLimit ?? 0;
    return limit - _responseController.text.length;
  }

  bool get _canSubmit {
    final hasText = _responseController.text.trim().isNotEmpty;
    final withinLimit = _remainingChars >= 0;
    return hasText && withinLimit && !_isSubmitting;
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = _request;

    if (request == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('정산을 찾을 수 없습니다.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(context),
        ),
        title: Text(
          '정산 응답',
          style: AppTextStyles.labelLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 팬 정보 카드
              FadeSlideTransition(
                child: _FanInfoCard(request: request),
              ),

              const SizedBox(height: 20),

              // 팬의 요청 메시지
              FadeSlideTransition(
                delay: const Duration(milliseconds: 50),
                child: _RequestMessageCard(request: request),
              ),

              const SizedBox(height: 24),

              // 응답 작성 섹션
              FadeSlideTransition(
                delay: const Duration(milliseconds: 100),
                child: _ResponseSection(
                  controller: _responseController,
                  textLimit: request.textLimit,
                  remainingChars: _remainingChars,
                  onChanged: () => setState(() {}),
                ),
              ),

              // 음성 업로드 섹션 (옵션이 있는 경우)
              if (request.hasVoiceOption) ...[
                const SizedBox(height: 20),
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 150),
                  child: _VoiceUploadSection(
                    hasUploaded: _hasVoiceUploaded,
                    onUpload: () {
                      // 데모: 업로드 시뮬레이션
                      setState(() => _hasVoiceUploaded = true);
                    },
                    onRemove: () {
                      setState(() => _hasVoiceUploaded = false);
                    },
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // 제출 버튼
              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: _SubmitButton(
                  canSubmit: _canSubmit,
                  isSubmitting: _isSubmitting,
                  onSubmit: () => _handleSubmit(request),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    if (_responseController.text.isEmpty) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('작성을 취소할까요?', style: AppTextStyles.h4),
        content: Text(
          '작성 중인 내용이 사라집니다.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '계속 작성',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text(
              '취소하기',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(SeisanRequest request) async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(seisanProvider.notifier).respondToRequest(
            requestId: request.id,
            responseText: _responseController.text.trim(),
            voiceUrl: _hasVoiceUploaded ? 'demo_voice_url' : null,
          );

      if (mounted) {
        // 성공 다이얼로그
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.send,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '응답 전송 완료!',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 8),
                Text(
                  '${request.fanNickname}님에게\n특별한 답장을 보냈어요.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: Text(
                  '확인',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _FanInfoCard extends StatelessWidget {
  final SeisanRequest request;

  const _FanInfoCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: request.fanProfileImage,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 56,
                height: 56,
                color: AppColors.shimmerBase,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: AppColors.shimmerBase,
                child: const Icon(Icons.person, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.fanNickname,
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _SmallBadge(
                      text: '${_formatAmount(request.amount)}원',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    _SmallBadge(
                      text: '${request.textLimit}자',
                      color: AppColors.info,
                    ),
                    if (request.hasVoiceOption) ...[
                      const SizedBox(width: 6),
                      _SmallBadge(
                        icon: Icons.mic,
                        text: '음성',
                        color: AppColors.secondary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

class _SmallBadge extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;

  const _SmallBadge({
    this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestMessageCard extends StatelessWidget {
  final SeisanRequest request;

  const _RequestMessageCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fanBubble,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '팬의 요청',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.requestMessage,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseSection extends StatelessWidget {
  final TextEditingController controller;
  final int textLimit;
  final int remainingChars;
  final VoidCallback onChanged;

  const _ResponseSection({
    required this.controller,
    required this.textLimit,
    required this.remainingChars,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOverLimit = remainingChars < 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '답장 작성',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            // 남은 글자 수
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isOverLimit
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$remainingChars자 남음',
                style: AppTextStyles.caption.copyWith(
                  color: isOverLimit ? AppColors.error : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverLimit ? AppColors.error : AppColors.divider,
              width: isOverLimit ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            maxLines: 8,
            decoration: InputDecoration(
              hintText: '팬에게 특별한 답장을 작성해주세요...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.6,
            ),
          ),
        ),
        if (isOverLimit) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                '글자 수 제한을 초과했습니다',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _VoiceUploadSection extends StatelessWidget {
  final bool hasUploaded;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const _VoiceUploadSection({
    required this.hasUploaded,
    required this.onUpload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.mic,
                  size: 20,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '음성 메시지',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '팬이 음성 메시지를 요청했어요',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (hasUploaded)
            ScaleOnTap(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '음성 파일 업로드됨',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '탭하여 삭제',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            )
          else
            ScaleOnTap(
              onTap: onUpload,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.upload,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '음성 파일 업로드',
                      style: AppTextStyles.labelMedium.copyWith(
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
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _SubmitButton({
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: canSubmit ? onSubmit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: canSubmit ? AppColors.primaryGradient : null,
          color: canSubmit ? null : AppColors.divider,
          borderRadius: BorderRadius.circular(16),
          boxShadow: canSubmit
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send,
                      size: 20,
                      color: canSubmit ? Colors.white : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '답장 보내기',
                      style: AppTextStyles.button.copyWith(
                        color:
                            canSubmit ? Colors.white : AppColors.textTertiary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
