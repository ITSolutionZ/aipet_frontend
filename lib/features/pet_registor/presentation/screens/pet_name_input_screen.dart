import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/providers/providers.dart';
import '../constants/pet_registration_texts.dart';
import '../utils/pet_image_utils.dart';
import '../widgets/widgets.dart';

class PetNameInputScreen extends ConsumerStatefulWidget {
  const PetNameInputScreen({super.key});

  @override
  ConsumerState<PetNameInputScreen> createState() => _PetNameInputScreenState();
}

class _PetNameInputScreenState extends ConsumerState<PetNameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _microchipController = TextEditingController();
  bool _isValid = false;
  String? _selectedGender;
  bool _isNeutered = false;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);

    // 기존 데이터 복원
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _microchipController.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _isValid =
          _nameController.text.trim().length >= 2 &&
          _nameController.text.trim().length <= 20;
    });
  }

  /// 전역 상태에서 기존 데이터 복원
  void _restoreData() {
    final registrationState = ref.read(petRegistrationStateProvider);

    setState(() {
      if (registrationState.petName != null) {
        _nameController.text = registrationState.petName!;
      }
      if (registrationState.petGender != null) {
        _selectedGender = registrationState.petGender;
      }
      if (registrationState.isNeutered != null) {
        _isNeutered = registrationState.isNeutered!;
      }
      if (registrationState.microchipNumber != null) {
        _microchipController.text = registrationState.microchipNumber!;
      }
      if (registrationState.petImagePath != null) {
        _selectedImagePath = registrationState.petImagePath;
      }
    });
  }

  /// 전역 상태에 데이터 저장
  void _saveData() {
    final registrationNotifier = ref.read(
      petRegistrationStateProvider.notifier,
    );
    registrationNotifier.setPetName(_nameController.text.trim());
    registrationNotifier.setPetGenderInfo(
      gender: _selectedGender,
      isNeutered: _isNeutered,
    );
    registrationNotifier.setPetImagePath(_selectedImagePath);
    registrationNotifier.setMicrochipNumber(_microchipController.text.trim());
  }

  String _getDefaultImagePath() {
    final registrationState = ref.read(petRegistrationStateProvider);
    final petType = registrationState.selectedPetType;
    final breed = registrationState.currentBreed;
    return PetImageUtils.getPetImagePath(petType, breed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: SoftGradientAppBar(
        title: PetRegistrationTexts.enterName,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // 이전 페이지로 이동 (품종 선택 - 일반적으로 강아지 품종 선택)
            context.go(RouteConstants.dogBreedSelectionRoute);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 영역 (스크롤 추가)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 프로그레스바
                    const PetRegistrationProgressBar(
                      currentStep: 3,
                      totalSteps: 7,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 제목
                    Text(
                      '名前を教えてください',
                      style: AppFonts.titleLarge.copyWith(
                        color: AppColors.pointBrown,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 펫 이미지
                    PetImagePicker(
                      selectedImagePath: _selectedImagePath,
                      defaultImagePath: _getDefaultImagePath(),
                      onImageChanged: (imagePath) {
                        setState(() {
                          _selectedImagePath = imagePath;
                        });
                        _saveData();
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 이름 입력 필드
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        style: AppFonts.bodyLarge.copyWith(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'ぺこ',
                          hintStyle: AppFonts.bodyLarge.copyWith(
                            fontSize: 18,
                            color: AppColors.pointGray.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: AppColors.pureWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.pointBrown.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.pointBrown.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.pointBrown,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                            horizontal: AppSpacing.md,
                          ),
                        ),
                        onChanged: (value) {
                          _saveData();
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 성별 선택 버튼
                    GenderSelection(
                      selectedGender: _selectedGender,
                      onGenderChanged: (gender) {
                        setState(() {
                          _selectedGender = gender;
                        });
                        _saveData();
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 중성화/피임 체크박스
                    Row(
                      children: [
                        Checkbox(
                          value: _isNeutered,
                          onChanged: (value) {
                            setState(() {
                              _isNeutered = value ?? false;
                            });
                            _saveData();
                          },
                          activeColor: AppColors.pointBrown,
                        ),
                        Expanded(
                          child: Text(
                            '去勢・避妊済',
                            style: AppFonts.bodyMedium.copyWith(
                              color: AppColors.pointDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 마이크로칩 번호 입력
                    MicrochipInput(
                      controller: _microchipController,
                      onChanged: _saveData,
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
                    return NextButton(
                      text: '次へ',
                      isEnabled: _isValid && _selectedGender != null,
                      onPressed: (_isValid && _selectedGender != null)
                          ? () {
                              // 전역 상태에 저장
                              _saveData();

                              // 등록이 완료된 상태라면 등록확인 페이지로
                              final updatedState = ref.read(
                                petRegistrationStateProvider,
                              );
                              if (updatedState.isRegistrationComplete) {
                                context.go(
                                  RouteConstants.petAnniversarySummaryRoute,
                                );
                                return;
                              }

                              // 다음 단계로 이동
                              context.go(RouteConstants.petSizeWeightRoute);
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
