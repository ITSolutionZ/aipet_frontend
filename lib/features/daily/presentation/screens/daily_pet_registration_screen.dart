import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/pet_registration_logic.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/pet_registration/pet_registration_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/actions/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 리팩토링된 Pet Registration 화면 - UI와 로직 완전 분리
class DailyPetRegistrationScreen extends ConsumerWidget {
  const DailyPetRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _PetRegistrationForm();
  }
}

/// Pet Registration 폼 위젯
class _PetRegistrationForm extends ConsumerStatefulWidget {
  const _PetRegistrationForm();

  @override
  ConsumerState<_PetRegistrationForm> createState() =>
      _PetRegistrationFormState();
}

class _PetRegistrationFormState extends ConsumerState<_PetRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  late final PetRegistrationLogic _logic;
  late final PetRegistrationController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _logic = PetRegistrationLogic();
    _controller = ref.read(petRegistrationControllerProvider.notifier);
  }

  @override
  void dispose() {
    // Riverpod provider로 관리되는 컨트롤러는 자동으로 dispose됩니다
    super.dispose();
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
          physics: const BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainContentCard(formData),
              const SizedBox(height: AppSpacing.xl),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// 메인 컨텐츠 카드
  Widget _buildMainContentCard(PetRegistrationFormData formData) {
    return Container(
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
          _buildPetImageSection(formData),
          _buildSectionDivider(),
          _buildPetBasicInfoSection(formData),
          _buildSectionDivider(),
          _buildPetTypeSection(formData),
          _buildSectionDivider(),
          _buildPetBreedSection(formData),
          _buildSectionDivider(),
          _buildPetGenderSection(formData),
          _buildSectionDivider(),
          _buildPetRegistrationSection(),
          _buildSectionDivider(),
          _buildPetFoodSection(formData),
          _buildSectionDivider(),
          _buildPetIngredientsSection(),
          _buildSectionDivider(),
          _buildPetBodyPartsSection(),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  /// 펫 이미지 섹션
  Widget _buildPetImageSection(PetRegistrationFormData formData) {
    return PetImageSection(
      petImagePath: formData.petImagePath,
      isLoading: formData.isImageLoading,
      onImageTap: () => _handleImageSelection(formData.petImagePath),
    );
  }

  /// 펫 기본 정보 섹션
  Widget _buildPetBasicInfoSection(PetRegistrationFormData formData) {
    return PetBasicInfoSection(
      petNameController: _controller.petNameController,
      birthDateController: _controller.birthDateController,
      adoptionDateController: _controller.adoptionDateController,
      weightController: _controller.weightController,
      selectedBirthDate: formData.birthDate,
      selectedAdoptionDate: formData.adoptionDate,
      onBirthDateTap: () => _handleBirthDateSelection(formData.birthDate),
      onAdoptionDateTap: () =>
          _handleAdoptionDateSelection(formData.adoptionDate),
      petNameValidator: _controller.validatePetName,
      birthDateValidator: _controller.validateBirthDate,
      adoptionDateValidator: _controller.validateAdoptionDate,
      weightValidator: _controller.validateWeight,
    );
  }

  /// 펫 타입 섹션
  Widget _buildPetTypeSection(PetRegistrationFormData formData) {
    return PetTypeSection(
      selectedPetType: formData.petType,
      onPetTypeChanged: _controller.updatePetType,
    );
  }

  /// 펫 품종 섹션
  Widget _buildPetBreedSection(PetRegistrationFormData formData) {
    return PetBreedSection(
      selectedPetType: formData.petType,
      selectedBreed: formData.breed,
      onBreedChanged: _controller.updateBreed,
    );
  }

  /// 펫 성별 섹션 (중성화 체크박스 포함)
  Widget _buildPetGenderSection(PetRegistrationFormData formData) {
    return PetGenderSection(
      selectedGender: formData.gender,
      isNeutered: formData.isNeutered,
      onGenderChanged: _controller.updateGender,
      onNeuteringChanged: _controller.updateNeuteringStatus,
    );
  }

  /// 펫 등록증 섹션
  Widget _buildPetRegistrationSection() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(petRegistrationControllerProvider);
        return PetRegistrationSection(
          guardianNameController: _controller.guardianNameController,
          institutionNameController: _controller.institutionNameController,
          registrationNumberController:
              _controller.registrationNumberController,
          onRegistrationImageTap: _handleRegistrationImageSelection,
          registrationImagePath: state.registrationImagePath,
          isProcessingOCR: state.isProcessingOCR,
        );
      },
    );
  }

  /// 펫 사료 섹션
  Widget _buildPetFoodSection(PetRegistrationFormData formData) {
    return PetFoodSection(
      selectedFood: formData.food,
      selectedSupplement: formData.supplement,
      selectedTreat: formData.treat,
      onFoodChanged: _controller.updateFood,
      onSupplementChanged: _controller.updateSupplement,
      onTreatChanged: _controller.updateTreat,
    );
  }

  /// 펫 원료 섹션
  Widget _buildPetIngredientsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final controller = ref.watch(
          petRegistrationControllerProvider.notifier,
        );
        final state = ref.watch(petRegistrationControllerProvider);

        return PetIngredientsSection(
          forbiddenIngredients: state.forbiddenIngredients,
          onAddIngredient: (ingredient, context) {
            controller.addForbiddenIngredientWithNotification(
              ingredient,
              context,
            );
          },
          onRemoveIngredient: (ingredient) {
            controller.removeForbiddenIngredient(ingredient);
          },
        );
      },
    );
  }

  /// 섹션 구분선
  Widget _buildSectionDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Divider(
        color: AppColors.borderGray.withValues(alpha: 0.2),
        thickness: 1,
        height: 1,
      ),
    );
  }

  /// 펫 신체 부위 섹션
  Widget _buildPetBodyPartsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final controller = ref.watch(
          petRegistrationControllerProvider.notifier,
        );
        final state = ref.watch(petRegistrationControllerProvider);

        return PetBodyPartsSection(
          bodyPartsToManage: state.bodyPartsToManage,
          onUpdateBodyParts: (bodyParts) {
            controller.updateBodyPartsToManage(bodyParts);
          },
          onClearBodyParts: () {
            controller.clearBodyPartsToManage();
          },
        );
      },
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons() {
    final buttons = [
      ActionButtonData.primary(
        text: '登録する',
        onPressed: _isLoading ? null : _handleSubmit,
        isLoading: _isLoading,
      ),
      ActionButtonData.outlined(
        text: 'キャンセル',
        onPressed: _isLoading ? null : () => context.pop(),
      ),
    ];

    return ActionButtonGroup.vertical(buttons: buttons);
  }

  /// 이미지 선택 핸들러
  Future<void> _handleImageSelection(String? currentImagePath) async {
    try {
      print('📸 Starting image selection, current path: $currentImagePath');
      _controller.setImageLoading(true);

      final result = await _logic.selectPetImage(
        context: context,
        currentImagePath: currentImagePath,
      );

      print('📸 Image selection result: $result');

      if (result == null) {
        print('📸 Image selection cancelled');
        return;
      }

      if (result == 'REMOVE') {
        print('📸 Removing image');
        _controller.updatePetImagePath(null);
      } else {
        print('📸 Setting new image path: $result');
        _controller.updatePetImagePath(result);
      }
    } finally {
      _controller.setImageLoading(false);
      print('📸 Image loading finished');
    }
  }

  /// 생년월일 선택 핸들러
  Future<void> _handleBirthDateSelection(DateTime? currentDate) async {
    final picked = await _logic.selectBirthDate(
      context: context,
      currentDate: currentDate,
    );

    if (picked != null) {
      _controller.updateBirthDate(picked);
    }
  }

  /// 집에 온 날 선택 핸들러
  Future<void> _handleAdoptionDateSelection(DateTime? currentDate) async {
    final picked = await _logic.selectAdoptionDate(
      context: context,
      currentDate: currentDate,
    );

    if (picked != null) {
      _controller.updateAdoptionDate(picked);
    }
  }

  /// 폼 제출 핸들러
  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _logic.submitPetRegistration(
        formKey: _formKey,
        controller: _controller,
      );

      if (mounted) {
        _showSuccessMessage(_logic.getSuccessMessage());
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        final errorMessage = _logic.getErrorMessage(error);
        print('🚨 Registration error: $errorMessage');
        _showErrorMessage(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 성공 메시지 표시
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.pointGreen),
    );
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

  /// 등록증 이미지 선택 및 OCR 처리
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
}
