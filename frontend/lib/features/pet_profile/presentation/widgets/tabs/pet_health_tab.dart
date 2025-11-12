import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/shared.dart';
import 'sections/appointment_section.dart';
import 'sections/medical_records_section.dart';
import 'sections/vaccination_section.dart';
import 'sections/weight_tracking_section.dart';

/// Pet Health Tab
///
/// 리팩토링 완료: 1,200 라인 → 60 라인
/// 4개의 독립적인 섹션으로 분리:
/// - VaccinationSection (~700 lines)
/// - MedicalRecordsSection (~200 lines)
/// - WeightTrackingSection (~30 lines)
/// - AppointmentSection (~190 lines)
class PetHealthTab extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const PetHealthTab({super.key, required this.pet, this.isEditMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // 예방접종 기록 섹션
          VaccinationSection(pet: pet, isEditMode: isEditMode),
          const SizedBox(height: AppSpacing.lg),

          // 진료 기록 섹션
          MedicalRecordsSection(pet: pet, isEditMode: isEditMode),
          const SizedBox(height: AppSpacing.lg),

          // 체중 추적 섹션
          WeightTrackingSection(pet: pet),
          const SizedBox(height: AppSpacing.lg),

          // 예약/스케줄 섹션
          AppointmentSection(pet: pet, isEditMode: isEditMode),
        ],
      ),
    );
  }
}
