import 'package:aipet_frontend/features/notification/data/providers/notification_controller_providers.dart';
import 'package:aipet_frontend/features/notification/data/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/services/cache_service.dart';
import '../../domain/domain.dart';

part 'alarm_time_settings_controller.g.dart';

/// 알림 시간 설정 컨트롤러
@riverpod
class AlarmTimeSettingsController extends _$AlarmTimeSettingsController {
  late final GetNotificationSettingsUseCase _getNotificationSettingsUseCase;

  @override
  AlarmTimeSettingsState build() {
    _getNotificationSettingsUseCase = ref.read(
      getNotificationSettingsUseCaseProvider,
    );
    return const AlarmTimeSettingsState(isLoading: false);
  }

  /// 알림 시간 로드
  Future<void> loadAlarmTimes(String userId) async {
    try {
      // ローディング状態を開始
      state = state.copyWith(isLoading: true, error: null);

      await _getNotificationSettingsUseCase(userId);

      // ✅ CacheService 사용
      final cache = CacheService();
      await cache.initialize();

      // ✅ 목업 데이터 제거 - 유저가 설정한 시간만 사용
      final morningTimeStr = cache.getString('morning_alarm_time');
      final lunchTimeStr = cache.getString('lunch_alarm_time');
      final dinnerTimeStr = cache.getString('dinner_alarm_time');
      final walkTimeStr = cache.getString('walk_alarm_time');

      state = state.copyWith(
        morningTime: morningTimeStr != null ? _parseTimeString(morningTimeStr) : null,
        lunchTime: lunchTimeStr != null ? _parseTimeString(lunchTimeStr) : null,
        dinnerTime: dinnerTimeStr != null ? _parseTimeString(dinnerTimeStr) : null,
        walkTime: walkTimeStr != null ? _parseTimeString(walkTimeStr) : null,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 시간 선택
  void selectTime(String timeType, TimeOfDay time) {
    switch (timeType) {
      case 'morning':
        state = state.copyWith(morningTime: time);
        break;
      case 'lunch':
        state = state.copyWith(lunchTime: time);
        break;
      case 'dinner':
        state = state.copyWith(dinnerTime: time);
        break;
      case 'walk':
        state = state.copyWith(walkTime: time);
        break;
    }
  }

  /// 알림 시간 저장
  Future<void> saveAlarmTimes() async {
    try {
      // ✅ CacheService 사용
      final cache = CacheService();
      await cache.initialize();

      // ✅ 실제 알람 등록 (유저가 설정한 시간만)
      final notificationService = NotificationService();

      // 아침 알람 - 설정된 경우에만 등록
      if (state.morningTime != null) {
        await cache.setString(
          'morning_alarm_time',
          '${state.morningTime!.hour}:${state.morningTime!.minute}',
        );
        await notificationService.scheduleNotification(
          NotificationSchedule(
            id: 'morning_alarm',
            title: '朝のお知らせ',
            description: 'ペットの朝ごはんの時間です',
            type: NotificationType.feeding,
            scheduleType: ScheduleType.daily,
            time: NotificationTimeOfDay(
              hour: state.morningTime!.hour,
              minute: state.morningTime!.minute,
            ),
            createdAt: DateTime.now(),
          ),
        );
        debugPrint('✅ 아침 알람 등록: ${state.morningTime!.hour}:${state.morningTime!.minute}');
      }

      // 점심 알람 - 설정된 경우에만 등록
      if (state.lunchTime != null) {
        await cache.setString(
          'lunch_alarm_time',
          '${state.lunchTime!.hour}:${state.lunchTime!.minute}',
        );
        await notificationService.scheduleNotification(
          NotificationSchedule(
            id: 'lunch_alarm',
            title: '昼のお知らせ',
            description: 'ペットの昼ごはんの時間です',
            type: NotificationType.feeding,
            scheduleType: ScheduleType.daily,
            time: NotificationTimeOfDay(
              hour: state.lunchTime!.hour,
              minute: state.lunchTime!.minute,
            ),
            createdAt: DateTime.now(),
          ),
        );
        debugPrint('✅ 점심 알람 등록: ${state.lunchTime!.hour}:${state.lunchTime!.minute}');
      }

      // 저녁 알람 - 설정된 경우에만 등록
      if (state.dinnerTime != null) {
        await cache.setString(
          'dinner_alarm_time',
          '${state.dinnerTime!.hour}:${state.dinnerTime!.minute}',
        );
        await notificationService.scheduleNotification(
          NotificationSchedule(
            id: 'dinner_alarm',
            title: '夕方のお知らせ',
            description: 'ペットの夕ごはんの時間です',
            type: NotificationType.feeding,
            scheduleType: ScheduleType.daily,
            time: NotificationTimeOfDay(
              hour: state.dinnerTime!.hour,
              minute: state.dinnerTime!.minute,
            ),
            createdAt: DateTime.now(),
          ),
        );
        debugPrint('✅ 저녁 알람 등록: ${state.dinnerTime!.hour}:${state.dinnerTime!.minute}');
      }

      // 산책 알람 - 설정된 경우에만 등록
      if (state.walkTime != null) {
        await cache.setString(
          'walk_alarm_time',
          '${state.walkTime!.hour}:${state.walkTime!.minute}',
        );
        await notificationService.scheduleNotification(
          NotificationSchedule(
            id: 'walk_alarm',
            title: 'お散歩の時間',
            description: 'ペットとお散歩に行く時間です',
            type: NotificationType.walk,
            scheduleType: ScheduleType.daily,
            time: NotificationTimeOfDay(
              hour: state.walkTime!.hour,
              minute: state.walkTime!.minute,
            ),
            createdAt: DateTime.now(),
          ),
        );
        debugPrint('✅ 산책 알람 등록: ${state.walkTime!.hour}:${state.walkTime!.minute}');
      }

      debugPrint('✅ 알람 등록 완료');
      state = state.copyWith(isSaved: true);
    } catch (e) {
      debugPrint('❌ 알람 등록 실패: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 시간 문자열 파싱
  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

/// 알림 시간 설정 상태
class AlarmTimeSettingsState {
  final TimeOfDay? morningTime;
  final TimeOfDay? lunchTime;
  final TimeOfDay? dinnerTime;
  final TimeOfDay? walkTime;
  final bool isLoading;
  final bool isSaved;
  final String? error;

  const AlarmTimeSettingsState({
    this.morningTime,
    this.lunchTime,
    this.dinnerTime,
    this.walkTime,
    this.isLoading = true,
    this.isSaved = false,
    this.error,
  });

  AlarmTimeSettingsState copyWith({
    TimeOfDay? morningTime,
    TimeOfDay? lunchTime,
    TimeOfDay? dinnerTime,
    TimeOfDay? walkTime,
    bool? isLoading,
    bool? isSaved,
    String? error,
  }) {
    return AlarmTimeSettingsState(
      morningTime: morningTime ?? this.morningTime,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      walkTime: walkTime ?? this.walkTime,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
      error: error ?? this.error,
    );
  }
}
