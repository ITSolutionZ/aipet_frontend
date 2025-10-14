import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Google Places API 서비스
///
/// Google Maps Places API를 사용하여 동물병원 및 동물 관련 시설을 검색합니다
class GooglePlacesService {
  // Google Maps API 키 설정
  // 보안상 환경변수 또는 secure storage 사용을 권장합니다
  static final String _apiKey =
      dotenv.env['GOOGLE_MAPS_API_KEY'] ??
      dotenv.env['GOOGLE_PUBLIC_API_KEY'] ??
      '';

  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  /// 주변 동물병원 검색
  static Future<List<Map<String, dynamic>>> searchNearbyVeterinary({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) {
    return _nearbySearch(
      latitude: latitude,
      longitude: longitude,
      keyword: '動物病院',
      type: 'veterinary_care',
      radiusMeters: radiusMeters,
    );
  }

  /// 주변 펫 그루밍샵 검색
  static Future<List<Map<String, dynamic>>> searchNearbyGrooming({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) {
    return _nearbySearch(
      latitude: latitude,
      longitude: longitude,
      keyword: 'ペット美容',
      radiusMeters: radiusMeters,
    );
  }

  /// 주변 펫샵 검색
  static Future<List<Map<String, dynamic>>> searchNearbyPetShop({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) {
    return _nearbySearch(
      latitude: latitude,
      longitude: longitude,
      keyword: 'ペットショップ',
      type: 'pet_store',
      radiusMeters: radiusMeters,
    );
  }

  /// 주변 펫카페 검색
  static Future<List<Map<String, dynamic>>> searchNearbyPetCafe({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) {
    return _nearbySearch(
      latitude: latitude,
      longitude: longitude,
      keyword: 'ペットカフェ',
      radiusMeters: radiusMeters,
    );
  }

  /// 주변 도그런/펫파크 검색
  static Future<List<Map<String, dynamic>>> searchNearbyPetPark({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) {
    return _nearbySearch(
      latitude: latitude,
      longitude: longitude,
      keyword: 'ドッグラン',
      type: 'park',
      radiusMeters: radiusMeters,
    );
  }

  /// 모든 동물 관련 시설 검색
  static Future<List<Map<String, dynamic>>> searchAllPetFacilities({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) async {
    try {
      // 병렬로 여러 타입 검색
      final results = await Future.wait([
        searchNearbyVeterinary(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
        ),
        searchNearbyGrooming(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
        ),
        searchNearbyPetShop(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
        ),
        searchNearbyPetCafe(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
        ),
        searchNearbyPetPark(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
        ),
      ]);

      // 모든 결과 합치기
      final allFacilities = <Map<String, dynamic>>[];
      for (final result in results) {
        allFacilities.addAll(result);
      }

      // 중복 제거 (place_id 기준)
      final uniqueFacilities = <String, Map<String, dynamic>>{};
      for (final facility in allFacilities) {
        final placeId = facility['place_id'] as String;
        if (!uniqueFacilities.containsKey(placeId)) {
          uniqueFacilities[placeId] = facility;
        }
      }

      return uniqueFacilities.values.toList();
    } catch (e) {
      debugPrint('모든 시설 검색 실패: $e');
      return [];
    }
  }

  /// 텍스트 검색
  static Future<List<Map<String, dynamic>>> textSearch({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final location = latitude != null && longitude != null
          ? '$latitude,$longitude'
          : null;

      final url = Uri.parse(
        '$_baseUrl/textsearch/json?query=$query&key=$_apiKey${location != null ? '&location=$location&radius=10000' : ''}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results != null) {
          return results
              .map((result) => _convertToFacilityData(result))
              .toList();
        }
      } else {
        debugPrint('Google Places API 오류: ${response.statusCode}');
      }

      return [];
    } catch (e) {
      debugPrint('텍스트 검색 실패: $e');
      return [];
    }
  }

  /// 주변 검색 (Nearby Search API)
  static Future<List<Map<String, dynamic>>> _nearbySearch({
    required double latitude,
    required double longitude,
    required String keyword,
    String? type,
    double radiusMeters = 5000,
  }) async {
    try {
      final location = '$latitude,$longitude';
      final typeParam = type != null ? '&type=$type' : '';

      final url = Uri.parse(
        '$_baseUrl/nearbysearch/json?location=$location&radius=$radiusMeters&keyword=$keyword$typeParam&key=$_apiKey&language=ja',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results != null) {
          return results
              .map((result) => _convertToFacilityData(result))
              .toList();
        }
      } else {
        debugPrint('Google Places API 오류: ${response.statusCode}');
      }

      return [];
    } catch (e) {
      debugPrint('주변 검색 실패: $e');
      return [];
    }
  }

  /// Google Places API 응답을 앱 데이터 형식으로 변환
  static Map<String, dynamic> _convertToFacilityData(dynamic placeData) {
    final place = placeData as Map<String, dynamic>;
    final geometry = place['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;

    return {
      'id': place['place_id'] as String,
      'name': place['name'] as String,
      'description': place['vicinity'] as String?,
      'address': place['vicinity'] as String? ?? '',
      'latitude': location?['lat'] as double? ?? 0.0,
      'longitude': location?['lng'] as double? ?? 0.0,
      'phone': null, // Details API로 가져와야 함
      'email': null,
      'type': _determineTypeFromPlace(place),
      'rating': (place['rating'] as num?)?.toDouble() ?? 0.0,
      'reviewCount': place['user_ratings_total'] as int? ?? 0,
      'imagePath': null,
      'photoReference': _getPhotoReference(place),
      'isFavorite': false,
      'hasHistory': false,
      'isOpen': place['opening_hours']?['open_now'] as bool? ?? false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Place 데이터에서 시설 타입 결정
  static String _determineTypeFromPlace(Map<String, dynamic> place) {
    final types = place['types'] as List<dynamic>?;
    if (types == null) return 'other';

    if (types.contains('veterinary_care')) return 'hospital';
    if (types.contains('pet_store')) return 'petShop';
    if (types.contains('park')) return 'park';
    if (types.contains('cafe')) return 'cafe';

    // 이름이나 vicinity에서 판단
    final name = (place['name'] as String? ?? '').toLowerCase();
    final vicinity = (place['vicinity'] as String? ?? '').toLowerCase();

    if (name.contains('美容') ||
        vicinity.contains('美容') ||
        name.contains('grooming') ||
        vicinity.contains('grooming')) {
      return 'grooming';
    }
    if (name.contains('病院') ||
        vicinity.contains('病院') ||
        name.contains('動物') ||
        vicinity.contains('動物')) {
      return 'hospital';
    }
    if (name.contains('カフェ') ||
        vicinity.contains('カフェ') ||
        name.contains('cafe')) {
      return 'cafe';
    }
    if (name.contains('ホテル') ||
        vicinity.contains('ホテル') ||
        name.contains('hotel')) {
      return 'hotel';
    }

    return 'other';
  }

  /// 사진 참조 가져오기
  static String? _getPhotoReference(Map<String, dynamic> place) {
    final photos = place['photos'] as List<dynamic>?;
    if (photos != null && photos.isNotEmpty) {
      final firstPhoto = photos[0] as Map<String, dynamic>;
      return firstPhoto['photo_reference'] as String?;
    }
    return null;
  }

  /// 사진 URL 생성
  static String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=$_apiKey';
  }

  /// 시설 상세 정보 가져오기 (Place Details API)
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/details/json?place_id=$placeId&fields=name,formatted_address,formatted_phone_number,opening_hours,website,rating,user_ratings_total,photos,geometry&key=$_apiKey&language=ja',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = data['result'] as Map<String, dynamic>?;

        if (result != null) {
          return _convertToDetailedFacilityData(result);
        }
      } else {
        debugPrint('Place Details API 오류: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      debugPrint('시설 상세 정보 가져오기 실패: $e');
      return null;
    }
  }

  /// 상세 정보를 앱 데이터 형식으로 변환
  static Map<String, dynamic> _convertToDetailedFacilityData(
    Map<String, dynamic> detailsData,
  ) {
    final geometry = detailsData['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;

    return {
      'name': detailsData['name'] as String,
      'address': detailsData['formatted_address'] as String? ?? '',
      'phone': detailsData['formatted_phone_number'] as String?,
      'website': detailsData['website'] as String?,
      'latitude': location?['lat'] as double? ?? 0.0,
      'longitude': location?['lng'] as double? ?? 0.0,
      'rating': (detailsData['rating'] as num?)?.toDouble() ?? 0.0,
      'reviewCount': detailsData['user_ratings_total'] as int? ?? 0,
      'openingHours': detailsData['opening_hours'] as Map<String, dynamic>?,
      'photos': detailsData['photos'] as List<dynamic>?,
    };
  }

  /// 현재 위치 가져오기
  static Future<Position?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied) {
          debugPrint('위치 권한 거부됨');
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      debugPrint('현재 위치 가져오기 실패: $e');
      return null;
    }
  }

  /// 기본 위치 (도쿄) 반환
  static Position getDefaultLocation() {
    return Position(
      latitude: 35.6762,
      longitude: 139.6503,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
}
