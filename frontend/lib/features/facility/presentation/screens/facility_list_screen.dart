import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/facility_providers.dart';
import '../../domain/entities/facility_entity.dart';
import 'facility_detail_screen.dart';

class FacilityListScreen extends ConsumerStatefulWidget {
  const FacilityListScreen({super.key});

  @override
  ConsumerState<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends ConsumerState<FacilityListScreen> {
  @override
  Widget build(BuildContext context) {
    // Google Places API에서 시설 데이터 가져오기
    final facilitiesAsync = ref.watch(nearbyFacilitiesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB89B8A),
              Color(0xFFA08A7A),
              Color(0xFF967E6D),
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
                child: facilitiesAsync.when(
                  data: (result) {
                    if (!result.isSuccess) {
                      return _buildErrorState(result.error?.toString() ?? 'エラーが発生しました');
                    }
                    final facilities = result.dataOrNull ?? [];
                    if (facilities.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildFacilityList(facilities);
                  },
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(error.toString()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return const GradientAppBar(
      title: null, // タイトルを削除
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
            '周辺のペット施設',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointOffWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityList(List<Facility> facilities) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(nearbyFacilitiesProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: facilities.length,
        itemBuilder: (context, index) {
          final facility = facilities[index];
          return _buildFacilityCard(facility);
        },
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
                        color: facility.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: Icon(
                        facility.icon,
                        color: facility.color,
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
                            facility.typeName,
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 시설 타입별 뱃지
                        if (facility.badgeText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: facility.badgeColor,
                              borderRadius: BorderRadius.circular(AppSpacing.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  facility.badgeIcon,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  facility.badgeText,
                                  style: AppFonts.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 4),
                        // 영업 상태 뱃지
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: facility.openStatusColor,
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          child: Text(
                            facility.openStatusText,
                            style: AppFonts.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
                      facility.formattedRating,
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
                    if (facility.distance != null) ...[
                      const SizedBox(width: AppSpacing.md),
                      const Icon(Icons.directions_walk, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        facility.formattedDistance,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '詳細を見る',
                      style: AppFonts.bodyMedium.copyWith(
                        color: facility.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: facility.color,
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

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.lg),
          Text(
            '周辺の施設を検索中...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.pointGray,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'エラーが発生しました',
              style: AppFonts.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(nearbyFacilitiesProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: AppColors.toneLightGray,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '周辺に施設が見つかりません',
              style: AppFonts.bodyLarge.copyWith(color: AppColors.toneDarkGray),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '別のカテゴリを選択するか、\n検索範囲を広げてみてください',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.toneDarkGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(nearbyFacilitiesProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('再検索'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Facility facility) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FacilityDetailScreen(
          facility: {
            'id': facility.id,
            'name': facility.name,
            'type': facility.typeName,
            'address': facility.address,
            'rating': facility.rating,
            'reviewCount': facility.reviewCount,
            'phone': facility.phone ?? facility.phoneNumber,
            'website': facility.website,
            'description': facility.description,
            'latitude': facility.latitude,
            'longitude': facility.longitude,
            'isOpen': facility.isOpen,
          },
        ),
      ),
    );
  }
}
