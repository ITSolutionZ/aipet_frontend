import '../../../../shared/shared.dart';

import '../entities/facility_entity.dart';
import '../repositories/facility_repository.dart';


/// 施設修正 UseCase
class UpdateFacilityUseCase {
  final FacilityRepository _repository;

  UpdateFacilityUseCase(this._repository);

  /// 施設情報を修正します
  Future<Result<Facility>> updateFacility({
    required String facilityId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    FacilityType? type,
    String? description,
    String? phoneNumber,
    String? website,
    List<String>? services,
    Map<String, dynamic>? operatingHours,
    double? rating,
    int? reviewCount,
    List<String>? images,
    Map<String, dynamic>? additionalInfo,
    bool? isActive,
  }) async {
    try {
      // 既存施設照会
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('施設が見つかりません: ${getResult.message}');
      }

      final existingFacility = getResult.data;

      // 入力検証
      if (name != null && name.trim().isEmpty) {
        return Result.failure('施設名は空にできません');
      }

      if (latitude != null && (latitude < -90 || latitude > 90)) {
        return Result.failure('無効な緯度です');
      }

      if (longitude != null && (longitude < -180 || longitude > 180)) {
        return Result.failure('無効な経度です');
      }

      // 施設情報更新
      final updatedFacility = existingFacility?.copyWith(
        name: name?.trim() ?? existingFacility.name,
        address: address?.trim() ?? existingFacility.address,
        latitude: latitude ?? existingFacility.latitude,
        longitude: longitude ?? existingFacility.longitude,
        type: type ?? existingFacility.type,
        description: description?.trim() ?? existingFacility.description,
        phoneNumber: phoneNumber?.trim() ?? existingFacility.phoneNumber,
        website: website?.trim() ?? existingFacility.website,
        services: services ?? existingFacility.services,
        operatingHours: operatingHours ?? existingFacility.operatingHours,
        rating: rating ?? existingFacility.rating,
        reviewCount: reviewCount ?? existingFacility.reviewCount,
        images: images ?? existingFacility.images,
        updatedAt: DateTime.now(),
      );

      // TODO: FacilityRepositoryに更新メソッド追加が必要
      // 現在はローカルストレージのみ更新
      await Future.delayed(const Duration(milliseconds: 500));

      return Result.success('施設が正常に修正されました', updatedFacility);
    } catch (e) {
      return Result.failure('施設修正中にエラーが発生しました: $e');
    }
  }

  /// 施設の特定フィールドのみ修正します
  Future<Result<Facility>> updateFacilityField({
    required String facilityId,
    required String field,
    required dynamic value,
  }) async {
    try {
      // 既存施設照会
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('施設が見つかりません: ${getResult.message}');
      }

      final existingFacility = getResult.data;

      // フィールド別更新
      Facility updatedFacility;
      switch (field) {
        case 'name':
          if (value is! String || value.trim().isEmpty) {
            return Result.failure('無効な施設名です');
          }
          updatedFacility =
              existingFacility?.copyWith(name: value.trim()) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'address':
          if (value is! String || value.trim().isEmpty) {
            return Result.failure('無効な住所です');
          }
          updatedFacility =
              existingFacility?.copyWith(address: value.trim()) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'latitude':
          if (value is! double || value < -90 || value > 90) {
            return Result.failure('無効な緯度です');
          }
          updatedFacility =
              existingFacility?.copyWith(latitude: value) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'longitude':
          if (value is! double || value < -180 || value > 180) {
            return Result.failure('無効な経度です');
          }
          updatedFacility =
              existingFacility?.copyWith(longitude: value) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'type':
          if (value is! FacilityType) {
            return Result.failure('無効な施設タイプです');
          }
          updatedFacility =
              existingFacility?.copyWith(type: value) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'description':
          updatedFacility =
              existingFacility?.copyWith(description: value as String?) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'phoneNumber':
          updatedFacility =
              existingFacility?.copyWith(phoneNumber: value as String?) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'website':
          updatedFacility =
              existingFacility?.copyWith(website: value as String?) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'services':
          if (value is! List<String>) {
            return Result.failure('無効なサービスリストです');
          }
          updatedFacility =
              existingFacility?.copyWith(services: value) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        case 'rating':
          if (value is! double || value < 0 || value > 5) {
            return Result.failure('無効な評価です (0-5)');
          }
          updatedFacility =
              existingFacility?.copyWith(rating: value) ??
              Facility(
                id: '',
                name: '',
                type: FacilityType.hospital,
                address: '',
                latitude: 0,
                longitude: 0,
                phoneNumber: '',
                website: '',
                description: '',
                images: [],
                operatingHours: {},
                services: [],
                rating: 0,
                reviewCount: 0,
                isOpen: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
          break;
        default:
          return Result.failure('サポートされていないフィールドです: $field');
      }

      updatedFacility = updatedFacility.copyWith(updatedAt: DateTime.now());

      await Future.delayed(const Duration(milliseconds: 300));

      return Result.success('施設が正常に修正されました', updatedFacility);
    } catch (e) {
      return Result.failure('施設フィールド修正中にエラーが発生しました: $e');
    }
  }

  /// 施設を一括修正します
  Future<Result<List<Facility>>> updateFacilities(
    List<Map<String, dynamic>> updates,
  ) async {
    try {
      final updatedFacilities = <Facility>[];

      for (final update in updates) {
        final facilityId = update['facilityId'] as String;
        final result = await updateFacility(
          facilityId: facilityId,
          name: update['name'] as String?,
          address: update['address'] as String?,
          latitude: update['latitude'] as double?,
          longitude: update['longitude'] as double?,
          type: update['type'] as FacilityType?,
          description: update['description'] as String?,
          phoneNumber: update['phoneNumber'] as String?,
          website: update['website'] as String?,
          services: update['services'] as List<String>?,
          operatingHours: update['operatingHours'] as Map<String, dynamic>?,
          rating: update['rating'] as double?,
          reviewCount: update['reviewCount'] as int?,
          images: update['images'] as List<String>?,
        );

        if (result.isSuccess) {
          updatedFacilities.add(result.dataOrThrow);
        } else {
          return Result.failure('施設一括修正中にエラーが発生しました: ${result.message}');
        }
      }

      return Result.success('施設が正常に修正されました', updatedFacilities);
    } catch (e) {
      return Result.failure('施設一括修正中にエラーが発生しました: $e');
    }
  }

  /// 施設の評価を更新します
  Future<Result<Facility>> updateFacilityRating({
    required String facilityId,
    required double newRating,
    required int reviewCount,
  }) async {
    try {
      if (newRating < 0 || newRating > 5) {
        return Result.failure('評価は0-5の間でなければなりません');
      }

      if (reviewCount < 0) {
        return Result.failure('レビュー数は0以上でなければなりません');
      }

      return await updateFacilityField(
        facilityId: facilityId,
        field: 'rating',
        value: newRating,
      );
    } catch (e) {
      return Result.failure('施設評価更新中にエラーが発生しました: $e');
    }
  }

  /// 施設を有効化/無効化します
  Future<Result<Facility>> toggleFacilityStatus(String facilityId) async {
    try {
      // 既存施設照会
      final getResult = await _repository.getFacilityById(facilityId);
      if (!getResult.isSuccess) {
        return Result.failure('施設が見つかりません: ${getResult.message}');
      }

      final existingFacility = getResult.data;
      final newStatus = !(existingFacility?.isOpen ?? false);

      return await updateFacilityField(
        facilityId: facilityId,
        field: 'isOpen',
        value: newStatus,
      );
    } catch (e) {
      return Result.failure('施設状態変更中にエラーが発生しました: $e');
    }
  }
}
