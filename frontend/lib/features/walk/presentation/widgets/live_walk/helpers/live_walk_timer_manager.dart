import 'dart:async';

import 'package:flutter/foundation.dart';


/// Live Walk 타이머 관리자
class LiveWalkTimerManager {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  /// 타이머 시작
  void startTimer(VoidCallback onTick) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      onTick();
    });
  }

  /// 타이머 정지
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 타이머 리셋
  void resetTimer() {
    _timer?.cancel();
    _timer = null;
    _elapsedTime = Duration.zero;
  }

  /// 경과 시간 가져오기
  Duration get elapsedTime => _elapsedTime;

  /// 경과 시간 설정
  void setElapsedTime(Duration duration) {
    _elapsedTime = duration;
  }

  /// 정리
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
