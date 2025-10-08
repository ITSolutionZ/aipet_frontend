import 'package:aipet_frontend/features/daily/presentation/providers/pet_selection_provider.dart';
import 'package:aipet_frontend/features/daily/presentation/providers/reservation_list_provider.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/cancel_reservation_modal.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/pet_selection_modal.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/reservation_card.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/facility/reservation_mock_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReservationStatusScreen extends ConsumerStatefulWidget {
  const ReservationStatusScreen({super.key});

  @override
  ConsumerState<ReservationStatusScreen> createState() =>
      _ReservationStatusScreenState();
}

class _ReservationStatusScreenState
    extends ConsumerState<ReservationStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 펫 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petSelectionProvider.notifier).loadPets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPetSelector(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReservationList(ReservationMockData.pending),
                _buildReservationList(ReservationMockData.confirmed),
                _buildReservationList(ReservationMockData.cancelled),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.pointBrown,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        '예약내역',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.pointBrown,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.go('/calendar'),
          child: const Text(
            '시설검색',
            style: TextStyle(color: AppColors.pointBrown),
          ),
        ),
      ],
    );
  }

  Widget _buildPetSelector() {
    final petSelectionState = ref.watch(petSelectionProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: InkWell(
        onTap: () => _showPetSelectionModal(),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.pointDark,
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                petSelectionState.selectedPetId != null
                    ? petSelectionState.availablePets
                          .firstWhere(
                            (pet) => pet.id == petSelectionState.selectedPetId,
                            orElse: () => petSelectionState.availablePets.first,
                          )
                          .name
                    : '전체',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointOffWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.pointOffWhite,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.pointOffWhite,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.pointBrown,
        labelColor: AppColors.pointBrown,
        unselectedLabelColor: AppColors.toneDarkGray,
        tabs: const [
          Tab(text: '예약대기'),
          Tab(text: '예약확정'),
          Tab(text: '예약취소'),
        ],
      ),
    );
  }

  Widget _buildReservationList(String status) {
    final petSelectionState = ref.watch(petSelectionProvider);

    // 선택된 펫과 상태에 따른 예약 목록 필터링
    final reservations = ReservationMockData.getReservationsByPetAndStatus(
      petSelectionState.selectedPetId,
      status,
    );

    if (reservations.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(reservationListProvider.notifier).loadReservations();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ReservationCard(
              reservation: reservation,
              onCancel: () => _cancelReservation(reservation),
              onConfirm: () => _confirmReservation(reservation),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
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
            '해당 상태의 예약내역이 없습니다.',
            style: AppFonts.bodyLarge.copyWith(color: AppColors.toneDarkGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '내근처 예약 가능한 시설을 찾아봐요',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.toneDarkGray),
          ),
        ],
      ),
    );
  }

  void _showPetSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PetSelectionModal(),
    );
  }

  void _cancelReservation(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (context) => CancelReservationModal(
        reservationId: reservation['id'] as String,
        facilityName: reservation['facilityName'] as String,
        onCancelConfirmed: (String reason, String detail) {
          // 예약 취소 확인 후 로컬 데이터 수정
          ref
              .read(reservationListProvider.notifier)
              .cancelReservation(
                reservation['id'] as String,
                reason: reason,
                detail: detail,
              );
          setState(() {}); // UI 업데이트
        },
      ),
    );
  }

  void _confirmReservation(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 확정'),
        content: const Text('예약을 확정하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(reservationListProvider.notifier)
                  .confirmReservation(reservation['id'] as String);
              setState(() {}); // UI 업데이트
            },
            child: const Text('예'),
          ),
        ],
      ),
    );
  }
}
