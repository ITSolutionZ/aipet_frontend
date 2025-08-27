import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';
import '../widgets/facility_card.dart';
import '../widgets/filter_chips.dart';
import '../widgets/search_bar_widget.dart';

class HospitalReservationScreen extends ConsumerStatefulWidget {
  const HospitalReservationScreen({super.key});

  @override
  ConsumerState<HospitalReservationScreen> createState() =>
      _HospitalReservationScreenState();
}

class _HospitalReservationScreenState
    extends ConsumerState<HospitalReservationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentFilter = 'All';
  String _searchQuery = '';

  // 목업 데이터 서비스에서 가져오기
  late List<Facility> _facilities;

  @override
  void initState() {
    super.initState();
    _facilities = MockDataService.getMockHospitalFacilities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Facility> get _filteredFacilities {
    List<Facility> filtered = _facilities;

    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (facility) =>
                facility.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                facility.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // 카테고리 필터
    switch (_currentFilter) {
      case 'Favorites':
        filtered = filtered.where((facility) => facility.isFavorite).toList();
        break;
      case 'History':
        filtered = filtered.where((facility) => facility.hasHistory).toList();
        break;
      case 'All':
      default:
        break;
    }

    return filtered;
  }

  void _toggleFavorite(String facilityId) {
    setState(() {
      final index = _facilities.indexWhere((f) => f.id == facilityId);
      if (index != -1) {
        _facilities[index] = _facilities[index].copyWith(
          isFavorite: !_facilities[index].isFavorite,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'Hospital',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SearchBarWidget(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              hintText: 'Search by hospital name',
            ),
          ),

          // 필터 칩
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: FilterChips(
              currentFilter: _currentFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _currentFilter = filter;
                });
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 시설 목록
          Expanded(
            child: _filteredFacilities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '검색 결과가 없습니다',
                          style: AppFonts.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: _filteredFacilities.length,
                    itemBuilder: (context, index) {
                      final facility = _filteredFacilities[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: FacilityCard(
                          facility: facility,
                          onFavoriteToggle: () => _toggleFavorite(facility.id),
                          onTap: () {
                            context.push('/facility-detail/${facility.id}');
                          },
                        ),
                      );
                    },
                  ),
          ),

          // 찾아보기 버튼
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/facility-list');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    side: const BorderSide(color: Colors.blue, width: 1),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.blue),
                label: Text(
                  '찾아보기',
                  style: AppFonts.fredoka(
                    fontSize: AppFonts.lg,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
