import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../constants/basic_info_constants.dart';

/// 보호자 섹션
///
/// 보호자 정보를 표시하고 편집 모드에서 삭제 기능 제공
class CaretakerSection extends StatelessWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const CaretakerSection({
    super.key,
    required this.pet,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCaretakerSection(context);
  }

  /// 보호자 섹션
  Widget _buildCaretakerSection(BuildContext context) {
    final guardianInfo = _getGuardianInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCaretakerSectionTitle(),
        const SizedBox(height: AppSpacing.md),
        if (guardianInfo.name.isNotEmpty)
          _buildCaretakerCardWithSpacing(context, guardianInfo)
        else
          _buildEmptyCaretakerCard(),
      ],
    );
  }

  /// 보호자 정보 가져오기
  ({String name, String institution}) _getGuardianInfo() {
    final guardianName = pet.additionalInfo?['guardianName']?.toString() ?? '';
    final institutionName =
        pet.additionalInfo?['institutionName']?.toString() ?? '';

    return (
      name: guardianName,
      institution: institutionName.isNotEmpty ? institutionName : '未設定',
    );
  }

  /// 보호자 섹션 제목
  Widget _buildCaretakerSectionTitle() {
    return Text(
      BasicInfoConstants.familyLabel,
      style: AppFonts.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.pointDark,
      ),
    );
  }

  /// 보호자 카드와 간격
  Widget _buildCaretakerCardWithSpacing(
    BuildContext context,
    ({String name, String institution}) guardianInfo,
  ) {
    return Column(
      children: [
        _buildCaretakerCard(
          context,
          guardianInfo.name,
          guardianInfo.institution,
          isDeletable: true,
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  /// 보호자 카드
  Widget _buildCaretakerCard(
    BuildContext context,
    String name,
    String email, {
    bool isDeletable = false,
  }) {
    return GenericInfoCard.withIcon(
      icon: Icons.person,
      iconColor: AppColors.pointGray,
      iconBackgroundColor: AppColors.pointGray.withValues(alpha: 0.1),
      title: name,
      subtitle: email,
      badge: '管理者',
      badgeColor: AppColors.pointBrown,
      trailing: _buildDeleteButton(context, name, isDeletable),
    );
  }

  /// 삭제 버튼
  Widget? _buildDeleteButton(
    BuildContext context,
    String name,
    bool isDeletable,
  ) {
    if (!isDeletable || !isEditMode) return null;

    return IconButton(
      icon: const Icon(
        Icons.delete,
        size: BasicInfoConstants.editIconSize,
        color: Colors.red,
      ),
      onPressed: () => _showDeleteCaretakerDialog(context, name),
    );
  }

  /// 빈 보호자 카드
  Widget _buildEmptyCaretakerCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: _buildEmptyCardDecoration(),
      child: _buildEmptyCardContent(),
    );
  }

  /// 빈 카드 디코레이션
  BoxDecoration _buildEmptyCardDecoration() {
    return BoxDecoration(
      color: AppColors.pointGray.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(BasicInfoConstants.cardBorderRadius),
      border: Border.all(
        color: AppColors.pointGray.withValues(alpha: 0.2),
        style: BorderStyle.solid,
      ),
    );
  }

  /// 빈 카드 컨텐츠
  Widget _buildEmptyCardContent() {
    return Row(
      children: [
        const Icon(
          Icons.person_add,
          color: AppColors.pointGray,
          size: BasicInfoConstants.smallIconSize,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '家族情報がありません',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
        ),
      ],
    );
  }

  /// 보호자 삭제 다이얼로그 표시
  void _showDeleteCaretakerDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteDialog(context, name),
    );
  }

  /// 삭제 다이얼로그 구성
  Widget _buildDeleteDialog(BuildContext context, String name) {
    return AlertDialog(
      title: const Text('家族情報を削除'),
      content: Text('$name の家族情報を削除しますか？'),
      actions: [
        _buildCancelButton(context),
        _buildDeleteConfirmButton(context),
      ],
    );
  }

  /// 취소 버튼
  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('キャンセル'),
    );
  }

  /// 삭제 확인 버튼
  Widget _buildDeleteConfirmButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleDeleteCaretaker(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      child: const Text('削除'),
    );
  }

  /// 보호자 삭제 처리
  void _handleDeleteCaretaker(BuildContext context) {
    _deleteCaretaker(context);
    Navigator.pop(context);
  }

  /// 보호자 삭제 실행
  void _deleteCaretaker(BuildContext context) {
    // TODO: 실제 삭제 로직 구현
    // 현재는 UI에서만 제거하고, 실제 데이터 삭제는 추후 구현
    _showDeleteSuccessMessage(context);
  }

  /// 삭제 성공 메시지 표시
  void _showDeleteSuccessMessage(BuildContext context) {
    SnackBarService.showSuccess(context, '家族情報を削除しました');
  }
}
