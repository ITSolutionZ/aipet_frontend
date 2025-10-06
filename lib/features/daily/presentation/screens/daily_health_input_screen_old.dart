import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/daily_date_header_widget.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/daily_health_widgets.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/sections/sections.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/mixins/mixins.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/actions/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 毎日の健康記録入力画面
class DailyHealthInputScreen extends ConsumerStatefulWidget {
  final DailyHealthRecord? existingRecord;

  const DailyHealthInputScreen({super.key, this.existingRecord});

  @override
  ConsumerState<DailyHealthInputScreen> createState() =>
      _DailyHealthInputScreenState();
}

class _DailyHealthInputScreenState extends ConsumerState<DailyHealthInputScreen>
    with FormStateMixin, ValidationMixin {
  final _temperatureController = TextEditingController();
  final _notesController = TextEditingController();

  HealthStatus _selectedHealthStatus = HealthStatus.good;
  List<String> _selectedSymptoms = [];
  String? _selectedPetId;

  @override
  void initializeForm() {
    _initializeForm();
  }

  @override
  void disposeForm() {
    _temperatureController.dispose();
    _notesController.dispose();
  }

  void _initializeForm() {
    if (widget.existingRecord != null) {
      final record = widget.existingRecord!;
      _temperatureController.text = record.temperature?.toString() ?? '';
      _selectedHealthStatus = record.overallHealth;
      _selectedSymptoms = List.from(record.symptoms);
      _notesController.text = record.notes ?? '';
      _selectedPetId = record.petId;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final pets = ref.read(petProfilesNotifierProvider).value;
        if (pets != null && pets.isNotEmpty) {
          setState(() {
            _selectedPetId = pets.first.id;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isEditing = widget.existingRecord != null;
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        isEditing ? '健康記録を編集' : '健康記録を追加',
        style: AppFonts.titleMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return _selectedPetId != null ? _buildForm() : _buildPetSelectionPrompt();
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DailyDateHeaderWidget(
              date: DateTime.now(),
              isEditing: widget.existingRecord != null,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildPetSelector(),
            const SizedBox(height: AppSpacing.lg),
            TemperatureInputSection(
              controller: _temperatureController,
            ),
            const SizedBox(height: AppSpacing.lg),
            HealthStatusSection(
              selectedStatus: _selectedHealthStatus,
              onChanged: (status) {
                if (status != null) {
                  setState(() {
                    _selectedHealthStatus = status;
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            SymptomsSelectionSection(
              selectedSymptoms: _selectedSymptoms,
              onChanged: (symptoms) {
                setState(() {
                  _selectedSymptoms = symptoms;
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            NotesInputSection(
              controller: _notesController,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPetSelectionPrompt() {
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



  Widget _buildPetSelector() {
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
          selectedPetId: _selectedPetId,
          onPetSelected: (petId) {
            setState(() {
              _selectedPetId = petId;
            });
          },
        ),
      ],
    );
  }





  Widget _buildActionButtons() {
    final buttons = [
      ActionButtonData.primary(
        text: widget.existingRecord != null ? '記録を更新' : '記録を保存',
        onPressed: _saveHealthRecord,
        isLoading: isLoading,
      ),
      ActionButtonData.outlined(text: 'キャンセル', onPressed: () => context.pop()),
    ];

    return ActionButtonGroup.vertical(buttons: buttons);
  }

  Future<void> _saveHealthRecord() async {
    await submitForm(
      onSubmit: () async {
        if (_selectedPetId == null) {
          throw Exception('ペットを選択してください');
        }

        final record = DailyHealthRecord(
          id:
              widget.existingRecord?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          petId: _selectedPetId!,
          date: widget.existingRecord?.date ?? DateTime.now(),
          temperature: _temperatureController.text.isNotEmpty
              ? double.tryParse(_temperatureController.text)
              : null,
          overallHealth: _selectedHealthStatus,
          symptoms: _selectedSymptoms,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          createdAt: widget.existingRecord?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final controller = ref.read(dailyHealthControllerProvider.notifier);

        if (widget.existingRecord != null) {
          await controller.updateHealthRecord(record);
        } else {
          await controller.addHealthRecord(record);
        }

        if (mounted) {
          context.pop();
        }
      },
      onSuccess: () {
        final message = widget.existingRecord != null
            ? '健康記録を更新しました'
            : '健康記録を追加しました';
        showSuccessMessage(message);
      },
      onError: (error) {
        showErrorMessage('エラーが発生しました: $error');
      },
    );
  }



}
