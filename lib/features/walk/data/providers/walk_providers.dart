import 'package:aipet_frontend/features/walk/domain/entities/pet_info.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'walk_providers.g.dart';

/// 선택된 펫 상태 관리
@riverpod
class SelectedPetNotifier extends _$SelectedPetNotifier {
  @override
  PetInfo? build() {
    return null;
  }

  void setSelectedPet(PetInfo? pet) {
    state = pet;
  }

  void clearSelection() {
    state = null;
  }
}

/// 산책 기록 상태 관리
@riverpod
class WalkRecordsNotifier extends _$WalkRecordsNotifier {
  @override
  List<WalkRecordEntity> build() {
    return [];
  }

  void addWalkRecord(WalkRecordEntity record) {
    state = [...state, record];
  }

  void updateWalkRecord(WalkRecordEntity updatedRecord) {
    state = state.map((record) {
      return record.id == updatedRecord.id ? updatedRecord : record;
    }).toList();
  }

  void removeWalkRecord(String recordId) {
    state = state.where((record) => record.id != recordId).toList();
  }

  void clearRecords() {
    state = [];
  }
}

/// 지도 확장 상태 관리
@riverpod
class MapExpandedNotifier extends _$MapExpandedNotifier {
  @override
  bool build() {
    return false;
  }

  void toggleExpanded() {
    state = !state;
  }

  void setExpanded(bool expanded) {
    state = expanded;
  }
}

/// 현재 산책 상태 관리
@riverpod
class CurrentWalkNotifier extends _$CurrentWalkNotifier {
  @override
  WalkRecordEntity? build() {
    return null;
  }

  void startWalk(WalkRecordEntity walkRecord) {
    state = walkRecord;
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

  void endWalk() {
    if (state != null) {
      state = state!.copyWith(
        status: WalkStatus.completed,
        endTime: DateTime.now(),
      );
    }
  }

  void cancelWalk() {
    if (state != null) {
      state = state!.copyWith(status: WalkStatus.cancelled);
    }
  }

  void clearCurrentWalk() {
    state = null;
  }
}
