import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';

class PetTypeSelectionScreen extends ConsumerStatefulWidget {
  const PetTypeSelectionScreen({super.key});

  @override
  ConsumerState<PetTypeSelectionScreen> createState() =>
      _PetTypeSelectionScreenState();
}

class _PetTypeSelectionScreenState
    extends ConsumerState<PetTypeSelectionScreen> {
  String? _selectedType;

  late final List<Map<String, dynamic>> _petTypes;

  @override
  void initState() {
    super.initState();
    _petTypes = MockDataService.getMockPetTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          '펫 종류 선택',
          style: AppFonts.titleMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                '今、誰と暮らしていますか?',
                style: AppFonts.titleLarge.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // 설명 제거 (디자인에 없음)
              const SizedBox(height: AppSpacing.xl),

              // 펫 종류 선택 카드들
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.0, // 정사각형으로 변경
                  ),
                  itemCount: _petTypes.length,
                  itemBuilder: (context, index) {
                    final petType = _petTypes[index];
                    final isSelected = _selectedType == petType['type'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = petType['type'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? petType['color'].withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.large),
                          border: Border.all(
                            color: isSelected
                                ? petType['color']
                                : Colors.grey.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 펫 이미지 (임시로 아이콘 사용)
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.medium,
                                  ),
                                ),
                                child: Icon(
                                  petType['icon'],
                                  size: 40,
                                  color: petType['color'],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // 이름
                            Expanded(
                              flex: 1,
                              child: Text(
                                petType['name'],
                                style: AppFonts.titleMedium.copyWith(
                                  color: AppColors.pointDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 선택 표시
                            if (isSelected) ...[
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: petType['color'],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 다음 버튼
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedType != null
                      ? () {
                          // 다음 단계로 이동
                          if (_selectedType == 'dog') {
                            context.go(RouteConstants.dogBreedSelectionRoute);
                          } else {
                            // 강아지가 아닌 경우 이름 입력으로 바로 이동
                            context.go(RouteConstants.petNameInputRoute);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                  ),
                  child: Text(
                    '다음',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.lg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
