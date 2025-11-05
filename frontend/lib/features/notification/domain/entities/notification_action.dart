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
