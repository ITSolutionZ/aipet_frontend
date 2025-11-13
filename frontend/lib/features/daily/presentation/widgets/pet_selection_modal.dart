import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../shared/shared.dart';
import '../providers/pet_selection_provider.dart';


/// 펫 선택 모달
class PetSelectionModal extends ConsumerWidget {
  const PetSelectionModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petSelectionState = ref.watch(petSelectionProvider);
    final petSelectionNotifier = ref.read(petSelectionProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ペット選択',
                  style: AppFonts.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // 전체 선택 옵션
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: InkWell(
              onTap: () {
                petSelectionNotifier.selectAllPets();
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.toneLightGray),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.pets,
                      color: AppColors.pointBrown,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      '全体',
                      style: AppFonts.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (petSelectionState.selectedPetId == null)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.pointBrown,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 펫 목록
          if (petSelectionState.isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: petSelectionState.availablePets.length,
              itemBuilder: (context, index) {
                final pet = petSelectionState.availablePets[index];
                final isSelected = petSelectionState.selectedPetId == pet.id;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: InkWell(
                    onTap: () {
                      petSelectionNotifier.selectPet(pet.id);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.pointBrown
                              : AppColors.toneLightGray,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // 펫 이미지
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.toneLightGray,
                            ),
                            child:
                                pet.imagePath != null &&
                                    pet.imagePath!.isNotEmpty
                                ? Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      pet.imagePath!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.pets,
                                    color: AppColors.pointBrown,
                                    size: 20,
                                  ),
                          ),
                          const SizedBox(width: AppSpacing.md),

                          // 펫 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet.name,
                                  style: AppFonts.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  pet.breed ?? '',
                                  style: AppFonts.bodySmall.copyWith(
                                    color: AppColors.toneDarkGray,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 선택 표시
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.pointBrown,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: AppSpacing.lg),

          // 하단 버튼들
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // 반려동물 관리 페이지로 이동
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      side: const BorderSide(color: AppColors.toneLightGray),
                    ),
                    child: Text(
                      'ペット管理',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.toneDarkGray,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBrown,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    child: Text(
                      '確認',
                      style: AppFonts.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
