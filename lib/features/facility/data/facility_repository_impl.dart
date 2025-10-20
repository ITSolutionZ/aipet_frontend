import 'package:aipet_frontend/shared/shared.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/domain.dart';
import 'services/facility_local_storage_service.dart';
import 'services/google_places_service.dart';

class FacilityRepositoryImpl implements FacilityRepository {
  final GooglePlacesService _googlePlacesService;

  FacilityRepositoryImpl(this._googlePlacesService);

  @override
  Future<Result<List<Facility>>> getNearbyFacilities() async {
    try {
      // 1. 로컬 저장소에서 캐시된 시설 확인
      final cachedFacilities =
          await FacilityLocalStorageService.getFacilities();

      if (cachedFacilities.isNotEmpty) {
        final facilities = _convertToFacilityList(cachedFacilities);
        return Result.success('근처 시설을 성공적으로 조회했습니다', facilities);
      }

      // 2. 캐시가 없으면 현재 위치 기반으로 Google Places API 검색
      final position = await _getCurrentPosition();

      final result = await _googlePlacesService.searchNearbyPetFacilities(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 5000,
      );

      if (!result.isSuccess) {
        // 에러를 문자열로 안전하게 변환 후 반환
        return Result.failure(result.error?.toString() ?? '시설 검색에 실패했습니다');
      }

      final facilities = result.dataOrNull ?? [];

      // 3. 검색 결과를 로컬 저장소에 저장
      if (facilities.isNotEmpty) {
        await FacilityLocalStorageService.addFacilities(
          facilities.map(_facilityToMap).toList(),
        );
      }

      return Result.success('근처 시설을 성공적으로 조회했습니다', facilities);
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  @override
  Future<Result<List<Facility>>> searchFacilities(String query) async {
    try {
      if (query.isEmpty) {
        return await getNearbyFacilities();
      }

      // 1. 먼저 로컬 저장소에서 검색
      final cachedFacilities =
          await FacilityLocalStorageService.getFacilities();
      final facilities = _convertToFacilityList(cachedFacilities);

      final lowerQuery = query.toLowerCase();
      final localResults = facilities.where((facility) {
        return facility.name.toLowerCase().contains(lowerQuery) ||
            (facility.description?.toLowerCase() ?? '').contains(lowerQuery) ||
            facility.address.toLowerCase().contains(lowerQuery);
      }).toList();

      // 2. 로컬 결과가 충분하면 반환
      if (localResults.length >= 5) {
        return Result.success('검색 결과를 성공적으로 조회했습니다', localResults);
      }

      // 3. 로컬 결과가 부족하면 Google Places API로 검색
      final position = await _getCurrentPosition();

      final result = await _googlePlacesService.searchFacilitiesByText(
        query: query,
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 10000,
      );

      if (!result.isSuccess) {
        return Result.success('검색 결과를 성공적으로 조회했습니다', localResults);
      }

      final apiResults = result.dataOrNull ?? [];

      // 4. 검색 결과를 로컬 저장소에 추가
      if (apiResults.isNotEmpty) {
        await FacilityLocalStorageService.addFacilities(
          apiResults.map(_facilityToMap).toList(),
        );
      }

      // 5. 로컬 결과와 API 결과 합치기 (중복 제거)
      final allResults = <String, Facility>{};
      for (final facility in [...localResults, ...apiResults]) {
        allResults[facility.id] = facility;
      }

      return Result.success('検索結果を正常に照会しました', allResults.values.toList());
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  @override
  Future<Result<List<Facility>>> getFacilitiesByType(FacilityType type) async {
    try {
      // 1. 로컬 저장소에서 검색
      final cachedFacilities =
          await FacilityLocalStorageService.getFacilities();
      final facilities = _convertToFacilityList(cachedFacilities);

      final filteredFacilities = facilities
          .where((facility) => facility.type == type)
          .toList();

      // 2. 로컬 결과가 충분하면 반환
      if (filteredFacilities.length >= 5) {
        return Result.success(
          '${type.name} タイプの施設を正常に照会しました',
          filteredFacilities,
        );
      }

      // 3. 로컬 결과가 부족하면 Google Places API로 타입별 검색
      final position = await _getCurrentPosition();

      // 타입에 맞는 검색어 생성
      String? placeType;
      switch (type) {
        case FacilityType.hospital:
        case FacilityType.veterinary:
          placeType = 'veterinary_care';
          break;
        case FacilityType.grooming:
          break;
        case FacilityType.petShop:
        case FacilityType.petStore:
          placeType = 'pet_store';
          break;
        case FacilityType.cafe:
          break;
        case FacilityType.park:
        case FacilityType.petPark:
        case FacilityType.dogRun:
          placeType = 'park';
          break;
        default:
          break;
      }

      final result = await _googlePlacesService.searchNearbyPetFacilities(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 5000,
        type: placeType,
      );

      if (!result.isSuccess) {
        return Result.success(
          '${type.name} タイプの施設を正常に照会しました',
          filteredFacilities,
        );
      }

      final apiResults = result.dataOrNull ?? [];

      // 4. 검색 결과를 로컬 저장소에 추가
      if (apiResults.isNotEmpty) {
        await FacilityLocalStorageService.addFacilities(
          apiResults.map(_facilityToMap).toList(),
        );
      }

      // 5. 로컬 결과와 API 결과 합치기
      final allResults = <String, Facility>{};
      for (final facility in [...filteredFacilities, ...apiResults]) {
        allResults[facility.id] = facility;
      }

      return Result.success(
        '${type.name} タイプの施設を正常に照会しました',
        allResults.values.toList(),
      );
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  @override
  Future<Result<Facility>> getFacilityById(String id) async {
    try {
      // 1. 로컬 저장소에서 검색
      final facilitiesData = await FacilityLocalStorageService.getFacilities();
      final facilities = _convertToFacilityList(facilitiesData);
      final facility = facilities.where((f) => f.id == id).firstOrNull;

      if (facility != null) {
        return Result.success('施設情報を正常に照会しました', facility);
      }

      // 2. 로컬에 없으면 Google Places Details API로 상세 정보 가져오기
      final result = await _googlePlacesService.getFacilityDetails(id);

      if (!result.isSuccess) {
        return Result.failure('施設を見つけることができません');
      }

      final facilityDetail = result.dataOrNull;
      if (facilityDetail != null) {
        // 로컬 저장소에 추가
        await FacilityLocalStorageService.addFacility(
          _facilityToMap(facilityDetail),
        );
        return Result.success('施設情報を正常に照会しました', facilityDetail);
      }

      return Result.failure('施設を見つけることができません');
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  @override
  Future<Result<List<Facility>>> getFacilitiesInRadius(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      // Google Places API로 반경 내 시설 검색
      final result = await _googlePlacesService.searchNearbyPetFacilities(
        latitude: latitude,
        longitude: longitude,
        radius: (radius * 1000).toInt(), // km를 m로 변환
      );

      if (!result.isSuccess) {
        // 에러 메시지는 문자열로 변환하여 반환
        final errorMessage = result.error?.toString() ?? '施設検索に失敗しました';
        return Result.failure(errorMessage);
      }

      final facilities = result.dataOrNull ?? [];

      // 로컬 저장소에 저장
      if (facilities.isNotEmpty) {
        await FacilityLocalStorageService.addFacilities(
          facilities.map(_facilityToMap).toList(),
        );
      }

      return Result.success('半径内の施設を正常に照会しました', facilities);
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  @override
  Future<Result<void>> setCurrentLocation(
    double latitude,
    double longitude,
    String address,
  ) async {
    try {
      // 현재 위치 기반으로 주변 시설 재검색
      final result = await _googlePlacesService.searchNearbyPetFacilities(
        latitude: latitude,
        longitude: longitude,
        radius: 5000,
      );

      if (!result.isSuccess) {
        // 에러 메시지는 문자열로 변환하여 반환
        final errorMessage = result.error?.toString() ?? '施設検索に失敗しました';
        return Result.failure(errorMessage);
      }

      final facilities = result.dataOrNull ?? [];

      // 기존 캐시 삭제 후 새로운 결과 저장
      await FacilityLocalStorageService.clearAllFacilities();

      if (facilities.isNotEmpty) {
        await FacilityLocalStorageService.addFacilities(
          facilities.map(_facilityToMap).toList(),
        );
      }

      return Result.success('現在地を正常に設定しました', null);
    } catch (e) {
      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure(appException.toString());
    }
  }

  /// 현재 위치 가져오기 (위치 권한 처리 포함)
  Future<Position> _getCurrentPosition() async {
    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        // 권한이 없으면 기본 위치 반환 (도쿄)
        return Position(
          latitude: 35.6762,
          longitude: 139.6503,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }

      // 현재 위치 가져오기
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );
    } catch (e) {
      // 에러 발생 시 기본 위치 반환 (도쿄)
      return Position(
        latitude: 35.6762,
        longitude: 139.6503,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
  }

  /// Facility를 Map으로 변환
  Map<String, dynamic> _facilityToMap(Facility facility) {
    return {
      'id': facility.id,
      'name': facility.name,
      'description': facility.description,
      'address': facility.address,
      'latitude': facility.latitude,
      'longitude': facility.longitude,
      'phone': facility.phone,
      'email': facility.email,
      'type': facility.type.name,
      'rating': facility.rating,
      'reviewCount': facility.reviewCount,
      'imagePath': facility.imagePath,
      'isFavorite': facility.isFavorite,
      'hasHistory': facility.hasHistory,
      'lastVisit': facility.lastVisit?.toIso8601String(),
      'isOpen': facility.isOpen,
      'createdAt': facility.createdAt?.toIso8601String(),
    };
  }

  /// Map 데이터를 Facility 객체 리스트로 변환
  List<Facility> _convertToFacilityList(
    List<Map<String, dynamic>> facilitiesData,
  ) {
    return facilitiesData
        .map(
          (data) => Facility(
            id: data['id'] as String,
            name: data['name'] as String,
            description: data['description'] as String? ?? '',
            address: data['address'] as String? ?? '',
            latitude: data['latitude'] as double? ?? 35.6762,
            longitude: data['longitude'] as double? ?? 139.6503,
            phone: data['phone'] as String?,
            email: data['email'] as String?,
            type: _convertStringToFacilityType(data['type'] as String?),
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            reviewCount: data['reviewCount'] as int? ?? 0,
            imagePath: data['imagePath'] as String?,
            isFavorite: data['isFavorite'] as bool? ?? false,
            hasHistory: data['hasHistory'] as bool? ?? false,
            lastVisit: data['lastVisit'] != null
                ? DateTime.parse(data['lastVisit'] as String)
                : null,
            isOpen: data['isOpen'] as bool? ?? true,
            createdAt: data['createdAt'] != null
                ? DateTime.parse(data['createdAt'] as String)
                : null,
          ),
        )
        .toList();
  }

  /// 문자열을 FacilityType으로 변환
  FacilityType _convertStringToFacilityType(String? typeString) {
    switch (typeString) {
      case 'hospital':
        return FacilityType.hospital;
      case 'veterinary':
        return FacilityType.veterinary;
      case 'grooming':
        return FacilityType.grooming;
      case 'petShop':
        return FacilityType.petShop;
      case 'petStore':
        return FacilityType.petStore;
      case 'dogRun':
        return FacilityType.dogRun;
      case 'park':
        return FacilityType.park;
      case 'petPark':
        return FacilityType.petPark;
      case 'cafe':
        return FacilityType.cafe;
      case 'hotel':
        return FacilityType.hotel;
      case 'petFriendlyAccommodation':
        return FacilityType.petFriendlyAccommodation;
      case 'training':
        return FacilityType.training;
      default:
        return FacilityType.other;
    }
  }
}
