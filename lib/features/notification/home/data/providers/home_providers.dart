import 'dart:async';

import 'package:aipet_frontend/features/pet_registor/data/providers/pet_providers.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'home_data_service_provider.dart';
// Export new providers
export 'home_usecase_providers.dart';

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

// 홈 화면에서 사용할 현재 선택된 펫 프로바이더
@riverpod
class HomeSelectedPetNotifier extends _$HomeSelectedPetNotifier {
  @override
  PetProfileEntity? build() {
    // 기본적으로 첫 번째 펫을 선택
    final petsAsync = ref.watch(petsNotifierProvider);
    return petsAsync.when(
      data: (pets) => pets.isNotEmpty ? pets.first : null,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  /// 펫 선택
  void selectPet(PetProfileEntity pet) {
    state = pet;
  }

  /// 다음 펫으로 이동
  void nextPet() {
    final petsAsync = ref.read(petsNotifierProvider);
    petsAsync.when(
      data: (pets) {
        if (pets.isNotEmpty && state != null) {
          final currentIndex = pets.indexWhere((p) => p.id == state!.id);
          if (currentIndex != -1) {
            final nextIndex = (currentIndex + 1) % pets.length;
            state = pets[nextIndex];
          }
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  /// 이전 펫으로 이동
  void previousPet() {
    final petsAsync = ref.read(petsNotifierProvider);
    petsAsync.when(
      data: (pets) {
        if (pets.isNotEmpty && state != null) {
          final currentIndex = pets.indexWhere((p) => p.id == state!.id);
          if (currentIndex != -1) {
            final previousIndex =
                (currentIndex - 1 + pets.length) % pets.length;
            state = pets[previousIndex];
          }
        }
      },
      loading: () {},
      error: (_, __) {},
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
      final timeString =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      controller.add(timeString);

      // 1초마다 시간 업데이트
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        final timeString =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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
