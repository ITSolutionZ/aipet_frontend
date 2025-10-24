import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helpers/helpers.dart';
import '../constants/basic_info_constants.dart';
import '../controllers/pet_basic_info_controller.dart';

/// 프로필 이미지 섹션
///
/// 프로필 이미지, 변경 버튼, 펫 이름 카드를 표시
class ProfileImageSection extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;
  final String tabId;

  const ProfileImageSection({
    super.key,
    required this.pet,
    required this.isEditMode,
    required this.tabId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(petBasicInfoControllerProvider(tabId));
    final displayImagePath = tabState.selectedImagePath ?? pet.imagePath;

    return Column(
      children: [
        _buildProfileImageContainer(displayImagePath),
        if (isEditMode) _buildImageChangeButton(context, ref),
        const SizedBox(height: AppSpacing.md),
        _buildPetNameWithChipCard(),
      ],
    );
  }

  /// 프로필 이미지 컨테이너
  Widget _buildProfileImageContainer(String? displayImagePath) {
    return Container(
      width: BasicInfoConstants.profileImageSize,
      height: BasicInfoConstants.profileImageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.pointGray.withValues(alpha: 0.3),
          width: BasicInfoConstants.borderWidth,
        ),
      ),
      child: ClipOval(
        child: displayImagePath != null
            ? PetInfoImageHelper.buildImageWidget(displayImagePath)
            : _buildDefaultImagePlaceholder(),
      ),
    );
  }

  /// 기본 이미지 플레이스홀더
  Widget _buildDefaultImagePlaceholder() {
    return Container(
      color: AppColors.pointGray.withValues(alpha: 0.2),
      child: const Icon(
        Icons.pets,
        size: BasicInfoConstants.iconSize,
        color: AppColors.pointGray,
      ),
    );
  }

  /// 이미지 변경 버튼
  Widget _buildImageChangeButton(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: () => PetInfoImageHelper.showChangeProfileImageModal(
            context,
            ref,
            tabId,
            pet.id,
          ),
          icon: const Icon(Icons.camera_alt),
          label: const Text(BasicInfoConstants.changePhotoButton),
        ),
      ],
    );
  }

  /// 펫 이름과 칩 정보 카드
  Widget _buildPetNameWithChipCard() {
    final registrationNumber = _getRegistrationNumber();
    final isRegistered = registrationNumber.isNotEmpty;

    return GenericInfoCard.withIcon(
      icon: Icons.pets,
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
      title: pet.name,
      subtitle: '${pet.type} • ${pet.breed}',
      badge: pet.gender,
      badgeColor: _getGenderBadgeColor(),
      trailing: _buildRegistrationStatusWidget(isRegistered),
    );
  }

  /// 등록번호 가져오기
  String _getRegistrationNumber() {
    return pet.additionalInfo?['registrationNumber']?.toString() ?? '';
  }

  /// 성별 배지 색상
  Color _getGenderBadgeColor() {
    return pet.gender == 'Male' ? AppColors.pointBlue : AppColors.pointPink;
  }

  /// 등록 상태 위젯
  Widget _buildRegistrationStatusWidget(bool isRegistered) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.memory,
          size: BasicInfoConstants.editIconSize,
          color: isRegistered ? AppColors.pointGreen : AppColors.pointGray,
        ),
        const SizedBox(height: 2),
        Text(
          isRegistered ? '登録済み' : '未登録',
          style: AppFonts.bodySmall.copyWith(
            color: isRegistered ? AppColors.pointGreen : AppColors.pointGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
