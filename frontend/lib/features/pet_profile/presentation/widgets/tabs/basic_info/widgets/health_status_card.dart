import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../../../../shared/shared.dart';
import '../constants/basic_info_constants.dart';
import '../controllers/pet_basic_info_controller.dart';


/// 건강 상태 카드
///
/// 펫의 건강 상태를 표시하고 편집할 수 있는 카드
class HealthStatusCard extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;
  final String tabId;

  const HealthStatusCard({
    super.key,
    required this.pet,
    required this.isEditMode,
    required this.tabId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(petBasicInfoControllerProvider(tabId));
    final healthConditions = tabState.editingHealthConditions;
    final hasHealthConditions = healthConditions.isNotEmpty;

    // 신체 부위 개수 확인
    final bodyPartsCount = _getBodyPartsCount();

    // 건강상태 결정: 건강 조건이 있거나 신체 부위가 3개 이상이면 "注意", 그 외는 "良好"
    final isWarning = hasHealthConditions || bodyPartsCount >= 3;
    final statusText = isWarning ? '注意' : '良好';
    final statusColor = isWarning ? AppColors.pointPink : AppColors.pointGreen;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(
          BasicInfoConstants.cardBorderRadius,
        ),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, statusText, statusColor),
          const SizedBox(height: AppSpacing.md),
          if (hasHealthConditions)
            _buildHealthConditionChips(healthConditions, statusColor),
        ],
      ),
    );
  }

  /// 신체 부위 개수 가져오기
  int _getBodyPartsCount() {
    if (pet.additionalInfo == null ||
        pet.additionalInfo!['bodyPartsToManage'] == null) {
      return 0;
    }

    final String bodyPartsString = pet.additionalInfo!['bodyPartsToManage']
        .toString();
    final bodyPartsList = bodyPartsString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return bodyPartsList.length;
  }

  /// 헤더 섹션 구성
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    String statusText,
    Color statusColor,
  ) {
    return Row(
      children: [
        _buildIcon(statusColor),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            BasicInfoConstants.healthStatusLabel,
            style: AppFonts.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _buildStatusBadge(statusText, statusColor),
        if (isEditMode) ...[
          const SizedBox(width: AppSpacing.sm),
          _buildEditHealthStatusButton(context, ref),
        ],
      ],
    );
  }

  /// 아이콘 컨테이너
  Widget _buildIcon(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Icon(
        Icons.health_and_safety,
        color: statusColor,
        size: BasicInfoConstants.iconSize,
      ),
    );
  }

  /// 상태 배지
  Widget _buildStatusBadge(String statusText, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Text(
        statusText,
        style: AppFonts.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 건강 상태 편집 버튼
  Widget _buildEditHealthStatusButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.edit, size: BasicInfoConstants.editIconSize),
      onPressed: () => _showHealthStatusDialog(context, ref),
    );
  }

  /// 건강 상태 칩 목록
  Widget _buildHealthConditionChips(
    List<String> healthConditions,
    Color statusColor,
  ) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: healthConditions.map((condition) {
        // 값을 레이블로 변환
        final label = BasicInfoConstants.getHealthConditionLabel(condition);

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppFonts.bodyMedium.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 건강 상태 선택 다이얼로그 표시
  void _showHealthStatusDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _buildHealthStatusDialog(context, ref),
    );
  }

  /// 건강 상태 선택 다이얼로그 빌드
  Widget _buildHealthStatusDialog(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(petBasicInfoControllerProvider(tabId));
    final selectedConditions = tabState.editingHealthConditions;

    return AlertDialog(
      title: const Text(BasicInfoConstants.selectHealthStatusTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: BasicInfoConstants.healthConditions.map((condition) {
            return _buildHealthConditionCheckbox(
              ref,
              condition['value']!,
              condition['label']!,
              selectedConditions,
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(BasicInfoConstants.cancelButton),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('完了'),
        ),
      ],
    );
  }

  /// 건강 상태 체크박스
  Widget _buildHealthConditionCheckbox(
    WidgetRef ref,
    String condition,
    String label,
    List<String> selectedConditions,
  ) {
    final isSelected = selectedConditions.contains(condition);

    return CheckboxListTile(
      value: isSelected,
      onChanged: (_) {
        ref
            .read(petBasicInfoControllerProvider(tabId).notifier)
            .toggleHealthCondition(condition);
      },
      title: Text(label),
    );
  }
}
