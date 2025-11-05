import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../shared/shared.dart';

/// API 환경 모드
enum ApiEnvironment {
  development, // 개발 모드 (Mock 데이터 사용)
  staging, // 스테이징 모드 (테스트 서버)
  production, // 프로덕션 모드 (실제 서버)
}

/// 백엔드 API 통신을 담당하는 서비스
/// Firebase Auth를 사용하여 인증 처리
class ApiService {
  // 환경별 베이스 URL
  static const String _developmentUrl = 'http://localhost:3000';
  static const String _stagingUrl = 'https://staging-api.aipet.com';
  static const String _productionUrl = 'https://api.aipet.com';

  static const Duration timeout = Duration(seconds: 30);

  // 현재 환경 모드 (개발 모드 기본값)
  static ApiEnvironment _currentEnvironment = ApiEnvironment.development;

  // Firebase Auth ID Token (프로덕션/스테이징 모드에서 사용)
  static String? _firebaseIdToken;

  // 로컬 유저 ID (개발 모드 전용)
  static const String _localUserId = 'local_user';

  /// 현재 환경에 맞는 베이스 URL 반환
  static String get baseUrl {
    switch (_currentEnvironment) {
      case ApiEnvironment.development:
        return _developmentUrl;
      case ApiEnvironment.staging:
        return _stagingUrl;
      case ApiEnvironment.production:
        return _productionUrl;
    }
  }

  /// 환경 설정
  static void setEnvironment(ApiEnvironment environment) {
    _currentEnvironment = environment;
    debugPrint('🌍 API Environment: ${environment.name} → $baseUrl');

    if (environment == ApiEnvironment.development) {
      debugPrint('👤 [DEV] 로컬 유저 모드: 로그인 불필요');
    }
  }

  /// Firebase Auth ID Token 설정 (프로덕션/스테이징 모드에서만 사용)
  static void setFirebaseToken(String? token) {
    if (isDevelopmentMode) {
      debugPrint('⚠️ [DEV] 개발 모드에서는 Firebase Token이 필요하지 않습니다');
      return;
    }

    _firebaseIdToken = token;
    debugPrint('🔑 Firebase Token ${token != null ? "설정됨" : "제거됨"}');
  }

  /// 현재 개발 모드인지 확인
  static bool get isDevelopmentMode =>
      _currentEnvironment == ApiEnvironment.development;

  /// 현재 사용자 ID 반환 (개발: 로컬 유저, 프로덕션: Firebase UID)
  static String? get currentUserId {
    if (isDevelopmentMode) {
      return _localUserId;
    }
    // 프로덕션 모드에서는 Firebase Token에서 UID 추출 필요
    return _firebaseIdToken != null ? 'firebase_user' : null;
  }

  /// GET 요청
  static Future<Result<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // 개발 모드에서는 Mock 데이터 반환
      if (isDevelopmentMode) {
        debugPrint('🔄 [DEV] Mock GET: $endpoint');
        return _getMockResponse(endpoint, fromJson);
      }

