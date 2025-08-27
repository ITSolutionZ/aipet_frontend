import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

// 홈 상태 관리
@riverpod
class HomeState extends _$HomeState {
  @override
  HomeStateData build() {
    return const HomeStateData(selectedIndex: 0, currentTime: '');
  }

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void updateCurrentTime(String time) {
    state = state.copyWith(currentTime: time);
  }
}

// 홈 상태 데이터 클래스
class HomeStateData {
  final int selectedIndex;
  final String currentTime;

  const HomeStateData({required this.selectedIndex, required this.currentTime});

  HomeStateData copyWith({int? selectedIndex, String? currentTime}) {
    return HomeStateData(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      currentTime: currentTime ?? this.currentTime,
    );
  }
}

// 현재 시간 스트림 (홈 화면용) - 메모리 안전한 구현
@riverpod
Stream<String> homeCurrentTimeStream(Ref ref) async* {
  late StreamController<String> controller;
  Timer? timer;
  
  controller = StreamController<String>(
    onListen: () {
      // 즉시 현재 시간을 emit
      final now = DateTime.now();
      final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      controller.add(timeString);
      
      // 1초마다 시간 업데이트
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        if (!controller.isClosed) {
          controller.add(timeString);
        }
      });
    },
    onCancel: () {
      timer?.cancel();
      timer = null;
    },
  );
  
  // Riverpod provider가 dispose될 때 정리
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });
  
  yield* controller.stream;
}
