import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../../data/providers/pet_activities_providers.dart';
import '../../domain/entities/trick_entity.dart';
import '../widgets/trick_category_section.dart';
import '../widgets/trick_detail_dialog.dart';
import '../widgets/tricks_empty_state.dart';
import '../widgets/tricks_search_and_filter.dart';

/// 모든 트릭 보기 화면
///
/// 사용 가능한 모든 트릭을 카테고리별로 보여주는 화면입니다.
class AllTricksScreen extends ConsumerStatefulWidget {
  const AllTricksScreen({super.key});

  @override
  ConsumerState<AllTricksScreen> createState() => _AllTricksScreenState();
}

class _AllTricksScreenState extends ConsumerState<AllTricksScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TrickEntity> _filterTricks(List<TrickEntity> tricks) {
    var filtered = tricks;

    // 카테고리 필터링
    if (_selectedCategory != 'all') {
      filtered = filtered
          .where((trick) => trick.difficulty == _selectedCategory)
          .toList();
    }

    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (trick) =>
                trick.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (trick.description?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    return filtered;
  }

  Map<String, List<TrickEntity>> _groupTricksByCategory(
    List<TrickEntity> tricks,
  ) {
    final Map<String, List<TrickEntity>> grouped = {};

    for (final trick in tricks) {
      final category = trick.difficulty ?? 'unknown';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(trick);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final allTricksState = ref.watch(allTricksProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientBackAppBar(title: 'トリック'),
      body: allTricksState.when(
        data: (tricks) => _buildContent(tricks),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pointBrown),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: AppSpacing.md),
              Text(
                'トリックの読み込みに失敗しました: $error',
                style: AppFonts.bodyMedium.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.refresh(allTricksProvider),
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<TrickEntity> allTricks) {
    final filteredTricks = _filterTricks(allTricks);
    final groupedTricks = _groupTricksByCategory(filteredTricks);

    return Column(
      children: [
        // 검색 및 필터 섹션
        TricksSearchAndFilter(
          searchController: _searchController,
          searchQuery: _searchQuery,
          selectedCategory: _selectedCategory,
          onSearchChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onCategoryChanged: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),

        // 트릭 목록
        Expanded(child: _buildTricksList(groupedTricks)),
      ],
    );
  }

  Widget _buildTricksList(Map<String, List<TrickEntity>> groupedTricks) {
    if (groupedTricks.isEmpty) {
      return const TricksEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: groupedTricks.length,
      itemBuilder: (context, index) {
        final category = groupedTricks.keys.elementAt(index);
        final tricks = groupedTricks[category]!;

        return TrickCategorySection(
          category: category,
          tricks: tricks,
          selectedCategory: _selectedCategory,
          onShowTrickDetail: _showTrickDetail,
          onStartLearning: _startLearning,
        );
      },
    );
  }

  void _showTrickDetail(TrickEntity trick) {
    showDialog(
      context: context,
      builder: (context) => TrickDetailDialog(trick: trick),
    );
  }

  void _startLearning(TrickEntity trick) {
    // TODO: 트릭 학습 시작 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${trick.name} 학습을 시작합니다!'),
        backgroundColor: AppColors.pointGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 트릭 상세 화면이나 학습 화면으로 이동
    context.push('/learn-trick/${trick.id}');
  }
}
