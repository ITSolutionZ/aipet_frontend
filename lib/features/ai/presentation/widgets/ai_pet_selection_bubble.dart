import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../../pet_registor/pet_registor.dart';

/// AI 메시지 버블 형태의 펫 선택 위젯
class AiPetSelectionBubble extends ConsumerWidget {
  final PetProfileEntity? selectedPet;
  final Function(PetProfileEntity?) onPetSelected;

  const AiPetSelectionBubble({
    super.key,
    this.selectedPet,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 아바타
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.pointBrown,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icons/logo_notinclude_text.png',
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 메시지 버블
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AppRadius.medium,
                ).copyWith(bottomLeft: Radius.zero),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AI 메시지 텍스트
                  Text(
                    'こんにちは！私はペット専門のAIアシスタントです。🐶 🐱',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'ペットに関連する内容をより具体的にご質問ください',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    '以下のような内容についてご質問ください：',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // 질문 예시 목록
                  _buildQuestionExample('• ペットの健康と病気について'),
                  _buildQuestionExample('• フードと栄養管理'),
                  _buildQuestionExample('• 行動矯正とトレーニング'),
                  _buildQuestionExample('• グルーミングとケア'),
                  _buildQuestionExample('• ペット用品と環境'),

                  const SizedBox(height: AppSpacing.md),

                  // 펫 선택 질문
                  Text(
                    'どのペットについて相談しますか？',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 펫 선택 위젯
                  Consumer(
                    builder: (context, ref, child) {
                      final petsAsync = ref.watch(petsNotifierProvider);
                      return petsAsync.when(
                        data: (pets) => _buildPetSelection(pets),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => _buildPetSelection([]),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // 타임스탬프
                  Text(
                    '今',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionExample(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: AppFonts.bodyMedium.copyWith(
          color: AppColors.pointGray,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildPetSelection(List<PetProfileEntity> pets) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pets.isNotEmpty)
          _buildPetSelectionGrid(pets)
        else
          _buildNoPetsCard(),

        const SizedBox(height: AppSpacing.sm),
        _buildGeneralConsultationOption(),
      ],
    );
  }

  Widget _buildNoPetsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.pointBrown.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pets_outlined,
            size: 48,
            color: AppColors.pointBrown.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '登録されたペットがありません',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'ペットを登録すると、より具体的な\nアドバイスが受けられます',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelectionGrid(List<PetProfileEntity> pets) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: pets.map((pet) => _buildPetChip(pet)).toList(),
    );
  }

  Widget _buildPetChip(PetProfileEntity pet) {
    final isSelected = selectedPet?.id == pet.id;

    return GestureDetector(
      onTap: () => onPetSelected(isSelected ? null : pet),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pointBrown : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected
                ? AppColors.pointBrown
                : AiColors.selectedBorderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AiColors.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pet.imagePath != null && pet.imagePath!.isNotEmpty)
              CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage(pet.imagePath!),
              )
            else
              Icon(
                pet.typeIcon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.pointBrown,
              ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pet.name,
                  style: AppFonts.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${pet.typeName} • ${pet.age}歳',
                  style: AppFonts.bodySmall.copyWith(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralConsultationOption() {
    final isGeneralSelected = selectedPet == null;

    return GestureDetector(
      onTap: () => onPetSelected(null),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isGeneralSelected
              ? AiColors.petSelectionBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isGeneralSelected
                ? AppColors.pointBrown
                : AiColors.unselectedBorderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.help_outline,
              size: 20,
              color: isGeneralSelected
                  ? AppColors.pointBrown
                  : AppColors.pointDark.withValues(alpha: 0.7),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '一般的なペット相談',
              style: AppFonts.bodySmall.copyWith(
                color: isGeneralSelected
                    ? AppColors.pointBrown
                    : AppColors.pointDark.withValues(alpha: 0.8),
                fontWeight: isGeneralSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
