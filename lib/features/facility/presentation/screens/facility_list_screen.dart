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
  String _selectedCategory = '전체';
  final List<String> _categories = ['전체', '미용실', '카페', '호텔', '놀이터', '교육센터'];

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
        '시설 예약',
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
            '카테고리별 시설',
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
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
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
                        category,
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
    final facilities = _getFilteredFacilities();

    if (facilities.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: facilities.length,
      itemBuilder: (context, index) {
        final facility = facilities[index];
        return _buildFacilityCard(facility);
      },
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> facility) {
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
                          facility['type'],
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: Icon(
                        _getCategoryIcon(facility['type']),
                        color: _getCategoryColor(facility['type']),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility['name'],
                            style: AppFonts.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            facility['type'],
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(facility['type']),
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: Text(
                        '예약 가능',
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
                        facility['address'],
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
                      '${facility['rating']}',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '(${facility['reviewCount']}개 리뷰)',
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
                        color: _getCategoryColor(facility['type']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: _getCategoryColor(facility['type']),
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
            '해당 카테고리의 시설이 없습니다.',
            style: AppFonts.bodyLarge.copyWith(color: AppColors.toneDarkGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '다른 카테고리를 선택해보세요',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.toneDarkGray),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredFacilities() {
    final allFacilities = _getMockFacilities();

    if (_selectedCategory == '전체') {
      return allFacilities;
    }

    return allFacilities
        .where((facility) => facility['type'] == _selectedCategory)
        .toList();
  }

  List<Map<String, dynamic>> _getMockFacilities() {
    return [
      // 미용실
      {
        'name': '펫뷰티 살롱',
        'type': '미용실',
        'address': '서울시 강남구 테헤란로 123',
        'rating': 4.8,
        'reviewCount': 156,
        'services': ['기본 미용', '전체 미용', '발톱 관리', '목욕', '드라이'],
      },
      {
        'name': '러블리 펫살롱',
        'type': '미용실',
        'address': '서울시 서초구 서초대로 456',
        'rating': 4.6,
        'reviewCount': 89,
        'services': ['기본 미용', '전체 미용', '발톱 관리', '목욕', '드라이'],
      },

      // 카페
      {
        'name': '펫프렌드 카페',
        'type': '카페',
        'address': '서울시 홍대입구역 789',
        'rating': 4.7,
        'reviewCount': 203,
        'services': ['기본 이용', '특별 메뉴', '이벤트 참여'],
      },
      {
        'name': '도그카페 루루',
        'type': '카페',
        'address': '서울시 이태원동 321',
        'rating': 4.5,
        'reviewCount': 134,
        'services': ['기본 이용', '특별 메뉴', '이벤트 참여'],
      },

      // 호텔
      {
        'name': '펫스테이 호텔',
        'type': '호텔',
        'address': '서울시 송파구 올림픽로 654',
        'rating': 4.9,
        'reviewCount': 278,
        'services': ['1박', '2박', '장기 숙박', '특별 케어'],
      },
      {
        'name': '펫파라다이스',
        'type': '호텔',
        'address': '서울시 강동구 천호대로 987',
        'rating': 4.4,
        'reviewCount': 95,
        'services': ['1박', '2박', '장기 숙박', '특별 케어'],
      },

      // 놀이터
      {
        'name': '펫플레이그라운드',
        'type': '놀이터',
        'address': '서울시 한강공원 내',
        'rating': 4.6,
        'reviewCount': 167,
        'services': ['기본 이용', '특별 프로그램', '그룹 활동'],
      },
      {
        'name': '도그파크 센트럴',
        'type': '놀이터',
        'address': '서울시 중앙공원 내',
        'rating': 4.3,
        'reviewCount': 112,
        'services': ['기본 이용', '특별 프로그램', '그룹 활동'],
      },

      // 교육센터
      {
        'name': '펫스쿨 아카데미',
        'type': '교육센터',
        'address': '서울시 마포구 홍대입구 147',
        'rating': 4.8,
        'reviewCount': 189,
        'services': ['기본 훈련', '고급 훈련', '행동 교정', '사회화 훈련'],
      },
      {
        'name': '도그트레이닝센터',
        'type': '교육센터',
        'address': '서울시 강서구 화곡동 258',
        'rating': 4.7,
        'reviewCount': 145,
        'services': ['기본 훈련', '고급 훈련', '행동 교정', '사회화 훈련'],
      },
    ];
  }

  IconData _getCategoryIcon(String type) {
    switch (type) {
      case '미용실':
        return Icons.content_cut;
      case '카페':
        return Icons.local_cafe;
      case '호텔':
        return Icons.hotel;
      case '놀이터':
        return Icons.park;
      case '교육센터':
        return Icons.school;
      default:
        return Icons.place;
    }
  }

  Color _getCategoryColor(String type) {
    switch (type) {
      case '미용실':
        return Colors.pink;
      case '카페':
        return Colors.brown;
      case '호텔':
        return Colors.blue;
      case '놀이터':
        return Colors.green;
      case '교육센터':
        return Colors.purple;
      default:
        return AppColors.pointGreen;
    }
  }

  void _navigateToDetail(Map<String, dynamic> facility) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FacilityDetailScreen(facility: facility),
      ),
    );
  }
}
