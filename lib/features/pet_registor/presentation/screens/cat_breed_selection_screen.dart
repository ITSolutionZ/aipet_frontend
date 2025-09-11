import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';
import '../widgets/next_button.dart';

class CatBreedSelectionScreen extends ConsumerStatefulWidget {
  const CatBreedSelectionScreen({super.key});

  @override
  ConsumerState<CatBreedSelectionScreen> createState() =>
      _CatBreedSelectionScreenState();
}

class _CatBreedSelectionScreenState
    extends ConsumerState<CatBreedSelectionScreen> {
  String? _selectedBreed;

  late final List<Map<String, dynamic>> _catBreeds;

  @override
  void initState() {
    super.initState();
    _catBreeds = _getCatBreedsData();
  }

  /// 고양이 품종 데이터 생성
  List<Map<String, dynamic>> _getCatBreedsData() {
    return [
      {
        'breed': 'maine_coon',
        'name': 'メインクーン',
        'imagePath': 'assets/images/cats/maine_coon.png',
      },
      {
        'breed': 'persian',
        'name': 'ペルシャ',
        'imagePath': 'assets/images/cats/persian.png',
      },
      {
        'breed': 'british_shorthair',
        'name': 'ブリティッシュショートヘア',
        'imagePath': 'assets/images/cats/british_shorthair.png',
      },
      {
        'breed': 'scottish_fold',
        'name': 'スコティッシュフォールド',
        'imagePath': 'assets/images/cats/scottish_fold.png',
      },
      {
        'breed': 'ragdoll',
        'name': 'ラグドール',
        'imagePath': 'assets/images/cats/ragdoll.png',
      },
      {
        'breed': 'american_shorthair',
        'name': 'アメリカンショートヘア',
        'imagePath': 'assets/images/cats/american_shorthair.png',
      },
      {
        'breed': 'russian_blue',
        'name': 'ロシアンブルー',
        'imagePath': 'assets/images/cats/russian_blue.png',
      },
      {
        'breed': 'mixed',
        'name': 'ミックス',
        'imagePath': 'assets/images/cats/mixed.png',
      },
    ];
  }

  /// 7단계 프로그레스바 생성
  Widget _buildProgressBar() {
    const int totalSteps = 7;
    const int currentStep = 2; // 두 번째 페이지

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 프로그레스바
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.pointGray.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: currentStep / totalSteps,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.pointPink,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: SoftGradientAppBar(
        title: '猫の種類を選択',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // 이전 페이지로 이동 (펫 타입 선택)
            context.go(RouteConstants.petTypeSelectionRoute);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로그레스바
                _buildProgressBar(),
                const SizedBox(height: AppSpacing.lg),

                // 제목
                Text(
                  'どの種類の猫ですか？',
                  style: AppFonts.titleLarge.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // 고양이 품종 선택 카드들
                SizedBox(
                  height: 500,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: _catBreeds.length,
                    itemBuilder: (context, index) {
                      final catBreed = _catBreeds[index];
                      final isSelected = _selectedBreed == catBreed['breed'];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBreed = catBreed['breed'];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.pointPink.withValues(alpha: 0.1)
                                : AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(
                              AppRadius.large,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.pointPink
                                  : AppColors.pointGray.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.pointDark.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 고양이 이미지
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.pointGray.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.medium,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.medium,
                                    ),
                                    child: Image.asset(
                                      catBreed['imagePath'],
                                      scale: 0.6,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.pets,
                                              size: 40,
                                              color: AppColors.pointPink,
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              // 품종 이름
                              Text(
                                catBreed['name'],
                                style: AppFonts.bodyMedium.copyWith(
                                  color: AppColors.pointDark,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 하단 버튼
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: NextButton(
                    isEnabled: _selectedBreed != null,
                    onPressed: _selectedBreed != null
                        ? () {
                            // 다음 단계로 이동 (이름 입력)
                            context.go(RouteConstants.petNameInputRoute);
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
