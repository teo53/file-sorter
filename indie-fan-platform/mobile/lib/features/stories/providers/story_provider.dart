import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_model.dart';

/// 스토리 상태
class StoriesState {
  final List<ArtistStoryGroup> storyGroups;
  final bool isLoading;
  final String? error;

  const StoriesState({
    this.storyGroups = const [],
    this.isLoading = false,
    this.error,
  });

  StoriesState copyWith({
    List<ArtistStoryGroup>? storyGroups,
    bool? isLoading,
    String? error,
  }) {
    return StoriesState(
      storyGroups: storyGroups ?? this.storyGroups,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 스토리 Notifier
class StoriesNotifier extends StateNotifier<StoriesState> {
  StoriesNotifier() : super(const StoriesState());

  /// 스토리 피드 로드
  Future<void> loadStoryFeed() async {
    state = state.copyWith(isLoading: true);

    // 데모 데이터 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      storyGroups: _demoStoryGroups,
      isLoading: false,
    );
  }

  /// 스토리 조회 처리
  Future<void> markAsViewed(String storyId) async {
    final updatedGroups = state.storyGroups.map((group) {
      final updatedStories = group.stories.map((story) {
        if (story.id == storyId && !story.isViewed) {
          return story.copyWith(isViewed: true);
        }
        return story;
      }).toList();

      final hasUnviewed = updatedStories.any((s) => !s.isViewed);

      return group.copyWith(
        stories: updatedStories,
        hasUnviewedStory: hasUnviewed,
      );
    }).toList();

    state = state.copyWith(storyGroups: updatedGroups);
  }

  /// 스토리 리액션
  Future<void> reactToStory(String storyId, String emoji) async {
    // TODO: API 호출
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// 특정 아티스트의 스토리 그룹 조회
  ArtistStoryGroup? getArtistStoryGroup(String artistId) {
    return state.storyGroups.where((g) => g.artistId == artistId).firstOrNull;
  }

  /// 다음 아티스트 스토리 그룹 조회
  ArtistStoryGroup? getNextArtistGroup(String currentArtistId) {
    final index = state.storyGroups.indexWhere((g) => g.artistId == currentArtistId);
    if (index == -1 || index >= state.storyGroups.length - 1) return null;
    return state.storyGroups[index + 1];
  }

  /// 이전 아티스트 스토리 그룹 조회
  ArtistStoryGroup? getPreviousArtistGroup(String currentArtistId) {
    final index = state.storyGroups.indexWhere((g) => g.artistId == currentArtistId);
    if (index <= 0) return null;
    return state.storyGroups[index - 1];
  }
}

/// Provider 정의
final storiesProvider = StateNotifierProvider<StoriesNotifier, StoriesState>(
  (ref) => StoriesNotifier(),
);

/// 안 본 스토리가 있는 아티스트만 필터링
final unviewedStoriesProvider = Provider<List<ArtistStoryGroup>>((ref) {
  final state = ref.watch(storiesProvider);
  return state.storyGroups.where((g) => g.hasUnviewedStory).toList();
});

/// 특정 아티스트의 스토리 그룹
final artistStoryGroupProvider = Provider.family<ArtistStoryGroup?, String>((ref, artistId) {
  final state = ref.watch(storiesProvider);
  return state.storyGroups.where((g) => g.artistId == artistId).firstOrNull;
});

// ============================================
// 데모 데이터
// ============================================

final _demoStoryGroups = [
  ArtistStoryGroup(
    artistId: 'artist_1',
    artistName: '유나',
    artistImage: 'https://picsum.photos/seed/yuna/200/200',
    hasUnviewedStory: true,
    latestStoryAt: DateTime.now().subtract(const Duration(hours: 1)),
    stories: [
      Story(
        id: 'story_1_1',
        artistId: 'artist_1',
        artistName: '유나',
        artistImage: 'https://picsum.photos/seed/yuna/200/200',
        mediaType: StoryMediaType.image,
        mediaUrl: 'https://picsum.photos/seed/story1/1080/1920',
        textOverlay: '오늘의 무대 준비 완료! 🎤',
        isViewed: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(hours: 22)),
      ),
      Story(
        id: 'story_1_2',
        artistId: 'artist_1',
        artistName: '유나',
        artistImage: 'https://picsum.photos/seed/yuna/200/200',
        mediaType: StoryMediaType.image,
        mediaUrl: 'https://picsum.photos/seed/story2/1080/1920',
        textOverlay: '리허설 끝! 💕',
        isViewed: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        expiresAt: DateTime.now().add(const Duration(hours: 23)),
      ),
    ],
  ),
  ArtistStoryGroup(
    artistId: 'artist_2',
    artistName: '미나',
    artistImage: 'https://picsum.photos/seed/mina/200/200',
    hasUnviewedStory: true,
    latestStoryAt: DateTime.now().subtract(const Duration(hours: 3)),
    stories: [
      Story(
        id: 'story_2_1',
        artistId: 'artist_2',
        artistName: '미나',
        artistImage: 'https://picsum.photos/seed/mina/200/200',
        mediaType: StoryMediaType.image,
        mediaUrl: 'https://picsum.photos/seed/story3/1080/1920',
        textOverlay: '새 앨범 곧 나와요~',
        isViewed: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        expiresAt: DateTime.now().add(const Duration(hours: 21)),
      ),
    ],
  ),
  ArtistStoryGroup(
    artistId: 'artist_3',
    artistName: '사쿠라',
    artistImage: 'https://picsum.photos/seed/sakura/200/200',
    hasUnviewedStory: false,
    latestStoryAt: DateTime.now().subtract(const Duration(hours: 5)),
    stories: [
      Story(
        id: 'story_3_1',
        artistId: 'artist_3',
        artistName: '사쿠라',
        artistImage: 'https://picsum.photos/seed/sakura/200/200',
        mediaType: StoryMediaType.image,
        mediaUrl: 'https://picsum.photos/seed/story4/1080/1920',
        textOverlay: '좋은 아침이에요 ☀️',
        isViewed: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        expiresAt: DateTime.now().add(const Duration(hours: 19)),
      ),
      Story(
        id: 'story_3_2',
        artistId: 'artist_3',
        artistName: '사쿠라',
        artistImage: 'https://picsum.photos/seed/sakura/200/200',
        mediaType: StoryMediaType.image,
        mediaUrl: 'https://picsum.photos/seed/story5/1080/1920',
        isViewed: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        expiresAt: DateTime.now().add(const Duration(hours: 20)),
      ),
    ],
  ),
  ArtistStoryGroup(
    artistId: 'artist_4',
    artistName: '하루',
    artistImage: 'https://picsum.photos/seed/haru/200/200',
    hasUnviewedStory: true,
    latestStoryAt: DateTime.now().subtract(const Duration(hours: 6)),
    stories: [
      Story(
        id: 'story_4_1',
        artistId: 'artist_4',
        artistName: '하루',
        artistImage: 'https://picsum.photos/seed/haru/200/200',
        mediaType: StoryMediaType.image,
        mediaUrl: 'https://picsum.photos/seed/story6/1080/1920',
        textOverlay: '메이드카페 출근! 🎀',
        isViewed: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        expiresAt: DateTime.now().add(const Duration(hours: 18)),
      ),
    ],
  ),
];
