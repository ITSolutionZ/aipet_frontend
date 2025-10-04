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
          const SizedBox(height: AppSpacing.lg),
          _buildPetBasicInfoSection(formData),
          const SizedBox(height: AppSpacing.lg),
          _buildPetTypeSection(formData),
          const SizedBox(height: AppSpacing.lg),
          _buildPetBreedSection(formData),
          const SizedBox(height: AppSpacing.lg),
          _buildPetGenderSection(formData),
          const SizedBox(height: AppSpacing.lg),
          _buildPetNeuteringSection(formData),
          const SizedBox(height: AppSpacing.lg),
          _buildPetRegistrationSection(),
          const SizedBox(height: AppSpacing.lg),
          const PetFoodSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildPetIngredientsSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildPetBodyPartsSection(),
        ],
      ),
    );
  }

  /// 펫 이미지 섹션
  Widget _buildPetImageSection(PetRegistrationFormData formData) {
    return PetImageSection(
      petImagePath: formData.petImagePath,
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

  /// 펫 성별 섹션
  Widget _buildPetGenderSection(PetRegistrationFormData formData) {
    return PetGenderSection(
      selectedGender: formData.gender,
      onGenderChanged: _controller.updateGender,
    );
  }

  /// 펫 중성화 섹션
  Widget _buildPetNeuteringSection(PetRegistrationFormData formData) {
    return PetNeuteringSection(
      isNeutered: formData.isNeutered,
      onNeuteringChanged: _controller.updateNeuteringStatus,
    );
  }

  /// 펫 등록증 섹션
  Widget _buildPetRegistrationSection() {
    return PetRegistrationSection(
      guardianNameController: _controller.guardianNameController,
      registrationNumberController: _controller.registrationNumberController,
      onRegistrationImageTap: () =>
          _showInfoMessage(PetRegistrationLogic.registrationImageMessage),
    );
  }

  /// 펫 원료 섹션
  Widget _buildPetIngredientsSection() {
    return PetIngredientsSection(
      onRegisterIngredients: () =>
          _showInfoMessage(PetRegistrationLogic.ingredientsMessage),
    );
  }

  /// 펫 신체 부위 섹션
  Widget _buildPetBodyPartsSection() {
    return PetBodyPartsSection(
      onRegisterBodyParts: () =>
          _showInfoMessage(PetRegistrationLogic.bodyPartsMessage),
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
    final result = await _logic.selectPetImage(
      context: context,
      currentImagePath: currentImagePath,
    );

    if (result == null) return;

    if (result == 'REMOVE') {
      _controller.updatePetImagePath(null);
    } else {
      _controller.updatePetImagePath(result);
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
        _showErrorMessage(_logic.getErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 정보 메시지 표시
  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 성공 메시지 표시
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.pointGreen),
    );
  }

  /// 에러 메시지 표시
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.pointRed),
    );
  }
}
