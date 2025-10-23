import 'dart:convert';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ✅ Removed SharedPreferences

/// 급수 기록 추가 화면
class AddWateringRecordScreen extends ConsumerStatefulWidget {
  const AddWateringRecordScreen({super.key});

  @override
  ConsumerState<AddWateringRecordScreen> createState() =>
      _AddWateringRecordScreenState();
}

class _AddWateringRecordScreenState
    extends ConsumerState<AddWateringRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = '定期的な給水';
  final List<String> _wateringTypes = ['定期的な給水', '追加給水', '手動給水', '自動給水'];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: '給水記録を追加'),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 급수량 입력
              _buildAmountInput(),
              const SizedBox(height: AppSpacing.lg),

              // 시간 선택
              _buildTimeSelector(),
              const SizedBox(height: AppSpacing.lg),

              // 급수 타입 선택
              _buildTypeSelector(),
              const SizedBox(height: AppSpacing.lg),

              // 메모 입력
              _buildNotesInput(),
              const SizedBox(height: AppSpacing.xl),

              // 저장 버튼
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 급수량 입력 위젯
  Widget _buildAmountInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '給水量',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '給水量 (ml)',
                hintText: '例: 200',
                suffixText: 'ml',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '給水量を入力してください';
                }
                final amount = int.tryParse(value);
                if (amount == null || amount <= 0) {
                  return '有効な給水量を入力してください';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 시간 선택 위젯
  Widget _buildTimeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '給水時間',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(
                Icons.access_time,
                color: AppColors.pointBlue,
              ),
              title: const Text('時間を選択'),
              subtitle: Text(
                _selectedTime.format(context),
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectTime,
            ),
          ],
        ),
      ),
    );
  }

  /// 급수 타입 선택 위젯
  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '給水タイプ',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._wateringTypes.map(
              (type) => RadioListTile<String>(
                title: Text(type),
                value: type,
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                activeColor: AppColors.pointBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메모 입력 위젯
  Widget _buildNotesInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'メモ',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'メモを入力 (任意)',
                hintText: '例: いつも通り完食',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 저장 버튼
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveWateringRecord,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        child: const Text('給水記録を保存'),
      ),
    );
  }

  /// 시간 선택
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// 급수 기록 저장
  Future<void> _saveWateringRecord() async {
    if (_formKey.currentState!.validate()) {
      // 로컬 데이터로 저장
      final cache = CacheService(); await cache.initialize();

      final wateringRecord = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'amount': int.parse(_amountController.text),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'type': _selectedType,
        'notes': _notesController.text,
        'date': DateTime.now().toIso8601String(),
      };

      // 기존 기록 가져오기
      final records = await cache.getPersistentCacheList('watering_records') ?? [];
      records.add(jsonEncode(wateringRecord));
      await await cache.setPersistentCacheList('watering_records', records);

      if (mounted) {
        SnackBarService.showSuccess(context, '給水記録を保存しました');
        context.pop();
      }
    }
  }
}
