import 'notification_model.dart';

/// 알림 템플릿 타입
enum TemplateType {
  greeting, // 인사
  reminder, // 리마인더
  celebration, // 축하
  warning, // 경고
  info, // 정보
  custom, // 사용자 정의
}

/// 알림 템플릿 모델
class NotificationTemplate {
  final String id;
  final String name;
  final String description;
  final TemplateType type;
  final NotificationType notificationType;
  final String titleTemplate;
  final String bodyTemplate;
  final List<String> variables; // 템플릿에서 사용할 변수들
  final Map<String, String> defaultValues; // 기본값
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsed;

  const NotificationTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.notificationType,
    required this.titleTemplate,
    required this.bodyTemplate,
    this.variables = const [],
    this.defaultValues = const {},
    this.isActive = true,
    required this.createdAt,
    this.lastUsed,
  });

  /// 템플릿에서 알림 생성
  NotificationModel createNotification({
    Map<String, String>? variables,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
  }) {
    final mergedVariables = Map<String, String>.from(defaultValues)
      ..addAll(variables ?? {});

    final title = _replaceVariables(titleTemplate, mergedVariables);
    final body = _replaceVariables(bodyTemplate, mergedVariables);

    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: notificationType,
      priority: priority,
      createdAt: DateTime.now(),
      data: data,
    );
  }

  /// 변수 치환
  String _replaceVariables(String template, Map<String, String> variables) {
    String result = template;

    for (final entry in variables.entries) {
      result = result.replaceAll('{{${entry.key}}}', entry.value);
    }

    // 치환되지 않은 변수는 기본값으로 대체
    for (final variable in this.variables) {
      if (!variables.containsKey(variable)) {
        result = result.replaceAll('{{$variable}}', '');
      }
    }

    return result;
  }

  /// 템플릿 유효성 검사
  bool isValid() {
    // 필수 변수가 모두 기본값에 있는지 확인
    for (final variable in variables) {
      if (!defaultValues.containsKey(variable)) {
        return false;
      }
    }
    return true;
  }

  /// 템플릿 미리보기 생성
  String getPreview() {
    return _replaceVariables(bodyTemplate, defaultValues);
  }

  /// 템플릿 복사본 생성
  NotificationTemplate copyWith({
    String? id,
    String? name,
    String? description,
    TemplateType? type,
    NotificationType? notificationType,
    String? titleTemplate,
    String? bodyTemplate,
    List<String>? variables,
    Map<String, String>? defaultValues,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return NotificationTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      notificationType: notificationType ?? this.notificationType,
      titleTemplate: titleTemplate ?? this.titleTemplate,
      bodyTemplate: bodyTemplate ?? this.bodyTemplate,
      variables: variables ?? this.variables,
      defaultValues: defaultValues ?? this.defaultValues,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'notificationType': notificationType.name,
      'titleTemplate': titleTemplate,
      'bodyTemplate': bodyTemplate,
      'variables': variables,
      'defaultValues': defaultValues,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory NotificationTemplate.fromJson(Map<String, dynamic> json) {
    return NotificationTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: TemplateType.values.firstWhere((e) => e.name == json['type']),
      notificationType: NotificationType.values.firstWhere(
        (e) => e.name == json['notificationType'],
      ),
      titleTemplate: json['titleTemplate'],
      bodyTemplate: json['bodyTemplate'],
      variables: List<String>.from(json['variables'] ?? []),
      defaultValues: Map<String, String>.from(json['defaultValues'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'])
          : null,
    );
  }

  @override
  String toString() {
    return 'NotificationTemplate(id: $id, name: $name, type: $type, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationTemplate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 기본 템플릿 팩토리
class NotificationTemplateFactory {
  /// 기본 템플릿들 생성
  static List<NotificationTemplate> getDefaultTemplates() {
    return [
      // 인사 템플릿
      NotificationTemplate(
        id: 'greeting_morning',
        name: '아침 인사',
        description: '아침 인사 알림 템플릿',
        type: TemplateType.greeting,
        notificationType: NotificationType.general,
        titleTemplate: '좋은 아침입니다, {{name}}님!',
        bodyTemplate: '오늘도 {{pet_name}}와 함께 행복한 하루 보내세요!',
        variables: ['name', 'pet_name'],
        defaultValues: {'name': '사용자', 'pet_name': '반려동물'},
        createdAt: DateTime.now(),
      ),

      // 리마인더 템플릿
      NotificationTemplate(
        id: 'feeding_reminder',
        name: '급여 리마인더',
        description: '급여 시간 알림 템플릿',
        type: TemplateType.reminder,
        notificationType: NotificationType.feeding,
        titleTemplate: '{{pet_name}} 급여 시간입니다',
        bodyTemplate: '{{time}}에 {{pet_name}}의 {{meal_type}} 급여를 잊지 마세요!',
        variables: ['pet_name', 'time', 'meal_type'],
        defaultValues: {'pet_name': '반려동물', 'time': '오후 6시', 'meal_type': '저녁'},
        createdAt: DateTime.now(),
      ),

      // 축하 템플릿
      NotificationTemplate(
        id: 'walk_celebration',
        name: '산책 축하',
        description: '산책 목표 달성 축하 템플릿',
        type: TemplateType.celebration,
        notificationType: NotificationType.walk,
        titleTemplate: '축하합니다! 🎉',
        bodyTemplate: '{{pet_name}}와 함께 {{goal}} 목표를 달성했습니다! 훌륭합니다!',
        variables: ['pet_name', 'goal'],
        defaultValues: {'pet_name': '반려동물', 'goal': '오늘의 산책'},
        createdAt: DateTime.now(),
      ),

      // 경고 템플릿
      NotificationTemplate(
        id: 'health_warning',
        name: '건강 경고',
        description: '건강 관련 경고 템플릿',
        type: TemplateType.warning,
        notificationType: NotificationType.health,
        titleTemplate: '⚠️ {{pet_name}} 건강 체크',
        bodyTemplate: '{{pet_name}}의 {{health_item}}을 확인해주세요. {{reason}}',
        variables: ['pet_name', 'health_item', 'reason'],
        defaultValues: {
          'pet_name': '반려동물',
          'health_item': '건강 상태',
          'reason': '정기 체크가 필요합니다',
        },
        createdAt: DateTime.now(),
      ),

      // 정보 템플릿
      NotificationTemplate(
        id: 'appointment_info',
        name: '예약 정보',
        description: '예약 관련 정보 템플릿',
        type: TemplateType.info,
        notificationType: NotificationType.reservation,
        titleTemplate: '예약 알림: {{service_type}}',
        bodyTemplate:
            '{{date}} {{time}}에 {{service_type}} 예약이 있습니다. {{location}}에서 진행됩니다.',
        variables: ['service_type', 'date', 'time', 'location'],
        defaultValues: {
          'service_type': '건강검진',
          'date': '내일',
          'time': '오후 2시',
          'location': '동물병원',
        },
        createdAt: DateTime.now(),
      ),

      // 사용자 정의 템플릿
      NotificationTemplate(
        id: 'custom_template',
        name: '사용자 정의',
        description: '사용자가 직접 만드는 템플릿',
        type: TemplateType.custom,
        notificationType: NotificationType.general,
        titleTemplate: '{{title}}',
        bodyTemplate: '{{message}}',
        variables: ['title', 'message'],
        defaultValues: {'title': '제목', 'message': '메시지'},
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// 템플릿 타입별로 필터링
  static List<NotificationTemplate> filterByType(
    List<NotificationTemplate> templates,
    TemplateType type,
  ) {
    return templates.where((template) => template.type == type).toList();
  }

  /// 알림 타입별로 필터링
  static List<NotificationTemplate> filterByNotificationType(
    List<NotificationTemplate> templates,
    NotificationType notificationType,
  ) {
    return templates
        .where((template) => template.notificationType == notificationType)
        .toList();
  }

  /// 활성화된 템플릿만 필터링
  static List<NotificationTemplate> filterActive(
    List<NotificationTemplate> templates,
  ) {
    return templates.where((template) => template.isActive).toList();
  }
}
