import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_form_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/daily_health_input_logic.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/daily_date_header_widget.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/daily_health_widgets.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/sections/sections.dart';
import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/actions/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 리팩토링된 Daily Health Input 화면 - UI와 로직 분리
class DailyHealthInputScreen extends ConsumerWidget {
  final DailyHealthRecord? existingRecord;

  const DailyHealthInputScreen({super.key, this.existingRecord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formController = ref.watch(
      dailyHealthFormControllerProvider(existingRecord),
    );
    final formControllerNotifier = ref.read(
      dailyHealthFormControllerProvider(existingRecord).notifier,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(formControllerNotifier),
      body: formController.selectedPetId != null
          ? _buildForm(context, ref, formController, formControllerNotifier)
          : _buildPetSelectionPrompt(context),
    );
  }

  PreferredSizeWidget _buildAppBar(DailyHealthFormController controller) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        controller.logic.appBarTitle,
        style: AppFonts.titleMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    WidgetRef ref,
    DailyHealthFormData formData,
    DailyHealthFormController controller,
  ) {
    final isLoading = ref.watch(dailyHealthInputLoadingProvider);

    return Form(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DailyDateHeaderWidget(
              date: DateTime.now(),
              isEditing: controller.logic.isEditing,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildPetSelector(formData, controller),
            const SizedBox(height: AppSpacing.lg),
            TemperatureInputSection(
              controller: controller.temperatureController,
            ),
            const SizedBox(height: AppSpacing.lg),
            HealthStatusSection(
              selectedStatus: formData.selectedHealthStatus,
              onChanged: (status) {
                if (status != null) {
                  controller.updateHealthStatus(status);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            SymptomsSelectionSection(
              selectedSymptoms: formData.selectedSymptoms,
              onChanged: controller.updateSymptoms,
            ),
            const SizedBox(height: AppSpacing.lg),
            NotesInputSection(controller: controller.notesController),
            const SizedBox(height: AppSpacing.xl),
            _buildActionButtons(context, ref, controller, isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildPetSelector(
    DailyHealthFormData formData,
    DailyHealthFormController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '対象ペット',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        PetSelectorWidget(
          selectedPetId: formData.selectedPetId,
          onPetSelected: controller.updateSelectedPet,
        ),
      ],
    );
  }

  Widget _buildPetSelectionPrompt(BuildContext context) {
    return Center(
      child: EmptyStateWidget(
        icon: Icons.pets,
        title: 'ペットを選択してください',
        subtitle: '健康記録を追加するペットを選択してください',
        actionText: 'ペットを追加',
        onActionPressed: () {
          context.push('/pet-type-selection');
        },
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    DailyHealthFormController controller,
    bool isLoading,
  ) {
    final buttons = [
      ActionButtonData.primary(
        text: controller.logic.saveButtonText,
        onPressed: isLoading
            ? null
            : () => _handleSave(context, ref, controller),
        isLoading: isLoading,
      ),
      ActionButtonData.outlined(
        text: 'キャンセル',
        onPressed: isLoading ? null : () => context.pop(),
      ),
    ];

    return ActionButtonGroup.vertical(buttons: buttons);
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    DailyHealthFormController controller,
  ) async {
    final loadingNotifier = ref.read(dailyHealthInputLoadingProvider.notifier);

    try {
      loadingNotifier.setLoading(true);
      await controller.saveHealthRecord();

      if (context.mounted) {
        _showSuccessMessage(context, controller.logic.getSuccessMessage());
        context.pop();
      }
    } catch (error) {
      if (context.mounted) {
        _showErrorMessage(context, controller.logic.getErrorMessage(error));
      }
    } finally {
      loadingNotifier.setLoading(false);
    }
  }

  /// ✅ Shared SnackBarService 사용
  void _showSuccessMessage(BuildContext context, String message) {
    SnackBarService.showSuccess(context, message);
  }

  /// ✅ Shared SnackBarService 사용
  void _showErrorMessage(BuildContext context, String message) {
    SnackBarService.showError(context, message);
  }
}
