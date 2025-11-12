import 'package:dio/dio.dart';

import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/shared.dart';

/// Backend Booking API Service
///
/// BackendApiClient를 사용하여 시설 예약 CRUD 및 상태 관리를 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
class BackendBookingApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 예약 목록 조회
  ///
  /// GET /bookings
  static Future<Result<List<Map<String, dynamic>>>> getBookings({
    int? petId,
    String? status,
    String? startDate,
    String? endDate,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (petId != null) {
        queryParams['petId'] = petId;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate;
      }

      final response = await _apiClient.get(
        '/bookings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> bookings = [];

        if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              bookings.add(item);
            }
          }
        }

        return Result.success('예약 목록을 가져왔습니다', bookings);
      } else {
        return Result.failure('예약 목록 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('예약 목록 조회', e);
    } catch (e) {
      return Result.failure('예약 목록 조회 중 오류 발생: $e');
    }
  }

  /// 예약 상세 조회
  ///
  /// GET /bookings/:bookingId
  static Future<Result<Map<String, dynamic>>> getBookingById(
    String bookingId,
  ) async {
    try {
      final response = await _apiClient.get('/bookings/$bookingId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Result.success('예약을 가져왔습니다', data['data']);
        }

        return Result.failure('예약 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('예약 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('예약 조회', e);
    } catch (e) {
      return Result.failure('예약 조회 중 오류 발생: $e');
    }
  }

  /// 다가오는 예약 조회
  ///
  /// GET /bookings/upcoming
  static Future<Result<List<Map<String, dynamic>>>> getUpcomingBookings({
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/bookings/upcoming',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> bookings = [];

        if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              bookings.add(item);
            }
          }
        }

        return Result.success('다가오는 예약을 가져왔습니다', bookings);
      } else {
        return Result.failure('다가오는 예약 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('다가오는 예약 조회', e);
    } catch (e) {
      return Result.failure('다가오는 예약 조회 중 오류 발생: $e');
    }
  }

  /// 예약 이력 조회
  ///
  /// GET /bookings/history
  static Future<Result<List<Map<String, dynamic>>>> getBookingHistory({
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        '/bookings/history',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> bookings = [];

        if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              bookings.add(item);
            }
          }
        }

        return Result.success('예약 이력을 가져왔습니다', bookings);
      } else {
        return Result.failure('예약 이력 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('예약 이력 조회', e);
    } catch (e) {
      return Result.failure('예약 이력 조회 중 오류 발생: $e');
    }
  }

  /// 예약 생성
  ///
  /// POST /bookings
  static Future<Result<Map<String, dynamic>>> createBooking({
    required int petId,
    required String facilityName,
    required String facilityType,
    required String bookingDate,
    required String bookingTime,
    String? facilityId,
    String? facilityAddress,
    String? facilityPhone,
    String? serviceType,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/bookings',
        data: {
          'petId': petId,
          'facilityName': facilityName,
          'facilityType': facilityType,
          'bookingDate': bookingDate,
          'bookingTime': bookingTime,
          if (facilityId != null) 'facilityId': facilityId,
          if (facilityAddress != null) 'facilityAddress': facilityAddress,
          if (facilityPhone != null) 'facilityPhone': facilityPhone,
          if (serviceType != null) 'serviceType': serviceType,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Result.success('예약을 생성했습니다', data['data']);
        }

        return Result.failure('예약 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('예약 생성에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('예약 생성', e);
    } catch (e) {
      return Result.failure('예약 생성 중 오류 발생: $e');
    }
  }

  /// 예약 수정
  ///
  /// PUT /bookings/:bookingId
  static Future<Result<Map<String, dynamic>>> updateBooking({
    required String bookingId,
    String? bookingDate,
    String? bookingTime,
    String? serviceType,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.put(
        '/bookings/$bookingId',
        data: {
          if (bookingDate != null) 'bookingDate': bookingDate,
          if (bookingTime != null) 'bookingTime': bookingTime,
          if (serviceType != null) 'serviceType': serviceType,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Result.success('예약을 수정했습니다', data['data']);
        }

        return Result.failure('예약 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('예약 수정에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('예약 수정', e);
    } catch (e) {
      return Result.failure('예약 수정 중 오류 발생: $e');
    }
  }

  /// 예약 취소
  ///
  /// DELETE /bookings/:bookingId
  static Future<Result<void>> cancelBooking(String bookingId) async {
    try {
      final response = await _apiClient.delete('/bookings/$bookingId');

      if (response.statusCode == 200) {
        return Result.success('예약을 취소했습니다');
      } else {
        return Result.failure('예약 취소에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('예약 취소', e);
    } catch (e) {
      return Result.failure('예약 취소 중 오류 발생: $e');
    }
  }

  /// 예약 상태 변경
  ///
  /// PUT /bookings/:bookingId/status
  static Future<Result<Map<String, dynamic>>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final response = await _apiClient.put(
        '/bookings/$bookingId/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Result.success('예약 상태를 변경했습니다', data['data']);
        }

        return Result.failure('예약 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('예약 상태 변경에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('예약 상태 변경', e);
    } catch (e) {
      return Result.failure('예약 상태 변경 중 오류 발생: $e');
    }
  }

  /// DioException 에러 처리
  static Result<T> _handleDioError<T>(String operation, DioException e) {
    String errorMessage = 'エラーが発生しました';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'タイムアウトが発生しました';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'ネットワーク接続を確認してください';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          errorMessage = '認証に失敗しました';
        } else if (statusCode == 403) {
          errorMessage = 'アクセスが拒否されました';
        } else if (statusCode == 404) {
          errorMessage = 'リソースが見つかりません';
        } else if (statusCode != null && statusCode >= 500) {
          errorMessage = 'サーバーエラーが発生しました';
        }
        break;
      default:
        errorMessage = '予期しないエラーが発生しました';
    }

    LoggerService.error('❌ BackendBookingApiService: $operation 실패 - $errorMessage');
    return Result.failure(errorMessage);
  }
}
