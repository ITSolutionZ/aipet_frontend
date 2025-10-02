import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../services/logger_service.dart';
import '../services/secure_storage_service.dart';
import 'api_constants.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorageService.getToken();
    if (token != null) {
      options.headers[ApiConstants.authHeaderKey] = '${ApiConstants.bearerPrefix}$token';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == ApiStatusCodes.unauthorized) {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          final newToken = await _refreshToken(refreshToken);
          if (newToken != null) {
            await SecureStorageService.saveToken(newToken);

            final opts = err.requestOptions;
            opts.headers[ApiConstants.authHeaderKey] = '${ApiConstants.bearerPrefix}$newToken';

            final dio = Dio();
            final response = await dio.fetch(opts);
            handler.resolve(response);
            return;
          }
        } catch (e) {
          await SecureStorageService.clearTokens();
        }
      }
    }
    handler.next(err);
  }

  Future<String?> _refreshToken(String refreshToken) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == ApiStatusCodes.success) {
        return response.data['access_token'];
      }
    } catch (e) {
      LoggerService.error('Token refresh failed', error: e);
    }
    return null;
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      LoggerService.info(
        'API Request: ${options.method} ${options.uri}',
        data: {
          'headers': options.headers,
          'queryParameters': options.queryParameters,
          'data': options.data,
        },
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      LoggerService.info(
        'API Response: ${response.statusCode} ${response.requestOptions.uri}',
        data: {
          'statusCode': response.statusCode,
          'headers': response.headers.map,
          'data': response.data,
        },
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      LoggerService.error(
        'API Error: ${err.requestOptions.method} ${err.requestOptions.uri}',
        error: err,
        data: {
          'statusCode': err.response?.statusCode,
          'message': err.message,
          'data': err.response?.data,
        },
      );
    }
    handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerService.error(
      'API Error occurred',
      error: err,
      data: {
        'url': err.requestOptions.uri.toString(),
        'method': err.requestOptions.method,
        'statusCode': err.response?.statusCode,
        'responseData': err.response?.data,
      },
    );
    handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {
  final int maxRetryAttempts;
  final Duration retryDelay;

  RetryInterceptor({
    int? maxRetryAttempts,
    Duration? retryDelay,
  })  : maxRetryAttempts = maxRetryAttempts ?? ApiConfig.maxRetryAttempts,
        retryDelay = retryDelay ?? ApiConfig.retryDelay;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retry_count'] ?? 0;

      if (retryCount < maxRetryAttempts) {
        LoggerService.info(
          'Retrying API request (attempt ${retryCount + 1}/$maxRetryAttempts)',
          data: {'url': err.requestOptions.uri.toString()},
        );

        await Future.delayed(retryDelay);

        final requestOptions = err.requestOptions;
        requestOptions.extra['retry_count'] = retryCount + 1;

        try {
          final dio = Dio();
          final response = await dio.fetch(requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          if (e is DioException) {
            handler.next(e);
          } else {
            handler.next(err);
          }
          return;
        }
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.cancel) return false;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }

    if (err.response?.statusCode != null) {
      final statusCode = err.response!.statusCode!;
      return statusCode >= 500 || statusCode == 408 || statusCode == 429;
    }

    return err.type == DioExceptionType.connectionError;
  }
}

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});

final loggingInterceptorProvider = Provider<LoggingInterceptor>((ref) {
  return LoggingInterceptor();
});

final errorInterceptorProvider = Provider<ErrorInterceptor>((ref) {
  return ErrorInterceptor();
});

final retryInterceptorProvider = Provider<RetryInterceptor>((ref) {
  return RetryInterceptor();
});