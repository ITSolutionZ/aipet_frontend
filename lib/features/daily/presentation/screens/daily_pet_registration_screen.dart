import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/pet_registration_logic.dart';
import 'package:aipet_frontend/features/daily/presentation/screens/daily_pet_registration_screen_widgets/daily_pet_registration_screen_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/actions/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// リファクタリングされた Pet Registration 画面 - UI とロジック完全分離
class DailyPetRegistrationScreen extends ConsumerWidget {
  const DailyPetRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _PetRegistrationForm();
  }
}

/// Pet Registration フォームウィジェット
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

  /// フォーム送信ハンドラ
  Future<void> _handleSubmit() async {
    await _handlers.handleSubmit((isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = isLoading;
        });
      }
    });
  }
}
