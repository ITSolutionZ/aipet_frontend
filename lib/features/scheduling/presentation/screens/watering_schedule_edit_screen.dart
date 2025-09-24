import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 급수 스케줄 편집 화면 상태 관리
final wateringScheduleEditProvider =
    StateNotifierProvider.family<
      WateringScheduleEditController,
      WateringScheduleEditState,
      String
    >((ref, scheduleId) => WateringScheduleEditController());

class WateringScheduleEditController
    extends StateNotifier<WateringScheduleEditState> {
  WateringScheduleEditController() : super(const WateringScheduleEditState());

  void initialize(String currentAmount, String currentTime) {
    final amountController = TextEditingController(
      text: currentAmount.replaceAll('ml', ''),
    );
    final formKey = GlobalKey<FormState>();

    TimeOfDay selectedTime = TimeOfDay.now();
    final timeParts = currentTime.split(':');
    if (timeParts.length == 2) {
      selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    state = state.copyWith(
      formKey: formKey,
      amountController: amountController,
      selectedTime: selectedTime,
    );
  }

  void updateTime(TimeOfDay time) {
    state = state.copyWith(selectedTime: time);
  }

  @override
  void dispose() {
    state.amountController?.dispose();
    super.dispose();
  }
}

class WateringScheduleEditState {
  final GlobalKey<FormState>? formKey;
  final TextEditingController? amountController;
  final TimeOfDay selectedTime;

  const WateringScheduleEditState({
    this.formKey,
    this.amountController,
    this.selectedTime = const TimeOfDay(hour: 9, minute: 0),
  });

  WateringScheduleEditState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? amountController,
    TimeOfDay? selectedTime,
  }) {
    return WateringScheduleEditState(
      formKey: formKey ?? this.formKey,
      amountController: amountController ?? this.amountController,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }
}

/// 급수 스케줄 편집 화면
class WateringScheduleEditScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleId = DateTime.now().millisecondsSinceEpoch.toString();
    final state = ref.watch(wateringScheduleEditProvider(scheduleId));

    // Initialize after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(wateringScheduleEditProvider(scheduleId).notifier)
          .initialize(currentAmount, currentTime);
    });

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: '給水スケジュール編集'),
      body: Form(
        key: state.formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 스케줄 정보 카드
              _buildScheduleInfoCard(),
              const SizedBox(height: AppSpacing.lg),

              // 시간 선택
              _buildTimeSelector(state),
              const SizedBox(height: AppSpacing.lg),

              // 급수량 입력
              _buildAmountInput(state),
              const SizedBox(height: AppSpacing.xl),

              // 버튼들
              _buildActionButtons(state),
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
  Widget _buildTimeSelector(WateringScheduleEditState state) {
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
                state.selectedTime.format(context),
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectTime(state),
            ),
          ],
        ),
      ),
    );
  }

  /// 급수량 입력 위젯
  Widget _buildAmountInput(WateringScheduleEditState state) {
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
              controller: state.amountController,
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
  Widget _buildActionButtons(WateringScheduleEditState state) {
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
            onPressed: () => _saveSchedule(state),
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
  Future<void> _selectTime(WateringScheduleEditState state) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: state.selectedTime,
    );
    if (picked != null && picked != state.selectedTime) {
      ref
          .read(wateringScheduleEditProvider(_scheduleId).notifier)
          .updateTime(picked);
    }
  }

  /// 스케줄 저장
  void _saveSchedule(WateringScheduleEditState state) {
    if (state.formKey?.currentState?.validate() ?? false) {
      final updatedSchedule = {
        'mealType': widget.mealType,
        'time': state.selectedTime.format(context),
        'amount': '${state.amountController?.text ?? ''}ml',
      };

      // Mock 저장 로직 (실제로는 API 호출)

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
