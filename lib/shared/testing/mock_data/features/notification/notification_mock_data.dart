import 'package:aipet_frontend/features/notification/notification.dart';

/// 알림 Mock 데이터
class NotificationMockData {
  /// 기본 알림 목록
  static List<NotificationModel> get notifications => [
    // 급여 알림
    NotificationModel(
      id: '1',
      title: '食事時間です',
      body: 'ポチの食事時間が近づいています。餌を準備してください。',
      type: NotificationType.feeding,
      priority: NotificationPriority.high,
      status: NotificationStatus.unread,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      data: {
        'petName': 'ポチ',
        'petId': 'pet_001',
        'feedingTime': '18:00',
        'actionUrl': '/feeding',
      },
      actions: [
        const NotificationAction(
          id: 'feed_now',
          title: '今すぐ給餌',
          type: 'take_action',
          data: {'action': 'feed_now', 'petId': 'pet_001'},
        ),
        const NotificationAction(
          id: 'snooze',
          title: '10分後に再通知',
          type: 'dismiss',
          data: {'snooze': 10},
        ),
      ],
    ),

    // 산책 알림
    NotificationModel(
      id: '2',
      title: '散歩時間です',
      body: 'ポチの散歩時間です。天気も良いので一緒に散歩しましょう。',
      type: NotificationType.walk,
      priority: NotificationPriority.normal,
      status: NotificationStatus.unread,
      createdAt: DateTime.now().subtract(Duration(hours: 1)),
      data: {
        'petName': 'ポチ',
        'petId': 'pet_001',
        'walkTime': '19:00',
        'weather': '晴れ',
        'actionUrl': '/walk',
      },
      actions: [
        const NotificationAction(
          id: 'start_walk',
          title: '散歩開始',
          type: 'take_action',
          data: {'action': 'start_walk', 'petId': 'pet_001'},
        ),
        const NotificationAction(
          id: 'reschedule',
          title: '時間変更',
          type: 'open_screen',
          data: {'screen_path': '/walk/schedule'},
        ),
      ],
    ),

    // 건강 알림
    NotificationModel(
      id: '3',
      title: '健康チェック',
      body: 'ポチの定期健康診断の予約を確認してください。',
      type: NotificationType.health,
      priority: NotificationPriority.normal,
      status: NotificationStatus.read,
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      readAt: DateTime.now().subtract(Duration(hours: 2)),
      data: {
        'petName': 'ポチ',
        'petId': 'pet_001',
        'checkupDate': '2024-01-15',
        'actionUrl': '/health',
      },
      actions: [
        const NotificationAction(
          id: 'book_appointment',
          title: '予約する',
          type: 'open_screen',
          data: {'screen_path': '/health/appointment'},
        ),
        const NotificationAction(
          id: 'view_details',
          title: '詳細を見る',
          type: 'view_details',
        ),
      ],
    ),

    // 약물 알림
    NotificationModel(
      id: '4',
      title: '薬の時間です',
      body: 'ポチの薬を飲ませる時間です。忘れずに与えてください。',
      type: NotificationType.medication,
      priority: NotificationPriority.high,
      status: NotificationStatus.unread,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      data: {
        'petName': 'ポチ',
        'petId': 'pet_001',
        'medicationName': '抗生物質',
        'dosage': '1錠',
        'actionUrl': '/health/medication',
      },
      actions: [
        const NotificationAction(
          id: 'give_medication',
          title: '薬を与える',
          type: 'take_action',
          data: {'action': 'give_medication', 'petId': 'pet_001'},
        ),
        const NotificationAction(
          id: 'mark_given',
          title: '与えた',
          type: 'confirm',
          data: {'medication_given': true},
        ),
      ],
    ),

    // 예약 알림
    NotificationModel(
      id: '5',
      title: 'グルーミング予約',
      body: '明日のグルーミング予約を確認してください。時間: 14:00',
      type: NotificationType.reservation,
      priority: NotificationPriority.normal,
      status: NotificationStatus.unread,
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      data: {
        'petName': 'ポチ',
        'petId': 'pet_001',
        'service': 'グルーミング',
        'date': '2024-01-15',
        'time': '14:00',
        'facility': 'ペットサロン',
        'actionUrl': '/facility/grooming',
      },
      actions: [
        const NotificationAction(
          id: 'confirm_reservation',
          title: '予約確認',
          type: 'confirm',
          data: {'reservation_confirmed': true},
        ),
        const NotificationAction(
          id: 'reschedule',
          title: '時間変更',
          type: 'open_screen',
          data: {'screen_path': '/facility/reschedule'},
        ),
        const NotificationAction(
          id: 'cancel',
          title: 'キャンセル',
          type: 'cancel',
          data: {'reservation_cancelled': true},
        ),
      ],
    ),

    // 시스템 알림
    NotificationModel(
      id: '6',
      title: 'アプリ更新',
      body: '新しいバージョンが利用可能です。更新して最新機能をお楽しみください。',
      type: NotificationType.system,
      priority: NotificationPriority.low,
      status: NotificationStatus.unread,
      createdAt: DateTime.now().subtract(Duration(hours: 3)),
      data: {
        'version': '2.1.0',
        'updateSize': '15.2MB',
        'actionUrl': '/settings/update',
      },
      actions: [
        const NotificationAction(
          id: 'update_now',
          title: '今すぐ更新',
          type: 'open_screen',
          data: {'screen_path': '/settings/update'},
        ),
        const NotificationAction(
          id: 'remind_later',
          title: '後で',
          type: 'dismiss',
          data: {'remind_later': true},
        ),
      ],
    ),

    // 긴급 알림
    NotificationModel(
      id: '7',
      title: '緊急連絡',
      body: 'ポチの健康状態に注意が必要です。獣医師に相談することをお勧めします。',
      type: NotificationType.emergency,
      priority: NotificationPriority.urgent,
      status: NotificationStatus.unread,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      data: {
        'petName': 'ポチ',
        'petId': 'pet_001',
        'symptom': '食欲不振',
        'severity': 'medium',
        'actionUrl': '/health/emergency',
      },
      actions: [
        const NotificationAction(
          id: 'call_vet',
          title: '獣医師に連絡',
          type: 'take_action',
          data: {'action': 'call_vet', 'phone': '03-1234-5678'},
        ),
        const NotificationAction(
          id: 'view_symptoms',
          title: '症状を詳しく見る',
          type: 'view_details',
          data: {'screen_path': '/health/symptoms'},
        ),
      ],
    ),

    // 리마인더 알림
    NotificationModel(
      id: '8',
      title: 'リマインダー',
      body: 'ポチの体重測定を忘れていませんか？毎週の測定をお忘れなく。',
      type: NotificationType.reminder,
      priority: NotificationPriority.low,
      status: NotificationStatus.unread,
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
      data: {
        'petName': 'ポチ',
        'petId': 'pet_001',
        'task': '体重測定',
        'frequency': '週1回',
        'actionUrl': '/health/weight',
      },
      actions: [
        const NotificationAction(
          id: 'record_weight',
          title: '体重を記録',
          type: 'take_action',
          data: {'action': 'record_weight', 'petId': 'pet_001'},
        ),
        const NotificationAction(
          id: 'snooze',
          title: '明日に延期',
          type: 'dismiss',
          data: {'snooze': 24},
        ),
      ],
    ),

    // 미용 알림
    NotificationModel(
      id: '9',
      title: 'グルーミング',
      body: 'ポチの爪切りとブラッシングの時間です。',
      type: NotificationType.grooming,
      priority: NotificationPriority.normal,
      status: NotificationStatus.read,
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      readAt: DateTime.now().subtract(Duration(hours: 1)),
      data: {
        'petName': 'ポチ',
        'petId': 'pet_001',
        'groomingType': '爪切り・ブラッシング',
        'lastGrooming': '2024-01-10',
        'actionUrl': '/health/grooming',
      },
      actions: [
        const NotificationAction(
          id: 'start_grooming',
          title: 'グルーミング開始',
          type: 'take_action',
          data: {'action': 'start_grooming', 'petId': 'pet_001'},
        ),
        const NotificationAction(
          id: 'schedule_professional',
          title: 'プロに依頼',
          type: 'open_screen',
          data: {'screen_path': '/facility/grooming'},
        ),
      ],
    ),

    // 일반 알림
    NotificationModel(
      id: '10',
      title: 'お知らせ',
      body: '新しいペット用品が入荷しました。チェックしてみてください。',
      type: NotificationType.general,
      priority: NotificationPriority.low,
      status: NotificationStatus.unread,
      createdAt: DateTime.now().subtract(Duration(hours: 4)),
      data: {'category': 'ペット用品', 'actionUrl': '/shop'},
      actions: [
        const NotificationAction(
          id: 'view_products',
          title: '商品を見る',
          type: 'open_screen',
          data: {'screen_path': '/shop'},
        ),
        const NotificationAction(id: 'dismiss', title: '閉じる', type: 'dismiss'),
      ],
    ),
  ];

