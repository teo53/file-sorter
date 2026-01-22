import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/animations.dart';
import '../models/seisan_model.dart';
import '../providers/seisan_provider.dart';

class SeisanRequestScreen extends ConsumerStatefulWidget {
  final String? artistId;

  const SeisanRequestScreen({
    super.key,
    this.artistId,
  });

  @override
  ConsumerState<SeisanRequestScreen> createState() =>
      _SeisanRequestScreenState();
}

class _SeisanRequestScreenState extends ConsumerState<SeisanRequestScreen> {
  final TextEditingController _messageController = TextEditingController();
  int _selectedAmount = 5000;
  bool _hasVoiceOption = false;
  String? _selectedArtistId;
  bool _isSubmitting = false;

  // 데모용 아티스트 목록
  final List<_DemoArtist> _artists = [
    _DemoArtist(
      id: 'artist_1',
      name: '유나',
      image: 'https://picsum.photos/seed/yuna/200/200',
    ),
    _DemoArtist(
      id: 'artist_2',
      name: '미나',
      image: 'https://picsum.photos/seed/mina/200/200',
    ),
    _DemoArtist(
      id: 'artist_3',
      name: '사쿠라',
      image: 'https://picsum.photos/seed/sakura/200/200',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedArtistId = widget.artistId ?? _artists.first.id;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  SeisanTier? get _selectedTier => SeisanTier.fromAmount(_selectedAmount);
  _DemoArtist? get _selectedArtist =>
      _artists.where((a) => a.id == _selectedArtistId).firstOrNull;

  int get _totalAmount =>
      _selectedAmount + (_hasVoiceOption ? 10000 : 0);

  bool get _canSubmit =>
      _selectedArtistId != null &&
      _messageController.text.trim().isNotEmpty &&
      !_isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '정산 요청하기',
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
              // 비공개 안내
              FadeSlideTransition(
                child: _PrivacyNotice(),
              ),

              const SizedBox(height: 24),

              // 아티스트 선택
              FadeSlideTransition(
                delay: const Duration(milliseconds: 50),
                child: _ArtistSelector(
                  artists: _artists,
                  selectedId: _selectedArtistId,
                  onSelect: (id) => setState(() => _selectedArtistId = id),
                ),
              ),

              const SizedBox(height: 24),

              // 금액 선택
              FadeSlideTransition(
                delay: const Duration(milliseconds: 100),
                child: _AmountSelector(
                  selectedAmount: _selectedAmount,
                  onSelect: (amount) => setState(() => _selectedAmount = amount),
                ),
              ),

              const SizedBox(height: 24),

              // 음성 메시지 옵션
              FadeSlideTransition(
                delay: const Duration(milliseconds: 150),
                child: _VoiceOptionToggle(
                  isEnabled: _hasVoiceOption,
                  onToggle: (value) => setState(() => _hasVoiceOption = value),
                ),
              ),

              const SizedBox(height: 24),

              // 요청 메시지 입력
              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: _MessageInput(
                  controller: _messageController,
                  artistName: _selectedArtist?.name ?? '아이돌',
                  onChanged: (_) => setState(() {}),
                ),
              ),

              const SizedBox(height: 32),

              // 최종 금액 표시 + 제출 버튼
              FadeSlideTransition(
                delay: const Duration(milliseconds: 250),
                child: _SubmitSection(
                  totalAmount: _totalAmount,
                  textLimit: _selectedTier?.textLimit ?? 0,
                  canSubmit: _canSubmit,
                  isSubmitting: _isSubmitting,
                  onSubmit: _handleSubmit,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      final artist = _selectedArtist;
      if (artist == null) return;

      await ref.read(seisanProvider.notifier).createRequest(
            artistId: artist.id,
            artistName: artist.name,
            artistImage: artist.image,
            amount: _selectedAmount,
            hasVoiceOption: _hasVoiceOption,
            requestMessage: _messageController.text.trim(),
          );

      if (mounted) {
        // 성공 다이얼로그
        await showDialog(
          context: context,
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
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 36,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '정산 요청 완료!',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 8),
                Text(
                  '${artist.name}님이 답장을 보내면\n알림으로 알려드릴게요.',
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
                  context.go('/seisan');
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

class _DemoArtist {
  final String id;
  final String name;
  final String image;

  const _DemoArtist({
    required this.id,
    required this.name,
    required this.image,
  });
}

class _PrivacyNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.accent.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '공개되지 않는 1:1 정산',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '요청과 답변 모두 나와 아이돌만 볼 수 있어요',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
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

class _ArtistSelector extends StatelessWidget {
  final List<_DemoArtist> artists;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _ArtistSelector({
    required this.artists,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '누구에게 요청할까요?',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              final isSelected = artist.id == selectedId;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < artists.length - 1 ? 12 : 0,
                ),
                child: ScaleOnTap(
                  onTap: () => onSelect(artist.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: artist.image,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 44,
                              height: 44,
                              color: AppColors.shimmerBase,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 44,
                              height: 44,
                              color: AppColors.shimmerBase,
                              child: const Icon(Icons.person, size: 22),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          artist.name,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AmountSelector extends StatelessWidget {
  final int selectedAmount;
  final ValueChanged<int> onSelect;

  const _AmountSelector({
    required this.selectedAmount,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selectedTier = SeisanTier.fromAmount(selectedAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '금액을 선택하세요',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: SeisanTier.tiers.map((tier) {
            final isSelected = tier.amount == selectedAmount;

            return ScaleOnTap(
              onTap: () => onSelect(tier.amount),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.divider,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '${_formatAmount(tier.amount)}원',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // 선택된 금액에 대한 설명
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Container(
            key: ValueKey(selectedAmount),
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.info,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '이 금액으로 아이돌은 최대 ${selectedTier?.textLimit ?? 0}자까지 답장할 수 있습니다',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

class _VoiceOptionToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _VoiceOptionToggle({
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: () => onToggle(!isEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.secondary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled
                ? AppColors.secondary
                : AppColors.divider,
            width: isEnabled ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.secondary.withOpacity(0.2)
                    : AppColors.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.mic,
                color: isEnabled
                    ? AppColors.secondary
                    : AppColors.textTertiary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '음성 메시지로 받기',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+10,000원',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isEnabled ? AppColors.secondary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isEnabled
                      ? AppColors.secondary
                      : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isEnabled
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final String artistName;
  final ValueChanged<String> onChanged;

  const _MessageInput({
    required this.controller,
    required this.artistName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '요청 메시지',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: '$artistName님에게 전하고 싶은 말을 적어주세요...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _SubmitSection extends StatelessWidget {
  final int totalAmount;
  final int textLimit;
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _SubmitSection({
    required this.totalAmount,
    required this.textLimit,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최종 금액',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${_formatAmount(totalAmount)}원',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '아이돌 응답',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                '최대 $textLimit자',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ScaleOnTap(
            onTap: canSubmit ? onSubmit : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: canSubmit ? AppColors.primaryGradient : null,
                color: canSubmit ? null : AppColors.divider,
                borderRadius: BorderRadius.circular(14),
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
                          valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        '정산 요청하기',
                        style: AppTextStyles.button.copyWith(
                          color: canSubmit
                              ? Colors.white
                              : AppColors.textTertiary,
                          fontSize: 16,
                        ),
                      ),
              ),
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
