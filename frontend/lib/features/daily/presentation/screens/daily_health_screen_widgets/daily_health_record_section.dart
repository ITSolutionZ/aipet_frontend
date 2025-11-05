import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/daily/data/providers/vaccine_provider.dart';
import '../../../../../../features/daily/domain/entities/daily_health_record.dart';
import '../../../../../../features/daily/presentation/widgets/daily_health_widgets.dart';
import '../../../../../../features/daily/presentation/widgets/hospital_management_card.dart';
import '../../../../../../features/daily/presentation/widgets/reservation_status_card.dart';
import '../../../../../../features/pet_profile/data/providers/pet_profile_providers.dart';
import '../../widgets/daily_health_common_widgets.dart' as daily_widgets;

// Daily health specific widgets

/// Daily Health 건강 기록 섹션
class DailyHealthRecordSection extends ConsumerWidget {
  final DailyHealthRecord healthRecord;
  final String currentPetId;

  const DailyHealthRecordSection({
    super.key,
    required this.healthRecord,
    required this.currentPetId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProfilesProvider);

    // 현재 선택된 펫의 몸무게, 타입, 이름 가져오기
    double? currentWeight;
    String petType = 'dog'; // 기본값
    String petName = 'ペット'; // 기본값
    petsAsync.whenData((pets) {
      if (pets.isNotEmpty) {
        final selectedPet = pets.firstWhere(
          (pet) => pet.id == currentPetId,
          orElse: () => pets.first,
        );
        currentWeight = selectedPet.weight;
        petType = selectedPet.type;
        petName = selectedPet.name;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const daily_widgets.SectionHeaderWidget(
          title: '今日の健康状態',
          subtitle: '最新の記録',
        ),
        const SizedBox(height: AppSpacing.md),
        TemperatureDisplayCard(healthRecord: healthRecord, petType: petType),
        const SizedBox(height: AppSpacing.md),
        WeightDisplayCard(weight: currentWeight),
        const SizedBox(height: AppSpacing.md),
        _VaccineHistorySection(petId: currentPetId, petName: petName),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: HospitalManagementCard(
                onTap: () => context.push('/home/daily/hospital-management'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ReservationStatusCard(
                upcomingReservations: 0, // 실제 예약 수 (로컬 저장소에서 조회)
                onTap: () => context.push('/home/daily/reservation-status'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        HealthStatusCard(healthRecord: healthRecord),
        const SizedBox(height: AppSpacing.md),
        SymptomsCard(healthRecord: healthRecord),
      ],
    );
  }
}

/// 백신 내역 섹션 (내부 위젯)
class _VaccineHistorySection extends ConsumerWidget {
  final String petId;
  final String petName;

  const _VaccineHistorySection({required this.petId, required this.petName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledAsync = ref.watch(scheduledVaccinesProvider(petId));
    final completedAsync = ref.watch(completedVaccinesProvider(petId));

    return scheduledAsync.when(
      data: (scheduled) => completedAsync.when(
        data: (completed) => VaccineHistoryCard(
          petName: petName,
          scheduledVaccines: scheduled,
          completedVaccines: completed,
          onRegister: () {
            // 백신 등록 화면으로 이동 (추후 구현)
          },
        ),
        loading: () => _VaccineLoadingCard(petName: petName),
        error: (error, stack) => VaccineHistoryCard(
          petName: petName,
          scheduledVaccines: scheduled,
          completedVaccines: const [],
        ),
      ),
      loading: () => _VaccineLoadingCard(petName: petName),
      error: (error, stack) => VaccineHistoryCard(
        petName: petName,
        scheduledVaccines: const [],
        completedVaccines: const [],
      ),
    );
  }
}

/// 백신 로딩 카드 (내부 위젯)
class _VaccineLoadingCard extends StatelessWidget {
  final String petName;

  const _VaccineLoadingCard({required this.petName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$petNameのワクチン接種',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
