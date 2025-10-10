import 'package:aipet_frontend/features/facility/data/facility_providers.dart';
import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/presentation/screens/facility_detail_screen.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FacilityListScreen extends ConsumerStatefulWidget {
  const FacilityListScreen({super.key});

  @override
  ConsumerState<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends ConsumerState<FacilityListScreen> {
  FacilityType? _selectedType;
  final List<Map<String, dynamic>> _categories = [
    {'name': '全体', 'type': null},
    {'name': '美容室', 'type': FacilityType.grooming},
    {'name': 'カフェ', 'type': FacilityType.cafe},
    {'name': 'ホテル', 'type': FacilityType.hotel},
    {'name': '遊び場', 'type': FacilityType.park},
    {'name': '教育センター', 'type': FacilityType.training},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB89B8A), // 갈색 그라데이션 시작
              Color(0xFFA08A7A), // 갈색 그라데이션 중간
              Color(0xFF967E6D), // 갈색 그라데이션 끝
            ],
          ),
        ),
        child: Column(
          children: [
            // 카테고리 필터
            _buildCategoryFilter(),
            // 메인 콘텐츠
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundGray,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: _buildFacilityList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.pointBrown,
      foregroundColor: AppColors.pointOffWhite,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        '施設予約',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'カテゴリ別施設',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointOffWhite,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final categoryName = category['name'] as String;
                final categoryType = category['type'] as FacilityType?;
                final isSelected = _selectedType == categoryType;

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = categoryType;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.pointOffWhite
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSpacing.lg),
                        border: Border.all(
                          color: AppColors.pointOffWhite,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        categoryName,
                        style: AppFonts.bodyMedium.copyWith(
                          color: isSelected
                              ? AppColors.pointBrown
                              : AppColors.pointOffWhite,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityList() {
    // Google Places API를 통한 시설 조회
    final facilitiesAsync = _selectedType != null
        ? ref.watch(facilitiesByTypeProvider(_selectedType!))
        : ref.watch(nearbyFacilitiesProvider);

    return facilitiesAsync.when(
      data: (result) {
        if (!result.isSuccess ||
            result.dataOrNull == null ||
            result.dataOrNull!.isEmpty) {
          return _buildEmptyState();
        }

        final facilities = result.dataOrNull!;
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: facilities.length,
          itemBuilder: (context, index) {
            final facility = facilities[index];
            return _buildFacilityCard(facility);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.pointRed,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'エラーが発生しました',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => ref.invalidate(
                _selectedType != null
                    ? facilitiesByTypeProvider(_selectedType!)
                    : nearbyFacilitiesProvider,
              ),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityCard(Facility facility) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        child: InkWell(
          onTap: () => _navigateToDetail(facility),
          borderRadius: BorderRadius.circular(AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          facility.type,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: Icon(
                        _getCategoryIcon(facility.type),
                        color: _getCategoryColor(facility.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility.name,
                            style: AppFonts.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _getTypeDisplayName(facility.type),
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (facility.isOpen)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(facility.type),
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                        child: Text(
                          '予約可能',
                          style: AppFonts.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        facility.address,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[600]),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      facility.rating.toStringAsFixed(1),
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '(${facility.reviewCount}件のレビュー)',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '詳細を見る',
                      style: AppFonts.bodyMedium.copyWith(
                        color: _getCategoryColor(facility.type),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: _getCategoryColor(facility.type),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/logos/aipet_black.png',
            width: 80,
            height: 80,
            color: AppColors.toneLightGray,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '該当カテゴリの施設がありません',
            style: AppFonts.bodyLarge.copyWith(color: AppColors.toneDarkGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '他のカテゴリを選択してください',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.toneDarkGray),
          ),
        ],
      ),
    );
  }

  /// 시설 타입에 따른 표시 이름 반환
  String _getTypeDisplayName(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
      case FacilityType.veterinary:
        return '動物病院';
      case FacilityType.grooming:
        return '美容室';
      case FacilityType.cafe:
        return 'カフェ';
      case FacilityType.hotel:
      case FacilityType.petFriendlyAccommodation:
        return 'ホテル';
      case FacilityType.park:
      case FacilityType.petPark:
      case FacilityType.dogRun:
        return '遊び場';
      case FacilityType.training:
        return '教育センター';
      case FacilityType.petShop:
      case FacilityType.petStore:
        return 'ペットショップ';
      default:
        return '施設';
    }
  }

  IconData _getCategoryIcon(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
      case FacilityType.veterinary:
        return Icons.local_hospital;
      case FacilityType.grooming:
        return Icons.content_cut;
      case FacilityType.cafe:
        return Icons.local_cafe;
      case FacilityType.hotel:
      case FacilityType.petFriendlyAccommodation:
        return Icons.hotel;
      case FacilityType.park:
      case FacilityType.petPark:
      case FacilityType.dogRun:
        return Icons.park;
      case FacilityType.training:
        return Icons.school;
      case FacilityType.petShop:
      case FacilityType.petStore:
        return Icons.store;
      default:
        return Icons.place;
    }
  }

  Color _getCategoryColor(FacilityType type) {
    switch (type) {
      case FacilityType.grooming:
        return Colors.pink;
      case FacilityType.cafe:
        return Colors.brown;
      case FacilityType.hotel:
      case FacilityType.petFriendlyAccommodation:
        return Colors.blue;
      case FacilityType.park:
      case FacilityType.petPark:
      case FacilityType.dogRun:
        return Colors.green;
      case FacilityType.training:
        return Colors.purple;
      case FacilityType.hospital:
      case FacilityType.veterinary:
        return AppColors.pointRed;
      case FacilityType.petShop:
      case FacilityType.petStore:
        return AppColors.pointBlue;
      default:
        return AppColors.pointGreen;
    }
  }

  void _navigateToDetail(Facility facility) {
    // Facility entity를 Map으로 변환하여 기존 화면에 전달
    // TODO: FacilityDetailScreen을 Facility entity를 받도록 수정
    final facilityMap = {
      'id': facility.id,
      'name': facility.name,
      'type': _getTypeDisplayName(facility.type),
      'address': facility.address,
      'phone': facility.phone ?? '',
      'rating': facility.rating,
      'reviewCount': facility.reviewCount,
      'description': facility.description ?? '',
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FacilityDetailScreen(facility: facilityMap),
      ),
    );
  }
}
