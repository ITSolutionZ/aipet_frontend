import 'package:aipet_frontend/shared/shared.dart';

/// 予約フォームの状態
class FacilityBookingState {
  final String name;
  final String phone;
  final String notes;
  final String? selectedPetId;
  final PetProfileEntity? selectedPet;
  final bool isPetSelectorExpanded;
  final String? selectedService;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  const FacilityBookingState({
    this.name = '',
    this.phone = '010-0000-0000',
    this.notes = '',
    this.selectedPetId,
    this.selectedPet,
    this.isPetSelectorExpanded = false,
    this.selectedService,
    this.selectedDate,
    this.selectedTimeSlot,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  FacilityBookingState copyWith({
    String? name,
    String? phone,
    String? notes,
    String? selectedPetId,
    PetProfileEntity? selectedPet,
    bool? isPetSelectorExpanded,
    String? selectedService,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return FacilityBookingState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      selectedPetId: selectedPetId ?? this.selectedPetId,
      selectedPet: selectedPet ?? this.selectedPet,
      isPetSelectorExpanded: isPetSelectorExpanded ?? this.isPetSelectorExpanded,
      selectedService: selectedService ?? this.selectedService,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
