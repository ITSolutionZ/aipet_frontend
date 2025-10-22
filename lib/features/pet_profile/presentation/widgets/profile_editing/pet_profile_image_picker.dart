import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_form_controller.dart';
import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Pet Profile 이미지 선택 다이얼로그
class PetProfileImagePicker {
  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImagePickerBottomSheet(ref: ref),
    );
  }
}

class _ImagePickerBottomSheet extends StatelessWidget {
  final WidgetRef ref;

  const _ImagePickerBottomSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.pointOffWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large),
          topRight: Radius.circular(AppRadius.large),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들 바
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.pointDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 타이틀
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                '프로필 이미지 선택',
                style: AppFonts.headlineSmall.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 옵션들
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                children: [
                  // 갤러리에서 선택
                  _buildOptionTile(
                    context,
                    icon: Icons.photo_library,
                    title: '갤러리에서 선택',
                    subtitle: '디바이스에서 이미지를 선택합니다',
                    onTap: () {
                      Navigator.pop(context);
                      _selectFromGallery(context);
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // 카메라로 촬영
                  _buildOptionTile(
                    context,
                    icon: Icons.camera_alt,
                    title: '카메라로 촬영',
                    subtitle: '새로운 사진을 촬영합니다',
                    onTap: () {
                      Navigator.pop(context);
                      _takePhoto(context);
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // 기본 이미지 선택
                  _buildOptionTile(
                    context,
                    icon: Icons.pets,
                    title: '기본 이미지 선택',
                    subtitle: '미리 설정된 이미지를 선택합니다',
                    onTap: () {
                      Navigator.pop(context);
                      _selectDefaultImage(context);
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 취소 버튼
                  CommonButton(
                    text: '취소',
                    type: ButtonType.outline,
                    size: ButtonSize.large,
                    width: double.infinity,
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.pointDark.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(icon, color: AppColors.pointBrown, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.pointDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    subtitle,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointDark.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.pointDark),
          ],
        ),
      ),
    );
  }

  void _selectFromGallery(BuildContext context) async {
    // 실제 갤러리 선택 구현
    final formController = ref.read(petProfileFormControllerProvider.notifier);

    try {
      // image_picker 패키지를 사용한 갤러리 선택
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // 선택된 이미지 경로 업데이트
        formController.updateImagePath(image.path);

        // 성공 메시지 표시
        if (context.mounted) {
          // ✅ Shared SnackBarService 사용
          SnackBarService.showSuccess(
            context,
            '画像を選択しました',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (error) {
      // 에러 처리
      if (context.mounted) {
        // ✅ Shared SnackBarService 사용
        SnackBarService.showError(context, '画像の選択に失敗しました: $error');
      }
    }
  }

  void _takePhoto(BuildContext context) async {
    // 실제 카메라 촬영 구현
    final formController = ref.read(petProfileFormControllerProvider.notifier);

    try {
      // image_picker 패키지를 사용한 카메라 촬영
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // 촬영된 이미지 경로 업데이트
        formController.updateImagePath(image.path);

        // 성공 메시지 표시
        if (context.mounted) {
          // ✅ Shared SnackBarService 사용
          SnackBarService.showSuccess(
            context,
            '写真を撮影しました',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (error) {
      // 에러 처리
      if (context.mounted) {
        // ✅ Shared SnackBarService 사용
        SnackBarService.showError(context, '写真の撮影に失敗しました: $error');
      }
    }
  }

  void _selectDefaultImage(BuildContext context) {
    final formController = ref.read(petProfileFormControllerProvider.notifier);

    // 기본 이미지 목록
    final defaultImages = [
      'assets/images/pets/dog_1.png',
      'assets/images/pets/dog_2.png',
      'assets/images/pets/cat_1.png',
      'assets/images/pets/cat_2.png',
      'assets/images/pets/bird_1.png',
      'assets/images/pets/hamster_1.png',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기본 이미지 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
            ),
            itemCount: defaultImages.length,
            itemBuilder: (context, index) {
              final imagePath = defaultImages[index];
              return GestureDetector(
                onTap: () {
                  formController.updateImagePath(imagePath);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(
                      color: AppColors.pointBrown.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.pointOffWhite,
                          child: const Icon(
                            Icons.pets,
                            color: AppColors.pointBrown,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}
