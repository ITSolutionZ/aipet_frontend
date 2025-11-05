import 'package:flutter/foundation.dart';


import '../../../shared/shared.dart';
import '../services/logger_service.dart';
import 'backend_api_client.dart';

/// BackendApiClient 사용 예제
///
/// Firebase ID Token이 자동으로 추가되어 백엔드로 전송되는 것을 보여줍니다.
class BackendApiUsageExample {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 예제 1: 현재 사용자 정보 조회
  ///
  /// GET /auth/me 호출 시:
  /// - FirebaseTokenInterceptor가 자동으로 Authorization 헤더 추가
  /// - 백엔드에서 토큰 검증 후 사용자 정보 반환
  static Future<void> exampleGetCurrentUser() async {
    try {
      if (kDebugMode) {
        LoggerService.debug('📖 [예제 1] 현재 사용자 정보 조회');
      }

      // ✅ Authorization 헤더가 자동으로 추가됨!
      final response = await _apiClient.getCurrentUser();

      if (response.statusCode == 200) {
        final userData = response.data;
        if (kDebugMode) {
          LoggerService.debug('✅ 사용자 정보 조회 성공:');
          LoggerService.debug('   UID: ${userData?['uid']}');
          LoggerService.debug('   Email: ${userData?['email']}');
          LoggerService.debug('   Name: ${userData?['displayName']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ 사용자 정보 조회 실패: $e');
      }
    }
  }

  /// 예제 2: 펫 목록 조회
  ///
  /// GET /pets 호출 시:
  /// - FirebaseTokenInterceptor가 자동으로 Authorization 헤더 추가
  /// - 백엔드에서 토큰으로 사용자 식별 후 해당 사용자의 펫 목록 반환
  static Future<void> exampleGetPets() async {
    try {
      if (kDebugMode) {
        LoggerService.debug('📖 [예제 2] 펫 목록 조회');
      }

      // ✅ Authorization 헤더가 자동으로 추가됨!
      final response = await _apiClient.get('/pets');

      if (response.statusCode == 200) {
        final pets = response.data;
        if (kDebugMode) {
          LoggerService.debug('✅ 펫 목록 조회 성공:');
          LoggerService.debug('   펫 개수: ${pets is List ? pets.length : 0}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ 펫 목록 조회 실패: $e');
      }
    }
  }

  /// 예제 3: 펫 생성
  ///
  /// POST /pets 호출 시:
  /// - FirebaseTokenInterceptor가 자동으로 Authorization 헤더 추가
  /// - 백엔드에서 토큰으로 사용자 식별 후 ownerId 자동 설정
  static Future<void> exampleCreatePet() async {
    try {
      if (kDebugMode) {
        LoggerService.debug('📖 [예제 3] 펫 생성');
      }

      // ✅ Authorization 헤더가 자동으로 추가됨!
      final response = await _apiClient.post(
        '/pets',
        data: {
          'name': 'テスト',
          'type': 'dog',
          'breed': '柴犬',
          'birthDate': '2020-01-15',
          'gender': 'male',
          'weight': 8.5,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final pet = response.data;
        if (kDebugMode) {
          LoggerService.debug('✅ 펫 생성 성공:');
          LoggerService.debug('   ID: ${pet?['id']}');
          LoggerService.debug('   Name: ${pet?['name']}');
          LoggerService.debug(
            '   OwnerId: ${pet?['ownerId']}',
          ); // 백엔드가 토큰에서 자동 설정
        }
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ 펫 생성 실패: $e');
      }
    }
  }

  /// 예제 4: 401 에러 시 자동 토큰 갱신
  ///
  /// 백엔드에서 401 Unauthorized 반환 시:
  /// - FirebaseTokenInterceptor가 자동으로 토큰 갱신
  /// - 갱신된 토큰으로 같은 요청 재시도
  static Future<void> exampleAutoTokenRefresh() async {
    try {
      if (kDebugMode) {
        LoggerService.debug('📖 [예제 4] 401 에러 시 자동 토큰 갱신');
      }

      // ✅ 토큰 만료 시 자동으로 갱신 및 재시도!
      final response = await _apiClient.get('/auth/me');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          LoggerService.debug('✅ 요청 성공 (토큰 갱신 여부와 관계없이)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ 요청 실패: $e');
      }
    }
  }

  /// 모든 예제 실행
  static Future<void> runAllExamples() async {
    if (kDebugMode) {
      LoggerService.debug('🚀 BackendApiClient 사용 예제 시작...\n');
    }

    await exampleGetCurrentUser();
    await Future.delayed(const Duration(seconds: 1));

    await exampleGetPets();
    await Future.delayed(const Duration(seconds: 1));

    await exampleCreatePet();
    await Future.delayed(const Duration(seconds: 1));

    await exampleAutoTokenRefresh();

    if (kDebugMode) {
      LoggerService.debug('\n✅ 모든 예제 실행 완료!');
    }
  }
}
