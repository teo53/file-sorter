import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/animations.dart';
import '../../../router/app_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고 및 타이틀 (애니메이션 적용)
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _logoRotateAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              FadeSlideTransition(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'PIPO',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 36,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  '좋아하는 아티스트와 더 가까이',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // 소셜 로그인 버튼들 (Staggered 애니메이션)
              StaggeredListItem(
                index: 0,
                baseDelay: const Duration(milliseconds: 500),
                child: _SocialLoginButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          await ref.read(authProvider.notifier).signInWithKakao();
                          if (context.mounted) {
                            context.go(AppRoutes.home);
                          }
                        },
                  icon: Icons.chat_bubble,
                  label: '카카오로 시작하기',
                  backgroundColor: const Color(0xFFFEE500),
                  textColor: const Color(0xFF191919),
                ),
              ),
              const SizedBox(height: 12),
              StaggeredListItem(
                index: 1,
                baseDelay: const Duration(milliseconds: 500),
                child: _SocialLoginButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          await ref.read(authProvider.notifier).signInWithGoogle();
                          if (context.mounted) {
                            context.go(AppRoutes.home);
                          }
                        },
                  icon: Icons.g_mobiledata,
                  label: 'Google로 시작하기',
                  backgroundColor: Colors.white,
                  textColor: AppColors.textPrimary,
                  borderColor: AppColors.divider,
                ),
              ),
              const SizedBox(height: 12),
              StaggeredListItem(
                index: 2,
                baseDelay: const Duration(milliseconds: 500),
                child: _SocialLoginButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          await ref.read(authProvider.notifier).signInWithApple();
                          if (context.mounted) {
                            context.go(AppRoutes.home);
                          }
                        },
                  icon: Icons.apple,
                  label: 'Apple로 시작하기',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // 로딩 표시
              if (authState.isLoading)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),

              const Spacer(),

              // 약관
              FadeSlideTransition(
                delay: const Duration(milliseconds: 800),
                beginOffset: const Offset(0, 0.2),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    '시작하기를 누르면 서비스 이용약관 및\n개인정보 처리방침에 동의하게 됩니다.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _SocialLoginButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: [
            BoxShadow(
              color: backgroundColor == Colors.white
                  ? Colors.black.withOpacity(0.05)
                  : backgroundColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: textColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.button.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
