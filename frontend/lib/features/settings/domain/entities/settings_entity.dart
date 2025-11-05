library;

import 'package:flutter/material.dart';


// UserProfileEntity는 shared/domain/entities에서 import
export 'package:aipet_frontend/shared/domain/entities/user_profile_entity.dart';

/// 앱 설정 엔티티
class AppSettingsEntity {
  final String language;
  final ThemeMode theme;
  final bool notificationsEnabled;
  final bool autoBackup;
  final bool biometricLogin;
  final DataSyncFrequency syncFrequency;

  const AppSettingsEntity({
    required this.language,
    required this.theme,
    required this.notificationsEnabled,
    required this.autoBackup,
    required this.biometricLogin,
    required this.syncFrequency,
  });

  AppSettingsEntity copyWith({
    String? language,
    ThemeMode? theme,
    bool? notificationsEnabled,
    bool? autoBackup,
    bool? biometricLogin,
    DataSyncFrequency? syncFrequency,
  }) {
    return AppSettingsEntity(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoBackup: autoBackup ?? this.autoBackup,
      biometricLogin: biometricLogin ?? this.biometricLogin,
      syncFrequency: syncFrequency ?? this.syncFrequency,
    );
  }
}

// ThemeMode는 Flutter Material에서 제공하는 것을 사용
// import 'package:flutter/material.dart' 필요

/// 데이터 동기화 빈도 열거형
enum DataSyncFrequency { realtime, hourly, daily, manual }

/// 비밀번호 변경 요청
class PasswordChangeRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  bool get isValid {
    return newPassword == confirmPassword && newPassword.length >= 6;
  }
}

/// 데이터 내보내기 결과
class DataExportResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;
  final DateTime exportedAt;

  const DataExportResult({
    required this.success,
    this.filePath,
    this.errorMessage,
    required this.exportedAt,
  });
}
