import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/pet_registration_logic.dart';
import 'package:aipet_frontend/features/daily/presentation/screens/daily_pet_registration_screen_widgets/daily_pet_registration_screen_widgets.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
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
    LoggerService.debug('🔍 DailyPetRegistrationScreen 빌드됨, petId: $petId');
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
  bool _hasLoadedPetData = false; // 펫 데이터 로드 여부 플래그

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // petId가 있고 아직 로드하지 않았으면 로드
    if (widget.petId != null &&
        widget.petId!.isNotEmpty &&
        !_hasLoadedPetData) {
      _hasLoadedPetData = true;

      // 다음 프레임에 로드 (Riverpod 생명주기 안전)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadExistingPetData(widget.petId!);
        }
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
    if (!mounted) return;

    try {
      LoggerService.debug('🔍 Loading existing pet data for ID: $petId');

      // 펫 프로필 repository에서 직접 로드
      final repository = ref.read(petProfileRepositoryProvider);
      final result = await repository.getPetById(petId);

      if (!mounted) return;

      if (result.isSuccess && result.dataOrNull != null) {
        final pet = result.dataOrNull!;
        LoggerService.debug('✅ Pet loaded from repository: ${pet.name}');
        LoggerService.debug(
          '📋 Pet data - id: ${pet.id}, type: ${pet.type}, breed: ${pet.breed}',
        );
        LoggerService.debug(
          '📋 Pet birthDate: ${pet.birthDate}, gender: ${pet.gender}, weight: ${pet.weight}',
        );
        LoggerService.debug('📋 Pet imagePath: ${pet.imagePath}');
        LoggerService.debug('📋 Pet additionalInfo: ${pet.additionalInfo}');

        // 폼 데이터에 기존 펫 정보 설정
        LoggerService.debug('🔄 Updating basic pet info...');
        _controller.updatePetName(pet.name);
        LoggerService.debug('  ✓ Name: ${pet.name}');

        _controller.updatePetType(pet.type);
        LoggerService.debug('  ✓ Type: ${pet.type}');

        _controller.updateBreed(pet.breed ?? '');
        LoggerService.debug('  ✓ Breed: ${pet.breed}');

        _controller.updateGender(pet.gender);
        LoggerService.debug('  ✓ Gender: ${pet.gender}');

        _controller.updateWeight(pet.weight.toString());
        LoggerService.debug('  ✓ Weight: ${pet.weight}');

        _controller.updateBirthDate(pet.birthDate);
        LoggerService.debug('  ✓ BirthDate: ${pet.birthDate}');

        if (pet.imagePath != null) {
          _controller.updatePetImagePath(pet.imagePath);
          LoggerService.debug('  ✓ ImagePath: ${pet.imagePath}');
        } else {
          LoggerService.debug('  ⚠️ ImagePath: null');
        }

        LoggerService.debug('✅ Basic pet info updated in controller');

        // 추가 정보 설정
        if (pet.additionalInfo != null) {
          final additionalInfo = pet.additionalInfo!;
          LoggerService.debug('🔍 Loading additionalInfo fields...');
          LoggerService.debug('   All keys: ${additionalInfo.keys.toList()}');

          // 중성화 여부 설정 (updateNeuteringStatus 메서드 사용)
          final isNeutered = additionalInfo['isNeutered'] == true;
          LoggerService.debug(
            '  ✓ isNeutered: $isNeutered (raw: ${additionalInfo['isNeutered']})',
          );
          _controller.updateNeuteringStatus(isNeutered);

          // 외견 설정
          final appearance = additionalInfo['appearance']?.toString() ?? '';
          LoggerService.debug(
            '  ✓ appearance: $appearance (raw: ${additionalInfo['appearance']})',
          );
          _controller.updateAppearance(appearance);

          final guardianName = additionalInfo['guardianName']?.toString() ?? '';
          _controller.updateGuardianName(guardianName);
          LoggerService.debug('  ✓ guardianName: $guardianName');

          final institutionName =
              additionalInfo['institutionName']?.toString() ?? '';
          _controller.updateInstitutionName(institutionName);
          LoggerService.debug('  ✓ institutionName: $institutionName');

          final registrationNumber =
              additionalInfo['registrationNumber']?.toString() ?? '';
          _controller.updateRegistrationNumber(registrationNumber);
          LoggerService.debug('  ✓ registrationNumber: $registrationNumber');

          // 입양일 설정
          if (additionalInfo['adoptionDate'] != null) {
            final adoptionDateStr = additionalInfo['adoptionDate'].toString();
            LoggerService.debug('  🔍 adoptionDate string: $adoptionDateStr');

            final adoptionDate = DateTime.tryParse(adoptionDateStr);
            if (adoptionDate != null) {
              _controller.updateAdoptionDate(adoptionDate);
              LoggerService.debug('  ✓ adoptionDate updated: $adoptionDate');
            } else {
              LoggerService.debug('  ⚠️ adoptionDate parse failed');
            }
          } else {
            LoggerService.debug('  ⚠️ adoptionDate: null');
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
          final bodyParts =
              additionalInfo['bodyPartsToManage']?.toString() ?? '';
          _controller.updateBodyPartsToManage(bodyParts);
          LoggerService.debug('  ✓ bodyPartsToManage: $bodyParts');

          // 먹이 정보 설정
          final food = additionalInfo['food']?.toString() ?? '';
          _controller.updateFood(food);
          LoggerService.debug('  ✓ food: $food');

          final supplement = additionalInfo['supplement']?.toString() ?? '';
          _controller.updateSupplement(supplement);
          LoggerService.debug('  ✓ supplement: $supplement');

          final treat = additionalInfo['treat']?.toString() ?? '';
          _controller.updateTreat(treat);
          LoggerService.debug(
            '  ✓ treat: $treat (raw: ${additionalInfo['treat']})',
          );

          LoggerService.debug('✅ All additionalInfo fields loaded');
        } else {
          LoggerService.debug('⚠️ additionalInfo is null!');
        }

        LoggerService.debug('✅ Existing pet data loaded successfully');
      } else {
        LoggerService.debug('❌ Pet not found with ID: $petId');
      }
    } catch (e) {
      LoggerService.debug('❌ Failed to load existing pet data: $e');
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
