import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';


import '../../../shared/shared.dart';
import '../api/backend_api_client.dart';
import 'firebase_token_service.dart';
import 'logger_service.dart';

/// 백엔드 토큰 전송 서비스
///
/// Firebase ID Token을 백엔드 서버로 전송하여 인증합니다.
class BackendTokenService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// Firebase ID Token을 백엔드로 전송하여 인증
  ///
  /// 로그인 성공 후 호출하여 백엔드 세션을 설정합니다.
  ///
  /// Returns: 성공 여부
  static Future<bool> sendTokenToBackend() async {
    try {
      if (kDebugMode) {
        LoggerService.debug('🔄 백엔드로 Firebase ID Token 전송 시작...');
      }

      // 1. Firebase ID Token 획득
      final token = await FirebaseTokenService.getIdToken();
      if (token == null) {
        if (kDebugMode) {
          LoggerService.debug('❌ Firebase ID Token이 없습니다');
        }
        return false;
      }

      // 2. SecureStorage에 토큰 저장 (백엔드 API 호출 시 사용)
      await FirebaseTokenService.saveTokenToStorage();

      // 3. 백엔드 API 호출 테스트 (예: /auth/verify-token)
      try {
        final response = await _apiClient.post(
          '/auth/verify-token',
          data: {'token': token},
        );

        if (response.statusCode == 200) {
          if (kDebugMode) {
            LoggerService.debug('✅ 백엔드 토큰 인증 성공');
            LoggerService.debug('   Response: ${response.data}');
          }
          return true;
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          // 백엔드에 /auth/verify-token 엔드포인트가 없는 경우
          // 토큰만 저장하고 성공으로 처리
          if (kDebugMode) {
            LoggerService.debug('⚠️ /auth/verify-token 엔드포인트 없음');
            LoggerService.debug('   토큰 저장만 완료 (백엔드 API 호출 시 자동 사용)');
          }
          return true;
        }

        if (kDebugMode) {
          LoggerService.debug('❌ 백엔드 API 에러: ${e.response?.statusCode}');
          LoggerService.debug('   Message: ${e.message}');
        }
        return false;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ 백엔드 토큰 전송 실패: $e');
      }
      return false;
    }
  }

  /// 사용자 정보를 백엔드로 전송
  ///
  /// Firebase 로그인 성공 후 사용자 정보를 백엔드에 등록/업데이트합니다.
  static Future<bool> syncUserToBackend() async {
    try {
      if (kDebugMode) {
        LoggerService.debug('🔄 백엔드로 사용자 정보 동기화 시작...');
      }

      final userId = FirebaseTokenService.getCurrentUserId();
      final email = FirebaseTokenService.getCurrentUserEmail();

      if (userId == null || email == null) {
        if (kDebugMode) {
          LoggerService.debug('❌ Firebase 사용자 정보가 없습니다');
        }
        return false;
      }

      // 백엔드 API 호출 (예: POST /users 또는 POST /auth/sync-user)
      try {
        final response = await _apiClient.post(
          '/users',
          data: {'uid': userId, 'email': email},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (kDebugMode) {
            LoggerService.debug('✅ 백엔드 사용자 동기화 성공');
            LoggerService.debug('   UID: $userId');
            LoggerService.debug('   Email: $email');
          }
          return true;
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          // 백엔드에 엔드포인트가 없는 경우
          if (kDebugMode) {
            LoggerService.debug('⚠️ 백엔드 /users 엔드포인트 없음 (건너뛰기)');
          }
          return true; // 엔드포인트 없어도 성공으로 처리
        }

        if (kDebugMode) {
          LoggerService.debug('❌ 사용자 동기화 실패: ${e.response?.statusCode}');
        }
        return false;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ 백엔드 사용자 동기화 실패: $e');
      }
      return false;
    }
  }

  /// 백엔드 연결 테스트
  ///
  /// 백엔드 서버가 정상 작동하는지 확인합니다.
  static Future<bool> testBackendConnection() async {
    try {
      if (kDebugMode) {
        LoggerService.debug('🔍 백엔드 연결 테스트...');
      }

      final response = await _apiClient.get('/');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          LoggerService.debug('✅ 백엔드 연결 성공');
          LoggerService.debug('   Response: ${response.data}');
        }
        return true;
      }

      return false;
    } on DioException catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ 백엔드 연결 실패: ${e.type}');
        LoggerService.debug('   Message: ${e.message}');

        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          LoggerService.debug('   💡 백엔드 서버가 실행 중인지 확인하세요');
          LoggerService.debug(
            '   💡 Android 에뮬레이터: adb reverse tcp:3000 tcp:3000',
          );
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ 백엔드 연결 테스트 실패: $e');
      }
      return false;
    }
  }

  /// 백엔드로 토큰과 사용자 정보를 모두 전송
  ///
  /// 로그인 성공 후 한 번에 호출하여 백엔드 인증 및 사용자 동기화를 수행합니다.
  static Future<bool> authenticateWithBackend() async {
    try {
      if (kDebugMode) {
        LoggerService.debug('🚀 백엔드 인증 프로세스 시작...');
      }

      // 1. 백엔드 연결 테스트
      final isConnected = await testBackendConnection();
      if (!isConnected) {
        if (kDebugMode) {
          LoggerService.debug('⚠️ 백엔드 연결 실패 - 인증 건너뛰기');
        }
        // 백엔드 연결 실패해도 앱은 계속 사용 가능 (로컬 모드)
        return false;
      }

      // 2. Firebase ID Token 전송
      final tokenSent = await sendTokenToBackend();
      if (!tokenSent) {
        if (kDebugMode) {
          LoggerService.debug('⚠️ 토큰 전송 실패');
        }
        return false;
      }

      // 3. 사용자 정보 동기화
      final userSynced = await syncUserToBackend();
      if (!userSynced) {
        if (kDebugMode) {
          LoggerService.debug('⚠️ 사용자 동기화 실패');
        }
        // 사용자 동기화 실패해도 토큰은 전송되었으므로 부분 성공
        return true;
      }

      if (kDebugMode) {
        LoggerService.debug('✅ 백엔드 인증 프로세스 완료');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ 백엔드 인증 프로세스 실패: $e');
      }
      return false;
    }
  }
}
