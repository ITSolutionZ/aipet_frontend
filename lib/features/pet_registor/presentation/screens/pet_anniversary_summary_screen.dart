import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/pet_registor/data/providers/pet_registration_provider.dart';
import 'package:aipet_frontend/features/pet_registor/presentation/widgets/pet_registor_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PetAnniversarySummaryScreen extends ConsumerStatefulWidget {
  const PetAnniversarySummaryScreen({super.key});

  @override
  ConsumerState<PetAnniversarySummaryScreen> createState() =>
      _PetAnniversarySummaryScreenState();
}

class _PetAnniversarySummaryScreenState
    extends ConsumerState<PetAnniversarySummaryScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  /// 성별 및 중성화 상태 텍스트
  String _getGenderText() {
    final registrationState = ref.read(petRegistrationStateProvider);
    final gender = registrationState.petGender ?? 'male';
    final isNeutered = registrationState.isNeutered ?? false;

    if (gender == 'male') {
      return isNeutered ? 'オス（去勢・避妊済）' : 'オス';
    } else {
      return isNeutered ? 'メス（去勢・避妊済）' : 'メス';
    }
  }

  /// 마이크로칩 정보 텍스트
  String _getMicrochipText() {
    final registrationState = ref.read(petRegistrationStateProvider);
    final microchipNumber = registrationState.microchipNumber;

    if (microchipNumber != null && microchipNumber.isNotEmpty) {
      return microchipNumber;
    } else {
      return '未登録';
    }
  }

  /// 7단계 프로그레스바 생성
  Widget _buildProgressBar() {
    const int totalSteps = 7;
    const int currentStep = 7; // 마지막 페이지

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

  /// 펫 등록 완료 처리
  void _completePetRegistration() {
    // 펫 등록 완료 화면으로 이동 (상태는 유지)
    context.go(RouteConstants.petRegistrationCompleteRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final registrationState = ref.watch(petRegistrationStateProvider);

        return Scaffold(
          backgroundColor: AppColors.pureWhite,
          appBar: DynamicAppBarStyles.brown(
            scrollController: _scrollController,
            title: '登録確認',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                context.go(RouteConstants.petAnniversaryRoute);
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const const const EdgeInsets.all(AppSpacing.lg),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 프로그레스바
                                _buildProgressBar(),
                                const const const SizedBox(height: AppSpacing.lg),

                                // 제목
                                Text(
                                  '登録確認',
                                  style: AppFonts.titleLarge.copyWith(
                                    color: AppColors.pointBrown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const const const SizedBox(height: AppSpacing.xl),

                                // 펫 이미지
                                PetImageDisplay(
                                  imageFile: registrationState.petImagePath,
                                  imagePath:
                                      registrationState.petImagePath == null
                                      ? _getPetImagePath()
                                      : null,
                                  width: 200,
                                  height: 200,
                                ),
                                const const const SizedBox(height: AppSpacing.xl),

                                // 정보 카드들
                                PetInfoCard(
                                  title: '名前',
                                  value: registrationState.petName ?? 'Unknown',
                                  icon: Icons.pets,
                                  onTap: () => context.go(
                                    RouteConstants.petNameInputRoute,
                                  ),
                                ),
                                PetInfoCard(
                                  title: '性別',
                                  value: _getGenderText(),
                                  icon: Icons.wc,
                                  onTap: () => context.go(
                                    RouteConstants.petNameInputRoute,
                                  ),
                                ),
                                PetInfoCard(
                                  title: '誕生日',
                                  value: registrationState.petBirthday != null
                                      ? '${registrationState.petBirthday!.year}年${registrationState.petBirthday!.month}月${registrationState.petBirthday!.day}日'
                                      : '未設定',
                                  icon: Icons.cake,
                                  badge: _calculateAge().isNotEmpty
                                      ? Container(
                                          padding: const const const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.pointPink,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
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
                                  onTap: () => context.go(
                                    RouteConstants.petAnniversaryRoute,
                                  ),
                                ),
                                PetInfoCard(
                                  title: '帰宅日',
                                  value:
                                      registrationState.petArrivalDate != null
                                      ? '${registrationState.petArrivalDate!.year}年${registrationState.petArrivalDate!.month}月${registrationState.petArrivalDate!.day}日'
                                      : '未設定',
                                  icon: Icons.home,
                                  onTap: () => context.go(
                                    RouteConstants.petAnniversaryRoute,
                                  ),
                                ),
                                PetInfoCard(
                                  title: 'マイクロチップ',
                                  value: _getMicrochipText(),
                                  icon: Icons.qr_code,
                                  onTap: () => context.go(
                                    RouteConstants.petNameInputRoute,
                                  ),
                                ),
                                PetInfoCard(
                                  title: '体重・サイズ',
                                  value:
                                      registrationState.petWeight != null &&
                                          registrationState.petSize != null
                                      ? '${registrationState.petWeight!.toStringAsFixed(1)}kg・${registrationState.petSize}'
                                      : '未設定',
                                  icon: Icons.monitor_weight,
                                  onTap: () => context.go(
                                    RouteConstants.petSizeWeightRoute,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),

                // 하단 등록완료 버튼
                Container(
                  padding: const const const EdgeInsets.all(AppSpacing.lg),
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
                    child: ElevatedButton(
                      onPressed: _completePetRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pointPink,
                        foregroundColor: AppColors.pureWhite,
                        padding: const const const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        elevation: 2,
                        shadowColor: AppColors.pointPink.withValues(alpha: 0.3),
                      ),
                      child: Text(
                        '登録完了',
                        style: AppFonts.titleMedium.copyWith(
                          color: AppColors.pureWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
