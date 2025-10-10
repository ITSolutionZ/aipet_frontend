import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 달력 통계 계산 헬퍼
class WalkCalendarStatsHelper {
  /// 총 거리 계산
  static double calculateTotalDistance(List<WalkRecordEntity> records) {
    return records.fold<double>(
      0,
      (sum, record) => sum + (record.distance ?? 0),
    );
  }

  /// 총 시간 계산
  static Duration calculateTotalDuration(List<WalkRecordEntity> records) {
    return records.fold<Duration>(
      Duration.zero,
      (sum, record) => sum + record.calculatedDuration,
    );
  }

  /// 달성률 계산
  static int calculateAchievementRate({
    required List<WalkRecordEntity> recordsForDay,
    required Duration totalDuration,
    required WidgetRef ref,
  }) {
    if (recordsForDay.isEmpty) return 0;

    // 로컬 저장소에서 펫의 1일 권장 시간 가져오기
    final petsAsync = ref.read(petListProvider);
    final recommendedMinutes = petsAsync.maybeWhen(
      data: (pets) {
        if (pets.isEmpty) return 30;
        final petId = recordsForDay.first.petId;
        final pet = pets.firstWhere(
          (p) => p.id == petId,
          orElse: () => pets.first,
        );
        return pet.recommendedWalkTime;
      },
      orElse: () => 30,
    );

    if (recommendedMinutes <= 0) return 0;

    final actualMinutes = totalDuration.inMinutes;
    final rate = (actualMinutes / recommendedMinutes * 100).round();

    // 최대 200%까지만 표시
    return rate > 200 ? 200 : rate;
  }
}
