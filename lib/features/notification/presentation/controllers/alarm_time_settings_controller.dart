import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/shared.dart';

/// 알림 시간 설정 컨트롤러
class AlarmTimeSettingsController
    extends StateNotifier<AlarmTimeSettingsState> {
  AlarmTimeSettingsController() : super(const AlarmTimeSettingsState());

  /// 알림 시간 로드
  Future<void> loadAlarmTimes() async {
    try {
      final notificationService = NotificationService();
      await notificationService.getNotificationSettings();

      // SharedPreferences에서 저장된 시간 정보 로드
      final prefs = await SharedPreferences.getInstance();

      final morningTime = _parseTimeString(
        prefs.getString('morning_alarm_time') ?? '8:0',
      );
      final lunchTime = _parseTimeString(
        prefs.getString('lunch_alarm_time') ?? '12:0',
      );
      final dinnerTime = _parseTimeString(
        prefs.getString('dinner_alarm_time') ?? '18:0',
      );
      final walkTime = _parseTimeString(
        prefs.getString('walk_alarm_time') ?? '16:0',
      );

      state = state.copyWith(
        morningTime: morningTime,
        lunchTime: lunchTime,
        dinnerTime: dinnerTime,
        walkTime: walkTime,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
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
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'morning_alarm_time',
        '${state.morningTime.hour}:${state.morningTime.minute}',
      );
      await prefs.setString(
        'lunch_alarm_time',
        '${state.lunchTime.hour}:${state.lunchTime.minute}',
      );
      await prefs.setString(
        'dinner_alarm_time',
        '${state.dinnerTime.hour}:${state.dinnerTime.minute}',
      );
      await prefs.setString(
        'walk_alarm_time',
        '${state.walkTime.hour}:${state.walkTime.minute}',
      );

      state = state.copyWith(isSaved: true);
    } catch (e) {
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
  final TimeOfDay morningTime;
  final TimeOfDay lunchTime;
  final TimeOfDay dinnerTime;
  final TimeOfDay walkTime;
  final bool isLoading;
  final bool isSaved;
  final String? error;

  const AlarmTimeSettingsState({
    this.morningTime = const TimeOfDay(hour: 8, minute: 0),
    this.lunchTime = const TimeOfDay(hour: 12, minute: 0),
    this.dinnerTime = const TimeOfDay(hour: 18, minute: 0),
    this.walkTime = const TimeOfDay(hour: 16, minute: 0),
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

/// 컨트롤러 프로바이더
final alarmTimeSettingsControllerProvider =
    StateNotifierProvider<AlarmTimeSettingsController, AlarmTimeSettingsState>((
      ref,
    ) {
      return AlarmTimeSettingsController();
    });
