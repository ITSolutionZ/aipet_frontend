import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';

class DogBreedSelectionScreen extends ConsumerStatefulWidget {
  const DogBreedSelectionScreen({super.key});

  @override
  ConsumerState<DogBreedSelectionScreen> createState() =>
      _DogBreedSelectionScreenState();
}

class _DogBreedSelectionScreenState
    extends ConsumerState<DogBreedSelectionScreen> {
  String? _selectedBreed;

  late final List<Map<String, dynamic>> _dogBreeds;

  @override
  void initState() {
    super.initState();
    _dogBreeds = MockDataService.getMockDogBreeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          'どんな子ですか？',
          style: AppFonts.titleMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // 품종 목록 (3x2 그리드)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _dogBreeds.length,
                  itemBuilder: (context, index) {
                    final breed = _dogBreeds[index];
                    final isSelected = _selectedBreed == breed['breed'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBreed = breed['breed'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.pointBrown
                                : Colors.grey.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 품종 이미지 (임시로 아이콘 사용)
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.small,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.pets,
                                  size: 30,
                                  color: AppColors.pointBrown,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // 품종 이름
                            Expanded(
                              flex: 1,
                              child: Text(
                                breed['name'],
                                style: AppFonts.bodyMedium.copyWith(
                                  color: AppColors.pointDark,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            // 선택 표시
                            if (isSelected) ...[
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppColors.pointBrown,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
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
                  onPressed: _selectedBreed != null
                      ? () {
                          // 다음 단계로 이동
                          context.go(RouteConstants.petNameInputRoute);
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
                    '次へ',
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
