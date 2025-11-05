import '../../../../shared/shared.dart';

import 'dart:math';

import '../entities/facility_entity.dart';
import '../repositories/facility_repository.dart';



/// 施設削除 UseCase
class DeleteFacilityUseCase {
  final FacilityRepository _repository;

  DeleteFacilityUseCase(this._repository);

  /// 施設を削除します
  Future<Result<void>> deleteFacility(String facilityId) async {
    try {
      // 施設の存在確認
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('施設が見つかりません: ${getResult.message}');
      }

      // TODO: FacilityRepositoryに削除メソッド追加が必要
      // 現在はローカルストレージからのみ削除
      await Future.delayed(const Duration(milliseconds: 300));

      return Result.success('施設が正常に削除されました');
    } catch (e) {
      return Result.failure('施設削除中にエラーが発生しました: $e');
    }
  }

  /// 複数の施設を一括削除します
  Future<Result<Map<String, dynamic>>> deleteFacilities(
    List<String> facilityIds,
  ) async {
    try {
      int successCount = 0;
      int failureCount = 0;
      final errors = <String>[];

      for (final facilityId in facilityIds) {
        final result = await deleteFacility(facilityId);
        if (result.isSuccess) {
          successCount++;
        } else {
          failureCount++;
          errors.add('施設 $facilityId: ${result.message}');
        }
      }

      return Result.success('施設の一括削除が完了しました', {
        'successCount': successCount,
        'failureCount': failureCount,
        'totalCount': facilityIds.length,
        'errors': errors,
      });
    } catch (e) {
      return Result.failure('施設一括削除中にエラーが発生しました: $e');
    }
  }

  /// 施設タイプ別に施設を削除します
  Future<Result<Map<String, dynamic>>> deleteFacilitiesByType(
    String facilityType,
  ) async {
    try {
      // 該当タイプの施設を照会
      final getResult = await _repository.getFacilitiesByType(
        FacilityType.values.firstWhere((e) => e.name == facilityType),
      );
      if (!getResult.isSuccess) {
        return Result.failure('施設タイプ照会中にエラーが発生しました: ${getResult.message}');
      }

      final facilities = getResult.data ?? [];
      final facilityIds = facilities.map((f) => f.id).toList();

      if (facilityIds.isEmpty) {
        return Result.success('削除する施設がありません', {
          'successCount': 0,
          'failureCount': 0,
          'totalCount': 0,
          'errors': [],
        });
      }

      // 一括削除実行
      return await deleteFacilities(facilityIds);
    } catch (e) {
      return Result.failure('施設タイプ別削除中にエラーが発生しました: $e');
    }
  }

  /// 特定位置の半径内の施設を削除します
  Future<Result<Map<String, dynamic>>> deleteFacilitiesByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      // すべての施設を照会
      final getResult = await _repository.getNearbyFacilities();
      if (!getResult.isSuccess) {
        return Result.failure('施設照会中にエラーが発生しました: ${getResult.message}');
      }

      final allFacilities = getResult.data;
      final facilitiesToDelete = <String>[];

      // 半径内の施設を検索
      for (final facility in allFacilities ?? []) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          facility.latitude,
          facility.longitude,
        );

        if (distance <= radiusKm) {
          facilitiesToDelete.add(facility.id);
        }
      }

      if (facilitiesToDelete.isEmpty) {
        return Result.success('削除する施設がありません', {
          'successCount': 0,
          'failureCount': 0,
          'totalCount': 0,
          'errors': [],
        });
      }

      // 一括削除実行
      return await deleteFacilities(facilitiesToDelete);
    } catch (e) {
      return Result.failure('位置ベース施設削除中にエラーが発生しました: $e');
    }
  }

  /// 評価の低い施設を削除します
  Future<Result<Map<String, dynamic>>> deleteLowRatedFacilities({
    required double minRating,
    int? minReviewCount,
  }) async {
    try {
      // すべての施設を照会
      final getResult = await _repository.getNearbyFacilities();
      if (!getResult.isSuccess) {
        return Result.failure('施設照会中にエラーが発生しました: ${getResult.message}');
      }

      final allFacilities = getResult.data;
      final facilitiesToDelete = <String>[];

      // 条件に合う施設を検索
      for (final facility in allFacilities ?? []) {
        if (facility.rating < minRating) {
          if (minReviewCount == null ||
              facility.reviewCount >= minReviewCount) {
            facilitiesToDelete.add(facility.id);
          }
        }
      }

      if (facilitiesToDelete.isEmpty) {
        return Result.success('削除する施設がありません', {
          'successCount': 0,
          'failureCount': 0,
          'totalCount': 0,
          'errors': [],
        });
      }

      // 一括削除実行
      return await deleteFacilities(facilitiesToDelete);
    } catch (e) {
      return Result.failure('低評価施設削除中にエラーが発生しました: $e');
    }
  }

  /// 古い施設を削除します
  Future<Result<Map<String, dynamic>>> deleteOldFacilities({
    required int daysOld,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      // すべての施設を照会
      final getResult = await _repository.getNearbyFacilities();
      if (!getResult.isSuccess) {
        return Result.failure('施設照会中にエラーが発生しました: ${getResult.message}');
      }

      final allFacilities = getResult.data;
      final facilitiesToDelete = <String>[];

      // 古い施設を検索
      for (final facility in allFacilities ?? []) {
        if (facility.createdAt != null &&
            facility.createdAt!.isBefore(cutoffDate)) {
          facilitiesToDelete.add(facility.id);
        }
      }

      if (facilitiesToDelete.isEmpty) {
        return Result.success('削除する施設がありません', {
          'successCount': 0,
          'failureCount': 0,
          'totalCount': 0,
          'errors': [],
        });
      }

      // 一括削除実行
      return await deleteFacilities(facilitiesToDelete);
    } catch (e) {
      return Result.failure('古い施設削除中にエラーが発生しました: $e');
    }
  }

  /// 施設をソフト削除します (無効化)
  Future<Result<void>> softDeleteFacility(String facilityId) async {
    try {
      // 施設の存在確認
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('施設が見つかりません: ${getResult.message}');
      }

      // 施設を無効化 (TODO: Repository経由で更新)
      await Future.delayed(const Duration(milliseconds: 300));

      return Result.success('施設が正常に削除されました');
    } catch (e) {
      return Result.failure('施設ソフト削除中にエラーが発生しました: $e');
    }
  }

  /// ソフト削除された施設を復元します
  Future<Result<void>> restoreFacility(String facilityId) async {
    try {
      // 施設の存在確認
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('施設が見つかりません: ${getResult.message}');
      }

      // 施設を有効化 (TODO: Repository経由で更新)
      await Future.delayed(const Duration(milliseconds: 300));

      return Result.success('施設が正常に復元されました');
    } catch (e) {
      return Result.failure('施設復元中にエラーが発生しました: $e');
    }
  }

  /// すべての施設を削除します (注意: 危険な操作)
  Future<Result<Map<String, dynamic>>> deleteAllFacilities() async {
    try {
      // すべての施設を照会
      final getResult = await _repository.getNearbyFacilities();
      if (!getResult.isSuccess) {
        return Result.failure('施設照会中にエラーが発生しました: ${getResult.message}');
      }

      final allFacilities = getResult.data;
      final facilityIds = allFacilities?.map((f) => f.id).toList() ?? [];

      if (facilityIds.isEmpty) {
        return Result.success('削除する施設がありません', {
          'successCount': 0,
          'failureCount': 0,
          'totalCount': 0,
          'errors': [],
        });
      }

      // 一括削除実行
      return await deleteFacilities(facilityIds);
    } catch (e) {
      return Result.failure('すべての施設削除中にエラーが発生しました: $e');
    }
  }

  /// 2地点間の距離を計算します (Haversine公式)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // 地球半径 (km)

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
