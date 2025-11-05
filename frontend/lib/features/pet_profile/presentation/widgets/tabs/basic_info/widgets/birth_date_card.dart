import 'package:flutter/material.dart';


import '../../../../../../../shared/shared.dart';
import '../constants/basic_info_constants.dart';


/// 생년월일 정보 카드 위젯
///
/// 펫의 생년월일과 나이를 표시하는 카드
class BirthDateCard extends StatelessWidget {
  final PetProfileEntity pet;

  const BirthDateCard({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    final birthDate = pet.birthDate;
    final formattedDate = _formatBirthDate(birthDate);

    return GenericInfoCard.withIcon(
      icon: Icons.cake,
      iconColor: AppColors.pointPink,
      iconBackgroundColor: AppColors.pointPink.withValues(alpha: 0.1),
      title: BasicInfoConstants.birthDateLabel,
      subtitle: formattedDate,
      badge: '${pet.age}${BasicInfoConstants.ageLabel}',
      badgeColor: AppColors.pointPink,
    );
  }

  /// 생년월일 포맷팅
  String _formatBirthDate(DateTime birthDate) {
    return BasicInfoConstants.formatDateJa(birthDate);
  }
}
