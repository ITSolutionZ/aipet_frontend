import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../../../shared/shared.dart';
import '../../../../../../../features/facility/data/providers/reservation_provider.dart';
import '../../../../../../../features/pet_profile/data/providers/pet_profile_providers.dart';
import '../../../../../../../features/settings/data/providers/settings_providers.dart';
import '../constants/booking_constants.dart';
import 'facility_booking_state.dart';



part 'facility_booking_controller.g.dart';

/// 予約画面のコントローラー
@riverpod
class FacilityBookingController extends _$FacilityBookingController {
  @override
  FacilityBookingState build() {
    // 初期化時にユーザー情報とペット情報を読み込む
    _loadUserProfile();
    _loadDefaultPet();

    return const FacilityBookingState();
  }

  /// ユーザープロフィール情報の読み込み
  void _loadUserProfile() {
    final userProfileAsync = ref.read(userProfileProvider);
    userProfileAsync.whenData((profile) {
      state = state.copyWith(
        name: profile.userName,
        phone: profile.contact ?? BookingConstants.defaultPhone,
      );
    });
  }

  /// デフォルトペット選択 (最初のペット)
  void _loadDefaultPet() {
    final petsAsync = ref.read(petProfilesProvider);
    petsAsync.whenData((pets) {
      if (pets.isNotEmpty && state.selectedPet == null) {
        state = state.copyWith(
          selectedPet: pets.first,
          selectedPetId: pets.first.id,
        );
      }
    });
  }

  /// 予約者名の更新
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  /// 連絡先の更新
  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  /// 特記事項の更新
  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// ペット選択
  void selectPet(PetProfileEntity pet) {
    state = state.copyWith(
      selectedPet: pet,
      selectedPetId: pet.id,
    );
  }

  /// ペットセレクター展開状態の切り替え
  void togglePetSelectorExpanded() {
    state = state.copyWith(
      isPetSelectorExpanded: !state.isPetSelectorExpanded,
    );
  }

  /// サービス選択
  void selectService(String service) {
    state = state.copyWith(selectedService: service);
  }

  /// 日付選択
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// 時間スロット選択
  void selectTimeSlot(String timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot);
  }

  /// 予約フォームのバリデーション
  bool validateForm() {
    if (state.name.isEmpty) {
      state = state.copyWith(
        errorMessage: BookingConstants.errorEmptyName,
      );
      return false;
    }

    if (state.phone.isEmpty) {
      state = state.copyWith(
        errorMessage: BookingConstants.errorEmptyPhone,
      );
      return false;
    }

    if (state.selectedService == null || state.selectedService!.isEmpty) {
      state = state.copyWith(
        errorMessage: BookingConstants.errorEmptyService,
      );
      return false;
    }

    if (state.selectedPetId == null) {
      state = state.copyWith(
        errorMessage: BookingConstants.errorEmptyPet,
      );
      return false;
    }

    if (state.selectedDate == null || state.selectedTimeSlot == null) {
      state = state.copyWith(
        errorMessage: BookingConstants.errorEmptyDateTime,
      );
      return false;
    }

    state = state.copyWith(errorMessage: null);
    return true;
  }

  /// 予約提出
  Future<bool> submitBooking({
    required String facilityName,
    required String facilityType,
    String? facilityId,
  }) async {
    // バリデーション
    if (!validateForm()) {
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      // 予約作成 (Notifierを使用)
      final notifier = ref.read(reservationsProvider.notifier);
      final reservation = HospitalReservation(
        
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        hospitalId: facilityId ?? '',
        hospitalName: facilityName,
        petId: state.selectedPetId!,
        petName: state.selectedPet?.name ?? '',
        reserverName: state.name,
        phoneNumber: state.phone,
        purpose: state.selectedService!,
        reservationDate: state.selectedDate!,
        timeSlot: state.selectedTimeSlot!,
        symptoms: state.notes.isNotEmpty ? state.notes : null,
        status: ReservationStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await notifier.addReservation(reservation);

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '予約の作成に失敗しました: $e',
      );
      return false;
    }
  }

  /// エラーメッセージをクリア
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
