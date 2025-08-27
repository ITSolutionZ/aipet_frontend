class UserProfileEntity {
  final String id;
  final String name;
  final String email;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarPath,
    required this.createdAt,
    this.lastLoginAt,
  });

  UserProfileEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

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

enum ThemeMode { light, dark, system }

enum DataSyncFrequency { realtime, hourly, daily, manual }

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
