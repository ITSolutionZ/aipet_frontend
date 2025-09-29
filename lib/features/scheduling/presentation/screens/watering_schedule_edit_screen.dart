import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      amountController: amountController,
      formKey: formKey,
      selectedTime: selectedTime,
      currentAmount: currentAmount,
      currentTime: currentTime,
    );
  }

  void updateAmount(String amount) {
    state = state.copyWith(amount: amount);
  }

  void updateTime(TimeOfDay time) {
    state = state.copyWith(selectedTime: time);
  }

  void updateMealType(String mealType) {
    state = state.copyWith(mealType: mealType);
  }

  Future<void> saveSchedule() async {
    if (state.formKey?.currentState?.validate() ?? false) {
      // 저장 로직
      state = state.copyWith(isLoading: true);

      // Mock 저장 로직
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(isLoading: false, isSaved: true);
    }
  }
}

/// 급수 스케줄 편집 상태
class WateringScheduleEditState {
  final TextEditingController? amountController;
  final GlobalKey<FormState>? formKey;
  final TimeOfDay selectedTime;
  final String amount;
  final String mealType;
  final String currentAmount;
  final String currentTime;
  final bool isLoading;
  final bool isSaved;

  const WateringScheduleEditState({
    this.amountController,
    this.formKey,
    this.selectedTime = const TimeOfDay(hour: 8, minute: 0),
    this.amount = '',
    this.mealType = '朝食',
    this.currentAmount = '200ml',
    this.currentTime = '08:00',
    this.isLoading = false,
    this.isSaved = false,
  });

  WateringScheduleEditState copyWith({
    TextEditingController? amountController,
    GlobalKey<FormState>? formKey,
    TimeOfDay? selectedTime,
    String? amount,
    String? mealType,
    String? currentAmount,
    String? currentTime,
    bool? isLoading,
    bool? isSaved,
  }) {
    return WateringScheduleEditState(
      amountController: amountController ?? this.amountController,
      formKey: formKey ?? this.formKey,
      selectedTime: selectedTime ?? this.selectedTime,
      amount: amount ?? this.amount,
      mealType: mealType ?? this.mealType,
      currentAmount: currentAmount ?? this.currentAmount,
      currentTime: currentTime ?? this.currentTime,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// 급수 스케줄 편집 화면
class WateringScheduleEditScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  final String currentAmount;
  final String currentTime;
  final String mealType;

  const WateringScheduleEditScreen({
    super.key,
    required this.scheduleId,
    required this.currentAmount,
    required this.currentTime,
    required this.mealType,
  });

  @override
  ConsumerState<WateringScheduleEditScreen> createState() =>
      _WateringScheduleEditScreenState();
}

class _WateringScheduleEditScreenState
    extends ConsumerState<WateringScheduleEditScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(wateringScheduleEditProvider(widget.scheduleId).notifier)
          .initialize(widget.currentAmount, widget.currentTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wateringScheduleEditProvider(widget.scheduleId));
    final controller = ref.read(
      wateringScheduleEditProvider(widget.scheduleId).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('급수 스케줄 편집'),
        backgroundColor: AppColors.pointBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: state.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 현재 설정 표시
              _buildCurrentSettings(state),
              const SizedBox(height: AppSpacing.lg),

              // 급수량 입력
              _buildAmountInput(state, controller),
              const SizedBox(height: AppSpacing.lg),

              // 시간 선택
              _buildTimeSelector(state, controller),
              const SizedBox(height: AppSpacing.lg),

              // 저장 버튼
              _buildSaveButton(state, controller),
            ],
          ),
        ),
      ),
    );
  }

  /// 현재 설정 표시
  Widget _buildCurrentSettings(WateringScheduleEditState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.water_drop, color: AppColors.pointBlue, size: 32),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.mealType,
                    style: AppFonts.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.pointDark,
                    ),
                  ),
                  Text(
                    '現在の設定: ${state.currentTime} - ${state.currentAmount}',
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
  Widget _buildAmountInput(
    WateringScheduleEditState state,
    WateringScheduleEditController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '급수량 설정',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: state.amountController,
              decoration: const InputDecoration(
                labelText: '급수량 (ml)',
                border: OutlineInputBorder(),
                suffixText: 'ml',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '급수량을 입력해주세요';
                }
                final amount = int.tryParse(value);
                if (amount == null || amount <= 0) {
                  return '올바른 급수량을 입력해주세요';
                }
                return null;
              },
              onChanged: controller.updateAmount,
            ),
          ],
        ),
      ),
    );
  }

  /// 시간 선택 위젯
  Widget _buildTimeSelector(
    WateringScheduleEditState state,
    WateringScheduleEditController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '시간 설정',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
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
              onTap: () => _selectTime(state, controller),
            ),
          ],
        ),
      ),
    );
  }

  /// 시간 선택
  Future<void> _selectTime(
    WateringScheduleEditState state,
    WateringScheduleEditController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: state.selectedTime,
    );
    if (picked != null) {
      controller.updateTime(picked);
    }
  }

  /// 저장 버튼
  Widget _buildSaveButton(
    WateringScheduleEditState state,
    WateringScheduleEditController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isLoading ? null : controller.saveSchedule,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        child: state.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('保存'),
      ),
    );
  }
}
