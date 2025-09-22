import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../app/services/dio_client.dart';
import '../../../app/services/secure_storage.dart';
import '../domain/auth_repository.dart';

/// AuthRepository의 구현체
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    Dio? dio,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _dio = dio ?? DioClient.instance;

  @override
  Future<String> exchangeServerToken(String idToken) async {
    try {
      final response = await _dio.post(
        '/api/firebase-auth/login', // Changed: 상대 경로로 수정
        data: {'idToken': idToken},
      );

      final serverJWT = response.data['token'] as String?;
      if (serverJWT == null || serverJWT.isEmpty) {
        throw Exception('서버에서 유효한 JWT 토큰을 받지 못했습니다');
      }

      // Changed: 만료 시간과 함께 토큰 저장
      final expiresIn = response.data['expiresIn'] as int? ?? 3600; // 기본 1시간
      final expiry = DateTime.now().add(Duration(seconds: expiresIn));

      await SecureStorage.saveServerJWTWithExpiry(serverJWT, expiry);

      if (kDebugMode) {
        print('💾 토큰 만료 시간: ${expiry.toIso8601String()}');
      }

      if (kDebugMode) {
        print('✅ 서버 JWT 교환 성공');
      }

      return serverJWT;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ 서버 JWT 교환 실패: ${e.message}');
      }

      switch (e.response?.statusCode) {
        case 400:
          throw Exception('잘못된 요청입니다. Firebase 토큰을 확인해주세요'); // Changed: 구체적 메시지
        case 401:
          throw Exception('Firebase ID 토큰이 만료되었습니다. 다시 로그인해주세요'); // Changed: 재로그인 유도
        case 403:
          throw Exception('접근 권한이 없습니다'); // Changed: 403 케이스 추가
        case 500:
          throw Exception('서버 내부 오류입니다. 잠시 후 다시 시도해주세요'); // Changed: 재시도 유도
        case 503:
          throw Exception('서버가 일시적으로 사용할 수 없습니다'); // Changed: 503 케이스 추가
        default:
          if (e.type == DioExceptionType.connectionTimeout) { // Changed: 타임아웃 구분
            throw Exception('연결 시간이 초과되었습니다. 네트워크를 확인해주세요');
          } else if (e.type == DioExceptionType.receiveTimeout) {
            throw Exception('응답 시간이 초과되었습니다. 다시 시도해주세요');
          } else {
            throw Exception('네트워크 오류가 발생했습니다: ${e.message}');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 예상치 못한 오류: $e');
      }
      throw Exception('토큰 교환 중 오류가 발생했습니다');
    }
  }

  @override
  Future<String?> getCurrentUserIdToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('⚠️ Firebase 사용자가 로그인되지 않음');
        }
        return null;
      }

      // 최신 ID 토큰 획득 (강제 새로고침)
      final idToken = await user.getIdToken(true);

      if (kDebugMode) {
        print('✅ Firebase ID 토큰 획득 성공');
      }

      return idToken;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase ID 토큰 획득 실패: $e');
      }
      throw Exception('Firebase ID 토큰을 가져올 수 없습니다');
    }
  }

  @override
  Future<String?> getStoredServerToken() async {
    return SecureStorage.getServerJWT();
  }

  @override
  Future<void> saveServerToken(String token) async {
    await SecureStorage.saveServerJWT(token);
  }

  @override
  Future<void> clearServerToken() async {
    await SecureStorage.deleteServerJWT();
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      // Firebase 인증 확인
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // 서버 JWT 토큰 확인
      final serverToken = await getStoredServerToken();
      if (serverToken == null || serverToken.isEmpty) return false;

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 인증 상태 확인 실패: $e');
      }
      return false;
    }
  }

  /// Firebase 로그인 완료된 사용자의 idToken을 서버 JWT로 교환하는 헬퍼 메서드
  Future<String> exchangeCurrentUserToken() async {
    final idToken = await getCurrentUserIdToken();
    if (idToken == null) {
      throw Exception('Firebase 사용자가 로그인되지 않았습니다');
    }

    return exchangeServerToken(idToken);
  }
}