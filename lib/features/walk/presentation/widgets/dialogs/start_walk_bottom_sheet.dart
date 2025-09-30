import 'package:aipet_frontend/features/walk/presentation/controllers/start_walk_form_controller.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/start_walk_info_section.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/start_walk_pet_selector.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StartWalkBottomSheet extends ConsumerWidget {
  final WalkController controller;

  const StartWalkBottomSheet({super.key, required this.controller});

  static Future<void> show(BuildContext context, WalkController controller) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      builder: (context) => StartWalkBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(startWalkFormProvider);
    final formController = ref.read(startWalkFormProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large),
          topRight: Radius.circular(AppRadius.large),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          // const 사용 불가: MediaQuery.of(context) 호출 필요
        ),
        // Padding 위젯을 SingleChildScrollView로 감싸서, viewInsets.bottom 동적 적용
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 헤더 섹션
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.pointBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                    child: const Icon(Icons.directions_walk, size: 32, color: AppColors.pointBlue),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '新しい散歩を始める',
                    style: AppFonts.fredoka(fontSize: AppFonts.xxl, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '愛犬との楽しい散歩時間を記録しましょう',
                    style: AppFonts.base(fontSize: AppFonts.sm, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),

              // 입력 섹션
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 산책 제목
                  Text(
                    '散歩のタイトル',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.lg,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WalkFormFields.buildTitleField(
                    initialValue: formState.title,
                    onChanged: (value) => formController.updateTitle(value ?? ''),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'タイトルを入力してください。';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 펫 선택
                  Text(
                    'ペットを選択',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.lg,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  StartWalkPetSelector(
                    selectedPetId: formState.selectedPetId,
                    onSelectPet: formController.selectPet,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 散歩 정보
                  const StartWalkInfoSection(),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // 버튼 섹션
              _buildActionButtons(context, ref, formState, formController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    StartWalkFormState formState,
    StartWalkFormController formController,
  ) {
    return Container(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close),
              label: const Text('キャンセル'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.pointGray,
                side: const BorderSide(color: AppColors.pointGray),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: formController.isFormValid() ? () => _startWalk(context, formState) : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('散歩を始める'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startWalk(BuildContext context, StartWalkFormState formState) async {
    if (formState.title.trim().isEmpty) return;

    final result = await controller.startNewWalk(
      title: formState.title,
      petId: formState.selectedPetId,
      petName: formState.selectedPetId == 'pet1' ? 'Maxi' : 'Luna',
      petImage: 'assets/images/dogs/shiba.png',
    );

    if (result.isSuccess && context.mounted) {
      context.pop();
      UiService.showSuccess(context, result.message);
    } else if (context.mounted) {
      UiService.showError(context, result.message);
    }
  }
}
