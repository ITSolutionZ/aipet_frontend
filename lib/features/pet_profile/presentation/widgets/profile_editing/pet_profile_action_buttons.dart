import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_form_controller.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pet Profile 액션 버튼들 (편집, 저장, 취소)
class PetProfileActionButtons extends ConsumerWidget {
  final PetProfileEntity pet;
  final VoidCallback? onEditComplete;

  const PetProfileActionButtons({
    super.key,
    required this.pet,
    this.onEditComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(petProfileFormControllerProvider);
    final formController = ref.read(petProfileFormControllerProvider.notifier);

    if (formState.isEditMode) {
      return _buildEditModeButtons(context, formState, formController);
    } else {
      return _buildViewModeButtons(context, formController);
    }
  }

  Widget _buildViewModeButtons(
    BuildContext context,
    PetProfileFormController formController,
  ) {
    return Container(
      padding: const const const EdgeInsets.all(AppSpacing.md),
      child: CommonButton(
        text: '편집',
        icon: Icons.edit,
        type: ButtonType.primary,
        size: ButtonSize.large,
        width: double.infinity,
        onPressed: () => formController.startEdit(pet),
      ),
    );
  }

  Widget _buildEditModeButtons(
    BuildContext context,
    PetProfileFormState formState,
    PetProfileFormController formController,
  ) {
    return Container(
      padding: const const const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // 에러 메시지 표시
          if (formState.errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const const const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.pointPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(color: AppColors.pointPink),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.pointPink,
                    size: 20,
                  ),
                  const const const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      formState.errorMessage!,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointPink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const const const SizedBox(height: AppSpacing.md),
          ],

          // 액션 버튼들
          Row(
            children: [
              // 취소 버튼
              Expanded(
                child: CommonButton(
                  text: '취소',
                  type: ButtonType.outline,
                  size: ButtonSize.large,
                  onPressed: formState.isLoading
                      ? null
                      : () {
                          formController.cancelEdit();
                          onEditComplete?.call();
                        },
                ),
              ),
              const const const SizedBox(width: AppSpacing.md),

              // 저장 버튼
              Expanded(
                child: CommonButton(
                  text: '저장',
                  type: ButtonType.primary,
                  size: ButtonSize.large,
                  isLoading: formState.isLoading,
                  onPressed:
                      formState.isLoading || !formController.isFormValid()
                      ? null
                      : () async {
                          await formController.saveChanges(pet);

                          if (context.mounted && !formState.isEditMode) {
                            onEditComplete?.call();

                            // 성공 메시지 표시
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('프로필이 성공적으로 저장되었습니다.'),
                                backgroundColor: AppColors.pointGreen,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.small,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
