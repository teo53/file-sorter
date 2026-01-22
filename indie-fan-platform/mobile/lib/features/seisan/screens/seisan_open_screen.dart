import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 정산 열기 애니메이션 상태
enum SeisanOpenState {
  preview,  // 배경 dim + 아이돌 이미지 페이드인
  reveal,   // 봉투 열림 애니메이션
  read,     // 편지 내용 표시 (최종 상태)
}

/// 정산 열기(개봉) 화면 - 특별한 1:1 경험을 위한 연출
class SeisanOpenScreen extends StatefulWidget {
  final String idolName;
  final String idolImageUrl;
  final String responseText;
  final bool hasHeartEffect;
  final String? voiceUrl;

  const SeisanOpenScreen({
    super.key,
    required this.idolName,
    required this.idolImageUrl,
    required this.responseText,
    this.hasHeartEffect = false,
    this.voiceUrl,
  });

  @override
  State<SeisanOpenScreen> createState() => _SeisanOpenScreenState();
}

class _SeisanOpenScreenState extends State<SeisanOpenScreen>
    with TickerProviderStateMixin {

  // 상태 머신
  SeisanOpenState _state = SeisanOpenState.preview;

  // 애니메이션 컨트롤러들
  late AnimationController _dimController;
  late AnimationController _portraitController;
  late AnimationController _copyBlockController;
  late AnimationController _envelopeController;
  late AnimationController _letterController;
  late AnimationController _portraitMotionController;

  // 애니메이션들
  late Animation<double> _dimAnimation;
  late Animation<double> _portraitAnimation;
  late Animation<double> _copyBlockAnimation;
  late Animation<double> _envelopeSlideAnimation;
  late Animation<double> _envelopeOpenAnimation;
  late Animation<double> _letterAnimation;
  late Animation<double> _portraitScaleAnimation;

  // 하트 이펙트
  final List<_FloatingHeart> _hearts = [];
  bool _heartsTriggered = false;

  // 애니메이션 시퀀스 취소를 위한 플래그
  bool _isDisposed = false;

  // MediaQuery 캐싱
  Size _screenSize = Size.zero;
  bool _reduceMotion = false;

  // 하트 ID 카운터 (중복 방지)
  static int _heartIdCounter = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery 캐싱
    _screenSize = MediaQuery.of(context).size;
    _reduceMotion = MediaQuery.of(context).disableAnimations;

    // 첫 번째 didChangeDependencies에서 애니메이션 시작
    if (_state == SeisanOpenState.preview &&
        !_dimController.isAnimating &&
        _dimController.value == 0) {
      _startAnimationSequence();
    }
  }

  void _initAnimations() {
    // 배경 dim (0ms ~ 500ms)
    _dimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _dimAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dimController, curve: Curves.easeOut),
    );

    // 아이돌 포트레이트 (0ms ~ 500ms, dim과 동시)
    _portraitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _portraitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _portraitController, curve: Curves.easeOut),
    );

    // 도착 문구 (500ms ~ 900ms)
    _copyBlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _copyBlockAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _copyBlockController, curve: Curves.easeOut),
    );

    // 봉투 슬라이드업 + 열림 (1200ms ~ 1800ms)
    _envelopeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _envelopeSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _envelopeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _envelopeOpenAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _envelopeController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // 편지 내용 (1800ms ~ 2200ms)
    _letterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _letterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _letterController, curve: Curves.easeOut),
    );

    // 아이돌 포트레이트 미세 모션 (지속)
    _portraitMotionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _portraitScaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _portraitMotionController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimationSequence() async {
    // 접근성: reduced motion 설정 시 애니메이션 건너뛰기
    if (_reduceMotion) {
      _skipToFinalState();
      return;
    }

    // t=0ms: 배경 dim + 포트레이트 시작
    if (_isDisposed || !mounted) return;
    _dimController.forward();
    _portraitController.forward();
    _portraitMotionController.repeat(reverse: true);

    // t=500ms: 도착 문구 표시
    await Future.delayed(const Duration(milliseconds: 500));
    if (_isDisposed || !mounted) return;
    _copyBlockController.forward();

    // t=900ms: 하트 이펙트 (조건부)
    await Future.delayed(const Duration(milliseconds: 400));
    if (_isDisposed || !mounted) return;
    if (widget.hasHeartEffect && !_heartsTriggered) {
      _triggerHeartEffect();
      _heartsTriggered = true;
    }

    // t=1200ms: 봉투 슬라이드업 + 열림
    await Future.delayed(const Duration(milliseconds: 300));
    if (_isDisposed || !mounted) return;
    setState(() => _state = SeisanOpenState.reveal);
    _envelopeController.forward();

    // t=1800ms: 편지 내용 표시
    await Future.delayed(const Duration(milliseconds: 600));
    if (_isDisposed || !mounted) return;
    _letterController.forward();

    // t=2200ms: 최종 상태
    await Future.delayed(const Duration(milliseconds: 400));
    if (_isDisposed || !mounted) return;
    setState(() => _state = SeisanOpenState.read);
  }

  /// 접근성을 위해 애니메이션 없이 최종 상태로 이동
  void _skipToFinalState() {
    _dimController.value = 1.0;
    _portraitController.value = 1.0;
    _copyBlockController.value = 1.0;
    _envelopeController.value = 1.0;
    _letterController.value = 1.0;
    _portraitScaleAnimation = AlwaysStoppedAnimation(1.0);

    if (mounted) {
      setState(() => _state = SeisanOpenState.read);
    }
  }

  void _triggerHeartEffect() {
    if (_isDisposed || !mounted) return;

    final random = Random();
    final heartCount = 2 + random.nextInt(4); // 2~5개

    for (int i = 0; i < heartCount; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (_isDisposed || !mounted) return;
        setState(() {
          _hearts.add(_FloatingHeart(
            id: _heartIdCounter++,
            startX: 0.2 + random.nextDouble() * 0.6, // 화면 20%~80% 위치
            delay: Duration(milliseconds: random.nextInt(200)),
          ));
        });
      });
    }

    // 3초 후 하트 제거
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (_isDisposed || !mounted) return;
      setState(() => _hearts.clear());
    });
  }

  @override
  void dispose() {
    _isDisposed = true;

    // 모든 애니메이션 컨트롤러 정리
    _portraitMotionController.stop(); // repeat 중인 컨트롤러는 먼저 stop

    _dimController.dispose();
    _portraitController.dispose();
    _copyBlockController.dispose();
    _envelopeController.dispose();
    _letterController.dispose();
    _portraitMotionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // A. DimmedBackdrop
          _buildDimmedBackdrop(),

          // B. IdolPortraitMotion
          _buildIdolPortrait(),

          // C. HeartEmitterLayer
          if (widget.hasHeartEffect) _buildHeartEmitterLayer(),

          // Arrival Copy Block (도착 문구)
          _buildArrivalCopyBlock(),

          // D. EnvelopeCard
          _buildEnvelopeCard(),

          // E. TopBarMinimal
          _buildTopBar(),

          // F. FooterPrivacyLabel
          _buildPrivacyFooter(),
        ],
      ),
    );
  }

  Widget _buildDimmedBackdrop() {
    return AnimatedBuilder(
      animation: _dimAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.85 * _dimAnimation.value),
        );
      },
    );
  }

  Widget _buildIdolPortrait() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: _screenSize.height * 0.45,
      child: AnimatedBuilder(
        animation: _portraitAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _portraitAnimation.value,
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _portraitScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _portraitScaleAnimation.value,
              child: child,
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 아이돌 이미지
              CachedNetworkImage(
                imageUrl: widget.idolImageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.darkSurface,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.darkSurface,
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              // 하단 그라데이션 오버레이
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 150,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeartEmitterLayer() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: _hearts
              .map((heart) => _FloatingHeartWidget(
                    heart: heart,
                    screenSize: _screenSize,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildArrivalCopyBlock() {
    return Positioned(
      top: _screenSize.height * 0.38,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _copyBlockAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _copyBlockAnimation.value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - _copyBlockAnimation.value)),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.idolName}님을 위한 정산이 도착했습니다',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnvelopeCard() {
    return Positioned(
      top: _screenSize.height * 0.42,
      left: 20,
      right: 20,
      bottom: 100,
      child: AnimatedBuilder(
        animation: _envelopeSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _envelopeSlideAnimation.value),
            child: Opacity(
              opacity: _state == SeisanOpenState.preview ? 0.0 : 1.0,
              child: child,
            ),
          );
        },
        child: AnimatedBuilder(
          animation: _letterAnimation,
          builder: (context, child) {
            return _EnvelopeCard(
              openProgress: _envelopeOpenAnimation.value,
              letterOpacity: _letterAnimation.value,
              responseText: widget.responseText,
              voiceUrl: widget.voiceUrl,
              idolName: widget.idolName,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 닫기 버튼
              IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => context.pop(),
              ),
              // 신고 메뉴
              PopupMenuButton<String>(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                color: AppColors.darkSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '신고하기',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  // TODO: 신고 기능
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                '이 정산은 나와 아이돌만 볼 수 있습니다.',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 봉투 카드 위젯
class _EnvelopeCard extends StatelessWidget {
  final double openProgress;
  final double letterOpacity;
  final String responseText;
  final String? voiceUrl;
  final String idolName;

  const _EnvelopeCard({
    required this.openProgress,
    required this.letterOpacity,
    required this.responseText,
    this.voiceUrl,
    required this.idolName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 봉투 상단 플랩 (열림 애니메이션)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(openProgress * -3.14159 / 2),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2A2A3E),
                      Color(0xFF1E1E2E),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.mail,
                    color: AppColors.primary.withOpacity(0.5),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // 편지지 내용
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
              child: Opacity(
                opacity: letterOpacity,
                child: _LetterContent(
                  responseText: responseText,
                  voiceUrl: voiceUrl,
                  idolName: idolName,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 편지 내용 위젯
class _LetterContent extends StatelessWidget {
  final String responseText;
  final String? voiceUrl;
  final String idolName;

  const _LetterContent({
    required this.responseText,
    this.voiceUrl,
    required this.idolName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5), // 오프화이트 편지지
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 발신자
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'From. $idolName',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 구분선
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 메시지 내용
            Text(
              responseText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.8,
                letterSpacing: 0.3,
              ),
            ),

            // 음성 메시지 버튼 (있는 경우)
            if (voiceUrl != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '음성 메시지 듣기',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// 떠다니는 하트 데이터
class _FloatingHeart {
  final int id;
  final double startX; // 0.0 ~ 1.0 화면 비율
  final Duration delay;

  _FloatingHeart({
    required this.id,
    required this.startX,
    required this.delay,
  });
}

/// 떠다니는 하트 위젯
class _FloatingHeartWidget extends StatefulWidget {
  final _FloatingHeart heart;
  final Size screenSize;

  const _FloatingHeartWidget({
    required this.heart,
    required this.screenSize,
  });

  @override
  State<_FloatingHeartWidget> createState() => _FloatingHeartWidgetState();
}

class _FloatingHeartWidgetState extends State<_FloatingHeartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _yAnimation = Tween<double>(begin: 0.85, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    Future.delayed(widget.heart.delay, () {
      if (!_isDisposed && mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.screenSize.width * widget.heart.startX - 15,
          top: widget.screenSize.height * _yAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: const Icon(
                Icons.favorite,
                color: AppColors.secondary,
                size: 30,
              ),
            ),
          ),
        );
      },
    );
  }
}
