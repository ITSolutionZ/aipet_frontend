import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/pet_registration/pet_registration_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/actions/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Daily Health 스타일의 펫 등록 화면
class DailyPetRegistrationScreen extends ConsumerStatefulWidget {
  const DailyPetRegistrationScreen({super.key});

  @override
  ConsumerState<DailyPetRegistrationScreen> createState() =>
      _DailyPetRegistrationScreenState();
}

class _DailyPetRegistrationScreenState
    extends ConsumerState<DailyPetRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PetRegistrationController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(petRegistrationControllerProvider.notifier);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final formData = ref.read(petRegistrationControllerProvider);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: formData.birthDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _controller.updateBirthDate(picked);
    }
  }

  Future<void> _selectAdoptionDate(BuildContext context) async {
    final formData = ref.read(petRegistrationControllerProvider);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: formData.adoptionDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _controller.updateAdoptionDate(picked);
    }
  }

  Future<void> _selectPetImage() async {
    try {
      _controller.setImageLoading(true);

      final formData = ref.read(petRegistrationControllerProvider);
      final result = await ImageService.showImagePickerOptions(
        context,
        allowRemoval: formData.petImagePath != null,
        currentImagePath: formData.petImagePath,
      );

      if (!mounted || result == null) {
        return;
      }

      if (result == 'REMOVE') {
        _controller.updatePetImagePath(null);
        return;
      }

      _controller.updatePetImagePath(result);
    } finally {
      _controller.setImageLoading(false);
    }
  }

  Future<void> _handleRegistrationImageSelection() async {
    try {
      await _controller.selectAndProcessRegistrationImage();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('등록증 정보를 자동으로 입력했습니다. 확인 후 수정해주세요.'),
            backgroundColor: AppColors.pointGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('등록증 처리 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.pointRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(petRegistrationControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: const SoftGradientBackAppBar(title: 'ペット情報入力'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 메인 컨텍스트 카드로 모든 섹션을 감싸기
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    PetImageSection(
                      petImagePath: formData.petImagePath,
                      isLoading: formData.isImageLoading,
                      onImageTap: _selectPetImage,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PetBasicInfoSection(
                      petNameController: _controller.petNameController,
                      birthDateController: _controller.birthDateController,
                      weightController: _controller.weightController,
                      selectedBirthDate: formData.birthDate,
                      onBirthDateTap: () => _selectBirthDate(context),
                      petNameValidator: _controller.validatePetName,
                      birthDateValidator: _controller.validateBirthDate,
                      weightValidator: _controller.validateWeight,
                      adoptionDateController:
                          _controller.adoptionDateController,
                      selectedAdoptionDate: formData.adoptionDate,
                      onAdoptionDateTap: () => _selectAdoptionDate(context),
                      adoptionDateValidator: _controller.validateAdoptionDate,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PetTypeSection(
                      selectedPetType: formData.petType,
                      onPetTypeChanged: _controller.updatePetType,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PetBreedSection(
                      selectedPetType: formData.petType,
                      selectedBreed: formData.breed,
                      onBreedChanged: _controller.updateBreed,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PetGenderSection(
                      selectedGender: formData.gender,
                      isNeutered: formData.isNeutered,
                      onGenderChanged: _controller.updateGender,
                      onNeuteringChanged: _controller.updateNeuteringStatus,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PetRegistrationSection(
                      guardianNameController:
                          _controller.guardianNameController,
                      institutionNameController:
                          _controller.institutionNameController,
                      registrationNumberController:
                          _controller.registrationNumberController,
                      onRegistrationImageTap: _handleRegistrationImageSelection,
                      registrationImagePath: formData.registrationImagePath,
                      isProcessingOCR: formData.isProcessingOCR,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PetFoodSection(
                      selectedFood: formData.food,
                      selectedSupplement: formData.supplement,
                      selectedTreat: formData.treat,
                      onFoodChanged: _controller.updateFood,
                      onSupplementChanged: _controller.updateSupplement,
                      onTreatChanged: _controller.updateTreat,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Consumer(
                      builder: (context, ref, child) {
                        final controller = ref.watch(
                          petRegistrationControllerProvider.notifier,
                        );
                        final state = ref.watch(
                          petRegistrationControllerProvider,
                        );

                        return Column(
                          children: [
                            PetIngredientsSection(
                              forbiddenIngredients: state.forbiddenIngredients,
                              onAddIngredient: (ingredient, context) {
                                controller
                                    .addForbiddenIngredientWithNotification(
                                      ingredient,
                                      context,
                                    );
                              },
                              onRemoveIngredient: (ingredient) {
                                controller.removeForbiddenIngredient(
                                  ingredient,
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PetBodyPartsSection(
                              bodyPartsToManage: state.bodyPartsToManage,
                              onUpdateBodyParts: (bodyParts) {
                                controller.updateBodyPartsToManage(bodyParts);
                              },
                              onClearBodyParts: () {
                                controller.clearBodyPartsToManage();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final buttons = [
      ActionButtonData.primary(
        text: '登録する',
        onPressed: _savePetRegistration,
        isLoading: _isLoading,
      ),
      ActionButtonData.outlined(text: 'キャンセル', onPressed: () => context.pop()),
    ];

    return ActionButtonGroup.vertical(buttons: buttons);
  }

  Future<void> _savePetRegistration() async {
    // 폼 검증 전에 텍스트 컨트롤러와 state 동기화
    print('🔄 Synchronizing text controllers with state before validation');
    _controller.updatePetName(_controller.petNameController.text);
    _controller.updateWeight(_controller.weightController.text);
    _controller.updateGuardianName(_controller.guardianNameController.text);
    _controller.updateInstitutionName(
      _controller.institutionNameController.text,
    );
    _controller.updateRegistrationNumber(
      _controller.registrationNumberController.text,
    );

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final breedValidation = _controller.validateBreed();
    if (breedValidation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(breedValidation),
          backgroundColor: AppColors.pointRed,
        ),
      );
      return;
    }

    final genderValidation = _controller.validateGender();
    if (genderValidation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(genderValidation),
          backgroundColor: AppColors.pointRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _controller.submitForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ペット登録が完了しました！'),
            backgroundColor: AppColors.pointGreen,
          ),
        );

        // 등록 완료 후 daily health 화면으로 돌아가기
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        _showErrorMessage('エラーが発生しました: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 에러 메시지 표시
  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: AppColors.pointRed),
            SizedBox(width: AppSpacing.sm),
            Text('登録エラー'),
          ],
        ),
        content: Text(message, style: AppFonts.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }
}
