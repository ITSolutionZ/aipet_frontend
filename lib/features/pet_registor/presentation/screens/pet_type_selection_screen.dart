import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/providers/microchip_service_provider.dart';
import '../../data/providers/pet_registration_provider.dart';
import '../constants/pet_registration_texts.dart';
import '../widgets/next_button.dart';
import '../widgets/pet_type_card.dart';

class PetTypeSelectionScreen extends ConsumerStatefulWidget {
  const PetTypeSelectionScreen({super.key});

  @override
  ConsumerState<PetTypeSelectionScreen> createState() =>
      _PetTypeSelectionScreenState();
}

class _PetTypeSelectionScreenState
    extends ConsumerState<PetTypeSelectionScreen> {
  bool _showMicrochipBanner = false;

  late final List<Map<String, dynamic>> _petTypes;

  @override
  void initState() {
    super.initState();
    _petTypes = _getPetTypesData();
  }

  /// 마이크로칩 모달 표시
  Widget _showMicrochipModal(String? petType) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MicrochipRegistrationBanner.showModal(
        context,
        petType: petType,
        onRegisterTap: () async {
          try {
            final microchipService = ref.read(microchipServiceProvider);
            await microchipService.openRegistrationSite();
          } catch (e) {
            // URL을 열 수 없는 경우 에러 처리
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('URLが開けません')));
            }
          }
        },
        onDismiss: () {
          // 모달 닫기 기능
          setState(() {
            _showMicrochipBanner = false;
          });
        },
      );
    });
    return const SizedBox.shrink();
  }

  /// 7단계 프로그레스바 생성
  Widget _buildProgressBar() {
    const int totalSteps = 7;
    const int currentStep = 1; // 첫 번째 페이지

    return Container(
      width: double.infinity,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.pointGray.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: currentStep / totalSteps,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.pointPink,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// 펫 타입 데이터 생성
  List<Map<String, dynamic>> _getPetTypesData() {
    return [
      {
        'type': 'dog',
        'imagePath': 'assets/images/pet_selector/dog.png',
        'color': AppColors.pointPink,
      },
      {
        'type': 'cat',
        'imagePath': 'assets/images/pet_selector/cat.png',
        'color': AppColors.pointPink,
      },
      {
        'type': 'rabbit',
        'imagePath': 'assets/images/pet_selector/rabbit.png',
        'color': AppColors.pointPink,
      },
      {
        'type': 'hamster',
        'imagePath': 'assets/images/pet_selector/hamster.png',
        'color': AppColors.pointPink,
      },
      {
        'type': 'bird',
        'imagePath': 'assets/images/pet_selector/bird.png',
        'color': AppColors.pointPink,
      },
      {
        'type': 'turtle',
        'imagePath': 'assets/images/pet_selector/turtle.png',
        'color': AppColors.pointPink,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final petRegistrationState = ref.watch(petRegistrationStateProvider);
    final petRegistrationNotifier = ref.read(
      petRegistrationStateProvider.notifier,
    );

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: const SoftGradientAppBar(
        title: PetRegistrationTexts.petTypeSelection,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 마이크로칩 등록 모달 (개, 고양이 선택 시에만 표시)
            if (_showMicrochipBanner)
              _showMicrochipModal(petRegistrationState.selectedPetType),

            // 스크롤 가능한 상단 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로그레스바
                    _buildProgressBar(),
                    const SizedBox(height: AppSpacing.lg),

                    // 제목
                    Text(
                      PetRegistrationTexts.whoDoYouLiveWith,
                      style: AppFonts.titleLarge.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // 설명 제거 (디자인에 없음)
                    const SizedBox(height: AppSpacing.xl),

                    // 펫 종류 선택 카드들
                    SizedBox(
                      height: 400, // 고정 높이 설정
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                              childAspectRatio: 1.0, // 정사각형으로 변경
                            ),
                        itemCount: _petTypes.length,
                        itemBuilder: (context, index) {
                          final petType = _petTypes[index];
                          final isSelected =
                              petRegistrationState.selectedPetType ==
                              petType['type'];

                          return PetTypeCard(
                            imagePath: petType['imagePath'],
                            color: petType['color'],
                            isSelected: isSelected,
                            onTap: () {
                              petRegistrationNotifier.selectPetType(
                                petType['type'],
                              );

                              setState(() {
                                // 개나 고양이를 선택했을 때만 마이크로칩 배너 표시
                                _showMicrochipBanner =
                                    (petType['type'] == 'dog' ||
                                    petType['type'] == 'cat');
                              });
                            },
                          );
                        },
                      ),
                    ),

                    // 종류가 없다 버튼
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // 종류가 없는 경우 처리 (예: 커스텀 입력 화면으로 이동)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                PetRegistrationTexts.customPetTypeComingSoon,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                          ),
                          side: BorderSide(
                            color: AppColors.pointGray.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          PetRegistrationTexts.noTypeAvailable,
                          style: AppFonts.titleMedium.copyWith(
                            color: AppColors.pointGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 하단 고정 버튼 영역
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                border: Border(
                  top: BorderSide(
                    color: AppColors.pointGray.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Consumer(
                  builder: (context, ref, child) {
                    final registrationState = ref.watch(
                      petRegistrationStateProvider,
                    );
                    final hasDataBeyond = registrationState.hasDataBeyondStep(
                      1,
                    );

                    return NextButton(
                      text: hasDataBeyond ? '選択' : null,
                      isEnabled: registrationState.selectedPetType != null,
                      onPressed: registrationState.selectedPetType != null
                          ? () {
                              // 등록이 완료된 상태라면 등록확인 페이지로
                              if (registrationState.isRegistrationComplete) {
                                context.go(
                                  RouteConstants.petAnniversarySummaryRoute,
                                );
                                return;
                              }

                              // 다음 단계로 이동
                              if (registrationState.selectedPetType == 'dog') {
                                context.go(
                                  RouteConstants.dogBreedSelectionRoute,
                                );
                              } else if (registrationState.selectedPetType ==
                                  'cat') {
                                context.go(
                                  RouteConstants.catBreedSelectionRoute,
                                );
                              } else {
                                // 강아지나 고양이가 아닌 경우 이름 입력으로 바로 이동
                                context.go(RouteConstants.petNameInputRoute);
                              }
                            }
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
