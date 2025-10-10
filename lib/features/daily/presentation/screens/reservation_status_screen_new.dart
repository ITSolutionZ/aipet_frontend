import 'package:aipet_frontend/features/daily/data/services/reservation_local_storage_service.dart';
import 'package:aipet_frontend/features/daily/presentation/providers/pet_selection_provider.dart';
import 'package:aipet_frontend/features/daily/presentation/providers/reservation_list_provider.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/cancel_reservation_modal.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/pet_selection_modal.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/reservation_card.dart';
import 'package:aipet_frontend/shared/design/design.dart';
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
                _buildReservationList(ReservationLocalStorageService.pending),
                _buildReservationList(ReservationLocalStorageService.confirmed),
                _buildReservationList(ReservationLocalStorageService.cancelled),
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
        '予約履歴',
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
            '施設検索',
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
                    : '全体',
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
          Tab(text: '予約待ち'),
          Tab(text: '予約確定'),
          Tab(text: 'キャンセル'),
        ],
      ),
    );
  }

  Widget _buildReservationList(String status) {
    final petSelectionState = ref.watch(petSelectionProvider);
    final reservationState = ref.watch(reservationListProvider);

    // 로컬 저장소에서 예약 목록 로드
    if (reservationState.reservations.isEmpty && !reservationState.isLoading) {
      // 초기 로드
      Future.microtask(() {
        ref
            .read(reservationListProvider.notifier)
            .loadReservations(
              petId: petSelectionState.selectedPetId,
              status: status,
            );
      });
    }

    // 선택된 펫과 상태에 따른 예약 목록 필터링
    final reservations = reservationState.reservations
        .where((r) => r['status'] == status)
        .toList();

    if (reservationState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
            'この状態の予約はありません。',
            style: AppFonts.bodyLarge.copyWith(color: AppColors.toneDarkGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '近くの予約可能な施設を探してみましょう',
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
        title: const Text('予約確定'),
        content: const Text('予約を確定しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('いいえ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(reservationListProvider.notifier)
                  .confirmReservation(reservation['id'] as String);
              setState(() {}); // UI 업데이트
            },
            child: const Text('はい'),
          ),
        ],
      ),
    );
  }
}
