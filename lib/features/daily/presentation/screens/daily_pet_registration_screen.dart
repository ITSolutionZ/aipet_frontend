import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/pet_registration_logic.dart';
import 'package:aipet_frontend/features/daily/presentation/screens/daily_pet_registration_screen_widgets/daily_pet_registration_screen_widgets.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_unified_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/actions/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// リファクタリングされた Pet Registration 画面 - UI とロジック完全分離
class DailyPetRegistrationScreen extends ConsumerWidget {
  final String? petId; // 편집 모드용 petId

  const DailyPetRegistrationScreen({super.key, this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🔍 DailyPetRegistrationScreen 빌드됨, petId: $petId');
    return _PetRegistrationForm(petId: petId);
  }
}

/// Pet Registration フォームウィジェット
class _PetRegistrationForm extends ConsumerStatefulWidget {
  final String? petId; // 편집 모드용 petId

  const _PetRegistrationForm({this.petId});

  @override
  ConsumerState<_PetRegistrationForm> createState() =>
      _PetRegistrationFormState();
}

class _PetRegistrationFormState extends ConsumerState<_PetRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  late final PetRegistrationLogic _logic;
  late final PetRegistrationController _controller;
  late final RegistrationFormHandlers _handlers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _logic = PetRegistrationLogic();
    _controller = ref.read(petRegistrationControllerProvider.notifier);
    _handlers = RegistrationFormHandlers(
      context: context,
      controller: _controller,
      logic: _logic,
      formKey: _formKey,
    );

    // petId가 있으면 기존 펫 정보 로드
    if (widget.petId != null && widget.petId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingPetData(widget.petId!);
      });
    }
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
      appBar: SoftGradientBackAppBar(
        title: widget.petId != null ? '반려동물 수정' : 'ペット情報入力',
      ),
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
              RegistrationFormContent(
                formData: formData,
                controller: _controller,
                onBirthDateTap: () =>
                    _handlers.handleBirthDateSelection(formData.birthDate),
                onAdoptionDateTap: () => _handlers.handleAdoptionDateSelection(
                  formData.adoptionDate,
                ),
                onImageSelection: () =>
                    _handlers.handleImageSelection(formData.petImagePath),
                onRegistrationImageSelection:
                    _handlers.handleRegistrationImageSelection,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// アクションボタン
  Widget _buildActionButtons() {
    final isEditMode = widget.petId != null && widget.petId!.isNotEmpty;

    final buttons = [
      ActionButtonData.primary(
        text: isEditMode ? '수정 완료' : '登録する',
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

  /// 기존 펫 데이터 로드
  Future<void> _loadExistingPetData(String petId) async {
    try {
      debugPrint('🔍 Loading existing pet data for ID: $petId');

      // 펫 프로필 로드
      final petProfileNotifier = ref.read(
        petProfileUnifiedControllerProvider.notifier,
      );
      await petProfileNotifier.loadPetProfile(petId);

      final petProfileState = ref.read(petProfileUnifiedControllerProvider);

      if (petProfileState.selectedPet != null) {
        final pet = petProfileState.selectedPet!;
        debugPrint('✅ Pet loaded: ${pet.name}');

        // 폼 데이터에 기존 펫 정보 설정
        _controller.updatePetName(pet.name);
        _controller.updatePetType(pet.type);
        _controller.updateBreed(pet.breed ?? '');
        _controller.updateGender(pet.gender);
        _controller.updateWeight(pet.weight.toString());
        _controller.updateBirthDate(pet.birthDate);
        _controller.updatePetImagePath(pet.imagePath);

        // 추가 정보 설정
        if (pet.additionalInfo != null) {
          final additionalInfo = pet.additionalInfo!;

          // 중성화 여부 설정 (updateNeuteringStatus 메서드 사용)
          _controller.updateNeuteringStatus(
            additionalInfo['isNeutered'] == true,
          );

          _controller.updateGuardianName(additionalInfo['guardianName'] ?? '');
          _controller.updateInstitutionName(
            additionalInfo['institutionName'] ?? '',
          );
          _controller.updateRegistrationNumber(
            additionalInfo['registrationNumber'] ?? '',
          );

          // 입양일 설정
          if (additionalInfo['adoptionDate'] != null) {
            final adoptionDate = DateTime.tryParse(
              additionalInfo['adoptionDate'],
            );
            if (adoptionDate != null) {
              _controller.updateAdoptionDate(adoptionDate);
            }
          }

          // 금지 성분 설정 (기존 리스트 클리어 후 추가)
          _controller.clearForbiddenIngredients();
          if (additionalInfo['forbiddenIngredients'] is List) {
            final ingredients = (additionalInfo['forbiddenIngredients'] as List)
                .map((e) => e.toString())
                .toList();
            for (final ingredient in ingredients) {
              _controller.addForbiddenIngredient(ingredient);
            }
          }

          // 관리 부위 설정
          _controller.updateBodyPartsToManage(
            additionalInfo['bodyPartsToManage'] ?? '',
          );

          // 먹이 정보 설정
          _controller.updateFood(additionalInfo['food'] ?? '');
          _controller.updateSupplement(additionalInfo['supplement'] ?? '');
          _controller.updateTreat(additionalInfo['treat'] ?? '');
        }

        debugPrint('✅ Existing pet data loaded successfully');
      } else {
        debugPrint('❌ Pet not found with ID: $petId');
      }
    } catch (e) {
      debugPrint('❌ Failed to load existing pet data: $e');
    }
  }

  /// フォーム送信ハンドラ
  Future<void> _handleSubmit() async {
    await _handlers.handleSubmit(
      (isLoading) {
        if (mounted) {
          setState(() {
            _isLoading = isLoading;
          });
        }
      },
      editPetId: widget.petId, // 편집 모드용 petId 전달
    );
  }
}
