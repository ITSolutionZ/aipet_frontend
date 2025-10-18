import 'package:aipet_frontend/features/walk/data/services/local_walk_storage_service.dart';
import 'package:aipet_frontend/features/walk/data/services/mock_walk_data_generator.dart';
import 'package:aipet_frontend/features/walk/domain/entities/pet_info.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_location_entity.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'walk_providers.g.dart';

/// 선택된 펫 상태 관리 (다중 선택 지원)
@riverpod
class SelectedPetsNotifier extends _$SelectedPetsNotifier {
  @override
  List<WalkPetInfo> build() {
    return [];
  }

  /// 펫 선택 토글 (선택/해제)
  void togglePet(WalkPetInfo pet) {
    final isSelected = state.any((p) => p.id == pet.id);

    if (isSelected) {
      // 이미 선택된 경우 해제
      state = state.where((p) => p.id != pet.id).toList();
    } else {
      // 선택되지 않은 경우 추가
      state = [...state, pet];
    }
  }

  /// 단일 펫만 선택 (기존 호환성)
  void setSelectedPet(WalkPetInfo pet) {
    state = [pet];
  }

  /// 모든 선택 해제
  void clearSelection() {
    state = [];
  }

  /// 특정 펫이 선택되어 있는지 확인
  bool isSelected(String petId) {
    return state.any((p) => p.id == petId);
  }

  /// 첫 번째 선택된 펫 (단일 선택 호환)
  WalkPetInfo? get firstSelected {
    return state.isEmpty ? null : state.first;
  }
}

/// 산책 기록 상태 관리
@riverpod
class WalkRecordsNotifier extends _$WalkRecordsNotifier {
  @override
  List<WalkRecordEntity> build() {
    // TODO: 목업 데이터 삭제 - 테스트 완료 후 제거
    // 목업 데이터 생성 및 초기화
    final mockRecords = MockWalkDataGenerator.generateMockWalkRecords();
    debugPrint('🚀 목업 산책 데이터 생성 완료: ${mockRecords.length}개');

    // 디버그: 각 산책 기록의 경로 확인
    for (final record in mockRecords) {
      debugPrint('  ✅ 산책 ${record.id}: 경로 포인트=${record.route.length}개, 상태=${record.status}, 펫=${record.petName}');
    }

    return mockRecords;
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

  void setWalkRecords(List<WalkRecordEntity> records) {
    state = records;
  }

  List<WalkRecordEntity> getRecentWalkRecords() {
    return state;
  }

  /// 모든 데이터 삭제 (테스트 완료 후)
  void clearAllMockData() {
    debugPrint('🗑️  목업 데이터 삭제 완료');
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
      // 산책 종료 시 상태를 null로 설정하여 UI 초기화
      state = null;
    }
  }

  void cancelWalk() {
    if (state != null) {
      // 산책 취소 시 상태를 null로 설정하여 UI 초기화
      state = null;
    }
  }

  void clearCurrentWalk() {
    state = null;
  }

  void addLocationToCurrentWalk(WalkLocation location) {
    if (state != null) {
      final updatedRoute = [...state!.route, location];
      state = state!.copyWith(route: updatedRoute);
    }
  }
}

/// 위치 추적 상태 관리
@riverpod
class LocationTrackingNotifier extends _$LocationTrackingNotifier {
  @override
  bool build() {
    return false;
  }

  void startTracking() {
    state = true;
  }

  void stopTracking() {
    state = false;
  }
}
