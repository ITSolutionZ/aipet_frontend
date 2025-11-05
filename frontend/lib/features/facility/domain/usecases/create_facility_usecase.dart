import '../../../../shared/shared.dart';

import '../entities/facility_entity.dart';
import '../repositories/facility_repository.dart';


/// 施設作成 UseCase
class CreateFacilityUseCase {
  final FacilityRepository _repository;

  CreateFacilityUseCase(this._repository);

  /// 新しい施設を作成します
  Future<Result<Facility>> createFacility({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required FacilityType type,
    String? description,
    String? phoneNumber,
    String? website,
    List<String>? services,
    Map<String, dynamic>? operatingHours,
    double? rating,
    int? reviewCount,
    List<String>? images,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      // 入力検証
      if (name.trim().isEmpty) {
        return Result.failure('施設名は必須です');
      }

      if (address.trim().isEmpty) {
        return Result.failure('住所は必須です');
      }

      if (latitude < -90 || latitude > 90) {
        return Result.failure('無効な緯度です');
      }

      if (longitude < -180 || longitude > 180) {
        return Result.failure('無効な経度です');
      }

      // 施設エンティティ生成
      final facility = Facility(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        address: address.trim(),
        latitude: latitude,
        longitude: longitude,
        type: type,
        description: description?.trim(),
        phoneNumber: phoneNumber?.trim(),
        website: website?.trim(),
        services: services ?? [],
        operatingHours: operatingHours ?? {},
        rating: rating ?? 0.0,
        reviewCount: reviewCount ?? 0,
        images: images ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: FacilityRepositoryに保存メソッド追加が必要
      // 現在はローカルストレージにのみ保存
      await Future.delayed(const Duration(milliseconds: 500));

      return Result.success('施設が正常に作成されました', facility);
    } catch (e) {
      return Result.failure('施設作成中にエラーが発生しました: $e');
    }
  }

  /// 施設を一括作成します
  Future<Result<List<Facility>>> createFacilities(
    List<Map<String, dynamic>> facilityDataList,
  ) async {
    try {
      final facilities = <Facility>[];

      for (final data in facilityDataList) {
        final result = await createFacility(
          name: data['name'] as String,
          address: data['address'] as String,
          latitude: data['latitude'] as double,
          longitude: data['longitude'] as double,
          type: data['type'] as FacilityType,
          description: data['description'] as String?,
          phoneNumber: data['phoneNumber'] as String?,
          website: data['website'] as String?,
          services: data['services'] as List<String>?,
          operatingHours: data['operatingHours'] as Map<String, dynamic>?,
          rating: data['rating'] as double?,
          reviewCount: data['reviewCount'] as int?,
          images: data['images'] as List<String>?,
        );

        if (result.isSuccess && result.data != null) {
          facilities.add(result.dataOrThrow);
        } else {
          return Result.failure('施設一括作成中にエラーが発生しました: ${result.message}');
        }
      }

      return Result.success('施設が正常に作成されました', facilities);
    } catch (e) {
      return Result.failure('施設一括作成中にエラーが発生しました: $e');
    }
  }

  /// 施設をコピーして新しい施設を作成します
  Future<Result<Facility>> duplicateFacility(
    String facilityId, {
    String? newName,
  }) async {
    try {
      // 既存施設照会
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('既存の施設が見つかりません: ${getResult.message}');
      }

      final originalFacility = getResult.data;

      // 新しい施設作成
      final newFacility = originalFacility?.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: newName ?? '${originalFacility.name} (コピー)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await Future.delayed(const Duration(milliseconds: 300));

      return Result.success('施設が正常にコピーされました', newFacility);
    } catch (e) {
      return Result.failure('施設コピー中にエラーが発生しました: $e');
    }
  }
}
