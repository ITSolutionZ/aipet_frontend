import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../../data/providers/pet_activities_providers.dart';
import '../../domain/entities/trick_entity.dart';
import '../widgets/trick_card.dart';

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
      filtered = filtered.where((trick) => trick.difficulty == _selectedCategory).toList();
    }

    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((trick) =>
          trick.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (trick.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    return filtered;
  }

  Map<String, List<TrickEntity>> _groupTricksByCategory(List<TrickEntity> tricks) {
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
      appBar: AppBar(
        backgroundColor: AppColors.pointOffWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.pointDark,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'All Tricks',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
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
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Error loading tricks: $error',
                style: AppFonts.bodyMedium.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.refresh(allTricksProvider),
                child: const Text('Retry'),
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
        _buildSearchAndFilter(),
        
        // 트릭 목록
        Expanded(
          child: _buildTricksList(groupedTricks),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // 검색 바
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tricks...',
              prefixIcon: const Icon(Icons.search, color: AppColors.pointDark),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.pointDark),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // 카테고리 필터
          _buildCategoryFilter(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    const categories = [
      {'key': 'all', 'label': 'All'},
      {'key': 'easy', 'label': 'Easy'},
      {'key': 'medium', 'label': 'Medium'},
      {'key': 'hard', 'label': 'Hard'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category['key'];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(
                category['label']!,
                style: AppFonts.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.pointDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.pointBrown,
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category['key']!;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                side: BorderSide(
                  color: isSelected ? AppColors.pointBrown : AppColors.pointDark.withValues(alpha: 0.2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTricksList(Map<String, List<TrickEntity>> groupedTricks) {
    if (groupedTricks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.pointDark.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No tricks found',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting your search or filter',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: groupedTricks.length,
      itemBuilder: (context, index) {
        final category = groupedTricks.keys.elementAt(index);
        final tricks = groupedTricks[category]!;
        
        return _buildCategorySection(category, tricks);
      },
    );
  }

  Widget _buildCategorySection(String category, List<TrickEntity> tricks) {
    String getCategoryLabel(String category) {
      switch (category) {
        case 'easy':
          return 'Easy Tricks';
        case 'medium':
          return 'Medium Tricks';
        case 'hard':
          return 'Hard Tricks';
        default:
          return 'Other Tricks';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 헤더
        if (_selectedCategory == 'all') ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  getCategoryLabel(category),
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${tricks.length} tricks',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // 트릭 카드들
        ...tricks.map((trick) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: TrickCard(
            trick: trick,
            onTap: () => _showTrickDetail(trick),
            onStartLearning: () => _startLearning(trick),
          ),
        )),
        
        if (_selectedCategory == 'all' && tricks.isNotEmpty)
          const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  void _showTrickDetail(TrickEntity trick) {
    showDialog(
      context: context,
      builder: (context) => _TrickDetailDialog(trick: trick),
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

/// 트릭 상세 다이얼로그
class _TrickDetailDialog extends StatelessWidget {
  final TrickEntity trick;

  const _TrickDetailDialog({required this.trick});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    trick.name,
                    style: AppFonts.titleLarge.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.pointDark),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // 트릭 이미지
            Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  image: DecorationImage(
                    image: AssetImage(trick.imagePath),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                ),
              ),
            
            const SizedBox(height: AppSpacing.md),
            
            // 난이도 태그
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getDifficultyColor(trick.difficulty).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Text(
                trick.difficulty?.toUpperCase() ?? 'UNKNOWN',
                style: AppFonts.bodySmall.copyWith(
                  color: _getDifficultyColor(trick.difficulty),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // 설명
            if (trick.description?.isNotEmpty == true) ...[
              Text(
                'Description',
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                trick.description!,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointDark.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            
            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.pointDark),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/learn-trick/${trick.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                    ),
                    child: Text(
                      'Start Learning',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return AppColors.pointGreen;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return AppColors.pointDark;
    }
  }
}