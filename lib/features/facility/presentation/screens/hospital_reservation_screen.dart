import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../controllers/hospital_reservation_controller.dart';
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
  late HospitalReservationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HospitalReservationController(ref, context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadHospitalFacilities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _controller.updateSearchQuery(query);
  }

  void _onFilterChanged(String filter) {
    _controller.updateFilter(filter);
  }

  void _toggleFavorite(String facilityId) {
    _controller.toggleFavorite(facilityId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(hospitalReservationControllerProvider);

        return Scaffold(
          backgroundColor: AppColors.pointOffWhite,
          appBar: const SoftGradientBackAppBar(title: '動物病院'),
          body: Column(
            children: [
              // 검색바
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SearchBarWidget(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  hintText: '病院名で検索...',
                ),
              ),

              // 필터 칩
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: FilterChips(
                  currentFilter: state.currentFilter,
                  onFilterChanged: _onFilterChanged,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 시설 목록
              Expanded(
                child: state.filteredFacilities.isEmpty
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
                              '検索結果がありません',
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
                        itemCount: state.filteredFacilities.length,
                        itemBuilder: (context, index) {
                          final facility = state.filteredFacilities[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: FacilityCard(
                              facility: facility,
                              onFavoriteToggle: () =>
                                  _toggleFavorite(facility.id),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        side: const BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.blue),
                    label: Text(
                      'もっと探す',
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
      },
    );
  }
}
