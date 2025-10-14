import 'notification_action.dart';
import 'notification_priority.dart';
import 'notification_status.dart';
import 'notification_type.dart';

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
