import 'package:dio/dio.dart';


import '../../../../shared/shared.dart';
import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';


/// 백엔드 Schedule API 서비스
///
/// ⚠️ 주의: 현재 백엔드에 /api/schedules 엔드포인트가 구현되어 있지 않습니다.
/// 백엔드는 Notification API를 통해 스케줄링을 수행합니다 (scheduledAt 필드).
///
/// 향후 작업:
/// 1. 백엔드에 /api/schedules 엔드포인트 구현 필요
/// 2. 또는 프론트엔드를 Notification API를 사용하도록 리팩토링 필요
///
/// BackendApiClient를 사용하여 일정 CRUD를 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
class BackendScheduleApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 일정 생성
  ///
  /// POST /api/schedules
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<Map<String, dynamic>>> createSchedule({
    required String petId,
    required String title,
    required String scheduleType,
    required String scheduledTime,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post('/schedules', data: {
        'pet_id': petId,
        'title': title,
        'schedule_type': scheduleType,
        'scheduled_time': scheduledTime,
        if (notes != null) 'notes': notes,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final schedule = data['data'] ?? data;
          return Result.success('スケジュールを作成しました', schedule);
        }
      }
      return Result.failure('スケジュールの作成に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('일정 생성', e);
    } catch (e) {
      return Result.failure('スケジュールの作成に失敗しました');
    }
  }

  /// 특정 일정 조회
  ///
  /// GET /api/schedules/:scheduleId
  static Future<Result<Map<String, dynamic>?>> getScheduleById(
    String scheduleId,
  ) async {
    try {
      final response = await _apiClient.get('/schedules/$scheduleId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final schedule = data['data'] ?? data;
          return Result.success('スケジュールを取得しました', schedule);
        }
      } else if (response.statusCode == 404) {
        return Result.success('スケジュールが見つかりません', null);
      }
      return Result.failure('スケジュールの取得に失敗しました');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.success('スケジュールが見つかりません', null);
      }
      return _handleDioError('일정 조회', e);
    } catch (e) {
      return Result.failure('スケジュールの取得に失敗しました');
    }
  }

  /// 펫의 일정 목록 조회
  ///
  /// GET /api/pets/:petId/schedules
  static Future<Result<List<Map<String, dynamic>>>> getPetSchedules(
    String petId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/pets/$petId/schedules',
        queryParameters: {
          'limit': limit,
          'offset': offset,
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

        return Result.success('スケジュールリストを取得しました', schedules);
      }
      return Result.failure('スケジュールリストの取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('펫 일정 조회', e);
    } catch (e) {
      return Result.failure('スケジュールリストの取得に失敗しました');
    }
  }

  /// 사용자의 모든 일정 조회
  ///
  /// GET /api/schedules
  static Future<Result<List<Map<String, dynamic>>>> getUserSchedules({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/schedules',
        queryParameters: {
          'limit': limit,
          'offset': offset,
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

        return Result.success('スケジュールリストを取得しました', schedules);
      }
      return Result.failure('スケジュールリストの取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('사용자 일정 조회', e);
    } catch (e) {
      return Result.failure('スケジュールリストの取得に失敗しました');
    }
  }

  /// 예정된 일정 조회
  ///
  /// GET /api/schedules/upcoming/list
  static Future<Result<List<Map<String, dynamic>>>> getUpcomingSchedules({
    int daysAhead = 7,
  }) async {
    try {
      final response = await _apiClient.get(
        '/schedules/upcoming/list',
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

        return Result.success('予定されたスケジュールを取得しました', schedules);
      }
      return Result.failure('スケジュールの取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('예정된 일정 조회', e);
    } catch (e) {
      return Result.failure('スケジュールの取得に失敗しました');
    }
  }

  /// 완료된 일정 조회
  ///
  /// GET /api/schedules/completed/list
  static Future<Result<List<Map<String, dynamic>>>> getCompletedSchedules({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/schedules/completed/list',
        queryParameters: {
          'limit': limit,
          'offset': offset,
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

        return Result.success('完了したスケジュールを取得しました', schedules);
      }
      return Result.failure('スケジュールの取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('완료된 일정 조회', e);
    } catch (e) {
      return Result.failure('スケジュールの取得に失敗しました');
    }
  }

  /// 일정 업데이트
  ///
  /// PUT /api/schedules/:scheduleId
  static Future<Result<Map<String, dynamic>>> updateSchedule(
    String scheduleId, {
    String? title,
    String? scheduleType,
    String? scheduledTime,
    bool? isCompleted,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.put('/schedules/$scheduleId', data: {
        if (title != null) 'title': title,
        if (scheduleType != null) 'schedule_type': scheduleType,
        if (scheduledTime != null) 'scheduled_time': scheduledTime,
        if (isCompleted != null) 'is_completed': isCompleted,
        if (notes != null) 'notes': notes,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final schedule = data['data'] ?? data;
          return Result.success('スケジュールを更新しました', schedule);
        }
      }
      return Result.failure('スケジュールの更新に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('일정 업데이트', e);
    } catch (e) {
      return Result.failure('スケジュールの更新に失敗しました');
    }
  }

  /// 일정 완료 처리
  ///
  /// PATCH /api/schedules/:scheduleId/complete
  static Future<Result<Map<String, dynamic>>> completeSchedule(
    String scheduleId,
  ) async {
    try {
      final response = await _apiClient.patch('/schedules/$scheduleId/complete');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final schedule = data['data'] ?? data;
          return Result.success('スケジュールを完了しました', schedule);
        }
      }
      return Result.failure('スケジュールの完了処理に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('일정 완료 처리', e);
    } catch (e) {
      return Result.failure('スケジュールの完了処理に失敗しました');
    }
  }

  /// 일정 삭제
  ///
  /// DELETE /api/schedules/:scheduleId
  static Future<Result<void>> deleteSchedule(String scheduleId) async {
    try {
      final response = await _apiClient.delete('/schedules/$scheduleId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success('スケジュールを削除しました', null);
      }
      return Result.failure('スケジュールの削除に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('일정 삭제', e);
    } catch (e) {
      return Result.failure('スケジュールの削除に失敗しました');
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
