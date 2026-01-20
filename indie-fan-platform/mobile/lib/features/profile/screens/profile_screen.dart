import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/animations.dart';
import '../../../router/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/subscriptions_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(subscriptionsProvider.notifier).loadSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final subscriptions = ref.watch(activeSubscriptionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 프로필 헤더
              FadeSlideTransition(
                beginOffset: const Offset(0, -0.1),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // 프로필 이미지
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: user?.profileImage ?? '',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 100,
                                    height: 100,
                                    color: AppColors.shimmerBase,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 100,
                                    height: 100,
                                    color: AppColors.surface,
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: ScaleOnTap(
                                onTap: () {
                                  // TODO: 프로필 이미지 변경
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 닉네임
                      Text(
                        user?.nickname ?? '팬',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 통계
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatCard(
                            icon: Icons.favorite,
                            value: '${subscriptions.length}',
                            label: '구독 중',
                            color: AppColors.secondary,
                            delay: const Duration(milliseconds: 100),
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            icon: Icons.calendar_today,
                            value: _getMemberDays(user?.createdAt),
                            label: '함께한 날',
                            color: AppColors.primary,
                            delay: const Duration(milliseconds: 200),
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            icon: Icons.chat_bubble,
                            value: '127',
                            label: '받은 메시지',
                            color: AppColors.accent,
                            delay: const Duration(milliseconds: 300),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 메뉴 섹션
              _buildMenuSection(),

              const SizedBox(height: 24),

              // 앱 정보
              FadeSlideTransition(
                delay: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        'PIPO',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      _MenuItem(
        icon: Icons.person_outline,
        title: '프로필 수정',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.credit_card_outlined,
        title: '결제 관리',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        title: '알림 설정',
        onTap: () {},
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'ON',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      _MenuItem(
        icon: Icons.help_outline,
        title: '고객센터',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.description_outlined,
        title: '이용약관',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.shield_outlined,
        title: '개인정보 처리방침',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.logout,
        title: '로그아웃',
        titleColor: AppColors.error,
        onTap: () => _showLogoutDialog(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
        child: Column(
          children: menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == menuItems.length - 1;

            return StaggeredListItem(
              index: index,
              baseDelay: const Duration(milliseconds: 200),
              itemDelay: const Duration(milliseconds: 40),
              child: Column(
                children: [
                  ScaleOnTap(
                    onTap: item.onTap,
                    scaleFactor: 0.98,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (item.titleColor ?? AppColors.textPrimary)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.icon,
                              size: 20,
                              color: item.titleColor ?? AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: item.titleColor ?? AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (item.trailing != null)
                            item.trailing!
                          else
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.textTertiary,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        height: 1,
                        color: AppColors.divider,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getMemberDays(DateTime? createdAt) {
    if (createdAt == null) return '0';
    final days = DateTime.now().difference(createdAt).inDays;
    return '$days';
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Duration delay;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideTransition(
      delay: delay,
      beginOffset: const Offset(0, 0.2),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  value.toString(),
                  style: AppTextStyles.h3.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.titleColor,
    required this.onTap,
    this.trailing,
  });
}
