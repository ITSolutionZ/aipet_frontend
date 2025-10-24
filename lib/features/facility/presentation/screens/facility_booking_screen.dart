import 'package:aipet_frontend/features/facility/presentation/screens/booking/constants/booking_constants.dart';
import 'package:aipet_frontend/features/facility/presentation/screens/booking/controllers/facility_booking_controller.dart';
import 'package:aipet_frontend/features/facility/presentation/screens/booking/widgets/booking_header_section.dart';
import 'package:aipet_frontend/features/facility/presentation/screens/booking/widgets/date_time_selector.dart';
import 'package:aipet_frontend/features/facility/presentation/screens/booking/widgets/pet_selection_section.dart';
import 'package:aipet_frontend/features/facility/presentation/screens/booking/widgets/service_selection_section.dart';
import 'package:aipet_frontend/features/facility/presentation/screens/booking/widgets/user_info_section.dart';
import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 施設予約画面
/// リファクタリング済み: ConsumerWidget + Riverpod Controller パターン
class FacilityBookingScreen extends ConsumerWidget {
  final String facilityName;
  final String facilityType;
  final String? facilityId;

  const FacilityBookingScreen({
    super.key,
    required this.facilityName,
    required this.facilityType,
    this.facilityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(facilityBookingControllerProvider.notifier);
    final state = ref.watch(facilityBookingControllerProvider);

    // TextEditingController はローカルで管理（簡略化のため）
    final nameController = TextEditingController(text: state.name);
    final phoneController = TextEditingController(text: state.phone);
    final notesController = TextEditingController(text: state.notes);

    // テキスト変更リスナー
    nameController.addListener(() {
      if (nameController.text != state.name) {
        controller.updateName(nameController.text);
      }
    });
    phoneController.addListener(() {
      if (phoneController.text != state.phone) {
        controller.updatePhone(phoneController.text);
      }
    });
    notesController.addListener(() {
      if (notesController.text != state.notes) {
        controller.updateNotes(notesController.text);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB89B8A), // ブラウングラデーション開始
              Color(0xFFA08A7A), // ブラウングラデーション中間
              Color(0xFF967E6D), // ブラウングラデーション終了
            ],
          ),
        ),
        child: Column(
          children: [
            // 施設情報ヘッダーセクション
            BookingHeaderSection(
              facilityName: facilityName,
              facilityType: facilityType,
            ),
            // メインコンテンツ
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundGray,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Form(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),

                        // 施設情報表示
                        _buildFacilityInfo(),
                        const SizedBox(height: AppSpacing.xl),

                        // 予約者情報
                        UserInfoSection(
                          nameController: nameController,
                          phoneController: phoneController,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ペット情報
                        _buildSectionTitle(BookingConstants.titlePetInfo),
                        const SizedBox(height: AppSpacing.md),
                        PetSelectionSection(
                          selectedPet: state.selectedPet,
                          isPetSelectorExpanded: state.isPetSelectorExpanded,
                          onPetSelected: (pet) {
                            controller.selectPet(pet);
                            controller.togglePetSelectorExpanded();
                          },
                          onToggleExpanded:
                              controller.togglePetSelectorExpanded,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // サービス選択
                        _buildSectionTitle(BookingConstants.titleServiceSelect),
                        const SizedBox(height: AppSpacing.md),
                        ServiceSelectionSection(
                          selectedService: state.selectedService,
                          facilityType: facilityType,
                          onServiceChanged: (service) {
                            if (service != null) {
                              controller.selectService(service);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 予約日時
                        _buildSectionTitle(BookingConstants.titleDateTime),
                        const SizedBox(height: AppSpacing.md),
                        DateTimeSelector(
                          selectedDate: state.selectedDate,
                          selectedTimeSlot: state.selectedTimeSlot,
                          onTap:
                              () => _showDateTimeBottomSheet(
                                context,
                                controller,
                                state.selectedDate,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 特記事項
                        _buildSectionTitle(BookingConstants.titleNotes),
                        const SizedBox(height: AppSpacing.md),
                        _buildNotesField(notesController),
                        const SizedBox(height: AppSpacing.xl),

                        // 予約ボタン
                        _buildBookingButton(
                          context,
                          ref,
                          controller,
                          state.isSubmitting,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.pointBrown,
      foregroundColor: Colors.white,
      title: const Text('施設予約'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildFacilityInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(_getFacilityIcon(), color: Colors.blue[700], size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facilityName,
                  style: AppFonts.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$facilityTypeの予約を進めます',
                  style: AppFonts.bodySmall.copyWith(color: Colors.blue[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.titleSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildNotesField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: BookingConstants.hintNotes,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.pointGreen),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  Widget _buildBookingButton(
    BuildContext context,
    WidgetRef ref,
    FacilityBookingController controller,
    bool isSubmitting,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            isSubmitting
                ? null
                : () => _handleBooking(context, ref, controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
        ),
        child:
            isSubmitting
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  BookingConstants.buttonBook,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  Future<void> _handleBooking(
    BuildContext context,
    WidgetRef ref,
    FacilityBookingController controller,
  ) async {
    final success = await controller.submitBooking(
      facilityName: facilityName,
      facilityType: facilityType,
      facilityId: facilityId,
    );

    if (context.mounted) {
      if (success) {
        SnackBarService.showSuccess(context, '予約が完了しました');
        context.pop();
      } else {
        final errorMessage =
            ref.read(facilityBookingControllerProvider).errorMessage ??
            '予約に失敗しました';
        SnackBarService.showError(context, errorMessage);
      }
    }
  }

  void _showDateTimeBottomSheet(
    BuildContext context,
    FacilityBookingController controller,
    DateTime? currentSelectedDate,
  ) {
    DateTime? tempSelectedDate = currentSelectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // ヘッダー
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '予約日時選択',
                            style: AppFonts.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    // 日付選択 (簡易版カレンダー)
                    Expanded(
                      child: _buildSimpleDatePicker(tempSelectedDate, (date) {
                        setModalState(() {
                          tempSelectedDate = date;
                        });
                      }),
                    ),
                    // 確認ボタン
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              tempSelectedDate != null
                                  ? () {
                                    controller.selectDate(tempSelectedDate!);
                                    controller.selectTimeSlot('09:00');
                                    Navigator.pop(context);
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pointGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.md,
                              ),
                            ),
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: const Text(
                            '確認',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildSimpleDatePicker(
    DateTime? selectedDate,
    ValueChanged<DateTime> onDateSelected,
  ) {
    final today = DateTime.now();
    final dates = List.generate(
      14,
      (i) => DateTime(today.year, today.month, today.day + i),
    );

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final isSelected =
            selectedDate != null &&
            selectedDate.year == date.year &&
            selectedDate.month == date.month &&
            selectedDate.day == date.day;

        return InkWell(
          onTap: () => onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.pointBrown.withValues(alpha: 0.1)
                      : Colors.white,
              border: Border.all(
                color: isSelected ? AppColors.pointBrown : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: isSelected ? AppColors.pointBrown : Colors.grey,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '${date.year}年${date.month}月${date.day}日 (${_getWeekdayJa(date.weekday)})',
                  style: AppFonts.bodyMedium.copyWith(
                    color: isSelected ? AppColors.pointBrown : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  const Icon(Icons.check_circle, color: AppColors.pointBrown),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getWeekdayJa(int weekday) {
    return BookingConstants.weekdaysJa[weekday % 7];
  }

  IconData _getFacilityIcon() {
    switch (facilityType) {
      case '美容室':
      case '미용실':
        return Icons.content_cut;
      case 'カフェ':
      case '카페':
        return Icons.local_cafe;
      case 'ホテル':
      case '호텔':
        return Icons.hotel;
      case '遊び場':
      case '놀이터':
        return Icons.park;
      case '教育センター':
      case '교육센터':
        return Icons.school;
      default:
        return Icons.place;
    }
  }
}
