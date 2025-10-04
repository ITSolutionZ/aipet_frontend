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

  Future<void> _selectPetImage() async {
    final result = await ImageService.showImagePickerOptions(
      context,
      allowRemoval: _controller.state.petImagePath != null,
      currentImagePath: _controller.state.petImagePath,
    );

    if (!mounted || result == null) {
      return;
    }

    if (result == 'REMOVE') {
      _controller.updatePetImagePath(null);
      return;
    }

    _controller.updatePetImagePath(result);
  }

  void _showRegistrationImageDialog() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('登録証写真アップロード機能は近日実装予定')));
  }

  void _showIngredientsDialog() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('原料登録画面は近日実装予定')));
  }

  void _showBodyPartsDialog() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('身体部位登録画面は近日実装予定')));
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
                      onGenderChanged: _controller.updateGender,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PetNeuteringSection(
                      isNeutered: formData.isNeutered,
                      onNeuteringChanged: _controller.updateNeuteringStatus,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PetRegistrationSection(
                      guardianNameController:
                          _controller.guardianNameController,
                      registrationNumberController:
                          _controller.registrationNumberController,
                      onRegistrationImageTap: _showRegistrationImageDialog,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const PetFoodSection(),
                    const SizedBox(height: AppSpacing.lg),
                    PetIngredientsSection(
                      onRegisterIngredients: _showIngredientsDialog,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PetBodyPartsSection(
                      onRegisterBodyParts: _showBodyPartsDialog,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $error'),
            backgroundColor: AppColors.pointRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
