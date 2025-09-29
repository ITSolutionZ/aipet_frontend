import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'secure_storage.dart';

/// 토큰 자동 갱신 인터셉터
///
/// 401 에러 발생 시 Firebase 토큰을 자동으로 갱신하고
/// 서버 JWT를 다시 교환한 후 원래 요청을 재시도합니다.
class TokenRefreshInterceptor extends Interceptor {
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;
  bool _isRefreshing = false;

  TokenRefreshInterceptor({FirebaseAuth? firebaseAuth, required Dio dio})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _dio = dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        if (kDebugMode) {
          debugPrint('🔄 토큰 자동 갱신 시작...');
        }

        // Firebase 토큰 갱신 시도
        final refreshed = await _tryRefreshFirebaseToken();
        if (refreshed) {
          // 원래 요청 재시도
          final options = err.requestOptions;

          // 새로운 서버 JWT로 헤더 업데이트
          final newServerJWT = await SecureStorage.getServerJWT();
          if (newServerJWT != null) {
            options.headers['Authorization'] = 'Bearer $newServerJWT';
          }

          if (kDebugMode) {
            debugPrint('🔄 원래 요청 재시도: ${options.path}');
          }

          final response = await _dio.fetch(options);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ 토큰 갱신 실패: $e');
        }
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }

  /// Firebase 토큰 갱신 및 서버 JWT 재교환
  Future<bool> _tryRefreshFirebaseToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase 사용자가 로그인되지 않음');
        }
        return false;
      }

      // Firebase 토큰 강제 갱신
      final newIdToken = await user.getIdToken(true);
      if (kDebugMode) {
        debugPrint('✅ Firebase 토큰 갱신 성공');
      }

      // 서버 JWT 재교환
      final response = await _dio.post(
        '/api/firebase-auth/login',
        data: {'idToken': newIdToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // Authorization 헤더 제거 (토큰 교환 요청이므로)
          },
        ),
      );

      final newServerJWT = response.data['token'] as String?;
      if (newServerJWT != null && newServerJWT.isNotEmpty) {
        await SecureStorage.saveServerJWT(newServerJWT);
        if (kDebugMode) {
          debugPrint('✅ 서버 JWT 자동 갱신 완료');
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase 토큰 갱신 오류: $e');
      }
      return false;
    }
  }
}
