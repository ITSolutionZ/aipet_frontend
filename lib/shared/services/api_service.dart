import 'dart:convert';
import 'package:http/http.dart' as http;
import '../mock_data/mock_data.dart';

/// 백엔드 API 통신을 담당하는 서비스
class ApiService {
  static const String baseUrl = 'https://api.aipet.com'; // 실제 백엔드 URL로 교체
  static const Duration timeout = Duration(seconds: 30);

  /// GET 요청
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Mock 환경에서는 실제 HTTP 요청 대신 Mock 데이터 반환
      if (_useMockData) {
        return _getMockResponse(endpoint, fromJson);
      }

      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      ).timeout(timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('ネットワークエラーが発生しました: $e');
    }
  }

  /// POST 요청
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Mock 환경에서는 실제 HTTP 요청 대신 Mock 데이터 반환
      if (_useMockData) {
        return _postMockResponse(endpoint, body, fromJson);
      }

      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body != null ? json.encode(body) : null,
      ).timeout(timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('ネットワークエラーが発生しました: $e');
    }
  }

  /// PUT 요청
  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Mock 환경에서는 실제 HTTP 요청 대신 Mock 데이터 반환
      if (_useMockData) {
        return _putMockResponse(endpoint, body, fromJson);
      }

      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body != null ? json.encode(body) : null,
      ).timeout(timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('ネットワークエラーが発生しました: $e');
    }
  }

  /// DELETE 요청
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Mock 환경에서는 실제 HTTP 요청 대신 Mock 데이터 반환
      if (_useMockData) {
        return _deleteMockResponse(endpoint, fromJson);
      }

      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      ).timeout(timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('ネットワークエラーが発生しました: $e');
    }
  }

  /// HTTP 응답 처리
  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (fromJson != null) {
        return ApiResponse.success(fromJson(data['data'] ?? data));
      } else {
        return ApiResponse.success(data as T);
      }
    } else {
      return ApiResponse.error(
        data['message'] ?? 'サーバーエラーが発生しました',
        statusCode: response.statusCode,
      );
    }
  }

  // Mock 데이터 사용 여부 (개발 환경에서는 true)
  static bool get _useMockData => const bool.fromEnvironment('USE_MOCK_DATA', defaultValue: true);

  /// Mock GET 응답
  static Future<ApiResponse<T>> _getMockResponse<T>(
    String endpoint,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션
    
    // Mock 데이터 반환 로직
    final mockData = await _getMockDataForEndpoint(endpoint);
    if (mockData == null) {
      return ApiResponse.error('엔드포인트를 찾을 수 없습니다: $endpoint');
    }

    if (fromJson != null) {
      return ApiResponse.success(fromJson(mockData));
    } else {
      return ApiResponse.success(mockData as T);
    }
  }

  /// Mock POST 응답
  static Future<ApiResponse<T>> _postMockResponse<T>(
    String endpoint,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800)); // 네트워크 지연 시뮬레이션
    
    final mockData = await _postMockDataForEndpoint(endpoint, body);
    if (mockData == null) {
      return ApiResponse.error('엔드포인트를 찾을 수 없습니다: $endpoint');
    }

    if (fromJson != null) {
      return ApiResponse.success(fromJson(mockData));
    } else {
      return ApiResponse.success(mockData as T);
    }
  }

  /// Mock PUT 응답
  static Future<ApiResponse<T>> _putMockResponse<T>(
    String endpoint,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final mockData = await _putMockDataForEndpoint(endpoint, body);
    if (mockData == null) {
      return ApiResponse.error('엔드포인트를 찾을 수 없습니다: $endpoint');
    }

    if (fromJson != null) {
      return ApiResponse.success(fromJson(mockData));
    } else {
      return ApiResponse.success(mockData as T);
    }
  }

  /// Mock DELETE 응답
  static Future<ApiResponse<T>> _deleteMockResponse<T>(
    String endpoint,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final mockData = await _deleteMockDataForEndpoint(endpoint);
    if (mockData == null) {
      return ApiResponse.error('엔드포인트를 찾을 수 없습니다: $endpoint');
    }

    if (fromJson != null) {
      return ApiResponse.success(fromJson(mockData));
    } else {
      return ApiResponse.success(mockData as T);
    }
  }

  /// GET 엔드포인트별 Mock 데이터
  static Future<Map<String, dynamic>?> _getMockDataForEndpoint(String endpoint) async {
    // AuthMockData의 메서드들을 활용
    switch (endpoint) {
      case '/auth/me':
        final userData = await AuthMockData.mockGetCurrentUser();
        return userData != null ? {'user': userData} : null;
      
      default:
        return null;
    }
  }

  /// POST 엔드포인트별 Mock 데이터
  static Future<Map<String, dynamic>?> _postMockDataForEndpoint(
    String endpoint, 
    Map<String, dynamic>? body,
  ) async {
    switch (endpoint) {
      case '/auth/login':
        if (body?['idToken'] != null) {
          return AuthMockData.mockBackendLogin(body!['idToken'] as String);
        }
        return null;
      
      case '/auth/register':
        if (body?['idToken'] != null) {
          return AuthMockData.mockBackendRegister(body!['idToken'] as String);
        }
        return null;
      
      default:
        return null;
    }
  }

  /// PUT 엔드포인트별 Mock 데이터
  static Future<Map<String, dynamic>?> _putMockDataForEndpoint(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    // PUT 요청에 대한 Mock 데이터
    return {'message': 'Updated successfully'};
  }

  /// DELETE 엔드포인트별 Mock 데이터
  static Future<Map<String, dynamic>?> _deleteMockDataForEndpoint(String endpoint) async {
    // DELETE 요청에 대한 Mock 데이터
    return {'message': 'Deleted successfully'};
  }
}

/// API 응답을 래핑하는 클래스
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  const ApiResponse._({
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data) => ApiResponse._(data: data);
  factory ApiResponse.error(String error, {int? statusCode}) => 
      ApiResponse._(error: error, statusCode: statusCode);

  bool get isSuccess => error == null;
  bool get isError => error != null;
}