import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/layout_constants.dart';
import '../../../core/utils/formatters.dart';
import '../models/story_model.dart';
import '../providers/story_provider.dart';

/// 스토리 뷰어 화면
class StoryViewerScreen extends ConsumerStatefulWidget {
  final String artistId;

  const StoryViewerScreen({
    super.key,
    required this.artistId,
  });

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late PageController _artistPageController;

  int _currentStoryIndex = 0;
  String _currentArtistId = '';
  bool _isPaused = false;

  static const _storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentArtistId = widget.artistId;

    // 프로그레스 애니메이션 컨트롤러
    _progressController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    );

    // 아티스트 페이지 컨트롤러
    final initialArtistIndex = _getArtistIndex(_currentArtistId);
    _artistPageController = PageController(initialPage: initialArtistIndex);

    // 상태바 숨김
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // 첫 스토리 시작
    _startStory();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _artistPageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  int _getArtistIndex(String artistId) {
    final groups = ref.read(storiesProvider).storyGroups;
    return groups.indexWhere((g) => g.artistId == artistId).clamp(0, groups.length - 1);
  }

  ArtistStoryGroup? get _currentGroup {
    final groups = ref.read(storiesProvider).storyGroups;
    return groups.where((g) => g.artistId == _currentArtistId).firstOrNull;
  }

  Story? get _currentStory {
    final group = _currentGroup;
    if (group == null || _currentStoryIndex >= group.stories.length) return null;
    return group.stories[_currentStoryIndex];
  }

  void _startStory() {
    _progressController.reset();
    _progressController.forward();

    // 스토리 조회 처리
    final story = _currentStory;
    if (story != null) {
      ref.read(storiesProvider.notifier).markAsViewed(story.id);
    }

    // 자동 진행
    _progressController.addStatusListener(_onProgressComplete);
  }

  void _onProgressComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isPaused) {
      _goToNextStory();
    }
  }

  void _goToNextStory() {
    final group = _currentGroup;
    if (group == null) return;

    if (_currentStoryIndex < group.stories.length - 1) {
      // 다음 스토리로
      setState(() {
        _currentStoryIndex++;
      });
      _startStory();
    } else {
      // 다음 아티스트로
      _goToNextArtist();
    }
  }

  void _goToPreviousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _startStory();
    } else {
      // 이전 아티스트로
      _goToPreviousArtist();
    }
  }

  void _goToNextArtist() {
    final groups = ref.read(storiesProvider).storyGroups;
    final currentIndex = groups.indexWhere((g) => g.artistId == _currentArtistId);

    if (currentIndex < groups.length - 1) {
      _artistPageController.nextPage(
        duration: LayoutConstants.animationNormal,
        curve: Curves.easeInOut,
      );
    } else {
      // 마지막 아티스트면 닫기
      context.pop();
    }
  }

  void _goToPreviousArtist() {
    final groups = ref.read(storiesProvider).storyGroups;
    final currentIndex = groups.indexWhere((g) => g.artistId == _currentArtistId);

    if (currentIndex > 0) {
      _artistPageController.previousPage(
        duration: LayoutConstants.animationNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  void _onArtistPageChanged(int index) {
    final groups = ref.read(storiesProvider).storyGroups;
    if (index >= 0 && index < groups.length) {
      setState(() {
        _currentArtistId = groups[index].artistId;
        _currentStoryIndex = 0;
      });
      _startStory();
    }
  }

  void _onTapLeft() {
    _goToPreviousStory();
  }

  void _onTapRight() {
    _goToNextStory();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isPaused = true;
    });
    _progressController.stop();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _isPaused = false;
    });
    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storiesProvider);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _artistPageController,
        onPageChanged: _onArtistPageChanged,
        itemCount: state.storyGroups.length,
        itemBuilder: (context, artistIndex) {
          final group = state.storyGroups[artistIndex];
          final isCurrentArtist = group.artistId == _currentArtistId;
          final storyIndex = isCurrentArtist ? _currentStoryIndex : 0;
          final story = group.stories.isNotEmpty && storyIndex < group.stories.length
              ? group.stories[storyIndex]
              : null;

          if (story == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return GestureDetector(
            onTapUp: (details) {
              if (!isCurrentArtist) return;

              final tapX = details.localPosition.dx;
              if (tapX < screenSize.width / 3) {
                _onTapLeft();
              } else {
                _onTapRight();
              }
            },
            onLongPressStart: isCurrentArtist ? _onLongPressStart : null,
            onLongPressEnd: isCurrentArtist ? _onLongPressEnd : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 스토리 이미지
                CachedNetworkImage(
                  imageUrl: story.mediaUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(Icons.error, color: AppColors.error, size: 48),
                    ),
                  ),
                ),

                // 그라데이션 오버레이 (상단)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 150,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 상단 UI (프로그레스 바 + 아티스트 정보)
                if (isCurrentArtist)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 프로그레스 바
                        _ProgressBars(
                          totalCount: group.stories.length,
                          currentIndex: storyIndex,
                          animation: _progressController,
                        ),
                        const SizedBox(height: 12),
                        // 아티스트 정보
                        _ArtistHeader(
                          name: group.artistName,
                          imageUrl: group.artistImage,
                          timeAgo: story.createdAt.timeAgo(),
                          onClose: () => context.pop(),
                        ),
                      ],
                    ),
                  ),

                // 텍스트 오버레이
                if (story.textOverlay != null)
                  Positioned(
                    bottom: 100,
                    left: 20,
                    right: 20,
                    child: Text(
                      story.textOverlay!,
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 하단 리액션 바
                if (isCurrentArtist)
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    left: 16,
                    right: 16,
                    child: _ReactionBar(
                      onReact: (emoji) {
                        ref.read(storiesProvider.notifier).reactToStory(story.id, emoji);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$emoji 반응을 보냈어요!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 프로그레스 바
class _ProgressBars extends StatelessWidget {
  final int totalCount;
  final int currentIndex;
  final AnimationController animation;

  const _ProgressBars({
    required this.totalCount,
    required this.currentIndex,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalCount, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalCount - 1 ? 4 : 0),
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withOpacity(0.3),
            ),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                double progress;
                if (index < currentIndex) {
                  progress = 1.0;
                } else if (index == currentIndex) {
                  progress = animation.value;
                } else {
                  progress = 0.0;
                }

                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

/// 아티스트 헤더
class _ArtistHeader extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String timeAgo;
  final VoidCallback onClose;

  const _ArtistHeader({
    required this.name,
    required this.imageUrl,
    required this.timeAgo,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 아티스트 프로필
        ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 36,
              height: 36,
              color: AppColors.shimmerBase,
            ),
            errorWidget: (_, __, ___) => Container(
              width: 36,
              height: 36,
              color: AppColors.shimmerBase,
              child: const Icon(Icons.person, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // 이름 + 시간
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                ),
              ),
              Text(
                timeAgo,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        // 닫기 버튼
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: onClose,
        ),
      ],
    );
  }
}

/// 리액션 바
class _ReactionBar extends StatelessWidget {
  final Function(String emoji) onReact;

  const _ReactionBar({required this.onReact});

  static const _emojis = ['❤️', '🔥', '😍', '👏', '😢'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _emojis.map((emoji) {
          return GestureDetector(
            onTap: () => onReact(emoji),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          );
        }).toList(),
      ),
    );
  }
}