      debugPrint('📡 GET: $baseUrl$endpoint');
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .get(uri, headers: _buildHeaders(headers))
          .timeout(timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      debugPrint('❌ GET Error: $e');
      return Result.failure('ネットワークエラーが発生しました: $e');
    }
  }

  /// POST 요청
  static Future<Result<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // 개발 모드에서는 Mock 데이터 반환
      if (isDevelopmentMode) {
        debugPrint('🔄 [DEV] Mock POST: $endpoint');
        return _postMockResponse(endpoint, body, fromJson);
      }

      debugPrint('📡 POST: $baseUrl$endpoint');
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      debugPrint('❌ POST Error: $e');
      return Result.failure('ネットワークエラーが発生しました: $e');
    }
  }

  /// PUT 요청
  static Future<Result<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // 개발 모드에서는 Mock 데이터 반환
      if (isDevelopmentMode) {
        debugPrint('🔄 [DEV] Mock PUT: $endpoint');
        return _putMockResponse(endpoint, body, fromJson);
      }

      debugPrint('📡 PUT: $baseUrl$endpoint');
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      debugPrint('❌ PUT Error: $e');
      return Result.failure('ネットワークエラーが発生しました: $e');
    }
  }

  /// DELETE 요청
  static Future<Result<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // 개발 모드에서는 Mock 데이터 반환
      if (isDevelopmentMode) {
        debugPrint('🔄 [DEV] Mock DELETE: $endpoint');
        return _deleteMockResponse(endpoint, fromJson);
      }

      debugPrint('📡 DELETE: $baseUrl$endpoint');
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      debugPrint('❌ DELETE Error: $e');
      return Result.failure('ネットワークエラーが発生しました: $e');
    }
  }

  /// HTTP 헤더 빌드 (Firebase Auth Token 포함)
  static Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 개발 모드: 로컬 유저 헤더 추가
    if (isDevelopmentMode) {
      headers['X-Local-User-Id'] = _localUserId;
      headers['X-Development-Mode'] = 'true';
      debugPrint('👤 [DEV] 로컬 유저 헤더 추가: $_localUserId');
    }
    // 프로덕션/스테이징 모드: Firebase Auth Token 추가
    else if (_firebaseIdToken != null) {
      headers['Authorization'] = 'Bearer $_firebaseIdToken';
      debugPrint('🔑 Firebase Token 헤더 추가');
    }

    // 커스텀 헤더 병합
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// HTTP 응답 처리
  static Result<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    debugPrint('📥 Response Status: ${response.statusCode}');

    try {
      final data = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ API 성공: ${response.statusCode}');
        if (fromJson != null) {
          return Result.success(
            'API 호출이 성공했습니다',
            fromJson(data['data'] ?? data),
          );
        } else {
          return Result.success('API 호출이 성공했습니다', data as T);
        }
      } else {
        debugPrint('❌ API 에러: ${response.statusCode} - ${data['message']}');
        return Result.failure(data['message'] ?? 'サーバーエラーが発生しました');
      }
    } catch (e) {
      debugPrint('❌ Response 파싱 에러: $e');
      return Result.failure('レスポンス処理中にエラーが発生しました: $e');
    }
  }

  /// Mock GET 응답 (개발 모드)
  static Future<Result<T>> _getMockResponse<T>(
    String endpoint,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    debugPrint('⏳ [MOCK] GET 지연 시뮬레이션...');
    await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션

    // Mock 데이터 반환 로직
    final mockData = await _getMockDataForEndpoint(endpoint);
    if (mockData == null) {
      debugPrint('❌ [MOCK] 엔드포인트를 찾을 수 없음: $endpoint');
      return Result.failure('엔드포인트를 찾을 수 없습니다: $endpoint');
    }

    debugPrint('✅ [MOCK] GET 성공: $endpoint');
    if (fromJson != null) {
      return Result.success('Mock GET 요청이 성공했습니다', fromJson(mockData));
    } else {
      return Result.success('Mock GET 요청이 성공했습니다', mockData as T);
    }
  }

  /// Mock POST 응답 (개발 모드)
  static Future<Result<T>> _postMockResponse<T>(
    String endpoint,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    debugPrint('⏳ [MOCK] POST 지연 시뮬레이션...');
    await Future.delayed(const Duration(milliseconds: 800)); // 네트워크 지연 시뮬레이션

    final mockData = await _postMockDataForEndpoint(endpoint, body);
    if (mockData == null) {
      debugPrint('❌ [MOCK] 엔드포인트를 찾을 수 없음: $endpoint');
      return Result.failure('엔드포인트를 찾을 수 없습니다: $endpoint');
    }

    debugPrint('✅ [MOCK] POST 성공: $endpoint');
    if (fromJson != null) {
      return Result.success('Mock POST 요청이 성공했습니다', fromJson(mockData));
    } else {
      return Result.success('Mock POST 요청이 성공했습니다', mockData as T);
    }
  }

  /// Mock PUT 응답 (개발 모드)
  static Future<Result<T>> _putMockResponse<T>(
    String endpoint,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    debugPrint('⏳ [MOCK] PUT 지연 시뮬레이션...');
    await Future.delayed(const Duration(milliseconds: 600));

    final mockData = await _putMockDataForEndpoint(endpoint, body);
    if (mockData == null) {
      debugPrint('❌ [MOCK] 엔드포인트를 찾을 수 없음: $endpoint');
      return Result.failure('엔드포인트를 찾을 수 없습니다: $endpoint');
    }

    debugPrint('✅ [MOCK] PUT 성공: $endpoint');
    if (fromJson != null) {
      return Result.success('Mock PUT 요청이 성공했습니다', fromJson(mockData));
    } else {
      return Result.success('Mock PUT 요청이 성공했습니다', mockData as T);
    }
  }

  /// Mock DELETE 응답 (개발 모드)
  static Future<Result<T>> _deleteMockResponse<T>(
    String endpoint,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    debugPrint('⏳ [MOCK] DELETE 지연 시뮬레이션...');
    await Future.delayed(const Duration(milliseconds: 400));

    final mockData = await _deleteMockDataForEndpoint(endpoint);
    if (mockData == null) {
      debugPrint('❌ [MOCK] 엔드포인트를 찾을 수 없음: $endpoint');
      return Result.failure('엔드포인트를 찾을 수 없습니다: $endpoint');
    }

    debugPrint('✅ [MOCK] DELETE 성공: $endpoint');
    if (fromJson != null) {
      return Result.success('Mock DELETE 요청이 성공했습니다', fromJson(mockData));
    } else {
      return Result.success('Mock DELETE 요청이 성공했습니다', mockData as T);
    }
  }

  /// GET 엔드포인트별 Mock 데이터 (개발 모드)
  static Future<Map<String, dynamic>?> _getMockDataForEndpoint(
    String endpoint,
  ) async {
    debugPrint('📦 [MOCK] Mock 데이터 조회: $endpoint');

    switch (endpoint) {
      case '/auth/me':
        // 개발 모드: 자동으로 로컬 유저 데이터 반환
        debugPrint('👤 [MOCK] 로컬 유저 데이터 반환: $_localUserId');
        return {
          'user': {
            'id': _localUserId,
            'email': 'local@aipet.dev',
            'name': 'ローカルユーザー',
            'createdAt': DateTime.now().toIso8601String(),
          },
        };

      default:
        debugPrint('⚠️ [MOCK] 정의되지 않은 엔드포인트: $endpoint');
        return null;
    }
  }

  /// POST 엔드포인트별 Mock 데이터 (개발 모드)
  static Future<Map<String, dynamic>?> _postMockDataForEndpoint(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    debugPrint('📦 [MOCK] Mock 데이터 생성: $endpoint');

    switch (endpoint) {
      case '/auth/login':
        // 개발 모드: 로그인 불필요, 자동으로 로컬 유저 반환
        debugPrint('👤 [MOCK] 로컬 유저로 자동 로그인 (Firebase 불필요)');
        return {
          'user': {
            'id': _localUserId,
            'email': 'local@aipet.dev',
            'name': 'ローカルユーザー',
            'createdAt': DateTime.now().toIso8601String(),
          },
          'accessToken': 'local_mock_token',
        };

      case '/auth/register':
        // 개발 모드: 회원가입 불필요, 자동으로 로컬 유저 반환
        debugPrint('👤 [MOCK] 로컬 유저로 자동 회원가입 (Firebase 불필요)');
        return {
          'user': {
            'id': _localUserId,
            'email': 'local@aipet.dev',
            'name': 'ローカルユーザー',
            'createdAt': DateTime.now().toIso8601String(),
          },
          'accessToken': 'local_mock_token',
        };

      default:
        debugPrint('⚠️ [MOCK] 정의되지 않은 엔드포인트: $endpoint');
        return null;
    }
  }

  /// PUT 엔드포인트별 Mock 데이터 (개발 모드)
  static Future<Map<String, dynamic>?> _putMockDataForEndpoint(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    debugPrint('📦 [MOCK] Mock PUT 응답 생성: $endpoint');
    return {'message': 'Updated successfully'};
  }

  /// DELETE 엔드포인트별 Mock 데이터 (개발 모드)
  static Future<Map<String, dynamic>?> _deleteMockDataForEndpoint(
    String endpoint,
  ) async {
    debugPrint('📦 [MOCK] Mock DELETE 응답 생성: $endpoint');
    return {'message': 'Deleted successfully'};
  }
}
