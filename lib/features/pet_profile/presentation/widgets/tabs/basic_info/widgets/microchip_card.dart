import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/basic_info_constants.dart';
import '../controllers/pet_basic_info_controller.dart';

/// 마이크로칩 정보 카드 위젯
///
/// 펫의 마이크로칩 등록 정보를 표시하는 카드
class MicrochipCard extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;
  final String tabId;

  const MicrochipCard({
    super.key,
    required this.pet,
    required this.isEditMode,
    required this.tabId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationNumber = _getMicrochipRegistrationNumber(ref);
    final isRegistered = registrationNumber.isNotEmpty;

    return GenericInfoCard.withIcon(
      icon: Icons.memory,
      iconColor: AppColors.pointBlue,
      iconBackgroundColor: AppColors.pointBlue.withValues(alpha: 0.1),
      title: BasicInfoConstants.microchipLabel,
      subtitle: isRegistered ? registrationNumber : '未登録',
      badge: isRegistered ? '登録済み' : '未登録',
      badgeColor: isRegistered ? AppColors.pointGreen : AppColors.pointGray,
    );
  }

  /// 마이크로칩 등록번호 가져오기
  String _getMicrochipRegistrationNumber(WidgetRef ref) {
    if (isEditMode) {
      final controller = ref.watch(petBasicInfoControllerProvider(tabId).notifier);
      return controller.microchipController.text.isNotEmpty
          ? controller.microchipController.text
          : pet.additionalInfo?['registrationNumber'] ?? '';
    }
    return pet.additionalInfo?['registrationNumber'] ?? '';
  }
}
