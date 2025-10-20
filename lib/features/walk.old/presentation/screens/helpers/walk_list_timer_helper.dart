import 'dart:async';

import 'package:flutter/material.dart';

/// 산책 타이머 관리 헬퍼
class WalkListTimerHelper {
  /// 타이머 시작
  static Timer startTimer({
    required VoidCallback onTick,
    required bool Function() shouldTick,
  }) {
    return Timer.periodic(const Duration(seconds: 1), (timer) {
      if (shouldTick()) {
        onTick();
      }
    });
  }

  /// 타이머 정지
  static void stopTimer(Timer? timer) {
    timer?.cancel();
  }

  /// 경과 시간 계산 (초 단위)
  static int calculateElapsedSeconds(DateTime startTime) {
    return DateTime.now().difference(startTime).inSeconds;
  }

  /// 시간 포맷팅 (h:mm:ss)
  static String formatElapsedTime(int elapsedSeconds) {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 시간 포맷팅 (h:s - 정보 카드용)
  static String formatTimeForInfoCard(int elapsedSeconds) {
    final hours = elapsedSeconds ~/ 3600;
    final seconds = elapsedSeconds % 60;
    return '$hours:${seconds.toString().padLeft(2, '0')}';
  }
}
