/// 스토리 미디어 타입
enum StoryMediaType {
  image,
  video,
}

/// 스토리 공개 범위
enum StoryVisibility {
  public,
  subscribers,
}

/// 개별 스토리 모델
class Story {
  final String id;
  final String artistId;
  final String artistName;
  final String artistImage;
  final StoryMediaType mediaType;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? textOverlay;
  final StoryVisibility visibility;
  final bool isViewed;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Story({
    required this.id,
    required this.artistId,
    required this.artistName,
    required this.artistImage,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.textOverlay,
    this.visibility = StoryVisibility.public,
    this.isViewed = false,
    required this.createdAt,
    required this.expiresAt,
  });

  /// 남은 시간 (시간 단위)
  int get remainingHours {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);
    return diff.inHours.clamp(0, 24);
  }

  /// 만료 여부
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Story copyWith({
    String? id,
    String? artistId,
    String? artistName,
    String? artistImage,
    StoryMediaType? mediaType,
    String? mediaUrl,
    String? thumbnailUrl,
    String? textOverlay,
    StoryVisibility? visibility,
    bool? isViewed,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Story(
      id: id ?? this.id,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      artistImage: artistImage ?? this.artistImage,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      textOverlay: textOverlay ?? this.textOverlay,
      visibility: visibility ?? this.visibility,
      isViewed: isViewed ?? this.isViewed,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// 아티스트별 스토리 그룹
class ArtistStoryGroup {
  final String artistId;
  final String artistName;
  final String artistImage;
  final List<Story> stories;
  final bool hasUnviewedStory;
  final DateTime latestStoryAt;

  const ArtistStoryGroup({
    required this.artistId,
    required this.artistName,
    required this.artistImage,
    required this.stories,
    required this.hasUnviewedStory,
    required this.latestStoryAt,
  });

  /// 스토리 개수
  int get storyCount => stories.length;

  /// 본 스토리 개수
  int get viewedCount => stories.where((s) => s.isViewed).length;

  /// 현재 진행률 (0.0 ~ 1.0)
  double get progress {
    if (stories.isEmpty) return 0;
    return viewedCount / storyCount;
  }

  ArtistStoryGroup copyWith({
    String? artistId,
    String? artistName,
    String? artistImage,
    List<Story>? stories,
    bool? hasUnviewedStory,
    DateTime? latestStoryAt,
  }) {
    return ArtistStoryGroup(
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      artistImage: artistImage ?? this.artistImage,
      stories: stories ?? this.stories,
      hasUnviewedStory: hasUnviewedStory ?? this.hasUnviewedStory,
      latestStoryAt: latestStoryAt ?? this.latestStoryAt,
    );
  }
}
