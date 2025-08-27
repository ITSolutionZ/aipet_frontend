import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/walk_record_entity.dart';

part 'walk_providers.g.dart';

// 산책 기록 목록 관리
@riverpod
class WalkRecordsNotifier extends _$WalkRecordsNotifier {
  @override
  List<WalkRecordEntity> build() => [];

  void setWalkRecords(List<WalkRecordEntity> records) {
    state = records;
  }

  void addWalkRecord(WalkRecordEntity record) {
    state = [record, ...state];
  }

  void updateWalkRecord(WalkRecordEntity record) {
    state = state.map((r) => r.id == record.id ? record : r).toList();
  }

  void removeWalkRecord(String recordId) {
    state = state.where((record) => record.id != recordId).toList();
  }

  List<WalkRecordEntity> getWalkRecordsByPet(String petId) {
    return state.where((record) => record.petId == petId).toList();
  }

  List<WalkRecordEntity> getRecentWalkRecords({int limit = 10}) {
    return state.take(limit).toList();
  }
}

// 현재 진행 중인 산책 관리
@riverpod
class CurrentWalkNotifier extends _$CurrentWalkNotifier {
  @override
  WalkRecordEntity? build() => null;

  void startWalk(WalkRecordEntity walk) {
    state = walk;
  }

  void updateCurrentWalk(WalkRecordEntity walk) {
    state = walk;
  }

  void endWalk() {
    state = null;
  }

  void pauseWalk() {
    if (state != null) {
      state = state!.copyWith(status: WalkStatus.paused);
    }
  }

  void resumeWalk() {
    if (state != null) {
      state = state!.copyWith(status: WalkStatus.inProgress);
    }
  }

  void addLocationToCurrentWalk(WalkLocation location) {
    if (state != null) {
      final updatedRoute = [...state!.route, location];
      state = state!.copyWith(route: updatedRoute);
    }
  }
}

// 선택된 반려동물 관리
@riverpod
class SelectedPetNotifier extends _$SelectedPetNotifier {
  @override
  PetInfo? build() => null;

  void setSelectedPet(PetInfo? pet) {
    state = pet;
  }
}

// 지도 확장 상태 관리
@riverpod
class MapExpandedNotifier extends _$MapExpandedNotifier {
  @override
  bool build() => false;

  void toggleExpanded() {
    state = !state;
  }

  void setExpanded(bool expanded) {
    state = expanded;
  }
}

class PetInfo {
  final String id;
  final String name;
  final String imagePath;

  const PetInfo({
    required this.id,
    required this.name,
    required this.imagePath,
  });
}
