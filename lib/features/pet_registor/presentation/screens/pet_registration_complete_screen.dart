// import 'package:aipet_frontend/features/pet_registor/data/providers/pet_providers.dart';
// import 'package:aipet_frontend/features/onboarding/domain/utils/pet_registration_converter.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 🎯 Mock Pet Registration State Provider for Migration
final petRegistrationStateProvider = StateNotifierProvider<MockPetRegistrationController, String?>(
  (ref) => MockPetRegistrationController(),
);

class MockPetRegistrationController extends StateNotifier<String?> {
  MockPetRegistrationController() : super(null);

  void reset() {
    state = null;
  }
}

/// 🎯 Pet Registration Complete State Provider
final petRegistrationCompleteProvider =
    StateNotifierProvider<PetRegistrationCompleteController, String?>(
      (ref) => PetRegistrationCompleteController(),
    );

class PetRegistrationCompleteController extends StateNotifier<String?> {
  PetRegistrationCompleteController() : super(null);

  void setCreatedPetId(String petId) {
    state = petId;
  }

  void reset() {
    state = null;
  }
}

class PetRegistrationCompleteScreen extends ConsumerStatefulWidget {
  const PetRegistrationCompleteScreen({super.key});

  @override
  ConsumerState<PetRegistrationCompleteScreen> createState() =>
      _PetRegistrationCompleteScreenState();
}

class _PetRegistrationCompleteScreenState extends ConsumerState<PetRegistrationCompleteScreen>
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

  /// 펫을 시스템에 저장
  void _savePetToSystem() async {
    try {
      // Mock implementation since providers are not available
      await Future.delayed(const Duration(seconds: 1));

      // 임시 펫 ID 생성
      final petId = 'pet_${DateTime.now().millisecondsSinceEpoch}';

      // 생성된 펫 ID 저장
      ref.read(petRegistrationCompleteProvider.notifier).setCreatedPetId(petId);
    } catch (e) {
      // 실제 앱에서는 사용자에게 오류 메시지를 표시해야 함
    }
  }

  /// 선택된 펫 이미지 경로 가져오기
  String _getPetImagePath() {
    // Mock implementation since provider is not available
    return 'assets/images/dogs/shiba.png';
  }

  @override
  Widget build(BuildContext context) {
    final createdPetId = ref.watch(petRegistrationCompleteProvider);
    const petName = 'ペット'; // Mock name since provider is not available

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
                            style: AppFonts.titleLarge.copyWith(color: AppColors.pointDark),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Text(
                            'プロフィールページで詳細を\n確認できます',
                            style: AppFonts.bodyLarge.copyWith(color: AppColors.pointGray),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // 펫 이미지
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(_getPetImagePath()),
                                fit: BoxFit.cover,
                              ),
                            ),
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
                              ref.read(petRegistrationStateProvider.notifier).reset();
                              if (createdPetId != null) {
                                context.go('/home/pet-profile?petId=$createdPetId');
                              } else {
                                context.go('/home/pet-profile');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pointPink,
                              foregroundColor: AppColors.pureWhite,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.medium),
                              ),
                              elevation: 2,
                              shadowColor: AppColors.pointPink.withValues(alpha: 0.3),
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
                              ref.read(petRegistrationStateProvider.notifier).reset();
                              context.go('/home');
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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
