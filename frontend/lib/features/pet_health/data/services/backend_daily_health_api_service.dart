import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/shared.dart';

/// Backend Daily Health API Service
///
/// BackendApiClient를 사용하여 일일 건강 기록 CRUD 및 통계를 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
class BackendDailyHealthApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 일일 건강 기록 목록 조회
  ///
  /// GET /daily-health/records
  static Future<Result<List<Map<String, dynamic>>>> getDailyHealthRecords({
    int? petId,
    String? startDate,
    String? endDate,
    int limit = 30,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (petId != null) {
        queryParams['petId'] = petId;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate;
      }

      final response = await _apiClient.get(
        '/daily-health/records',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> records = [];

        if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              records.add(item);
            }
          }
        }

        return Result.success('일일 건강 기록을 가져왔습니다', records);
      } else {
        return Result.failure('일일 건강 기록 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('일일 건강 기록 조회', e);
    } catch (e) {
      return Result.failure('일일 건강 기록 조회 중 오류 발생: $e');
    }
  }

  /// 특정 건강 기록 조회
  ///
  /// GET /daily-health/records/:recordId
  static Future<Result<Map<String, dynamic>>> getDailyHealthRecordById(
    String recordId,
  ) async {
    try {
      final response = await _apiClient.get('/daily-health/records/$recordId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Result.success('건강 기록을 가져왔습니다', data['data']);
        }

        return Result.failure('건강 기록 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('건강 기록 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('건강 기록 조회', e);
    } catch (e) {
      return Result.failure('건강 기록 조회 중 오류 발생: $e');
    }
  }

  /// 특정 날짜의 건강 기록 조회
  ///
  /// GET /daily-health/records/by-date
  static Future<Result<Map<String, dynamic>>> getDailyHealthRecordByDate({
    required int petId,
    required String recordDate,
  }) async {
    try {
      final response = await _apiClient.get(
        '/daily-health/records/by-date',
        queryParameters: {
          'petId': petId,
          'recordDate': recordDate,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Result.success('건강 기록을 가져왔습니다', data['data']);
        }

        return Result.failure('건강 기록 데이터 형식이 올바르지 않습니다');
      } else if (response.statusCode == 404) {
        // 해당 날짜의 기록이 없는 경우
        return Result.success('해당 날짜의 건강 기록이 없습니다', null);
      } else {
        return Result.failure('건강 기록 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.success('해당 날짜의 건강 기록이 없습니다', null);
      }
      return _handleDioError('건강 기록 조회', e);
    } catch (e) {
      return Result.failure('건강 기록 조회 중 오류 발생: $e');
    }
  }

  /// 일일 건강 기록 생성/업데이트
  ///
  /// POST /daily-health/records
  /// 같은 날짜에 이미 기록이 있으면 업데이트됩니다
  static Future<Result<Map<String, dynamic>>> createDailyHealthRecord({
    required int petId,
    required String recordDate,
    int? mealCount,
    int? poopCount,
    int? exerciseDuration,
    int? sleepDuration,
    String? mood,
    String? condition,
    List<String>? symptoms,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/daily-health/records',
        data: {
          'petId': petId,
          'recordDate': recordDate,
          if (mealCount != null) 'mealCount': mealCount,
          if (poopCount != null) 'poopCount': poopCount,
          if (exerciseDuration != null) 'exerciseDuration': exerciseDuration,
          if (sleepDuration != null) 'sleepDuration': sleepDuration,
          if (mood != null) 'mood': mood,
          if (condition != null) 'condition': condition,
          if (symptoms != null) 'symptoms': symptoms,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Result.success('일일 건강 기록을 저장했습니다', data['data']);
        }

        return Result.failure('건강 기록 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('일일 건강 기록 저장에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('일일 건강 기록 저장', e);
    } catch (e) {
      return Result.failure('일일 건강 기록 저장 중 오류 발생: $e');
    }
  }

  /// 일일 건강 기록 수정
  ///
  /// PUT /daily-health/records/:recordId
  static Future<Result<Map<String, dynamic>>> updateDailyHealthRecord({
    required String recordId,
    int? mealCount,
    int? poopCount,
    int? exerciseDuration,
    int? sleepDuration,
    String? mood,
    String? condition,
    List<String>? symptoms,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.put(
        '/daily-health/records/$recordId',
        data: {
          if (mealCount != null) 'mealCount': mealCount,
          if (poopCount != null) 'poopCount': poopCount,
          if (exerciseDuration != null) 'exerciseDuration': exerciseDuration,
          if (sleepDuration != null) 'sleepDuration': sleepDuration,
          if (mood != null) 'mood': mood,
          if (condition != null) 'condition': condition,
          if (symptoms != null) 'symptoms': symptoms,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Result.success('일일 건강 기록을 수정했습니다', data['data']);
        }

        return Result.failure('건강 기록 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('일일 건강 기록 수정에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('일일 건강 기록 수정', e);
    } catch (e) {
      return Result.failure('일일 건강 기록 수정 중 오류 발생: $e');
    }
  }

  /// 일일 건강 기록 삭제
  ///
  /// DELETE /daily-health/records/:recordId
  static Future<Result<void>> deleteDailyHealthRecord(String recordId) async {
    try {
      final response = await _apiClient.delete('/daily-health/records/$recordId');

      if (response.statusCode == 200) {
        return Result.success('일일 건강 기록을 삭제했습니다');
      } else {
        return Result.failure('일일 건강 기록 삭제에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('일일 건강 기록 삭제', e);
    } catch (e) {
      return Result.failure('일일 건강 기록 삭제 중 오류 발생: $e');
    }
  }

  /// 일일 건강 통계 조회
  ///
  /// GET /daily-health/stats
  static Future<Result<Map<String, dynamic>>> getDailyHealthStats({
    required int petId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'petId': petId,
      };
      if (startDate != null) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate;
      }

      final response = await _apiClient.get(
        '/daily-health/stats',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Result.success('건강 통계를 가져왔습니다', data['data']);
        }

        return Result.failure('통계 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('건강 통계 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('건강 통계 조회', e);
    } catch (e) {
      return Result.failure('건강 통계 조회 중 오류 발생: $e');
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

    LoggerService.error('❌ BackendDailyHealthApiService: $operation 실패 - $errorMessage');
    return Result.failure(errorMessage);
  }
}
