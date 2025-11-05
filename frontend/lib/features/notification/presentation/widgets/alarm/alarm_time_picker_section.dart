import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../../../../shared/shared.dart';
/// アラーム時間選択セクション
///
/// AM/PM選択と時間・分ホイールを提供
class AlarmTimePickerSection extends StatefulWidget {
  final DateTime selectedTime;
  final ValueChanged<DateTime> onTimeChanged;

  const AlarmTimePickerSection({
    super.key,
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  State<AlarmTimePickerSection> createState() => _AlarmTimePickerSectionState();
}

class _AlarmTimePickerSectionState extends State<AlarmTimePickerSection> {
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final FocusNode _hourFocusNode = FocusNode();
  final FocusNode _minuteFocusNode = FocusNode();
  bool _isEditingHour = false;
  bool _isEditingMinute = false;

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _hourFocusNode.dispose();
    _minuteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointDark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AM/PM 選択
          _buildAmPmSelector(),
          const SizedBox(width: AppSpacing.lg),
          // 時間選択器
          _buildTimeWheels(),
        ],
      ),
    );
  }

  /// AM/PM セレクター
  Widget _buildAmPmSelector() {
    return Column(
      children: [
        _buildAmPmButton(true),
        const SizedBox(height: AppSpacing.sm),
        _buildAmPmButton(false),
      ],
    );
  }

  /// AM/PM ボタン
  Widget _buildAmPmButton(bool isAm) {
    final isSelected = (widget.selectedTime.hour < 12) == isAm;
    return GestureDetector(
      onTap: () => _handleAmPmChange(isAm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointPink
              : AppColors.pointGray.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Text(
          isAm ? '午前' : '午後',
          style: AppFonts.titleMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.pointGray,
          ),
        ),
      ),
    );
  }

  /// AM/PM 変更処理
  void _handleAmPmChange(bool isAm) {
    final currentHour = widget.selectedTime.hour;
    final newHour = isAm
        ? (currentHour >= 12 ? currentHour - 12 : currentHour)
        : (currentHour < 12 ? currentHour + 12 : currentHour);

    widget.onTimeChanged(
      DateTime(
        widget.selectedTime.year,
        widget.selectedTime.month,
        widget.selectedTime.day,
        newHour,
        widget.selectedTime.minute,
      ),
    );
  }

  /// 時間ホイール
  Widget _buildTimeWheels() {
    return Row(
      children: [
        _buildTimeWheel(
          value: widget.selectedTime.hour % 12 == 0
              ? 12
              : widget.selectedTime.hour % 12,
          min: 1,
          max: 12,
          isMinute: false,
          onChanged: (value) {
            final hour = widget.selectedTime.hour >= 12
                ? (value == 12 ? 12 : value + 12)
                : (value == 12 ? 0 : value);
            widget.onTimeChanged(
              DateTime(
                widget.selectedTime.year,
                widget.selectedTime.month,
                widget.selectedTime.day,
                hour,
                widget.selectedTime.minute,
              ),
            );
          },
        ),
        const Text(
          ' : ',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: AppColors.pointDark,
          ),
        ),
        _buildTimeWheel(
          value: widget.selectedTime.minute,
          min: 0,
          max: 59,
          isMinute: true,
          onChanged: (value) {
            widget.onTimeChanged(
              DateTime(
                widget.selectedTime.year,
                widget.selectedTime.month,
                widget.selectedTime.day,
                widget.selectedTime.hour,
                value,
              ),
            );
          },
        ),
      ],
    );
  }

  /// 時間/分ホイール
  Widget _buildTimeWheel({
    required int value,
    required int min,
    required int max,
    required bool isMinute,
    required ValueChanged<int> onChanged,
  }) {
    final isEditing = isMinute ? _isEditingMinute : _isEditingHour;
    final controller = isMinute ? _minuteController : _hourController;
    final focusNode = isMinute ? _minuteFocusNode : _hourFocusNode;

    return Container(
      height: 140,
      width: 80,
      decoration: BoxDecoration(
        color: AppColors.pointGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // 上矢印
          SizedBox(
            height: 32,
            child: IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: Icon(
                Icons.keyboard_arrow_up,
                color: value < max ? AppColors.pointBrown : AppColors.pointGray,
              ),
            ),
          ),
          // 数字表示
          Expanded(
            child: Center(
              child: isEditing
                  ? _buildEditableTimeField(
                      controller,
                      focusNode,
                      min,
                      max,
                      isMinute,
                      onChanged,
                    )
                  : _buildTappableTimeDisplay(value, isMinute),
            ),
          ),
          // 下矢印
          SizedBox(
            height: 32,
            child: IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: value > min ? AppColors.pointBrown : AppColors.pointGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 編集可能な時間フィールド
  Widget _buildEditableTimeField(
    TextEditingController controller,
    FocusNode focusNode,
    int min,
    int max,
    bool isMinute,
    ValueChanged<int> onChanged,
  ) {
    return SizedBox(
      width: 70,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        autofocus: true,
        maxLength: 2,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w300,
          color: AppColors.pointDark,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onSubmitted: (text) {
          final newValue = int.tryParse(text);
          if (newValue != null && newValue >= min && newValue <= max) {
            onChanged(newValue);
          }
          setState(() {
            if (isMinute) {
              _isEditingMinute = false;
            } else {
              _isEditingHour = false;
            }
          });
        },
      ),
    );
  }

  /// タップ可能な時間表示
  Widget _buildTappableTimeDisplay(int value, bool isMinute) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isMinute) {
            _isEditingMinute = true;
            _minuteController.text = value.toString().padLeft(2, '0');
            _minuteController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _minuteController.text.length,
            );
          } else {
            _isEditingHour = true;
            _hourController.text = value.toString();
            _hourController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _hourController.text.length,
            );
          }
        });
      },
      child: Text(
        isMinute ? value.toString().padLeft(2, '0') : value.toString(),
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w300,
          color: AppColors.pointDark,
        ),
      ),
    );
  }
}

