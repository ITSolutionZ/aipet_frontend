import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../shared/core/domain/result.dart';
import '../../../../shared/core/services/firebase_token_service.dart';
import '../../../../shared/core/services/logger_service.dart';
import '../../domain/entities/notification_schedule.dart';
import '../../domain/entities/notification_type.dart';

/// Firebase Firestore를 사용한 알림 스케줄 서비스
///
/// 알림 스케줄 데이터를 Firestore에 저장하고 관리합니다.
class FirestoreScheduleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'notification_schedules';

  /// 현재 사용자 ID 가져오기
  static String? get _currentUserId {
    return FirebaseTokenService.getCurrentUserId();
  }

  /// 모든 스케줄 조회
  static Future<Result<List<NotificationSchedule>>> getAllSchedules() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        LoggerService.debug('⚠️ Firestore: 로그인 필요 - 빈 리스트 반환');
        return Result.success('スケジュールがありません', []);
      }

      LoggerService.debug('📡 Firestore: 스케줄 목록 조회 시작 (userId: $userId)');

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              LoggerService.debug('⚠️ Firestore: 스케줄 조회 타임아웃 (5초)');
              throw Exception('タイムアウト');
            },
          );

      final schedules = <NotificationSchedule>[];

      for (final doc in querySnapshot.docs) {
        try {
          final schedule = _mapToSchedule(doc.id, doc.data());
          schedules.add(schedule);
        } catch (e) {
          LoggerService.debug('⚠️ Firestore: 스케줄 변환 실패 (${doc.id}): $e');
        }
      }

      // createdAt 기준 내림차순 정렬
      schedules.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      LoggerService.debug('✅ Firestore: 스케줄 목록 조회 성공 (${schedules.length}개)');
      return Result.success('スケジュールを取得しました', schedules);
    } catch (e) {
      LoggerService.debug('❌ Firestore: 스케줄 목록 조회 실패: $e');
      return Result.success('スケジュールがありません', []);
    }
  }

  /// 활성화된 스케줄만 조회
  static Future<Result<List<NotificationSchedule>>> getActiveSchedules() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.success('スケジュールがありません', []);
      }

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 5));

      final schedules = <NotificationSchedule>[];
      for (final doc in querySnapshot.docs) {
        try {
          schedules.add(_mapToSchedule(doc.id, doc.data()));
        } catch (e) {
          LoggerService.debug('⚠️ 스케줄 변환 실패: $e');
        }
      }

      return Result.success('アクティブなスケジュールを取得しました', schedules);
    } catch (e) {
      LoggerService.debug('❌ 활성 스케줄 조회 실패: $e');
      return Result.success('スケジュールがありません', []);
    }
  }

  /// 스케줄 생성
  static Future<Result<NotificationSchedule>> createSchedule(
    NotificationSchedule schedule,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 Firestore: 스케줄 생성 시작');
      LoggerService.debug('   제목: ${schedule.title}');

      final scheduleData = _scheduleToMap(schedule, userId);
      scheduleData['createdAt'] = FieldValue.serverTimestamp();
      scheduleData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection(_collectionName).add(scheduleData);

      // 생성된 문서 조회
      final doc = await docRef.get();
      final createdData = doc.data();
      if (createdData == null) {
        return Result.failure('スケジュールの作成に失敗しました');
      }

      final createdSchedule = _mapToSchedule(doc.id, createdData);

      LoggerService.debug('✅ Firestore: 스케줄 생성 성공 (id: ${doc.id})');
      return Result.success('スケジュールを作成しました', createdSchedule);
    } catch (e) {
      LoggerService.debug('❌ Firestore: 스케줄 생성 실패: $e');
      return Result.failure('スケジュールの作成に失敗しました: $e');
    }
  }

  /// 스케줄 업데이트
  static Future<Result<NotificationSchedule>> updateSchedule(
    NotificationSchedule schedule,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 Firestore: 스케줄 업데이트 시작 (id: ${schedule.id})');

      final scheduleData = _scheduleToMap(schedule, userId);
      scheduleData['updatedAt'] = FieldValue.serverTimestamp();
      scheduleData.remove('createdAt'); // createdAt은 변경하지 않음

      await _firestore.collection(_collectionName).doc(schedule.id).update(scheduleData);

      LoggerService.debug('✅ Firestore: 스케줄 업데이트 성공 (id: ${schedule.id})');
      return Result.success('スケジュールを更新しました', schedule);
    } catch (e) {
      LoggerService.debug('❌ Firestore: 스케줄 업데이트 실패: $e');
      return Result.failure('スケジュールの更新に失敗しました: $e');
    }
  }

  /// 스케줄 삭제
  static Future<Result<void>> deleteSchedule(String scheduleId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 Firestore: 스케줄 삭제 시작 (id: $scheduleId)');

      await _firestore.collection(_collectionName).doc(scheduleId).delete();

      LoggerService.debug('✅ Firestore: 스케줄 삭제 성공 (id: $scheduleId)');
      return Result.success('スケジュールを削除しました', null);
    } catch (e) {
      LoggerService.debug('❌ Firestore: 스케줄 삭제 실패: $e');
      return Result.failure('スケジュールの削除に失敗しました: $e');
    }
  }

  /// 스케줄 활성/비활성 토글
  static Future<Result<NotificationSchedule>> toggleScheduleActive(
    String scheduleId,
    bool isActive,
  ) async {
    try {
      await _firestore.collection(_collectionName).doc(scheduleId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await _firestore.collection(_collectionName).doc(scheduleId).get();
      if (!doc.exists || doc.data() == null) {
        return Result.failure('スケジュールが見つかりません');
      }

      final updatedSchedule = _mapToSchedule(doc.id, doc.data()!);
      return Result.success(
        isActive ? 'スケジュールを有効にしました' : 'スケジュールを無効にしました',
        updatedSchedule,
      );
    } catch (e) {
      return Result.failure('スケジュールの更新に失敗しました: $e');
    }
  }

  /// Firestore 데이터를 NotificationSchedule로 변환
  static NotificationSchedule _mapToSchedule(
    String id,
    Map<String, dynamic> data,
  ) {
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return NotificationSchedule(
      id: id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.general,
      ),
      scheduleType: ScheduleType.values.firstWhere(
        (e) => e.name == data['scheduleType'],
        orElse: () => ScheduleType.daily,
      ),
      time: NotificationTimeOfDay(
        hour: data['timeHour'] ?? 9,
        minute: data['timeMinute'] ?? 0,
      ),
      weekDays: data['weekDays'] != null ? List<int>.from(data['weekDays']) : null,
      dayOfMonth: data['dayOfMonth'],
      isActive: data['isActive'] ?? true,
      lastExecuted: parseTimestamp(data['lastExecuted']),
      nextExecution: parseTimestamp(data['nextExecution']),
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>?,
      sound: data['sound'] != null
          ? AlarmSound.fromKey(data['sound'])
          : AlarmSound.defaultSound,
    );
  }

  /// NotificationSchedule을 Firestore 데이터로 변환
  static Map<String, dynamic> _scheduleToMap(
    NotificationSchedule schedule,
    String userId,
  ) {
    return {
      'userId': userId,
      'title': schedule.title,
      'description': schedule.description,
      'type': schedule.type.name,
      'scheduleType': schedule.scheduleType.name,
      'timeHour': schedule.time.hour,
      'timeMinute': schedule.time.minute,
      'weekDays': schedule.weekDays,
      'dayOfMonth': schedule.dayOfMonth,
      'isActive': schedule.isActive,
      'lastExecuted': schedule.lastExecuted != null
          ? Timestamp.fromDate(schedule.lastExecuted!)
          : null,
      'nextExecution': schedule.nextExecution != null
          ? Timestamp.fromDate(schedule.nextExecution!)
          : null,
      'metadata': schedule.metadata,
      'sound': schedule.sound.key,
    };
  }
}
