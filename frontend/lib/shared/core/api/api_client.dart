import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import 'api_error_handler.dart';
import 'api_interceptors.dart';

class ApiClient {
  late final Dio _dio;
  final bool useMockServer;

  ApiClient({this.useMockServer = false}) {
    _dio = Dio();
    _setupDio();
  }

  Dio get dio => _dio;

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.fullApiUrl,
      connectTimeout: ApiConfig.defaultTimeout,
      receiveTimeout: ApiConfig.defaultTimeout,
      sendTimeout: ApiConfig.defaultTimeout,
      headers: ApiConfig.defaultHeaders,
    );

    final interceptors = <Interceptor>[
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
      RetryInterceptor(),
    ];

    // Mock 서버 활성화 시 MockApiInterceptor를 최우선으로 추가
    if (useMockServer) {
      // MockApiInterceptor는 조건부 import로 처리
      // import 'package:aipet_frontend/shared/testing/mock_server/mock_api_interceptor.dart';
      // interceptors.insert(0, MockApiInterceptor(enabled: true));
      // 주의: 프로덕션 빌드에서는 제거되어야 함
    }

    _dio.interceptors.addAll(interceptors);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  void dispose() {
    _dio.close();
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(() => client.dispose());
  return client;
});
