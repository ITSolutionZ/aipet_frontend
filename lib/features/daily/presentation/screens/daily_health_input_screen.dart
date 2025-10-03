import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/daily_health_widgets.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DailyHealthInputScreen extends ConsumerStatefulWidget {
  final DailyHealthRecord? existingRecord;

  const DailyHealthInputScreen({super.key, this.existingRecord});

  @override
  ConsumerState<DailyHealthInputScreen> createState() =>
      _DailyHealthInputScreenState();
}

class _DailyHealthInputScreenState
    extends ConsumerState<DailyHealthInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _temperatureController = TextEditingController();
  final _notesController = TextEditingController();

  HealthStatus _selectedHealthStatus = HealthStatus.good;
  final List<HealthSymptom> _symptoms = [];
  bool _isLoading = false;

  String? _selectedPetId;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      _initializeWithExistingRecord();
    }
  }

  void _initializeWithExistingRecord() {
    final record = widget.existingRecord!;
    _temperatureController.text = record.temperature.toString();
    _notesController.text = record.notes ?? '';
    _selectedHealthStatus = record.overallHealth;
    _symptoms.addAll(record.symptoms);
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petProfilesNotifierProvider);

    return petsAsync.when(
      data: (pets) {
        // 첫 번째 펫을 기본 선택으로 설정
        if (_selectedPetId == null && pets.isNotEmpty) {
          _selectedPetId = pets.first.id;
        }

        return Scaffold(
          backgroundColor: AppColors.pointOffWhite,
          appBar: AppBar(
            backgroundColor: AppColors.pointOffWhite,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: PetSelectorWidget(
              selectedPetId: _selectedPetId,
              onPetSelected: (petId) {
                setState(() {
                  _selectedPetId = petId;
                });
              },
            ),
            centerTitle: true,
            actions: [
              Semantics(
                label: '戻るボタン',
                button: true,
                hint: 'タップして前の画面に戻ります',
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DateHeaderWidget(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTemperatureSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildHealthStatusSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSymptomsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildNotesSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSaveButton(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        body: LoadingStateWidget(),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        body: ErrorStateWidget(
          error: error,
          onRetry: () => ref.invalidate(petProfilesNotifierProvider),
        ),
      ),
    );
  }

  Widget _buildTemperatureSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.thermostat, color: Colors.red[500], size: 24),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                '体温測定',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _temperatureController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '体温 (°C)',
              hintText: '37.5',
              suffixText: '°C',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppColors.toneOffWhite,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '体温を入力してください';
              }
              final temperature = double.tryParse(value);
              if (temperature == null) {
                return '正しい数字を入力してください';
              }
              if (temperature < 35.0 || temperature > 42.0) {
                return '体温が正常範囲を超えています';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '正常体温: 37.5°C - 39.2°C',
                    style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.pink[500], size: 24),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                '全体的な健康状態',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            children: HealthStatus.values.map((status) {
              return RadioListTile<HealthStatus>(
                title: Text(status.displayName),
                value: status,
                groupValue: _selectedHealthStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedHealthStatus = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: Colors.orange[500], size: 24),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                '症状',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addSymptom,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('追加'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_symptoms.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                  const Text(
                    '特別な症状はありません',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ..._symptoms.asMap().entries.map((entry) {
              final index = entry.key;
              final symptom = entry.value;
              return _buildSymptomItem(symptom, index);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSymptomItem(HealthSymptom symptom, int index) {
    Color severityColor;
    switch (symptom.severity) {
      case SymptomSeverity.mild:
        severityColor = Colors.yellow[600]!;
        break;
      case SymptomSeverity.moderate:
        severityColor = Colors.orange[600]!;
        break;
      case SymptomSeverity.severe:
        severityColor = Colors.red[600]!;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.toneOffWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  symptom.severity.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: severityColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (symptom.description != null &&
                    symptom.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    symptom.description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeSymptom(index),
            icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_add, color: Colors.green[500], size: 24),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                '追加メモ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '特記事項や追加で記録したい内容を入力してください',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppColors.toneOffWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveHealthRecord,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                widget.existingRecord != null ? '修正する' : '保存する',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _addSymptom() {
    showDialog<HealthSymptom>(
      context: context,
      builder: (context) => _SymptomInputDialog(),
    ).then((symptom) {
      if (symptom != null) {
        setState(() {
          _symptoms.add(symptom);
        });
      }
    });
  }

  void _removeSymptom(int index) {
    setState(() {
      _symptoms.removeAt(index);
    });
  }

  Future<void> _saveHealthRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final temperature = double.parse(_temperatureController.text);
      final notes = _notesController.text.trim();

      final record = DailyHealthRecord(
        id: widget.existingRecord?.id ?? '',
        petId: _selectedPetId ?? '',
        date: DateTime.now(),
        temperature: temperature,
        overallHealth: _selectedHealthStatus,
        symptoms: _symptoms,
        notes: notes.isNotEmpty ? notes : null,
      );

      if (widget.existingRecord != null) {
        await ref
            .read(dailyHealthControllerProvider.notifier)
            .updateHealthRecord(record);
      } else {
        await ref
            .read(dailyHealthControllerProvider.notifier)
            .createHealthRecord(record);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingRecord != null ? '健康記録が修正されました' : '健康記録が保存されました',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存中にエラーが発生しました: $e'),
            backgroundColor: Colors.red,
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

class _SymptomInputDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SymptomInputDialog> createState() =>
      _SymptomInputDialogState();
}

class _SymptomInputDialogState extends ConsumerState<_SymptomInputDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  SymptomSeverity _severity = SymptomSeverity.mild;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('症状追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '症状名',
              hintText: '例: 咳、下痢、食欲不振',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<SymptomSeverity>(
            value: _severity,
            decoration: const InputDecoration(labelText: '重症度'),
            items: SymptomSeverity.values.map((severity) {
              return DropdownMenuItem(
                value: severity,
                child: Text(severity.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _severity = value!;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '詳細説明 (選択事項)',
              hintText: '症状についての詳細な説明',
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              final symptom = HealthSymptom(
                id: 'symptom_${DateTime.now().millisecondsSinceEpoch}',
                name: _nameController.text.trim(),
                severity: _severity,
                description: _descriptionController.text.trim().isNotEmpty
                    ? _descriptionController.text.trim()
                    : null,
              );
              Navigator.of(context).pop(symptom);
            }
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}
