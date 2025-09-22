import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../../data/providers/providers.dart';
import '../../domain/utils/pet_registration_converter.dart';
import '../widgets/pet_registor_widgets.dart';

class PetRegistrationCompleteScreen extends ConsumerStatefulWidget {
  const PetRegistrationCompleteScreen({super.key});

  @override
  ConsumerState<PetRegistrationCompleteScreen> createState() =>
      _PetRegistrationCompleteScreenState();
}

class _PetRegistrationCompleteScreenState
    extends ConsumerState<PetRegistrationCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // 펫 등록 완료 시 펫 저장
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _savePetToSystem();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? _createdPetId;

  /// 펫을 시스템에 저장
  void _savePetToSystem() async {
    try {
      final registrationState = ref.read(petRegistrationStateProvider);

      // 등록 데이터가 유효한지 확인
      if (!PetRegistrationConverter.isValidForRegistration(registrationState)) {
        return;
      }

      // PetRegistrationData를 PetProfileEntity로 변환
      final petProfile = PetRegistrationConverter.convertToProfile(
        registrationState,
      );

      // PetsNotifier를 통해 펫 생성
      final petsNotifier = ref.read(petsNotifierProvider.notifier);
      final createdPet = await petsNotifier.createPet(petProfile);

      // 생성된 펫 ID 저장
      setState(() {
        _createdPetId = createdPet.id;
      });
    } catch (e) {
      // 실제 앱에서는 사용자에게 오류 메시지를 표시해야 함
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(petRegistrationStateProvider);
    final petName = registrationState.petName ?? 'ペット';

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 성공 아이콘
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.pointPink.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              size: 60,
                              color: AppColors.pointPink,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // 완료 메시지
                          Text(
                            '登録完了！',
                            style: AppFonts.headlineMedium.copyWith(
                              color: AppColors.pointDark,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          Text(
                            '$petNameの登録が完了しました',
                            style: AppFonts.titleLarge.copyWith(
                              color: AppColors.pointDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Text(
                            'プロフィールページで詳細を\n確認できます',
                            style: AppFonts.bodyLarge.copyWith(
                              color: AppColors.pointGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // 펫 이미지
                          PetImageDisplay(
                            imagePath: _getPetImagePath(),
                            width: 180,
                            height: 180,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 하단 버튼 영역
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
                    child: Column(
                      children: [
                        // 프로필 보기 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // 상태 초기화 후 펫 프로필 페이지로 이동
                              ref
                                  .read(petRegistrationStateProvider.notifier)
                                  .reset();
                              if (_createdPetId != null) {
                                context.go(
                                  '/home/pet-profile?petId=$_createdPetId',
                                );
                              } else {
                                context.go('/home/pet-profile');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pointPink,
                              foregroundColor: AppColors.pureWhite,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.lg,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.medium,
                                ),
                              ),
                              elevation: 2,
                              shadowColor: AppColors.pointPink.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            child: Text(
                              'プロフィールを見る',
                              style: AppFonts.titleMedium.copyWith(
                                color: AppColors.pureWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // 홈으로 돌아가기 버튼
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              // 상태 초기화 후 홈으로 이동
                              ref
                                  .read(petRegistrationStateProvider.notifier)
                                  .reset();
                              context.go('/home');
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.lg,
                              ),
                            ),
                            child: Text(
                              'ホームに戻る',
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
