import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/demo_data_service.dart';
import '../models/artist_model.dart';

/// 아티스트 목록 상태
class ArtistsState {
  final List<Artist> artists;
  final bool isLoading;
  final String? selectedCategory;
  final String searchQuery;

  const ArtistsState({
    this.artists = const [],
    this.isLoading = false,
    this.selectedCategory,
    this.searchQuery = '',
  });

  ArtistsState copyWith({
    List<Artist>? artists,
    bool? isLoading,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return ArtistsState(
      artists: artists ?? this.artists,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Artist> get filteredArtists {
    var result = artists;

    // 카테고리 필터
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      result = result.where((a) => a.category == selectedCategory).toList();
    }

    // 검색 필터
    if (searchQuery.isNotEmpty) {
      result = result.where((a) =>
          a.stageName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (a.bio?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    return result;
  }
}

/// 아티스트 목록 Notifier
class ArtistsNotifier extends StateNotifier<ArtistsState> {
  ArtistsNotifier() : super(const ArtistsState());

  /// 아티스트 목록 로드
  Future<void> loadArtists() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      artists: DemoDataService.demoArtists,
      isLoading: false,
    );
  }

  /// 카테고리 필터 설정
  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// 검색어 설정
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// 구독 토글 (데모)
  void toggleSubscription(String artistId) {
    final updatedArtists = state.artists.map((artist) {
      if (artist.id == artistId) {
        return Artist(
          id: artist.id,
          userId: artist.userId,
          stageName: artist.stageName,
          bio: artist.bio,
          profileImage: artist.profileImage,
          coverImage: artist.coverImage,
          category: artist.category,
          monthlyPrice: artist.monthlyPrice,
          subscriberCount: artist.isSubscribed
              ? artist.subscriberCount - 1
              : artist.subscriberCount + 1,
          twitterUrl: artist.twitterUrl,
          instagramUrl: artist.instagramUrl,
          youtubeUrl: artist.youtubeUrl,
          tiktokUrl: artist.tiktokUrl,
          isSubscribed: !artist.isSubscribed,
          createdAt: artist.createdAt,
        );
      }
      return artist;
    }).toList();

    state = state.copyWith(artists: updatedArtists);
  }
}

/// Provider
final artistsProvider = StateNotifierProvider<ArtistsNotifier, ArtistsState>((ref) {
  return ArtistsNotifier();
});

/// 특정 아티스트 Provider
final artistByIdProvider = Provider.family<Artist?, String>((ref, id) {
  final artists = ref.watch(artistsProvider).artists;
  try {
    return artists.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
});

/// 구독 중인 아티스트 Provider
final subscribedArtistsProvider = Provider<List<Artist>>((ref) {
  return ref.watch(artistsProvider).artists.where((a) => a.isSubscribed).toList();
});

/// 카테고리 목록 Provider
final categoriesProvider = Provider<List<String>>((ref) {
  return ['IDOL', 'MAID', 'COSPLAYER', 'STREAMER', 'OTHER'];
});
