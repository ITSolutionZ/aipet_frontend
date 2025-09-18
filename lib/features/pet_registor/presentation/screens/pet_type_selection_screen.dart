import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/providers/pet_registration_provider.dart';
import '../constants/pet_registration_texts.dart';
import '../widgets/widgets.dart';

class PetTypeSelectionScreen extends ConsumerStatefulWidget {
  const PetTypeSelectionScreen({super.key});

  @override
  ConsumerState<PetTypeSelectionScreen> createState() =>
      _PetTypeSelectionScreenState();
}

class _PetTypeSelectionScreenState
    extends ConsumerState<PetTypeSelectionScreen> {
  bool _showMicrochipBanner = false;


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
            MicrochipModalHandlerWidget(
              petType: petRegistrationState.selectedPetType,
              showModal: _showMicrochipBanner,
              onDismiss: () {
                setState(() {
                  _showMicrochipBanner = false;
                });
              },
            ),

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
                    PetTypeGridWidget(
                      selectedPetType: petRegistrationState.selectedPetType,
                      onPetTypeSelected: (petType) {
                        petRegistrationNotifier.selectPetType(petType);

                        setState(() {
                          _showMicrochipBanner =
                              (petType == 'dog' || petType == 'cat');
                        });
                      },
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
