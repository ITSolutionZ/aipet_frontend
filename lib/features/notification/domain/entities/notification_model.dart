import 'package:flutter/material.dart';

/// 알림 타입
enum NotificationType {
  /// 일반 알림
  general,

  /// 예약 알림
  reservation,

  /// 산책 알림
  walk,

  /// 급여 알림
  feeding,

  /// 건강 알림
  health,

  /// 약물 알림
  medication,

  /// 시스템 알림
  system,

  /// 음식 알림 (기존 호환성)
  food,

  /// 약속 알림 (기존 호환성)
  appointment,

  /// 리마인더 알림 (기존 호환성)
  reminder,

  /// 의료 알림 (기존 호환성)
  medical,

  /// 미용 알림 (기존 호환성)
  grooming,

  /// 긴급 알림 (기존 호환성)
  emergency,
}

/// NotificationType 확장
extension NotificationTypeExtension on NotificationType {
  /// 알림 타입별 색상
  Color get color {
    switch (this) {
      case NotificationType.general:
        return Colors.blue;
      case NotificationType.reservation:
        return Colors.orange;
      case NotificationType.walk:
        return Colors.green;
      case NotificationType.feeding:
        return Colors.amber;
      case NotificationType.health:
        return Colors.red;
      case NotificationType.medication:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.food:
        return Colors.amber;
      case NotificationType.appointment:
        return Colors.orange;
      case NotificationType.reminder:
        return Colors.blue;
      case NotificationType.medical:
        return Colors.red;
      case NotificationType.grooming:
        return Colors.purple;
      case NotificationType.emergency:
        return Colors.red;
    }
  }

  /// 알림 타입별 아이콘
  IconData get icon {
    switch (this) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.reservation:
        return Icons.calendar_today;
      case NotificationType.walk:
        return Icons.directions_walk;
      case NotificationType.feeding:
        return Icons.restaurant;
      case NotificationType.health:
        return Icons.medical_services;
      case NotificationType.medication:
        return Icons.medication;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.food:
        return Icons.restaurant;
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.medical:
        return Icons.medical_services;
      case NotificationType.grooming:
        return Icons.content_cut;
      case NotificationType.emergency:
        return Icons.warning;
    }
  }

  /// 알림 타입별 표시 이름
  String get name {
    switch (this) {
      case NotificationType.general:
        return '一般';
      case NotificationType.reservation:
        return '予約';
      case NotificationType.walk:
        return '散歩';
      case NotificationType.feeding:
        return '食事';
      case NotificationType.health:
        return '健康';
      case NotificationType.medication:
        return '薬';
      case NotificationType.system:
        return 'システム';
      case NotificationType.food:
        return '食事';
      case NotificationType.appointment:
        return '予約';
      case NotificationType.reminder:
        return 'リマインダー';
      case NotificationType.medical:
        return '医療';
      case NotificationType.grooming:
        return 'グルーミング';
      case NotificationType.emergency:
        return '緊急';
    }
  }
}

/// 알림 우선순위
enum NotificationPriority {
  /// 낮음
  low,

  /// 보통
  normal,

  /// 높음
  high,

  /// 긴급
  urgent,
}

/// 알림 상태
enum NotificationStatus {
  /// 읽지 않음
  unread,

  /// 읽음
  read,

  /// 삭제됨
  deleted,
}

/// 알림 모델
class NotificationModel {
  /// 알림 ID
  final String id;

  /// 알림 제목
  final String title;

  /// 알림 내용
  final String body;

  /// 알림 타입
  final NotificationType type;

  /// 알림 우선순위
  final NotificationPriority priority;

  /// 알림 상태
  final NotificationStatus status;

  /// 생성 시간
  final DateTime createdAt;

  /// 읽은 시간
  final DateTime? readAt;

  /// 만료 시간
  final DateTime? expiresAt;

  /// 관련 데이터 (JSON 형태)
  final Map<String, dynamic>? data;

  /// 액션 버튼들
  final List<NotificationAction>? actions;

  /// 이미지 URL
  final String? imageUrl;

