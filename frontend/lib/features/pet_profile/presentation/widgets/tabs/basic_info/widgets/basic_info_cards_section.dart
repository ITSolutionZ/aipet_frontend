import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helpers/helpers.dart';
import '../constants/basic_info_constants.dart';
import '../controllers/pet_basic_info_controller.dart';
import '../controllers/pet_basic_info_state.dart';

/// 기본 정보 카드 섹션
///
/// 이름, 체중, 보호자, 기관, 입양일 카드들을 표시하는 위젯
class BasicInfoCardsSection extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;
  final String tabId;

  const BasicInfoCardsSection({
    super.key,
    required this.pet,
    required this.isEditMode,
    required this.tabId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(petBasicInfoControllerProvider(tabId));

    return Column(
      children: [
        _buildNameCard(context, ref, tabState),
        const SizedBox(height: AppSpacing.md),
        _buildWeightCard(context, ref, tabState),
        const SizedBox(height: AppSpacing.md),
        _buildGuardianCard(),
        const SizedBox(height: AppSpacing.md),
        _buildInstitutionCard(),
        const SizedBox(height: AppSpacing.md),
        _buildAdoptionDateCard(),
      ],
    );
  }

  /// 이름 카드
  Widget _buildNameCard(
    BuildContext context,
    WidgetRef ref,
    PetBasicInfoState tabState,
  ) {
    final displayName = isEditMode
        ? (tabState.editingName.isNotEmpty ? tabState.editingName : pet.name)
        : pet.name;

    return _buildEditableAttributeCard(
      context,
      ref,
      BasicInfoConstants.nameLabel,
      displayName,
      type: 'name',
    );
  }

  /// 체중 카드
  Widget _buildWeightCard(
    BuildContext context,
    WidgetRef ref,
    PetBasicInfoState tabState,
  ) {
    final displayWeight = isEditMode
        ? '${tabState.editingWeight ?? pet.weight}kg'
        : '${pet.weight}kg';

    return _buildEditableAttributeCard(
      context,
      ref,
      BasicInfoConstants.weightLabel,
      displayWeight,
      type: 'weight',
    );
  }

  /// 보호자 카드
  Widget _buildGuardianCard() {
    return _buildInfoOnlyCard(
      BasicInfoConstants.guardianLabel,
      pet.additionalInfo?['guardianName']?.toString() ?? '未設定',
      Icons.person_outline,
    );
  }

  /// 등록 기관 카드
  Widget _buildInstitutionCard() {
    return _buildInfoOnlyCard(
      BasicInfoConstants.institutionLabel,
      pet.additionalInfo?['institutionName']?.toString() ?? '未設定',
      Icons.business,
    );
  }

  /// 입양일 카드
  Widget _buildAdoptionDateCard() {
    final displayDate = _formatAdoptionDate();

    return GenericInfoCard.withIcon(
      icon: Icons.home,
      iconColor: AppColors.pointGreen,
      iconBackgroundColor: AppColors.pointGreen.withValues(alpha: 0.1),
      title: BasicInfoConstants.adoptionDateLabel,
      subtitle: displayDate,
    );
  }

  /// 입양일 포맷팅
  String _formatAdoptionDate() {
    final adoptionDate = pet.additionalInfo?['adoptionDate'];

    if (adoptionDate == null) return '未設定';

    try {
      final date = DateTime.parse(adoptionDate.toString());
      return BasicInfoConstants.formatDateJa(date);
    } catch (e) {
      return '未設定';
    }
  }

  /// 읽기 전용 정보 카드
  Widget _buildInfoOnlyCard(String label, String value, IconData icon) {
    return GenericInfoCard.withIcon(
      icon: icon,
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
      title: label,
      subtitle: value,
    );
  }

  /// 편집 가능한 속성 카드
  Widget _buildEditableAttributeCard(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value, {
    required String type,
  }) {
    return GenericInfoCard.withIcon(
      icon: PetInfoUiHelper.getAttributeIcon(type),
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
      title: label,
      subtitle: value,
      trailing: isEditMode ? _buildEditButton(context, ref, type) : null,
    );
  }

  /// 편집 버튼
  Widget _buildEditButton(BuildContext context, WidgetRef ref, String type) {
    return IconButton(
      icon: const Icon(Icons.edit, size: BasicInfoConstants.editIconSize),
      onPressed: () => _editAttribute(context, ref, type),
    );
  }

  /// 속성 편집
  void _editAttribute(BuildContext context, WidgetRef ref, String type) {
    final editActions = _getEditActions();
    editActions[type]?.call(context, ref, tabId);
  }

  /// 편집 액션들 맵
  Map<String, void Function(BuildContext, WidgetRef, String)>
  _getEditActions() {
    return {
      'name': PetInfoDialogHelper.showEditNameDialog,
      'gender': PetInfoDialogHelper.showEditGenderDialog,
      'weight': PetInfoDialogHelper.showEditWeightDialog,
      'appearance': PetInfoDialogHelper.showEditAppearanceDialog,
    };
  }
}
