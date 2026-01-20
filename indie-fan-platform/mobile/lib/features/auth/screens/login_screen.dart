import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../router/app_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고 및 타이틀
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'IndieFan',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '좋아하는 아티스트와 더 가까이',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(flex: 2),

              // 소셜 로그인 버튼들
              _SocialLoginButton(
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
              const SizedBox(height: 12),
              _SocialLoginButton(
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
              const SizedBox(height: 12),
              _SocialLoginButton(
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

              const SizedBox(height: 24),

              // 로딩 표시
              if (authState.isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),

              const Spacer(),

              // 약관
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  '시작하기를 누르면 서비스 이용약관 및\n개인정보 처리방침에 동의하게 됩니다.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
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
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
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
