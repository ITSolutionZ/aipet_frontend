import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';

/// 급수 스케줄 편집 화면
class WateringScheduleEditScreen extends ConsumerStatefulWidget {
  final String mealType;
  final String currentTime;
  final String currentAmount;

  const WateringScheduleEditScreen({
    super.key,
    required this.mealType,
    required this.currentTime,
    required this.currentAmount,
  });

  @override
  ConsumerState<WateringScheduleEditScreen> createState() =>
      _WateringScheduleEditScreenState();
}

class _WateringScheduleEditScreenState
    extends ConsumerState<WateringScheduleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    // 현재 값들로 초기화
    _amountController.text = widget.currentAmount.replaceAll('ml', '');

    // 시간 파싱
    final timeParts = widget.currentTime.split(':');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: '給水スケジュール編集'),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 스케줄 정보 카드
              _buildScheduleInfoCard(),
              const SizedBox(height: AppSpacing.lg),

              // 시간 선택
              _buildTimeSelector(),
              const SizedBox(height: AppSpacing.lg),

              // 급수량 입력
              _buildAmountInput(),
              const SizedBox(height: AppSpacing.xl),

              // 버튼들
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// 스케줄 정보 카드
  Widget _buildScheduleInfoCard() {
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
                    widget.mealType,
                    style: AppFonts.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.pointDark,
                    ),
                  ),
                  Text(
                    '現在の設定: ${widget.currentTime} - ${widget.currentAmount}',
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
                '${_selectedTime.format(context)}',
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

  /// 액션 버튼들
  Widget _buildActionButtons() {
    return Row(
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
            onPressed: _saveSchedule,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            child: const Text('保存'),
          ),
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

  /// 스케줄 저장
  void _saveSchedule() {
    if (_formKey.currentState!.validate()) {
      // TODO: 실제 데이터 저장 로직 구현

      final updatedSchedule = {
        'mealType': widget.mealType,
        'time': _selectedTime.format(context),
        'amount': '${_amountController.text}ml',
      };

      // Mock 저장 로직 (실제로는 API 호출)
      print('급수 스케줄 업데이트: $updatedSchedule');

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('給水スケジュールを更新しました'),
          backgroundColor: AppColors.pointGreen,
        ),
      );

      // 이전 화면으로 돌아가기
      context.pop();
    }
  }
}
