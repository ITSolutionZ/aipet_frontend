import 'notification_type.dart';
import 'quiet_time_settings.dart';

/// 알림 설정
class NotificationSettings {
  /// 알림 활성화 여부
  final bool enabled;

  /// 알림 타입별 설정
  final Map<NotificationType, bool> typeSettings;

  /// 소리 알림 활성화
  final bool soundEnabled;

  /// 진동 알림 활성화
  final bool vibrationEnabled;

  /// 배지 표시 활성화
  final bool badgeEnabled;

  /// 조용한 시간 설정
  final QuietTimeSettings? quietTime;

  const NotificationSettings({
    this.enabled = true,
    this.typeSettings = const {
      NotificationType.general: true,
      NotificationType.reservation: true,
      NotificationType.walk: true,
      NotificationType.feeding: true,
      NotificationType.health: true,
      NotificationType.medication: true,
      NotificationType.system: true,
    },
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.badgeEnabled = true,
    this.quietTime,
  });

  /// JSON에서 NotificationSettings 생성
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final typeSettingsMap = <NotificationType, bool>{};
    final typeSettingsJson =
        json['typeSettings'] as Map<String, dynamic>? ?? {};

    for (final entry in typeSettingsJson.entries) {
      final type = NotificationType.values.firstWhere(
        (e) => e.name == entry.key,
        orElse: () => NotificationType.general,
      );
      typeSettingsMap[type] = entry.value as bool;
    }

    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      typeSettings: typeSettingsMap,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      badgeEnabled: json['badgeEnabled'] as bool? ?? true,
      quietTime: json['quietTime'] != null
          ? QuietTimeSettings.fromJson(json['quietTime'])
          : null,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    final typeSettingsJson = <String, bool>{};
    for (final entry in typeSettings.entries) {
      typeSettingsJson[entry.key.name] = entry.value;
    }

    return {
      'enabled': enabled,
      'typeSettings': typeSettingsJson,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'badgeEnabled': badgeEnabled,
      'quietTime': quietTime?.toJson(),
    };
  }

  /// 특정 타입의 알림이 활성화되었는지 확인
  bool isTypeEnabled(NotificationType type) {
    return enabled && typeSettings[type] == true;
  }

  /// 현재 조용한 시간인지 확인
  bool get isQuietTime {
    if (quietTime == null || !quietTime!.enabled) return false;
    return quietTime!.isCurrentlyQuietTime();
  }

  /// 설정 복사
  NotificationSettings copyWith({
    bool? enabled,
    Map<NotificationType, bool>? typeSettings,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? badgeEnabled,
    QuietTimeSettings? quietTime,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      typeSettings: typeSettings ?? this.typeSettings,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      badgeEnabled: badgeEnabled ?? this.badgeEnabled,
      quietTime: quietTime ?? this.quietTime,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(isEnabled: $enabled, typeSettings: $typeSettings)';
  }
}
