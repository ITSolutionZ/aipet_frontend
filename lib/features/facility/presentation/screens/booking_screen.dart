import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../controllers/booking_controller.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String facilityId;

  const BookingScreen({super.key, required this.facilityId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final TextEditingController _noteController = TextEditingController();

  // 시간 슬롯
  final List<String> _timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];

  @override
  void initState() {
    super.initState();
    // 컨트롤러를 통해 시설 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingControllerProvider(widget.facilityId).notifier);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleService(int index) {
    ref
        .read(bookingControllerProvider(widget.facilityId).notifier)
        .toggleService(index);
  }

  void _selectTime(String time) {
    ref
        .read(bookingControllerProvider(widget.facilityId).notifier)
        .selectTime(time);
  }

  void _selectDate(DateTime date) {
    ref
        .read(bookingControllerProvider(widget.facilityId).notifier)
        .selectDate(date);
  }

  void _confirmBooking() {
    ref
        .read(bookingControllerProvider(widget.facilityId).notifier)
        .confirmBooking();

    // 에러가 있는지 확인
    final error = ref.read(bookingControllerProvider(widget.facilityId)).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '予約確認',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(
                    bookingControllerProvider(widget.facilityId),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('施設: ${state.facility?.name ?? 'Unknown'}'),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '日付: ${state.selectedDate.year}年 ${state.selectedDate.month}月 ${state.selectedDate.day}日',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('時間: ${state.selectedTime}'),
                      const SizedBox(height: AppSpacing.sm),
                      Text('サービス: ${state.selectedServices.join(', ')}'),
                      if (_noteController.text.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text('メモ: ${_noteController.text}'),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('予約が完了しました。'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.pop();
              },
              child: const Text('確認'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // ignore: unused_local_variable
        final state = ref.watch(bookingControllerProvider(widget.facilityId));

        return Scaffold(
          backgroundColor: AppColors.pointOffWhite,
          appBar: AppBar(
            backgroundColor: AppColors.pointOffWhite,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.pointDark,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Book a date',
              style: AppFonts.fredoka(
                fontSize: AppFonts.lg,
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              // 펫 선택 (Maxi)
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.pointBrown,
                    ),
                    child: const Icon(
                      Icons.pets,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Maxi',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.sm,
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 시설 정보 카드
                _buildFacilityCard(),
                const SizedBox(height: AppSpacing.lg),

                // 날짜 선택
                _buildDateSelection(),
                const SizedBox(height: AppSpacing.lg),

                // 시간 선택
                _buildTimeSelection(),
                const SizedBox(height: AppSpacing.lg),

                // 서비스 선택
                _buildServiceSelection(),
                const SizedBox(height: AppSpacing.lg),

                // 메모 추가
                _buildNoteSection(),
                const SizedBox(height: AppSpacing.lg),

                // 예약 확인 버튼
                _buildConfirmButton(),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFacilityCard() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(bookingControllerProvider(widget.facilityId));

        if (state.facility == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.facility!.name,
                          style: AppFonts.fredoka(
                            fontSize: AppFonts.xl,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              state.facility!.address,
                              style: AppFonts.bodyMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Text(
                              '${state.facility!.rating}',
                              style: AppFonts.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: List.generate(5, (index) {
                                if (index < state.facility!.rating.floor()) {
                                  return const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                } else {
                                  return const Icon(
                                    Icons.star_border,
                                    color: Colors.white,
                                    size: 16,
                                  );
                                }
                              }),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${state.facility!.reviewCount} reviews',
                              style: AppFonts.bodyMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 시설 이미지
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.content_cut,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSelection() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(bookingControllerProvider(widget.facilityId));
        final days = ['土', '日', '月', '火', '水', '木', '金'];
        final selectedDayIndex = state.selectedDate.weekday % 7;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${days[selectedDayIndex]}, ${state.selectedDate.day} ${_getMonthName(state.selectedDate.month)}',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.lg,
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.pointDark,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (index) {
                    final date = DateTime.now().add(Duration(days: index));
                    final dayName = days[date.weekday % 7];
                    final isSelected = date.day == state.selectedDate.day;

                    return GestureDetector(
                      onTap: () => _selectDate(date),
                      child: Container(
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          '${date.day} $dayName',
                          style: AppFonts.bodyMedium.copyWith(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSelection() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(bookingControllerProvider(widget.facilityId));

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '利用可能時間',
                style: AppFonts.fredoka(
                  fontSize: AppFonts.lg,
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _timeSlots.map((time) {
                  final isSelected = state.selectedTime == time;
                  return GestureDetector(
                    onTap: () => _selectTime(time),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        time,
                        style: AppFonts.bodyMedium.copyWith(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceSelection() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(bookingControllerProvider(widget.facilityId));

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'サービス',
                style: AppFonts.fredoka(
                  fontSize: AppFonts.lg,
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Column(
                children: state.services.asMap().entries.map((entry) {
                  final index = entry.key;
                  final service = entry.value;
                  final isSelected = service['selected'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleService(index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey[400]!,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            service['name'],
                            style: AppFonts.bodyMedium.copyWith(
                              color: AppColors.pointDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          service['price'],
                          style: AppFonts.bodyMedium.copyWith(
                            color: AppColors.pointDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '料金は概算です。お支払いは施設で行います。',
                style: AppFonts.bodySmall.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'メモを入力してください',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _noteController,
            maxLength: 250,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'メモを入力してください',
              hintStyle: AppFonts.bodyMedium.copyWith(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              counterText: '${_noteController.text.length}/250',
              counterStyle: AppFonts.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _confirmBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
          child: Text(
            '予約確認',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ];
    return months[month - 1];
  }
}
