import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// 펫 활동 기록 관리 헬퍼
class WalkListActivityHelper {
  /// 펫 활동 기록
  static Future<Map<String, dynamic>?> recordPetActivity({
    required String activityType,
    required BuildContext context,
  }) async {
    try {
      // 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final activity = {
        'type': activityType,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

      LoggerService.debug(
        '✅ 活動記録追加: ${activityType == 'poop' ? '💩' : '💧'} at (${position.latitude}, ${position.longitude})',
      );

      return activity;
    } catch (e) {
      LoggerService.debug('❌ 活動記録失敗: $e');
      return null;
    }
  }

  /// 활동 타입에 따른 라벨 가져오기
  static String getActivityLabel(String activityType) {
    switch (activityType) {
      case 'poop':
        return '💩';
      case 'pee':
        return '💧';
      case 'no-entry':
        return '🚫';
      default:
        return '✅';
    }
  }

  /// 활동 타입에 따른 상세 라벨 가져오기
  static String getActivityDetailLabel(String activityType) {
    switch (activityType) {
      case 'poop':
        return '💩 排便';
      case 'pee':
        return '💧 排尿';
      case 'no-entry':
        return '🚫 立入禁止';
      default:
        return '記録';
    }
  }

  /// 활동 기록을 notes 형식으로 변환
  static String? convertActivitiesToNotes(
    List<Map<String, dynamic>> petActivities,
  ) {
    if (petActivities.isEmpty) return null;

    final activitiesJson = petActivities.map((a) {
      return {
        'type': a['type'],
        'latitude': a['latitude'],
        'longitude': a['longitude'],
        'timestamp': a['timestamp'],
      };
    }).toList();

    return 'activities:${activitiesJson.toString()}';
  }

  /// 활동 기록 성공 스낵바 표시
  static void showActivitySuccessSnackBar(
    BuildContext context,
    String activityType,
  ) {
    if (!context.mounted) return;

    SnackBarService.showSuccess(
      context,
      getActivityLabel(activityType),
      duration: const Duration(milliseconds: 800),
    );
  }

  /// 활동 기록 실패 스낵바 표시
  static void showActivityErrorSnackBar(BuildContext context) {
    if (!context.mounted) return;

    SnackBarService.showError(context, '位置情報を取得できませんでした');
  }
}
