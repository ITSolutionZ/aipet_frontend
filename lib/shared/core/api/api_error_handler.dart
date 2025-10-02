import 'package:dio/dio.dart';
import '../domain/common_errors.dart';
import 'api_constants.dart';

class ApiErrorHandler {
  static AppError handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }

    return UnknownError(details: error.toString());
  }

  static AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutError(details: error.message);

      case DioExceptionType.connectionError:
        return NetworkError(details: error.message);

      case DioExceptionType.badResponse:
        return _handleHttpError(error);

      case DioExceptionType.cancel:
        return UnknownError(details: '요청이 취소되었습니다.');

      case DioExceptionType.badCertificate:
        return NetworkError(details: '보안 인증서에 문제가 있습니다.');

      case DioExceptionType.unknown:
      default:
        return UnknownError(details: error.message);
    }
  }

  static AppError _handleHttpError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String message = '오류가 발생했습니다.';

    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? responseData['error'] ?? message;
    }

    switch (statusCode) {
      case ApiStatusCodes.badRequest:
        return ValidationError(
          field: 'request',
          reason: message,
          details: error.message,
        );

      case ApiStatusCodes.unauthorized:
        return AuthenticationError(
          '인증이 필요합니다.',
          details: error.message,
        );

      case ApiStatusCodes.forbidden:
        return PermissionError(
          '접근 권한이 없습니다.',
          details: error.message,
        );

      case ApiStatusCodes.notFound:
        return ClientError(
          statusCode: statusCode!,
          reason: '요청한 데이터를 찾을 수 없습니다.',
          details: error.message,
        );

      case ApiStatusCodes.conflict:
        return ClientError(
          statusCode: statusCode!,
          reason: '데이터 충돌이 발생했습니다.',
          details: error.message,
        );

      case ApiStatusCodes.unprocessableEntity:
        return ValidationError(
          field: 'entity',
          reason: message,
          details: error.message,
        );

      case ApiStatusCodes.tooManyRequests:
        return ClientError(
          statusCode: statusCode!,
          reason: '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
          details: error.message,
        );

      case ApiStatusCodes.internalServerError:
      case ApiStatusCodes.badGateway:
      case ApiStatusCodes.serviceUnavailable:
      case ApiStatusCodes.gatewayTimeout:
        return ServerError(
          statusCode: statusCode,
          details: error.message,
        );

      default:
        return UnknownError(details: error.message);
    }
  }

  static bool isRetryableError(AppError error) {
    return error is NetworkError ||
        error is TimeoutError ||
        error is ServerError;
  }

  static bool isAuthError(AppError error) {
    return error is AuthenticationError || error is PermissionError;
  }
}