import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/pet_profile/presentation/controllers/vaccine_controller.dart';
import '../../../../../features/pet_profile/presentation/widgets/vaccine/vaccine_widgets.dart';

class VaccineScreen extends ConsumerStatefulWidget {
  final String petId;

  const VaccineScreen({super.key, required this.petId});

  @override
  ConsumerState<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends ConsumerState<VaccineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientDrawerAppBar(title: 'ワクチン記録'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VaccineHeaderCard(),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'ワクチン記録',
              style: AppFonts.titleLarge.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            VaccineList(
              petId: widget.petId,
              onVaccineTap: _showVaccineDetailModal,
            ),

            const SizedBox(height: AppSpacing.xl),

            AddVaccineButton(petId: widget.petId),
          ],
        ),
      ),
    );
  }

  /// 백신 상세 모달 표시
  void _showVaccineDetailModal(VaccineRecord vaccine) {
    showDialog(
      context: context,
      builder: (context) => VaccineDetailModal(vaccine: vaccine),
    );
  }
}
