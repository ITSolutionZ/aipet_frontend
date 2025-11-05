import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/daily_health_record.dart';
import '../controllers/daily_health_form_controller.dart';
import '../logic/daily_health_input_logic.dart';
import '../widgets/daily_date_header_widget.dart';
import '../widgets/pet_selector_widget.dart';
import '../widgets/sections/health_status_section.dart';
import '../widgets/sections/notes_input_section.dart';
import '../widgets/sections/symptoms_selection_section.dart';
import '../widgets/sections/temperature_input_section.dart';

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
            buildPetSelector(formData, controller),
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
            buildActionButtons(context, ref, controller, isLoading),
          ],
        ),
      ),
    );
  }

  Widget buildPetSelector(
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
      child: EmptyState.withAction(
        title: 'ペットを選択してください',
        subtitle: '健康記録を追加するペットを選択してください',
        icon: Icons.pets,
        action: ElevatedButton(
          onPressed: () {
            context.push('/pet-type-selection');
          },
          child: const Text('ペットを追加'),
        ),
      ),
    );
  }

  Widget buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    DailyHealthFormController controller,
    bool isLoading,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () => handleSave(context, ref, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    controller.logic.saveButtonText,
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: const BorderSide(color: AppColors.borderGray),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
            child: Text(
              'キャンセル',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> handleSave(
    BuildContext context,
    WidgetRef ref,
    DailyHealthFormController controller,
  ) async {
    final loadingNotifier = ref.read(dailyHealthInputLoadingProvider.notifier);

    try {
      loadingNotifier.setLoading(true);
      await controller.saveHealthRecord();

      if (context.mounted) {
        showSuccessMessage(context, controller.logic.getSuccessMessage());
        context.pop();
      }
    } catch (error) {
      if (context.mounted) {
        showErrorMessage(context, controller.logic.getErrorMessage(error));
      }
    } finally {
      loadingNotifier.setLoading(false);
    }
  }

  /// ✅ Shared SnackBarService 사용
  void showSuccessMessage(BuildContext context, String message) {
    SnackBarService.showSuccess(context, message);
  }

  /// ✅ Shared SnackBarService 사용
  void showErrorMessage(BuildContext context, String message) {
    SnackBarService.showError(context, message);
  }
}
