import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import 'facility_detail_screen.dart';

class HospitalListScreen extends ConsumerStatefulWidget {
  const HospitalListScreen({super.key});

  @override
  ConsumerState<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends ConsumerState<HospitalListScreen>
    with TickerProviderStateMixin {
  Set<String> _selectedCategories = {'全て'};
  final List<String> _categories = ['全て', '24時間', '救急室', '特殊診療', '一般診療'];
  late AnimationController _animationController;

  // 검색 관련 상태
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 검색 텍스트 변경 리스너 추가
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
              Color(0xFF4A90E2), // 파란색 그라데이션 시작
              Color(0xFF357ABD), // 파란색 그라데이션 중간
              Color(0xFF2E6DA4), // 파란색 그라데이션 끝
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
                child: _buildHospitalList(),
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
      automaticallyImplyLeading: true,
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
            '病院タイプ別検索',
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
                final isSelected = _selectedCategories.contains(category);

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (category == '全て') {
                            // 전체 선택 시 다른 모든 선택 해제
                            _selectedCategories = {'全て'};
                          } else {
                            // 전체 선택 해제
                            _selectedCategories.remove('全て');

                            if (_selectedCategories.contains(category)) {
                              // 이미 선택된 카테고리면 해제
                              _selectedCategories.remove(category);
                            } else {
                              // 선택되지 않은 카테고리면 추가
                              _selectedCategories.add(category);
                            }

                            // 모든 카테고리가 해제되면 전체 선택
                            if (_selectedCategories.isEmpty) {
                              _selectedCategories = {'全て'};
                            }
                          }
                          print(
                            '🔍 Selected categories: $_selectedCategories',
                          ); // 디버그 로그
                        });
                        _animationController.forward().then((_) {
                          _animationController.reverse();
                        });
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.lg),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
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
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.pointOffWhite.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          category,
                          style: AppFonts.bodyMedium.copyWith(
                            color: isSelected
                                ? const Color(0xFF4A90E2)
                                : AppColors.pointOffWhite,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
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

  Widget _buildHospitalList() {
    // Google Places API를 통한 동물병원 조회
    final hospitalsAsync = ref.watch(
      facilitiesByTypeProvider(FacilityType.veterinary),
    );

    return hospitalsAsync.when(
      data: (result) {
        if (!result.isSuccess ||
            result.dataOrNull == null ||
            result.dataOrNull!.isEmpty) {
          return _buildEmptyState();
        }

        var hospitals = result.dataOrNull!;

        // 검색어로 필터링
        if (_searchQuery.isNotEmpty) {
          hospitals = hospitals
              .where(
                (hospital) =>
                    hospital.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    hospital.address.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
        }

        // 카테고리 필터링 (현재는 24시간/응급실 정보가 Google Places에 없으므로 생략)
        // TODO: Google Places API 응답에서 24시간 정보를 추출하여 필터링 구현

        if (hospitals.isEmpty) {
          return _buildEmptyState();
        }

        print(
          '🏥 Filtered hospitals count: ${hospitals.length} for categories: $_selectedCategories, search: "$_searchQuery"',
        );

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: hospitals.length,
          itemBuilder: (context, index) {
            final hospital = hospitals[index];
            return _buildHospitalCard(hospital);
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
                facilitiesByTypeProvider(FacilityType.veterinary),
              ),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalCard(Facility hospital) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: InkWell(
          onTap: () => _navigateToDetail(hospital),
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 섹션
                  Row(
                    children: [
                      // 병원 아이콘
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF4A90E2).withValues(alpha: 0.1),
                              const Color(0xFF4A90E2).withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                          border: Border.all(
                            color: const Color(
                              0xFF4A90E2,
                            ).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.local_hospital,
                          color: Color(0xFF4A90E2),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // 병원 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hospital.name,
                              style: AppFonts.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              hospital.description ?? '動物病院',
                              style: AppFonts.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // 상태 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.lg),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF4A90E2,
                              ).withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          hospital.isOpen ? '営業中' : '休業中',
                          style: AppFonts.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 주소 정보
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: Color(0xFF4A90E2),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            hospital.address,
                            style: AppFonts.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 평점 및 리뷰
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                          border: Border.all(
                            color: Colors.amber.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              hospital.rating.toStringAsFixed(1),
                              style: AppFonts.bodySmall.copyWith(
                                color: Colors.amber.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '(${hospital.reviewCount}件のレビュー)',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      // Google Places에서 24시간 정보가 없으므로 생략
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 연락처 및 운영시간
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGray.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 16,
                                color: Color(0xFF4A90E2),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  hospital.phone ?? '電話番号なし',
                                  style: AppFonts.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGray.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color(0xFF4A90E2),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  hospital.isOpen ? '営業中' : '休業中',
                                  style: AppFonts.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 예약 버튼
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '詳細を見る',
                          style: AppFonts.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
            '${_selectedCategories.join(', ')} の動物病院がありません。',
            style: AppFonts.bodyLarge.copyWith(color: AppColors.toneDarkGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '他のタイプを選択してください',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.toneDarkGray),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedCategories = {'全て'};
              });
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('全て表示'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mock 데이터 메서드 삭제 - Google Places API 사용으로 대체됨
  /*
  List<Map<String, dynamic>> _getFilteredHospitals() {
    final allHospitals = _getMockHospitals();

    // 검색어로 필터링
    List<Map<String, dynamic>> searchFilteredHospitals = allHospitals;
    if (_searchQuery.isNotEmpty) {
      searchFilteredHospitals = allHospitals.where((hospital) {
        final name = hospital['name']?.toString().toLowerCase() ?? '';
        final type = hospital['type']?.toString().toLowerCase() ?? '';
        final address = hospital['address']?.toString().toLowerCase() ?? '';
        final services =
            (hospital['services'] as List<dynamic>?)
                ?.map((s) => s.toString().toLowerCase())
                .join(' ') ??
            '';

        final searchLower = _searchQuery.toLowerCase();
        return name.contains(searchLower) ||
            type.contains(searchLower) ||
            address.contains(searchLower) ||
            services.contains(searchLower);
      }).toList();
    }

    // 카테고리로 필터링
    if (_selectedCategories.contains('全て')) {
      return searchFilteredHospitals;
    }

    // 선택된 카테고리들에 해당하는 병원 필터링 (중복 카테고리 지원)
    return searchFilteredHospitals.where((hospital) {
      final hospitalCategories = List<String>.from(
        hospital['categories'] ?? [],
      );
      return hospitalCategories.any(
        (category) => _selectedCategories.contains(category),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _getMockHospitals() {
    return [
      // 24시간 병원
      {
        'name': '24時間救急動物病院',
        'type': '救急医療センター',
        'categories': ['24時間', '救急室'], // 중복 카테고리
        'address': '東京都渋谷区恵比寿1-2-3',
        'rating': 4.9,
        'reviewCount': 312,
        'isEmergency': true,
        'isOpen24h': true,
        'services': ['救急診療', '手術', '入院', '24時間ケア'],
        'phone': '03-1234-5678',
        'hours': '24時間営業',
      },
      {
        'name': '夜間救急動物病院',
        'type': '救急医療センター',
        'categories': ['24時間', '救急室'], // 중복 카테고리
        'address': '東京都新宿区新宿3-4-5',
        'rating': 4.7,
        'reviewCount': 189,
        'isEmergency': true,
        'isOpen24h': true,
        'services': ['救急診療', '夜間診療', '24時間ケア'],
        'phone': '03-2345-6789',
        'hours': '24時間営業',
      },

      // 응급실 병원
      {
        'name': 'ペットメディカルセンター',
        'type': '総合動物病院',
        'categories': ['救急室', '特殊診療'], // 중복 카테고리
        'address': '東京都港区六本木6-7-8',
        'rating': 4.8,
        'reviewCount': 245,
        'isEmergency': true,
        'isOpen24h': false,
        'services': ['救急診療', '手術', '入院', 'リハビリ治療'],
        'phone': '03-3456-7890',
        'hours': '9:00-21:00',
      },
      {
        'name': '動物救急センター',
        'type': '救急医療センター',
        'categories': ['救急室'], // 단일 카테고리
        'address': '東京都世田谷区三軒茶屋9-10-11',
        'rating': 4.6,
        'reviewCount': 167,
        'isEmergency': true,
        'isOpen24h': false,
        'services': ['救急診療', '手術', '入院'],
        'phone': '03-4567-8901',
        'hours': '8:00-22:00',
      },

      // 특수진료 병원
      {
        'name': 'ペットスペシャルクリニック',
        'type': '特殊診療センター',
        'categories': ['特殊診療', '一般診療'], // 중복 카테고리
        'address': '東京都目黒区自由が丘12-13-14',
        'rating': 4.9,
        'reviewCount': 198,
        'isEmergency': false,
        'isOpen24h': false,
        'services': ['心臓病', '腫瘍学', '眼科', '歯科'],
        'phone': '03-5678-9012',
        'hours': '9:00-18:00',
      },
      {
        'name': '動物専門病院',
        'type': '特殊診療センター',
        'categories': ['特殊診療'], // 단일 카테고리
        'address': '東京都練馬区大泉学園15-16-17',
        'rating': 4.7,
        'reviewCount': 134,
        'isEmergency': false,
        'isOpen24h': false,
        'services': ['整形外科', '神経科', '皮膚科', '内科'],
        'phone': '03-6789-0123',
        'hours': '9:00-18:00',
      },

      // 일반진료 병원
      {
        'name': '愛動物病院',
        'type': '一般動物病院',
        'categories': ['一般診療'], // 단일 카테고리
        'address': '東京都中央区銀座18-19-20',
        'rating': 4.5,
        'reviewCount': 89,
        'isEmergency': false,
        'isOpen24h': false,
        'services': ['一般診療', '予防接種', '健康診断', '美容'],
        'phone': '03-7890-1234',
        'hours': '9:00-19:00',
      },
      {
        'name': '幸せ動物病院',
        'type': '一般動物病院',
        'categories': ['一般診療'], // 단일 카테고리
        'address': '東京都渋谷区原宿21-22-23',
        'rating': 4.4,
        'reviewCount': 76,
        'isEmergency': false,
        'isOpen24h': false,
        'services': ['一般診療', '予防接種', '健康診断', '美容'],
        'phone': '03-8901-2345',
        'hours': '9:00-19:00',
      },
    ];
  }
  */

  void _navigateToDetail(Facility hospital) {
    // Facility entity를 Map으로 변환하여 기존 화면에 전달
    // TODO: FacilityDetailScreen을 Facility entity를 받도록 수정
    final hospitalMap = {
      'id': hospital.id,
      'name': hospital.name,
      'type': '動物病院',
      'address': hospital.address,
      'phone': hospital.phone ?? '',
      'rating': hospital.rating,
      'reviewCount': hospital.reviewCount,
      'description': hospital.description ?? '',
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FacilityDetailScreen(facility: hospitalMap),
      ),
    );
  }
}