  /// 아이콘
  final String? icon;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.status = NotificationStatus.unread,
    required this.createdAt,
    this.readAt,
    this.expiresAt,
    this.data,
    this.actions,
    this.imageUrl,
    this.icon,
  });

  /// JSON에서 NotificationModel 생성
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NotificationStatus.unread,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      data: json['data'] as Map<String, dynamic>?,
      actions: json['actions'] != null
          ? (json['actions'] as List)
                .map((action) => NotificationAction.fromJson(action))
                .toList()
          : null,
      imageUrl: json['imageUrl'] as String?,
      icon: json['icon'] as String?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'data': data,
      'actions': actions?.map((action) => action.toJson()).toList(),
      'imageUrl': imageUrl,
      'icon': icon,
    };
  }

  /// 읽음 상태로 복사
  NotificationModel copyAsRead() {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      priority: priority,
      status: NotificationStatus.read,
      createdAt: createdAt,
      readAt: DateTime.now(),
      expiresAt: expiresAt,
      data: data,
      actions: actions,
      imageUrl: imageUrl,
      icon: icon,
    );
  }

  /// 삭제 상태로 복사
  NotificationModel copyAsDeleted() {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      priority: priority,
      status: NotificationStatus.deleted,
      createdAt: createdAt,
      readAt: readAt,
      expiresAt: expiresAt,
      data: data,
      actions: actions,
      imageUrl: imageUrl,
      icon: icon,
    );
  }

  /// 만료되었는지 확인
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 읽지 않았는지 확인
  bool get isUnread => status == NotificationStatus.unread;

  /// 긴급한지 확인
  bool get isUrgent => priority == NotificationPriority.urgent;

  /// 액션 URL (data에서 추출)
  String? get actionUrl => data?['actionUrl'] as String?;

  /// 펫 이름 (data에서 추출)
  String? get petName => data?['petName'] as String?;

  /// 메타데이터 (data에서 추출)
  Map<String, dynamic>? get metadata =>
      data?['metadata'] as Map<String, dynamic>?;

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 알림 액션
class NotificationAction {
  /// 액션 ID
  final String id;

  /// 액션 제목
  final String title;

  /// 액션 타입
  final String type;

  /// 액션 데이터
  final Map<String, dynamic>? data;

  const NotificationAction({
    required this.id,
    required this.title,
    required this.type,
    this.data,
  });

  /// JSON에서 NotificationAction 생성
  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'type': type, 'data': data};
  }

  @override
  String toString() {
    return 'NotificationAction(id: $id, title: $title, type: $type)';
  }
}

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
    return 'NotificationSettings(enabled: $enabled, typeSettings: $typeSettings)';
  }
}

/// 조용한 시간 설정
class QuietTimeSettings {
  /// 조용한 시간 활성화
  final bool enabled;

  /// 시작 시간 (HH:mm)
  final String startTime;

  /// 종료 시간 (HH:mm)
  final String endTime;

  /// 요일별 설정 (0=일요일, 6=토요일)
  final List<int> days;

  const QuietTimeSettings({
    this.enabled = false,
    this.startTime = '22:00',
    this.endTime = '08:00',
    this.days = const [0, 1, 2, 3, 4, 5, 6], // 모든 요일
  });

  /// JSON에서 QuietTimeSettings 생성
  factory QuietTimeSettings.fromJson(Map<String, dynamic> json) {
    return QuietTimeSettings(
      enabled: json['enabled'] as bool? ?? false,
      startTime: json['startTime'] as String? ?? '22:00',
      endTime: json['endTime'] as String? ?? '08:00',
      days: (json['days'] as List<dynamic>? ?? [0, 1, 2, 3, 4, 5, 6])
          .map((day) => day as int)
          .toList(),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'startTime': startTime,
      'endTime': endTime,
      'days': days,
    };
  }

  /// 현재 조용한 시간인지 확인
  bool isCurrentlyQuietTime() {
    if (!enabled) return false;

    final now = DateTime.now();
    final currentDay = now.weekday % 7; // 0=일요일, 6=토요일
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // 요일 확인
    if (!days.contains(currentDay)) return false;

    // 시간 확인
    if (startTime.compareTo(endTime) <= 0) {
      // 같은 날 내의 시간 범위 (예: 08:00-22:00)
      return currentTime.compareTo(startTime) >= 0 &&
          currentTime.compareTo(endTime) <= 0;
    } else {
      // 자정을 걸치는 시간 범위 (예: 22:00-08:00)
      return currentTime.compareTo(startTime) >= 0 ||
          currentTime.compareTo(endTime) <= 0;
    }
  }

  @override
  String toString() {
    return 'QuietTimeSettings(enabled: $enabled, startTime: $startTime, endTime: $endTime, days: $days)';
  }
}
