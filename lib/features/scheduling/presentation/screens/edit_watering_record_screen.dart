import 'dart:convert';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ✅ Removed SharedPreferences

/// 급수 기록 편집 화면
class EditWateringRecordScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> record;

  const EditWateringRecordScreen({super.key, required this.record});

  @override
  ConsumerState<EditWateringRecordScreen> createState() =>
      _EditWateringRecordScreenState();
}

class _EditWateringRecordScreenState
    extends ConsumerState<EditWateringRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = '定期的な給水';
  final List<String> _wateringTypes = ['定期的な給水', '追加給水', '手動給水', '自動給水'];

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    // 기존 값들로 초기화
    _amountController.text =
        widget.record['amount']?.toString().replaceAll('ml', '') ?? '';
    _notesController.text = widget.record['notes']?.toString() ?? '';
    _selectedType = widget.record['type']?.toString() ?? '定期的な給水';

    // 시간 파싱
    final timeStr = widget.record['time']?.toString() ?? '';
    final timeParts = timeStr.split(':');
    if (timeParts.length == 2) {
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }
  }

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
      appBar: const SoftGradientAppBar(title: '給水記録を編集'),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기록 정보 카드
              _buildRecordInfoCard(),
              const SizedBox(height: AppSpacing.lg),

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

              // 버튼들
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// 기록 정보 카드
  Widget _buildRecordInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.pointBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.water_drop,
                color: AppColors.pointBlue,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.record['date']} ${widget.record['time']}',
                    style: AppFonts.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.pointDark,
                    ),
                  ),
                  Text(
                    '${widget.record['amount']} - ${widget.record['type']}',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  /// 액션 버튼들
  Widget _buildActionButtons() {
    return Column(
      children: [
        // 삭제 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _deleteRecord,
            icon: const Icon(Icons.delete, color: AppColors.pointBrown),
            label: const Text('記録を削除'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.pointBrown,
              side: const BorderSide(color: AppColors.pointBrown),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 저장/취소 버튼
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: const Text('キャンセル'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ],
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

  /// 기록 저장
  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      // 로컬 데이터로 저장
      final cache = CacheService();
      await cache.initialize();

      final recordId = widget.record['id'] as String;

      final wateringRecord = {
        'id': recordId,
        'amount': int.parse(_amountController.text),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'type': _selectedType,
        'notes': _notesController.text,
        'date': DateTime.now().toIso8601String(),
      };

      // 기존 기록 가져오기
      final records = cache.getPersistentCacheList('watering_records') ?? [];
      final updatedRecords = records.map((record) {
        final data = jsonDecode(record) as Map<String, dynamic>;
        if (data['id'] == recordId) {
          return jsonEncode(wateringRecord);
        }
        return record;
      }).toList();

      await cache.setPersistentCacheList('watering_records', updatedRecords);

      if (mounted) {
        SnackBarService.showSuccess(context, '給水記録を更新しました');
        context.pop();
      }
    }
  }

  /// 기록 삭제
  void _deleteRecord() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('記録を削除'),
          content: const Text('この給水記録を削除しますか？この操作は取り消せません。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // 로컬 데이터에서 삭제
                final cache = CacheService();
                await cache.initialize();
                final records =
                    cache.getPersistentCacheList('watering_records') ?? [];
                final currentRecordId = widget.record['id'] as String;
                final filteredRecords = records.where((record) {
                  final data = jsonDecode(record) as Map<String, dynamic>;
                  return data['id'] != currentRecordId;
                }).toList();

                await cache.setPersistentCacheList(
                  'watering_records',
                  filteredRecords,
                );

                if (mounted) {
                  SnackBarService.showSuccess(context, '給水記録を削除しました');
                  context.pop();
                }
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }
}
