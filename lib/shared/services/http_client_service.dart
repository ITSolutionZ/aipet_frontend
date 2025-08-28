import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/data/services/token_storage_service.dart';
import '../../features/auth/domain/auth_token.dart';
import '../constants/error_codes.dart';
import '../mock_data/mock_data.dart';

/// Dio 기반 HTTP 클라이언트 서비스
/// 자동 토큰 갱신, 재시도, 인터셉터 기능 포함
class HttpClientService {
  static const String baseUrl = 'https://api.aipet.com'; // 실제 백엔드 URL로 교체
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  late final Dio _dio;
  static HttpClientService? _instance;

  HttpClientService._() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  static HttpClientService get instance {
    _instance ??= HttpClientService._();
    return _instance!;
  }

  void _setupInterceptors() {
    // 1. 요청 인터셉터 - 자동 Authorization 헤더 추가
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 인증이 필요한 엔드포인트에 토큰 자동 추가
        if (_requiresAuth(options.path)) {
          final token = await TokenStorageService.getToken();
          if (token != null && !token.isExpired) {
            options.headers['Authorization'] = '${token.tokenType} ${token.accessToken}';
          }
        }
        
        if (kDebugMode) {
          debugPrint('🚀 HTTP Request: ${options.method} ${options.path}');
          debugPrint('📋 Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('📦 Body: ${options.data}');
          }
        }
        
        handler.next(options);
      },
      
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('✅ HTTP Response: ${response.statusCode} ${response.requestOptions.path}');
        }
        handler.next(response);
      },
      
      onError: (error, handler) async {
        if (kDebugMode) {
          debugPrint('❌ HTTP Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          debugPrint('❌ Error Message: ${error.message}');
        }

        // 401 에러 처리 - 토큰 갱신 시도
        if (error.response?.statusCode == 401) {
          final refreshed = await _handleTokenRefresh(error, handler);
          if (refreshed) {
            return; // 재요청이 이미 처리됨
          }
        }

        // 네트워크 에러 재시도 로직
        if (_shouldRetry(error) && _getRetryCount(error.requestOptions) < maxRetries) {
          await _retryRequest(error, handler);
          return;
        }

        handler.next(error);
      },
    ));

    // 2. 로깅 인터셉터 (개발 환경에서만)
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  /// 401 에러 발생 시 토큰 갱신 및 재요청
  Future<bool> _handleTokenRefresh(DioException error, ErrorInterceptorHandler handler) async {
    try {
      final token = await TokenStorageService.getToken();
      if (token?.refreshToken == null) {
        // 리프레시 토큰이 없으면 로그아웃 처리
        await TokenStorageService.clearToken();
        return false;
      }

      // Mock 환경에서 토큰 리프레시
      final refreshResponse = await _refreshToken(token!.refreshToken!);
      if (refreshResponse != null) {
        // 새 토큰으로 저장
        await TokenStorageService.saveToken(refreshResponse);
        
        // 원래 요청을 새 토큰으로 재시도
        final originalRequest = error.requestOptions;
        originalRequest.headers['Authorization'] = '${refreshResponse.tokenType} ${refreshResponse.accessToken}';
        
        final retryResponse = await _dio.fetch(originalRequest);
        handler.resolve(retryResponse);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('토큰 갱신 실패: $e');
      }
      // 토큰 갱신 실패 시 로그아웃 처리
      await TokenStorageService.clearToken();
    }
    
    return false;
  }

  /// 리프레시 토큰으로 새 토큰 발급 (Mock)
  Future<AuthToken?> _refreshToken(String refreshToken) async {
    try {
      // Mock 환경에서 토큰 리프레시
      final mockResponse = await AuthMockData.mockBackendRefreshToken(refreshToken);
      
      if (mockResponse['success'] == true) {
        return AuthToken(
          accessToken: mockResponse['accessToken'] as String,
          refreshToken: mockResponse['refreshToken'] as String,
          expiresAt: DateTime.parse(mockResponse['expiresAt'] as String),
          tokenType: mockResponse['tokenType'] as String? ?? 'Bearer',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('토큰 리프레시 Mock 호출 실패: $e');
      }
    }
    
    return null;
  }

  /// 재시도가 필요한 에러인지 판단
  bool _shouldRetry(DioException error) {
    // 네트워크 연결 오류, 타임아웃, 500번대 서버 에러만 재시도
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.type == DioExceptionType.connectionError ||
           (error.response?.statusCode != null && 
            error.response!.statusCode! >= 500 &&
            error.response!.statusCode! < 600);
  }

  /// 요청 재시도 처리
  Future<void> _retryRequest(DioException error, ErrorInterceptorHandler handler) async {
    final retryCount = _getRetryCount(error.requestOptions) + 1;
    final delay = Duration(seconds: retryCount * 2); // 지수 백오프
    
    if (kDebugMode) {
      debugPrint('🔄 재시도 $retryCount/$maxRetries - ${delay.inSeconds}초 후 재시도');
    }
    
    await Future.delayed(delay);
    
    try {
      final retryOptions = error.requestOptions.copyWith(
        extra: {
          ...error.requestOptions.extra,
          'retryCount': retryCount,
        },
      );
      
      final response = await _dio.fetch(retryOptions);
      handler.resolve(response);
    } catch (retryError) {
      if (retryError is DioException) {
        handler.next(retryError);
      } else {
        handler.next(error);
      }
    }
  }

  /// 현재 재시도 횟수 가져오기
  int _getRetryCount(RequestOptions options) {
    return options.extra['retryCount'] as int? ?? 0;
  }

  /// 인증이 필요한 엔드포인트인지 확인
  bool _requiresAuth(String path) {
    final noAuthPaths = ['/auth/login', '/auth/register', '/health'];
    return !noAuthPaths.any((noAuthPath) => path.startsWith(noAuthPath));
  }

  /// GET 요청
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Mock 환경에서는 Mock 데이터 사용
      if (_useMockData) {
        return _getMockResponse(path, fromJson);
      }

      final response = await _dio.get(path, queryParameters: queryParameters);
      return _parseResponse(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// POST 요청
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Mock 환경에서는 Mock 데이터 사용
      if (_useMockData) {
        return _postMockResponse(path, data, fromJson);
      }

      final response = await _dio.post(path, data: data);
      return _parseResponse(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// PUT 요청
  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Mock 환경에서는 Mock 데이터 사용
      if (_useMockData) {
        return _putMockResponse(path, data, fromJson);
      }

      final response = await _dio.put(path, data: data);
      return _parseResponse(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// DELETE 요청
  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Mock 환경에서는 Mock 데이터 사용
      if (_useMockData) {
        return _deleteMockResponse(path, fromJson);
      }

      final response = await _dio.delete(path);
      return _parseResponse(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// 응답 파싱
  ApiResponse<T> _parseResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = response.data as Map<String, dynamic>;
    
    if (fromJson != null) {
      return ApiResponse.success(fromJson(data['data'] ?? data));
    } else {
      return ApiResponse.success(data as T);
    }
  }

  /// 에러 핸들링
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      String errorMessage;
      String? errorCode;
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          errorCode = ErrorCodes.networkConnectionTimeout;
          errorMessage = ErrorCodes.getErrorMessage(errorCode);
          break;
        case DioExceptionType.receiveTimeout:
          errorCode = ErrorCodes.networkReceiveTimeout;
          errorMessage = ErrorCodes.getErrorMessage(errorCode);
          break;
        case DioExceptionType.sendTimeout:
          errorCode = ErrorCodes.networkSendTimeout;
          errorMessage = ErrorCodes.getErrorMessage(errorCode);
          break;
        case DioExceptionType.connectionError:
          errorCode = ErrorCodes.networkConnectionError;
          errorMessage = ErrorCodes.getErrorMessage(errorCode);
          break;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 0;
          final responseData = error.response?.data;
          
          if (responseData is Map<String, dynamic> && responseData['message'] != null) {
            errorMessage = responseData['message'] as String;
            errorCode = responseData['errorCode'] as String?;
          } else {
            errorCode = ErrorCodes.mapHttpStatusError(statusCode);
            errorMessage = ErrorCodes.getErrorMessage(errorCode);
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = '요청이 취소되었습니다';
          errorCode = 'REQUEST_CANCELLED';
          break;
        default:
          errorCode = ErrorCodes.networkUnknownError;
          errorMessage = ErrorCodes.getErrorMessage(errorCode);
      }
      
      return ApiResponse.error(errorMessage, errorCode: errorCode);
    } else {
      return ApiResponse.error('예상치 못한 오류가 발생했습니다', errorCode: 'UNEXPECTED_ERROR');
    }
  }


  // Mock 관련 메서드들 (기존 ApiService에서 이동)
  static bool get _useMockData => const bool.fromEnvironment('USE_MOCK_DATA', defaultValue: true);

  Future<ApiResponse<T>> _getMockResponse<T>(String path, T Function(Map<String, dynamic>)? fromJson) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockData = await _getMockDataForEndpoint(path);
    if (mockData == null) {
      return ApiResponse.error('엔드포인트를 찾을 수 없습니다: $path');
    }

    if (fromJson != null) {
      return ApiResponse.success(fromJson(mockData));
    } else {
      return ApiResponse.success(mockData as T);
    }
  }

  Future<ApiResponse<T>> _postMockResponse<T>(String path, Map<String, dynamic>? body, T Function(Map<String, dynamic>)? fromJson) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final mockData = await _postMockDataForEndpoint(path, body);
    if (mockData == null) {
      return ApiResponse.error('엔드포인트를 찾을 수 없습니다: $path');
    }

    if (fromJson != null) {
      return ApiResponse.success(fromJson(mockData));
    } else {
      return ApiResponse.success(mockData as T);
    }
  }

  Future<ApiResponse<T>> _putMockResponse<T>(String path, Map<String, dynamic>? body, T Function(Map<String, dynamic>)? fromJson) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final mockData = await _putMockDataForEndpoint(path, body);
    if (mockData == null) {
      return ApiResponse.error('엔드포인트를 찾을 수 없습니다: $path');
    }

    if (fromJson != null) {
      return ApiResponse.success(fromJson(mockData));
    } else {
      return ApiResponse.success(mockData as T);
    }
  }

  Future<ApiResponse<T>> _deleteMockResponse<T>(String path, T Function(Map<String, dynamic>)? fromJson) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final mockData = await _deleteMockDataForEndpoint(path);
    if (mockData == null) {
      return ApiResponse.error('엔드포인트를 찾을 수 없습니다: $path');
    }

    if (fromJson != null) {
      return ApiResponse.success(fromJson(mockData));
    } else {
      return ApiResponse.success(mockData as T);
    }
  }

  Future<Map<String, dynamic>?> _getMockDataForEndpoint(String endpoint) async {
    switch (endpoint) {
      case '/auth/me':
        final userData = await AuthMockData.mockGetCurrentUser();
        return userData != null ? {'user': userData} : null;
      default:
        return null;
    }
  }

  Future<Map<String, dynamic>?> _postMockDataForEndpoint(String endpoint, Map<String, dynamic>? body) async {
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
      case '/auth/refresh':
        if (body?['refreshToken'] != null) {
          return AuthMockData.mockBackendRefreshToken(body!['refreshToken'] as String);
        }
        return null;
      default:
        return null;
    }
  }

  Future<Map<String, dynamic>?> _putMockDataForEndpoint(String endpoint, Map<String, dynamic>? body) async {
    return {'message': 'Updated successfully'};
  }

  Future<Map<String, dynamic>?> _deleteMockDataForEndpoint(String endpoint) async {
    return {'message': 'Deleted successfully'};
  }
}

/// API 응답을 래핑하는 클래스 (개선된 버전)
class ApiResponse<T> {
  final T? data;
  final String? error;
  final String? errorCode;
  final int? statusCode;

  const ApiResponse._({
    this.data,
    this.error,
    this.errorCode,
    this.statusCode,
  });

  factory ApiResponse.success(T data) => ApiResponse._(data: data);
  
  factory ApiResponse.error(String error, {String? errorCode, int? statusCode}) => 
      ApiResponse._(error: error, errorCode: errorCode, statusCode: statusCode);

  bool get isSuccess => error == null;
  bool get isError => error != null;
}