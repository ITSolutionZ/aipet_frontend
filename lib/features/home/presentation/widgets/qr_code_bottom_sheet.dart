import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/design/text_styles.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../shared/design/tokens/tokens.dart';

/// QR 코드 바텀시트 위젯 (70% 크기)
class QRCodeBottomSheet extends ConsumerStatefulWidget {
  const QRCodeBottomSheet({super.key});

  @override
  ConsumerState<QRCodeBottomSheet> createState() => _QRCodeBottomSheetState();

  /// 바텀시트 표시 헬퍼 메서드
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QRCodeBottomSheet(),
    );
  }
}

class _QRCodeBottomSheetState extends ConsumerState<QRCodeBottomSheet> {
  PetProfileEntity? selectedPet;
  bool isPetListExpanded = false;

  @override
  Widget build(BuildContext context) {
    final petsAsyncValue = ref.watch(petProfilesNotifierProvider);

    return petsAsyncValue.when(
      loading: () => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Center(child: Text('エラーが発生しました: $error')),
      ),
      data: (pets) {
        // 첫 로드 시 첫 번째 펫 선택
        if (selectedPet == null && pets.isNotEmpty) {
          selectedPet = pets.first;
        }

        if (pets.isEmpty) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: const Center(child: Text('登録されたペットがありません')),
          );
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // 헤더 (제목 + 닫기 버튼)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40), // 균형 맞추기
                    Text(
                      'ペットコード',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // 구분선
              Divider(height: 1, color: Colors.grey.shade300),

              // 스크롤 가능한 컨텐츠 영역
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // 설명 텍스트
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'あいぺっとは動物病院及び施設の\nQRコードリーダーに認証してください。',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 펫 선택기 (아코디언 스타일)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildPetSelector(pets),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // QR 코드
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: QrImageView(
                            data:
                                'AIPET:${selectedPet?.id}:${selectedPet?.name}:${DateTime.now().millisecondsSinceEpoch}',
                            version: QrVersions.auto,
                            size: 180,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // 하단 설명
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          '病院では受付として使用できます。\n共同保護者にQRコードをスキャンして、\nノミネートしてください。',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // 닫기 버튼 (고정)
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBrown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '閉じる',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 펫 선택기 위젯 (아코디언 스타일)
  Widget _buildPetSelector(List<PetProfileEntity> pets) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 선택된 펫 표시 (클릭 시 리스트 확장)
          InkWell(
            onTap: () {
              setState(() {
                isPetListExpanded = !isPetListExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // 프로필 사진
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.pointBrown.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: selectedPet?.imagePath != null
                        ? Image.asset(
                            selectedPet!.imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                                  'assets/icons/aipet_logo.png',
                                  fit: BoxFit.cover,
                                ),
                          )
                        : Image.asset(
                            'assets/icons/aipet_logo.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // 펫 이름
                  Expanded(
                    child: Text(
                      selectedPet?.name ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // 확장 아이콘
                  Icon(
                    isPetListExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // 펫 리스트 (확장 시에만 표시)
          if (isPetListExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade300),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: pets.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final pet = pets[index];
                final isSelected = selectedPet?.id == pet.id;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedPet = pet;
                      isPetListExpanded = false;
                    });
                  },
                  child: Container(
                    color: isSelected
                        ? AppColors.pointBrown.withValues(alpha: 0.1)
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        // 프로필 사진
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.pointBrown
                                  : AppColors.pointBrown.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: pet.imagePath != null
                              ? Image.asset(
                                  pet.imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                        'assets/icons/aipet_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                )
                              : Image.asset(
                                  'assets/icons/aipet_logo.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 12),
                        // 펫 이름
                        Expanded(
                          child: Text(
                            pet.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.pointBrown
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        // 선택 체크 아이콘
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.pointBrown,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
