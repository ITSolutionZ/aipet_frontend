import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/shared.dart';
import 'basic_info/controllers/pet_basic_info_controller.dart';
import 'basic_info/widgets/appearance_card.dart';
import 'basic_info/widgets/basic_info_cards_section.dart';
import 'basic_info/widgets/birth_date_card.dart';
import 'basic_info/widgets/body_parts_card.dart';
import 'basic_info/widgets/caretaker_section.dart';
import 'basic_info/widgets/health_status_card.dart';
import 'basic_info/widgets/microchip_card.dart';
import 'basic_info/widgets/profile_image_section.dart';
import 'helpers/pet_info_validation_helper.dart';


/// Pet Basic Info Tab 위젯
///
/// 리팩토링 완료: 1,186줄 → 약 100줄
/// - Controller/State를 basic_info/controllers/로 분리
/// - 8개의 독립적인 위젯 컴포넌트로 분해
/// - 메인 파일은 위젯 조합만 담당
class PetBasicInfoTab extends ConsumerStatefulWidget {
  final PetProfileEntity pet;
  final bool isEditMode;
  final VoidCallback onToggleEdit;

  const PetBasicInfoTab({
    super.key,
    required this.pet,
    required this.isEditMode,
    required this.onToggleEdit,
  });

  @override
  ConsumerState<PetBasicInfoTab> createState() => _PetBasicInfoTabState();
}

class _PetBasicInfoTabState extends ConsumerState<PetBasicInfoTab> {
  late final String tabId;

  @override
  void initState() {
    super.initState();
    tabId = DateTime.now().millisecondsSinceEpoch.toString();

    // Controller 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petBasicInfoControllerProvider(tabId).notifier).initialize(widget.pet);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // 프로필 이미지 섹션
          ProfileImageSection(
            pet: widget.pet,
            isEditMode: widget.isEditMode,
            tabId: tabId,
          ),
          const SizedBox(height: AppSpacing.lg),

          // 기본 정보 카드들 (이름, 체중, 보호자, 기관, 입양일)
          BasicInfoCardsSection(
            pet: widget.pet,
            isEditMode: widget.isEditMode,
            tabId: tabId,
          ),
          const SizedBox(height: AppSpacing.lg),

          // 마이크로칩 카드
          MicrochipCard(
            pet: widget.pet,
            isEditMode: widget.isEditMode,
            tabId: tabId,
          ),
          const SizedBox(height: AppSpacing.lg),

          // 생년월일 카드
          BirthDateCard(pet: widget.pet),
          const SizedBox(height: AppSpacing.lg),

          // 건강 상태 카드
          HealthStatusCard(
            pet: widget.pet,
            isEditMode: widget.isEditMode,
            tabId: tabId,
          ),
          const SizedBox(height: AppSpacing.lg),

          // 신체 부위 카드
          BodyPartsCard(pet: widget.pet),
          const SizedBox(height: AppSpacing.lg),

          // 외견 카드
          AppearanceCard(pet: widget.pet),
          const SizedBox(height: AppSpacing.lg),

          // 보호자 섹션
          CaretakerSection(
            pet: widget.pet,
            isEditMode: widget.isEditMode,
          ),
          const SizedBox(height: AppSpacing.xl),

          // 액션 버튼들 (편집/저장/취소)
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons(BuildContext context) {
    // 편집 모드일 때만 버튼 표시
    if (!widget.isEditMode) {
      return const SizedBox.shrink();
    }

    return ActionButtonGroup.toggle(
      isEditMode: widget.isEditMode,
      onEdit: widget.onToggleEdit,
      onSave: () => _handleSave(context),
      onCancel: _handleCancel,
      editLabel: '編集',
      saveLabel: '保存',
      cancelLabel: 'キャンセル',
    );
  }

  /// 저장 처리
  void _handleSave(BuildContext context) {
    PetInfoValidationHelper.saveChanges(
      context,
      ref,
      tabId,
      widget.pet,
      widget.onToggleEdit,
    );
  }

  /// 취소 처리
  void _handleCancel() {
    PetInfoValidationHelper.cancelEdit(
      ref,
      tabId,
      widget.pet,
      widget.onToggleEdit,
    );
  }
}
