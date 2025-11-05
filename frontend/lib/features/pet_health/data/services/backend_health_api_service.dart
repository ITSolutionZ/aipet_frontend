import 'package:dio/dio.dart';


import '../../../../shared/shared.dart';
import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';


/// 백엔드 Health API 서비스
///
/// BackendApiClient를 사용하여 건강 기록 CRUD를 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
class BackendHealthApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 건강 기록 생성
  ///
  /// POST /api/health
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<Map<String, dynamic>>> createHealthRecord({
    required String petId,
    required String recordType,
    required String recordDate,
    String? vetName,
    String? notes,
    String? nextScheduledDate,
  }) async {
    try {
      final response = await _apiClient.post('/health', data: {
        'pet_id': petId,
        'record_type': recordType,
        'record_date': recordDate,
        if (vetName != null) 'vet_name': vetName,
        if (notes != null) 'notes': notes,
        if (nextScheduledDate != null) 'next_scheduled_date': nextScheduledDate,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final record = data['data'] ?? data;
          return Result.success('健康記録を作成しました', record);
        }
      }
      return Result.failure('健康記録の作成に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('건강 기록 생성', e);
    } catch (e) {
      return Result.failure('健康記録の作成に失敗しました');
    }
  }

  /// 특정 건강 기록 조회
  ///
  /// GET /api/health/:recordId
  static Future<Result<Map<String, dynamic>?>> getHealthRecordById(
    String recordId,
  ) async {
    try {
      final response = await _apiClient.get('/health/$recordId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final record = data['data'] ?? data;
          return Result.success('健康記録を取得しました', record);
        }
      } else if (response.statusCode == 404) {
        return Result.success('健康記録が見つかりません', null);
      }
      return Result.failure('健康記録の取得に失敗しました');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.success('健康記録が見つかりません', null);
      }
      return _handleDioError('건강 기록 조회', e);
    } catch (e) {
      return Result.failure('健康記録の取得に失敗しました');
    }
  }

  /// 펫의 건강 기록 목록 조회
  ///
  /// GET /api/pets/:petId/health
  static Future<Result<List<Map<String, dynamic>>>> getPetHealthRecords(
    String petId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/pets/$petId/health',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> records = [];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              records.add(item);
            }
          }
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              records.add(item);
            }
          }
        }

        return Result.success('健康記録リストを取得しました', records);
      }
      return Result.failure('健康記録リストの取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('펫 건강 기록 조회', e);
    } catch (e) {
      return Result.failure('健康記録リストの取得に失敗しました');
    }
  }

  /// 타입별 건강 기록 조회
  ///
  /// GET /api/pets/:petId/health/:recordType
  static Future<Result<List<Map<String, dynamic>>>> getPetHealthRecordsByType(
    String petId,
    String recordType, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/pets/$petId/health/$recordType',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> records = [];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              records.add(item);
            }
          }
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              records.add(item);
            }
          }
        }

        return Result.success('健康記録リストを取得しました', records);
      }
      return Result.failure('健康記録リストの取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('타입별 건강 기록 조회', e);
    } catch (e) {
      return Result.failure('健康記録リストの取得に失敗しました');
    }
  }

  /// 건강 기록 업데이트
  ///
  /// PUT /api/health/:recordId
  static Future<Result<Map<String, dynamic>>> updateHealthRecord(
    String recordId, {
    String? recordType,
    String? recordDate,
    String? vetName,
    String? notes,
    String? nextScheduledDate,
  }) async {
    try {
      final response = await _apiClient.put('/health/$recordId', data: {
        if (recordType != null) 'record_type': recordType,
        if (recordDate != null) 'record_date': recordDate,
        if (vetName != null) 'vet_name': vetName,
        if (notes != null) 'notes': notes,
        if (nextScheduledDate != null) 'next_scheduled_date': nextScheduledDate,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final record = data['data'] ?? data;
          return Result.success('健康記録を更新しました', record);
        }
      }
      return Result.failure('健康記録の更新に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('건강 기록 업데이트', e);
    } catch (e) {
      return Result.failure('健康記録の更新に失敗しました');
    }
  }

  /// 건강 기록 삭제
  ///
  /// DELETE /api/health/:recordId
  static Future<Result<void>> deleteHealthRecord(String recordId) async {
    try {
      final response = await _apiClient.delete('/health/$recordId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success('健康記録を削除しました', null);
      }
      return Result.failure('健康記録の削除に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('건강 기록 삭제', e);
    } catch (e) {
      return Result.failure('健康記録の削除に失敗しました');
    }
  }

  /// 예정된 건강 일정 조회
  ///
  /// GET /api/health/schedules/upcoming
  static Future<Result<List<Map<String, dynamic>>>> getUpcomingHealthSchedules({
    int daysAhead = 30,
  }) async {
    try {
      final response = await _apiClient.get(
        '/health/schedules/upcoming',
        queryParameters: {
          'days_ahead': daysAhead,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> schedules = [];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              schedules.add(item);
            }
          }
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              schedules.add(item);
            }
          }
        }

        return Result.success('予定された健康スケジュールを取得しました', schedules);
      }
      return Result.failure('健康スケジュールの取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('예정된 건강 일정 조회', e);
    } catch (e) {
      return Result.failure('健康スケジュールの取得に失敗しました');
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

    return Result.failure(errorMessage);
  }
}
