import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/providers/providers.dart';
import '../widgets/pet_registor_widgets.dart';
import 'date_picker_screen.dart';

class PetAnniversaryScreen extends ConsumerStatefulWidget {
  const PetAnniversaryScreen({super.key});

  @override
  ConsumerState<PetAnniversaryScreen> createState() =>
      _PetAnniversaryScreenState();
}

class _PetAnniversaryScreenState extends ConsumerState<PetAnniversaryScreen> {
  String _selectedCardType = 'birthday'; // 'birthday' 또는 'arrival'

  /// 선택된 펫 이미지 경로 가져오기
  String _getPetImagePath() {
    final registrationState = ref.read(petRegistrationStateProvider);
    final petType = registrationState.selectedPetType;
    final breed = registrationState.currentBreed;

    if (petType == 'dog') {
      switch (breed) {
        case 'shiba':
          return 'assets/images/dogs/shiba.png';
        case 'poodle':
          return 'assets/images/dogs/poodle.jpg';
        case 'pomeranian':
          return 'assets/images/dogs/pomeranian.png';
        case 'dachshund':
          return 'assets/images/dogs/dachshund.png';
        case 'chiwawa':
          return 'assets/images/dogs/chiwawa.png';
        case 'mixed':
          return 'assets/images/dogs/mixed.png';
        default:
          return 'assets/images/dogs/dogs.png';
      }
    } else if (petType == 'cat') {
      return 'assets/images/cats/cat.png';
    }

    return 'assets/images/pets/default.png';
  }

  /// 나이 계산
  String _calculateAge() {
    final registrationState = ref.read(petRegistrationStateProvider);
    final birthday = registrationState.petBirthday;

    if (birthday == null) return '';

    final now = DateTime.now();

    int years = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      years--;
    }

    return '$years才';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: SoftGradientAppBar(
        title: 'ペットとの記念日は？',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.go(RouteConstants.petSizeWeightRoute);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 프로그레스바
                    const PetRegistrationProgressBar(currentStep: 5),
                    const SizedBox(height: AppSpacing.lg),

                    // 제목
                    Consumer(
                      builder: (context, ref, child) {
                        final registrationState = ref.watch(
                          petRegistrationStateProvider,
                        );
                        final petName = registrationState.petName ?? 'ぺこ';

                        return Text(
                          '$petNameの記念日は？',
                          style: AppFonts.titleLarge.copyWith(
                            color: AppColors.pointBrown,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // 펫 이미지
                    PetImageDisplay(
                      imagePath: _getPetImagePath(),
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // 기념일 카드들
                    Consumer(
                      builder: (context, ref, child) {
                        final registrationState = ref.watch(
                          petRegistrationStateProvider,
                        );

                        return Column(
                          children: [
                            AnniversarySelectionCard(
                              type: 'birthday',
                              title: '誕生日',
                              icon: Icons.cake,
                              selectedDate: registrationState.petBirthday,
                              badge:
                                  registrationState.petBirthday != null &&
                                      _calculateAge().isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.pointPink,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        _calculateAge(),
                                        style: AppFonts.bodySmall.copyWith(
                                          color: AppColors.pureWhite,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedCardType = 'birthday';
                                });
                                _navigateToDatePicker();
                              },
                            ),
                            AnniversarySelectionCard(
                              type: 'arrival',
                              title: '帰宅日',
                              icon: Icons.home,
                              selectedDate: registrationState.petArrivalDate,
                              onTap: () {
                                setState(() {
                                  _selectedCardType = 'arrival';
                                });
                                _navigateToDatePicker();
                              },
                            ),
                          ],
                        );
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

                    return NextButton(
                      text: '選択', // 기념일 화면은 항상 등록 확인으로 가므로 항상 '選택'
                      isEnabled: registrationState.petBirthday != null,
                      onPressed: registrationState.petBirthday != null
                          ? () {
                              context.go(
                                RouteConstants.petAnniversarySummaryRoute,
                              );
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

  /// 날짜 선택 화면으로 이동
  void _navigateToDatePicker() {
    final registrationState = ref.read(petRegistrationStateProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DatePickerScreen(
          selectedBirthday: registrationState.petBirthday,
          selectedArrivalDate: registrationState.petArrivalDate,
          initialTab: _selectedCardType,
          onDateSelected: (date, tabType) {
            // Provider에 직접 저장
            final registrationNotifier = ref.read(
              petRegistrationStateProvider.notifier,
            );
            if (tabType == 'birthday') {
              registrationNotifier.setPetBirthday(date);
            } else {
              registrationNotifier.setPetArrivalDate(date);
            }
          },
        ),
      ),
    );
  }
}
