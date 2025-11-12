import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/shared.dart';
import '../../../controllers/pet_profile_unified_controller.dart';

/// 예약/스케줄 섹션
///
/// Pet Health Tab에서 분리된 독립적인 위젯
/// 예약 정보의 CRUD를 담당합니다.
class AppointmentSection extends ConsumerStatefulWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const AppointmentSection({
    super.key,
    required this.pet,
    this.isEditMode = false,
  });

  @override
  ConsumerState<AppointmentSection> createState() => _AppointmentSectionState();
}

class _AppointmentSectionState extends ConsumerState<AppointmentSection> {
  late List<Map<String, dynamic>> _appointments;

  @override
  void initState() {
    super.initState();
    _loadAppointmentsData();
  }

  @override
  void didUpdateWidget(AppointmentSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pet.id != widget.pet.id ||
        (oldWidget.isEditMode && !widget.isEditMode)) {
      LoggerService.debug('🔄 예약 데이터 갱신');
      _loadAppointmentsData();
    }
  }

  void _loadAppointmentsData() {
    final additionalInfo = widget.pet.additionalInfo ?? {};
    _appointments =
        (additionalInfo['appointments'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    LoggerService.debug('✅ 예약 ${_appointments.length}건 로드');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '予約・スケジュール',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            if (widget.isEditMode)
              TextButton.icon(
                onPressed: _showAddAppointmentDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('追加'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.pointBrown,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_appointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.pointOffWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '予約がありません',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              ),
            ),
          )
        else
          ..._appointments.map((appointment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GenericInfoCard.withIcon(
                icon: Icons.schedule,
                iconColor: AppColors.pointBlue,
                iconBackgroundColor: AppColors.pointBlue.withValues(alpha: 0.1),
                title: appointment['title'] ?? '',
                subtitle:
                    '${_formatDateTime(appointment['date'], appointment['time'])} • ${appointment['hospital'] ?? ''}',
                badge: '予約済み',
                badgeColor: AppColors.pointBlue,
              ),
            );
          }),
      ],
    );
  }

  String _formatDateTime(dynamic date, dynamic time) {
    if (date == null) return '';
    try {
      final dateTime = DateTime.parse(date.toString());
      final dateStr = '${dateTime.year}年${dateTime.month}月${dateTime.day}日';

      if (time != null) {
        return '$dateStr $time';
      }
      return dateStr;
    } catch (e) {
      return '';
    }
  }

  void _showAddAppointmentDialog() {
    final titleController = TextEditingController();
    final hospitalController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('予約を追加'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '予約内容',
                    hintText: '例: 定期健康診断',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: hospitalController,
                  decoration: const InputDecoration(
                    labelText: '病院名',
                    hintText: '例: 田中動物病院',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  title: const Text('予約日'),
                  subtitle: Text(
                    '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      locale: const Locale('ja', 'JP'),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  title: const Text('予約時刻'),
                  subtitle: Text(
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    hospitalController.text.isEmpty) {
                  SnackBarService.showWarning(context, '予約内容と病院名を入力してください');
                  return;
                }

                final timeStr =
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                setState(() {
                  _appointments.add({
                    'title': titleController.text,
                    'hospital': hospitalController.text,
                    'date': selectedDate.toIso8601String(),
                    'time': timeStr,
                  });
                });

                _saveAppointmentsToFormData();

                Navigator.pop(context);
                SnackBarService.showSuccess(context, '予約を追加しました');
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAppointmentsToFormData() {
    ref
        .read(petProfileUnifiedControllerProvider.notifier)
        .updateFormData('appointments', _appointments);

    LoggerService.debug('💾 예약 저장: ${_appointments.length}건');
  }
}
