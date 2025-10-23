import 'package:flutter/material.dart';

import 'pet_registration_form_data.dart';
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';

/// TextEditingController 동기화 헬퍼
///
/// PetRegistrationFormData와 TextEditingController 간의 동기화를 담당
class PetControllerSyncHelper {
  PetControllerSyncHelper._();

  /// 상태로부터 텍스트 컨트롤러 업데이트
  static void updateControllersFromState(
    PetRegistrationFormData formData, {
    required TextEditingController petNameController,
    required TextEditingController birthDateController,
    required TextEditingController adoptionDateController,
    required TextEditingController weightController,
    required TextEditingController appearanceController,
    required TextEditingController guardianNameController,
    required TextEditingController institutionNameController,
    required TextEditingController registrationNumberController,
  }) {
    petNameController.text = formData.petName;

    if (formData.birthDate != null) {
      birthDateController.text = _formatDate(formData.birthDate!);
    }

    if (formData.adoptionDate != null) {
      adoptionDateController.text = _formatDate(formData.adoptionDate!);
    }

    if (formData.weight != null) {
      weightController.text = formData.weight.toString();
    }

    appearanceController.text = formData.appearance ?? '';

    guardianNameController.text = formData.guardianName;
    institutionNameController.text = formData.institutionName;
    registrationNumberController.text = formData.registrationNumber;
  }

  /// DateTime을 YYYY-MM-DD 형식으로 포맷
  static String _formatDate(DateTime date) {
    return DateTimeUtils.formatDateKey(date);
  }

  /// TextEditingController에서 날짜 문자열 생성
  static String formatDateForController(DateTime date) {
    return _formatDate(date);
  }
}
