import 'dart:convert';

import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../domain/domain.dart';

/// 루트 정보를 담는 클래스
class RouteInfo {
  final List<LatLng> polylinePoints;
  final String distanceText;
  final String durationText;
  final double distanceValue; // meters
  final double durationValue; // seconds

  const RouteInfo({
    required this.polylinePoints,
    required this.distanceText,
    required this.durationText,
    required this.distanceValue,
    required this.durationValue,
  });
}

/// Google Places API 통합 서비스
class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _directionsBaseUrl = 'https://maps.googleapis.com/maps/api/directions';
  static const Duration _timeout = Duration(seconds: 10);

  /// 주변 반려동물 관련 시설 검색
  Future<Result<List<Facility>>> searchNearbyPetFacilities({
    required double latitude,
    required double longitude,
    int radius = 5000, // 5km 반경
    String? type,
  }) async {
    try {
      final apiKey = AppConfig.current.googleMapsApiKey;
      if (apiKey.isEmpty) {
        if (AppConfig.current.isMockMode) {
          return _getMockFacilities();
        }
        return Result.failure('Google Maps API 키가 설정되지 않았습니다');
      }

      // Google Places API 요청 파라미터
      final Map<String, String> params = {
        'location': '$latitude,$longitude',
        'radius': radius.toString(),
        'type': type ?? 'veterinary_care', // 기본값: 동물병원
        'key': apiKey,
        'language': 'ja', // 일본어
      };

      final uri = Uri.parse(
        '$_baseUrl/nearbysearch/json',
      ).replace(queryParameters: params);

      LoggerService.debug('🗺️ Google Places API 요청: $uri');

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          final facilities = results
              .map(
                (result) => _mapPlaceToFacility(result as Map<String, dynamic>),
              )
              .where((facility) => facility != null)
              .cast<Facility>()
              .toList();

          return Result.success('주변 시설을 성공적으로 찾았습니다', facilities);
        } else {
          final errorMessage =
              data['error_message'] as String? ??
              'Google Places API 오류: ${data['status']}';
          return Result.failure(errorMessage);
        }
      } else {
        return Result.failure(
          'Google Places API 요청 실패: ${response.statusCode}',
        );
      }
    } catch (error) {
      LoggerService.debug('Google Places API 오류: $error');
      if (AppConfig.current.isMockMode) {
        return _getMockFacilities();
      }
      return Result.failure('주변 시설 검색에 실패했습니다: ${error.toString()}');
    }
  }

  /// 텍스트로 시설 검색
  Future<Result<List<Facility>>> searchFacilitiesByText({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 10000, // 10km 반경
  }) async {
    try {
      final apiKey = AppConfig.current.googleMapsApiKey;
      if (apiKey.isEmpty) {
        if (AppConfig.current.isMockMode) {
          return _getMockFacilities();
        }
        return Result.failure('Google Maps API 키가 설정되지 않았습니다');
      }

      final Map<String, String> params = {
        'query': '$query 동물병원 펜션 애완동물',
        'key': apiKey,
        'language': 'ja',
      };

      // 위치가 제공된 경우 위치 바이어스 추가
      if (latitude != null && longitude != null) {
        params['location'] = '$latitude,$longitude';
        params['radius'] = radius.toString();
      }

      final uri = Uri.parse(
        '$_baseUrl/textsearch/json',
      ).replace(queryParameters: params);

      LoggerService.debug('🔍 Google Places 텍스트 검색: $uri');

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          final facilities = results
              .map(
                (result) => _mapPlaceToFacility(result as Map<String, dynamic>),
              )
              .where((facility) => facility != null)
              .cast<Facility>()
              .toList();

          return Result.success('검색 결과를 성공적으로 가져왔습니다', facilities);
        } else {
          final errorMessage =
              data['error_message'] as String? ??
              'Google Places API 오류: ${data['status']}';
          return Result.failure(errorMessage);
        }
      } else {
        return Result.failure(
          'Google Places API 요청 실패: ${response.statusCode}',
        );
      }
    } catch (error) {
      LoggerService.debug('Google Places 텍스트 검색 오류: $error');
      if (AppConfig.current.isMockMode) {
        return _getMockFacilities();
      }
      return Result.failure('시설 검색에 실패했습니다: ${error.toString()}');
    }
  }

  /// 시설 상세 정보 가져오기
  Future<Result<Facility>> getFacilityDetails(String placeId) async {
    try {
      final apiKey = AppConfig.current.googleMapsApiKey;
      if (apiKey.isEmpty) {
        return Result.failure('Google Maps API 키가 설정되지 않았습니다');
      }

      final Map<String, String> params = {
        'place_id': placeId,
        'fields':
            'name,formatted_address,formatted_phone_number,website,opening_hours,rating,reviews,geometry,types',
        'key': apiKey,
        'language': 'ja',
      };

      final uri = Uri.parse(
        '$_baseUrl/details/json',
      ).replace(queryParameters: params);

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'OK') {
          final result = data['result'] as Map<String, dynamic>;
          final facility = _mapPlaceToFacility(result);

          if (facility != null) {
            return Result.success('시설 상세 정보를 가져왔습니다', facility);
          } else {
            return Result.failure('시설 정보를 파싱할 수 없습니다');
          }
        } else {
          final errorMessage =
              data['error_message'] as String? ??
              'Google Places API 오류: ${data['status']}';
          return Result.failure(errorMessage);
        }
      } else {
        return Result.failure(
          'Google Places API 요청 실패: ${response.statusCode}',
        );
      }
    } catch (error) {
      LoggerService.debug('Google Places 상세 정보 오류: $error');
      return Result.failure('시설 상세 정보를 가져오는데 실패했습니다: ${error.toString()}');
    }
  }

  /// 시설 리뷰 가져오기
  Future<Result<FacilityReviews>> getFacilityReviews(String placeId) async {
    try {
      final apiKey = AppConfig.current.googleMapsApiKey;
      if (apiKey.isEmpty) {
        if (AppConfig.current.isMockMode) {
          return Result.success('Mock 리뷰 데이터', _getMockReviews());
        }
        return Result.failure('Google Maps API 키가 설정되지 않았습니다');
      }

      final Map<String, String> params = {
        'place_id': placeId,
        'fields': 'rating,user_ratings_total,reviews',
        'key': apiKey,
        'language': 'ja',
        'reviews_sort': 'newest', // 최신순 정렬
      };

      final uri = Uri.parse(
        '$_baseUrl/details/json',
      ).replace(queryParameters: params);

      LoggerService.debug('📝 Google Places 리뷰 요청: $uri');

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'OK') {
          final result = data['result'] as Map<String, dynamic>;
          final reviews = FacilityReviews.fromPlaceDetails(result);
          return Result.success('リビューを取得しました', reviews);
        } else if (data['status'] == 'ZERO_RESULTS') {
          return Result.success('レビューがありません', FacilityReviews.empty);
        } else {
          final errorMessage =
              data['error_message'] as String? ??
              'Google Places API エラー: ${data['status']}';
          return Result.failure(errorMessage);
        }
      } else {
        return Result.failure(
          'Google Places API 요청 실패: ${response.statusCode}',
        );
      }
    } catch (error) {
      LoggerService.debug('Google Places 리뷰 오류: $error');
      if (AppConfig.current.isMockMode) {
        return Result.success('Mock 리뷰 데이터', _getMockReviews());
      }
      return Result.failure('レビュー取得に失敗しました: ${error.toString()}');
    }
  }

  /// Mock 리뷰 데이터
  FacilityReviews _getMockReviews() {
    return FacilityReviews(
      averageRating: 4.5,
      totalReviews: 127,
      reviews: [
        Review(
          authorName: '田中太郎',
          authorPhotoUrl: null,
          rating: 5.0,
          text: 'スタッフの方がとても親切で、うちの犬も安心して診察を受けられました。待ち時間も少なく、説明も丁寧でした。',
          relativeTimeDescription: '1週間前',
          time: DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
        ),
        Review(
          authorName: '鈴木花子',
          authorPhotoUrl: null,
          rating: 4.0,
          text: '清潔感があり、設備も整っています。予約制なので待ち時間が少ないのが良いです。',
          relativeTimeDescription: '2週間前',
          time: DateTime.now().subtract(const Duration(days: 14)).millisecondsSinceEpoch ~/ 1000,
        ),
        Review(
          authorName: '佐藤健一',
          authorPhotoUrl: null,
          rating: 5.0,
          text: '緊急時にも対応していただき、本当に助かりました。24時間対応は心強いです。',
          relativeTimeDescription: '1ヶ月前',
          time: DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
        ),
        Review(
          authorName: '山田優子',
          authorPhotoUrl: null,
          rating: 4.0,
          text: '料金は少し高めですが、サービスの質を考えると納得できます。',
          relativeTimeDescription: '2ヶ月前',
          time: DateTime.now().subtract(const Duration(days: 60)).millisecondsSinceEpoch ~/ 1000,
        ),
      ],
    );
  }

  /// Google Place 데이터를 Facility 엔티티로 변환
  Facility? _mapPlaceToFacility(Map<String, dynamic> place) {
    try {
      final geometry = place['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;

      if (location == null) return null;

      final types = (place['types'] as List<dynamic>?)?.cast<String>() ?? [];
      final facilityType = _determineFacilityType(types);

      return Facility(
        id: place['place_id'] as String? ?? '',
        name: place['name'] as String? ?? '알 수 없는 시설',
        address:
            place['formatted_address'] as String? ??
            place['vicinity'] as String? ??
            '주소 정보 없음',
        phone: place['formatted_phone_number'] as String?,
        website: place['website'] as String?,
        latitude: (location['lat'] as num).toDouble(),
        longitude: (location['lng'] as num).toDouble(),
        rating: (place['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: (place['user_ratings_total'] as int?) ?? 0,
        type: facilityType,
        isOpen: _isCurrentlyOpen(
          place['opening_hours'] as Map<String, dynamic>?,
        ),
        description: _generateDescription(place),
        isFavorite: false,
        hasHistory: false,
      );
    } catch (error) {
      LoggerService.debug('Place 데이터 변환 오류: $error');
      return null;
    }
  }

  /// Place 타입에서 Facility 타입 결정
  FacilityType _determineFacilityType(List<String> types) {
    if (types.contains('veterinary_care')) {
      return FacilityType.veterinary;
    } else if (types.contains('pet_store')) {
      return FacilityType.petStore;
    } else if (types.contains('lodging') || types.contains('rv_park')) {
      return FacilityType.petFriendlyAccommodation;
    } else if (types.contains('park')) {
      return FacilityType.petPark;
    } else {
      return FacilityType.other;
    }
  }

  /// 현재 영업 중인지 확인
  bool _isCurrentlyOpen(Map<String, dynamic>? openingHours) {
    return openingHours?['open_now'] as bool? ?? false;
  }

  /// 설명 생성
  String? _generateDescription(Map<String, dynamic> place) {
    final types = (place['types'] as List<dynamic>?)?.cast<String>() ?? [];
    final reviews = place['reviews'] as List<dynamic>?;

    String description = '';

    // 타입 기반 설명
    if (types.contains('veterinary_care')) {
      description += '동물병원 • ';
    }
    if (types.contains('pet_store')) {
      description += '펫샵 • ';
    }

    // 평점 정보
    final rating = place['rating'] as num?;
    if (rating != null) {
      description += '평점 ${rating.toStringAsFixed(1)} • ';
    }

    // 첫 번째 리뷰 요약
    if (reviews != null && reviews.isNotEmpty) {
      final firstReview = reviews.first as Map<String, dynamic>;
      final reviewText = firstReview['text'] as String?;
      if (reviewText != null && reviewText.length > 10) {
        description += reviewText.substring(0, 50);
        if (reviewText.length > 50) description += '...';
      }
    }

    return description.isNotEmpty ? description : null;
  }

  /// 두 지점 간의 직선 거리 계산 (km)
  static double calculateDistance({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final distanceInMeters = Geolocator.distanceBetween(
      fromLat,
      fromLng,
      toLat,
      toLng,
    );
    return distanceInMeters / 1000; // meters to km
  }

  /// 시설 목록에 현재 위치로부터의 거리 추가
  List<Facility> addDistanceToFacilities({
    required List<Facility> facilities,
    required double currentLat,
    required double currentLng,
  }) {
    return facilities.map((facility) {
      final distance = calculateDistance(
        fromLat: currentLat,
        fromLng: currentLng,
        toLat: facility.latitude,
        toLng: facility.longitude,
      );
      return facility.copyWith(distance: distance);
    }).toList()
      ..sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
  }

  /// Google Directions API를 사용하여 루트 정보 가져오기
  Future<Result<RouteInfo>> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'walking', // walking, driving, transit
  }) async {
    try {
      final apiKey = AppConfig.current.googleMapsApiKey;
      if (apiKey.isEmpty) {
        return Result.failure('Google Maps API 키가 설정되지 않았습니다');
      }

      final Map<String, String> params = {
        'origin': '$originLat,$originLng',
        'destination': '$destLat,$destLng',
        'mode': mode,
        'key': apiKey,
        'language': 'ja',
      };

      final uri = Uri.parse(
        '$_directionsBaseUrl/json',
      ).replace(queryParameters: params);

      LoggerService.debug('🚶 Google Directions API 요청: $uri');

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'OK') {
          final routes = data['routes'] as List<dynamic>;
          if (routes.isEmpty) {
            return Result.failure('ルートが見つかりませんでした');
          }

          final route = routes.first as Map<String, dynamic>;
          final legs = route['legs'] as List<dynamic>;
          if (legs.isEmpty) {
            return Result.failure('ルート情報が不完全です');
          }

          final leg = legs.first as Map<String, dynamic>;
          final distance = leg['distance'] as Map<String, dynamic>;
          final duration = leg['duration'] as Map<String, dynamic>;

          // Polyline 디코딩
          final overviewPolyline = route['overview_polyline'] as Map<String, dynamic>;
          final encodedPoints = overviewPolyline['points'] as String;
          final polylinePoints = _decodePolyline(encodedPoints);

          final routeInfo = RouteInfo(
            polylinePoints: polylinePoints,
            distanceText: distance['text'] as String,
            durationText: duration['text'] as String,
            distanceValue: (distance['value'] as num).toDouble(),
            durationValue: (duration['value'] as num).toDouble(),
          );

          return Result.success('ルートを取得しました', routeInfo);
        } else if (data['status'] == 'ZERO_RESULTS') {
          return Result.failure('この場所へのルートが見つかりませんでした');
        } else {
          final errorMessage =
              data['error_message'] as String? ??
              'Google Directions API エラー: ${data['status']}';
          return Result.failure(errorMessage);
        }
      } else {
        return Result.failure(
          'Google Directions API 요청 실패: ${response.statusCode}',
        );
      }
    } catch (error) {
      LoggerService.debug('Google Directions API 오류: $error');
      return Result.failure('ルート取得に失敗しました: ${error.toString()}');
    }
  }

  /// Google Encoded Polyline을 LatLng 리스트로 디코딩
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  /// 이동 모드에 따른 아이콘 반환
  static IconData getModeIcon(String mode) {
    switch (mode) {
      case 'walking':
        return Icons.directions_walk;
      case 'driving':
        return Icons.directions_car;
      case 'transit':
        return Icons.directions_transit;
      default:
        return Icons.directions;
    }
  }

  /// 이동 모드에 따른 이름 반환
  static String getModeName(String mode) {
    switch (mode) {
      case 'walking':
        return '徒歩';
      case 'driving':
        return '車';
      case 'transit':
        return '交通機関';
      default:
        return '';
    }
  }

  /// Mock 데이터 반환 (API 키가 없거나 테스트 환경일 때)
  Future<Result<List<Facility>>> _getMockFacilities() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mockFacilities = [
      const Facility(
        id: 'mock_vet_1',
        name: '도쿄 펫 동물병원',
        address: '도쿄도 시부야구 동물병원로 123',
        phone: '03-1234-5678',
        latitude: 35.6762,
        longitude: 139.6503,
        rating: 4.5,
        reviewCount: 127,
        type: FacilityType.veterinary,
        isOpen: true,
        description: '24시간 응급진료 가능한 종합 동물병원',
        isFavorite: false,
        hasHistory: false,
      ),
      const Facility(
        id: 'mock_store_1',
        name: '해피펫 용품점',
        address: '도쿄도 신주쿠구 펫샵거리 456',
        phone: '03-9876-5432',
        latitude: 35.6895,
        longitude: 139.6917,
        rating: 4.2,
        reviewCount: 89,
        type: FacilityType.petStore,
        isOpen: true,
        description: '프리미엄 반려동물 용품 전문점',
        isFavorite: false,
        hasHistory: false,
      ),
      const Facility(
        id: 'mock_park_1',
        name: '요요기 펫 파크',
        address: '도쿄도 시부야구 요요기공원 내',
        latitude: 35.6719,
        longitude: 139.6942,
        rating: 4.0,
        reviewCount: 203,
        type: FacilityType.petPark,
        isOpen: true,
        description: '넓은 잔디밭과 애견 놀이터가 있는 공원',
        isFavorite: false,
        hasHistory: false,
      ),
    ];

    return Result.success('Mock 시설 데이터를 로드했습니다', mockFacilities);
  }
}

/// GooglePlacesService Provider
final googlePlacesServiceProvider = Provider<GooglePlacesService>((ref) {
  return GooglePlacesService();
});
