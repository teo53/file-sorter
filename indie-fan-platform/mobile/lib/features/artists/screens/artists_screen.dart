import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/artists_provider.dart';
import '../widgets/artist_card.dart';
import '../widgets/category_chip.dart';

class ArtistsScreen extends ConsumerStatefulWidget {
  const ArtistsScreen({super.key});

  @override
  ConsumerState<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends ConsumerState<ArtistsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(artistsProvider.notifier).loadArtists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(artistsProvider);
    final categories = ref.watch(categoriesProvider);
    final filteredArtists = state.filteredArtists;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '아티스트 탐색',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '좋아하는 아티스트를 찾아보세요',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 검색바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(artistsProvider.notifier).setSearchQuery(value);
                },
                decoration: InputDecoration(
                  hintText: '아티스트 검색',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textTertiary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(artistsProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // 카테고리 필터
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  CategoryChip(
                    label: '전체',
                    isSelected: _selectedCategory == null,
                    onTap: () {
                      setState(() => _selectedCategory = null);
                      ref.read(artistsProvider.notifier).setCategory(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryChip(
                          label: ArtistCategory.toDisplayName(category),
                          category: category,
                          isSelected: _selectedCategory == category,
                          onTap: () {
                            setState(() => _selectedCategory = category);
                            ref.read(artistsProvider.notifier).setCategory(category);
                          },
                        ),
                      )),
                ],
              ),
            ),

            // 아티스트 리스트
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    )
                  : filteredArtists.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '검색 결과가 없습니다',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredArtists.length,
                          itemBuilder: (context, index) {
                            return ArtistCard(
                              artist: filteredArtists[index],
                              onTap: () {
                                context.push('/artists/${filteredArtists[index].id}');
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
