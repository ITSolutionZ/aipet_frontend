import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 마이크로칩 등록 권고 서비스
class MicrochipReminderService {
  static const String _keyPrefix = 'microchip_reminder_';
  static const String _remindLaterSuffix = '_remind_later';
  static const Duration _remindInterval = Duration(days: 7); // 일주일 후 다시 알림

  /// 마이크로칩 등록이 없는 펫에 대해 모달을 표시해야 하는지 확인
  static Future<bool> shouldShowReminder(PetProfileEntity pet) async {
    // 이미 마이크로칩이 등록된 경우
    final microchipId = pet.additionalInfo?['microchipId'] as String?;
    if (microchipId != null && microchipId.isNotEmpty) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final petId = pet.id;

    // 1주일 후 재표시 설정 확인
    final remindLaterTime = prefs.getInt(
      '$_keyPrefix$petId$_remindLaterSuffix',
    );
    if (remindLaterTime != null) {
      final lastRemindTime = DateTime.fromMillisecondsSinceEpoch(
        remindLaterTime,
      );
      final now = DateTime.now();

      // 7일이 지났는지 확인
      if (now.difference(lastRemindTime) < _remindInterval) {
        return false;
      } else {
        // 7일이 지났으므로 다시 마이크로칩 등록 상태 체크
        final currentMicrochipId =
            pet.additionalInfo?['microchipId'] as String?;
        if (currentMicrochipId != null && currentMicrochipId.isNotEmpty) {
          // 등록되었다면 알림 설정 제거하고 표시하지 않음
          await _clearReminders(petId);
          return false;
        }
        // 아직 등록되지 않았다면 계속 표시
        return true;
      }
    }

    // 처음 표시하는 경우
    return true;
  }

  /// 마이크로칩 등록 권고 모달 표시
  static Future<void> showReminderIfNeeded(
    BuildContext context,
    PetProfileEntity pet, {
    VoidCallback? onRegisterTap,
  }) async {
    if (!await shouldShowReminder(pet)) {
      return;
    }

    if (context.mounted) {
      await MicrochipRegistrationModal.show(
        context,
        petName: pet.name,
        onRegisterTap: () {
          onRegisterTap?.call();
          _clearReminders(pet.id);
        },
        onRemindLater: () => _setRemindLater(pet.id),
        onDismiss: () => _setRemindLater(pet.id), // 1주일 후 재표시
      );
    }
  }

  /// 나중에 알림 설정
  static Future<void> _setRemindLater(String petId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      '$_keyPrefix$petId$_remindLaterSuffix',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 알림 설정 초기화 (등록 완료 시)
  static Future<void> _clearReminders(String petId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$petId$_remindLaterSuffix');
  }

  /// 특정 펫의 알림 설정 리셋 (테스트용)
  static Future<void> resetPetReminders(String petId) async {
    await _clearReminders(petId);
  }

  /// 모든 펫의 알림 설정 리셋 (테스트용)
  static Future<void> resetAllReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