  /// 읽지 않은 알림만 필터링
  static List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => n.isUnread).toList();

  /// 읽은 알림만 필터링
  static List<NotificationModel> get readNotifications =>
      notifications.where((n) => !n.isUnread).toList();

  /// 특정 타입의 알림만 필터링
  static List<NotificationModel> getNotificationsByType(
    NotificationType type,
  ) => notifications.where((n) => n.type == type).toList();

  /// 특정 펫의 알림만 필터링
  static List<NotificationModel> getNotificationsByPet(String petId) =>
      notifications.where((n) => n.data?['petId'] == petId).toList();

  /// 긴급 알림만 필터링
  static List<NotificationModel> get urgentNotifications =>
      notifications.where((n) => n.isUrgent).toList();

  /// 오늘 생성된 알림만 필터링
  static List<NotificationModel> get todayNotifications {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    return notifications
        .where(
          (n) =>
              n.createdAt.isAfter(startOfDay) && n.createdAt.isBefore(endOfDay),
        )
        .toList();
  }

  /// 이번 주 생성된 알림만 필터링
  static List<NotificationModel> get thisWeekNotifications {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    return notifications
        .where((n) => n.createdAt.isAfter(startOfWeekDay))
        .toList();
  }

  /// 알림 통계 데이터
  static Map<String, dynamic> get notificationStats => {
    'totalCount': notifications.length,
    'unreadCount': unreadNotifications.length,
    'readCount': readNotifications.length,
    'typeDistribution': {
      'feeding': getNotificationsByType(NotificationType.feeding).length,
      'walk': getNotificationsByType(NotificationType.walk).length,
      'health': getNotificationsByType(NotificationType.health).length,
      'medication': getNotificationsByType(NotificationType.medication).length,
      'reservation': getNotificationsByType(
        NotificationType.reservation,
      ).length,
      'system': getNotificationsByType(NotificationType.system).length,
      'emergency': getNotificationsByType(NotificationType.emergency).length,
      'reminder': getNotificationsByType(NotificationType.reminder).length,
      'grooming': getNotificationsByType(NotificationType.grooming).length,
      'general': getNotificationsByType(NotificationType.general).length,
    },
    'priorityDistribution': {
      'low': notifications
          .where((n) => n.priority == NotificationPriority.low)
          .length,
      'normal': notifications
          .where((n) => n.priority == NotificationPriority.normal)
          .length,
      'high': notifications
          .where((n) => n.priority == NotificationPriority.high)
          .length,
      'urgent': notifications
          .where((n) => n.priority == NotificationPriority.urgent)
          .length,
    },
    'todayCount': todayNotifications.length,
    'thisWeekCount': thisWeekNotifications.length,
  };

  /// 알림 설정 Mock 데이터
  static NotificationSettings get defaultSettings => const NotificationSettings(
    enabled: true,
    typeSettings: {
      NotificationType.general: true,
      NotificationType.reservation: true,
      NotificationType.walk: true,
      NotificationType.feeding: true,
      NotificationType.health: true,
      NotificationType.medication: true,
      NotificationType.system: true,
      NotificationType.food: true,
      NotificationType.appointment: true,
      NotificationType.reminder: true,
      NotificationType.medical: true,
      NotificationType.grooming: true,
      NotificationType.emergency: true,
    },
    soundEnabled: true,
    vibrationEnabled: true,
    badgeEnabled: true,
  );

  /// 테스트용 간단한 알림 생성
  static NotificationModel createTestNotification({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    NotificationStatus? status,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? 'test_${DateTime.now().millisecondsSinceEpoch % 1000}',
      title: title ?? 'テスト通知',
      body: body ?? 'これはテスト通知です。',
      type: type ?? NotificationType.general,
      priority: priority ?? NotificationPriority.normal,
      status: status ?? NotificationStatus.unread,
      createdAt: createdAt ?? DateTime.now(),
      data: data,
    );
  }
}
