import 'package:dio/dio.dart';

import '../../../../shared/shared.dart';
import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';
import '../../domain/entities/schedule_entity.dart';

/// 백엔드 Schedule API 서비스
///
/// BackendApiClient를 사용하여 스케줄 CRUD를 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
class BackendScheduleApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 모든 스케줄 목록 조회
  ///
  /// GET /schedules
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<List<ScheduleEntity>>> getSchedules({
    int? petId,
    ScheduleType? type,
    ScheduleStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };

      if (petId != null) queryParams['petId'] = petId;
      if (type != null) queryParams['type'] = _scheduleTypeToString(type);
      if (status != null) queryParams['status'] = _scheduleStatusToString(status);
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        '/schedules',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<ScheduleEntity> schedules = [];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              schedules.add(_mapToScheduleEntity(item));
            }
          }
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              schedules.add(_mapToScheduleEntity(item));
            }
          }
        }

        return Result.success('スケジュールリストを取得しました', schedules);
      } else {
        return Result.failure('スケジュールリストの取得に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('스케줄 목록 조회', e);
    } catch (e) {
      return Result.failure('スケジュールリストの取得に失敗しました');
    }
  }

  /// 특정 스케줄 조회
  ///
  /// GET /schedules/:scheduleId
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<ScheduleEntity?>> getScheduleById(String scheduleId) async {
    try {
      final response = await _apiClient.get('/schedules/$scheduleId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final schedule = _mapToScheduleEntity(data['data'] ?? data);
          return Result.success('スケジュールを取得しました', schedule);
        }

        return Result.success('スケジュールが見つかりません', null);
      } else if (response.statusCode == 404) {
        return Result.success('スケジュールが見つかりません', null);
      } else {
        return Result.failure('スケジュールの取得に失敗しました');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.success('スケジュールが見つかりません', null);
      }
      return _handleDioError('스케줄 조회', e);
    } catch (e) {
      return Result.failure('スケジュールの取得に失敗しました');
    }
  }

  /// 스케줄 생성
  ///
  /// POST /schedules
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<ScheduleEntity>> createSchedule(
    ScheduleEntity schedule,
  ) async {
    try {
      final scheduleData = _scheduleEntityToMap(schedule);
      final response = await _apiClient.post('/schedules', data: scheduleData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final createdSchedule = _mapToScheduleEntity(data['data'] ?? data);
          return Result.success('スケジュールを作成しました', createdSchedule);
        }

        return Result.failure('スケジュールの作成に失敗しました');
      } else {
        return Result.failure('スケジュールの作成に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('스케줄 생성', e);
    } catch (e) {
      return Result.failure('スケジュールの作成に失敗しました');
    }
  }

  /// 스케줄 업데이트
  ///
  /// PUT /schedules/:scheduleId
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<ScheduleEntity>> updateSchedule(
    ScheduleEntity schedule,
  ) async {
    try {
      final scheduleData = _scheduleEntityToMap(schedule);
      final response = await _apiClient.put(
        '/schedules/${schedule.id}',
        data: scheduleData,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final updatedSchedule = _mapToScheduleEntity(data['data'] ?? data);
          return Result.success('スケジュールを更新しました', updatedSchedule);
        }

        return Result.failure('スケジュールの更新に失敗しました');
      } else {
        return Result.failure('スケジュールの更新に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('스케줄 업데이트', e);
    } catch (e) {
      return Result.failure('スケジュールの更新に失敗しました');
    }
  }

  /// 스케줄 상태 업데이트
  ///
  /// PUT /schedules/:scheduleId/status
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<void>> updateScheduleStatus(
    String scheduleId,
    ScheduleStatus status,
  ) async {
    try {
      final response = await _apiClient.put(
        '/schedules/$scheduleId/status',
        data: {
          'status': _scheduleStatusToString(status),
        },
      );

      if (response.statusCode == 200) {
        return Result.success('スケジュールステータスを更新しました', null);
      } else {
        return Result.failure('ステータスの更新に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('스케줄 상태 업데이트', e);
    } catch (e) {
      return Result.failure('ステータスの更新に失敗しました');
    }
  }

  /// 스케줄 삭제
  ///
  /// DELETE /schedules/:scheduleId
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<void>> deleteSchedule(String scheduleId) async {
    try {
      final response = await _apiClient.delete('/schedules/$scheduleId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success('スケジュールを削除しました', null);
      } else {
        return Result.failure('スケジュールの削除に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('스케줄 삭제', e);
    } catch (e) {
      return Result.failure('スケジュールの削除に失敗しました');
    }
  }

  /// 백엔드 응답 데이터를 ScheduleEntity로 변환
  /// Backend는 snake_case를 사용
  static ScheduleEntity _mapToScheduleEntity(Map<String, dynamic> json) {
    return ScheduleEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      startDateTime: (json['start_datetime'] ?? json['startDatetime']) != null
          ? DateTime.tryParse((json['start_datetime'] ?? json['startDatetime']).toString()) ??
              DateTime.now()
          : DateTime.now(),
      endDateTime: (json['end_datetime'] ?? json['endDatetime']) != null
          ? DateTime.tryParse((json['end_datetime'] ?? json['endDatetime']).toString())
          : null,
      duration: json['duration'] != null ? Duration(minutes: _parseInt(json['duration']) ?? 0) : null,
      type: _parseScheduleType(json['type']) ?? ScheduleType.custom,
      status: _parseScheduleStatus(json['status']) ?? ScheduleStatus.pending,
      priority: _parseSchedulePriority(json['priority']) ?? SchedulePriority.normal,
      petId: (json['pet_id'] ?? json['petId'])?.toString() ?? '',
      petName: (json['pet_name'] ?? json['petName'])?.toString() ?? '',
      petImagePath: (json['pet_image_path'] ?? json['petImagePath'])?.toString(),
      location: json['location']?.toString(),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      facilityId: (json['facility_id'] ?? json['facilityId'])?.toString(),
      facilityName: (json['facility_name'] ?? json['facilityName'])?.toString(),
      staffName: (json['staff_name'] ?? json['staffName'])?.toString(),
      staffPhone: (json['staff_phone'] ?? json['staffPhone'])?.toString(),
      price: _parseDouble(json['price']),
      services: json['services'] != null
          ? (json['services'] is List
              ? (json['services'] as List).map((e) => e.toString()).toList()
              : null)
          : null,
      hasReminder: _parseBool(json['has_reminder'] ?? json['hasReminder']) ?? false,
      reminderTime: json['reminder_time'] != null
          ? Duration(minutes: _parseInt(json['reminder_time']) ?? 0)
          : null,
      reminderTimes: json['reminder_times'] != null
          ? (json['reminder_times'] is List
              ? (json['reminder_times'] as List).map((e) => Duration(minutes: _parseInt(e) ?? 0)).toList()
              : null)
          : null,
      isRecurring: _parseBool(json['is_recurring'] ?? json['isRecurring']) ?? false,
      recurrenceRule: (json['recurrence_rule'] ?? json['recurrenceRule'])?.toString(),
      notes: json['notes']?.toString(),
      specialRequests: (json['special_requests'] ?? json['specialRequests'])?.toString(),
      customData: json['custom_data'] is Map<String, dynamic>
          ? json['custom_data'] as Map<String, dynamic>
          : (json['customData'] is Map<String, dynamic> ? json['customData'] as Map<String, dynamic> : null),
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']).toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.tryParse((json['updated_at'] ?? json['updatedAt']).toString())
          : null,
    );
  }

  /// ScheduleEntity를 백엔드 요청 데이터로 변환
  /// Backend는 snake_case를 사용
  static Map<String, dynamic> _scheduleEntityToMap(ScheduleEntity schedule) {
    return {
      'petId': int.tryParse(schedule.petId) ?? 0,
      'title': schedule.title,
      if (schedule.description != null) 'description': schedule.description,
      'startDatetime': schedule.startDateTime.toIso8601String(),
      if (schedule.endDateTime != null) 'endDatetime': schedule.endDateTime!.toIso8601String(),
      if (schedule.duration != null) 'duration': schedule.duration!.inMinutes,
      'type': _scheduleTypeToString(schedule.type),
      'status': _scheduleStatusToString(schedule.status),
      'priority': _schedulePriorityToString(schedule.priority),
      if (schedule.location != null) 'location': schedule.location,
      if (schedule.latitude != null) 'latitude': schedule.latitude,
      if (schedule.longitude != null) 'longitude': schedule.longitude,
      if (schedule.facilityId != null) 'facilityId': schedule.facilityId,
      if (schedule.facilityName != null) 'facilityName': schedule.facilityName,
      if (schedule.staffName != null) 'staffName': schedule.staffName,
      if (schedule.staffPhone != null) 'staffPhone': schedule.staffPhone,
      if (schedule.price != null) 'price': schedule.price,
      if (schedule.services != null) 'services': schedule.services,
      'hasReminder': schedule.hasReminder,
      if (schedule.reminderTime != null) 'reminderTime': schedule.reminderTime!.inMinutes,
      if (schedule.reminderTimes != null)
        'reminderTimes': schedule.reminderTimes!.map((d) => d.inMinutes).toList(),
      'isRecurring': schedule.isRecurring,
      if (schedule.recurrenceRule != null) 'recurrenceRule': schedule.recurrenceRule,
      if (schedule.notes != null) 'notes': schedule.notes,
      if (schedule.specialRequests != null) 'specialRequests': schedule.specialRequests,
      if (schedule.customData != null) 'customData': schedule.customData,
    };
  }

  /// ScheduleType enum을 문자열로 변환
  static String _scheduleTypeToString(ScheduleType type) {
    return type.toString().split('.').last;
  }

  /// 문자열을 ScheduleType enum으로 변환
  static ScheduleType? _parseScheduleType(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return ScheduleType.values.firstWhere(
      (e) => e.toString().split('.').last == str,
      orElse: () => ScheduleType.custom,
    );
  }

  /// ScheduleStatus enum을 문자열로 변환
  static String _scheduleStatusToString(ScheduleStatus status) {
    return status.toString().split('.').last;
  }

  /// 문자열을 ScheduleStatus enum으로 변환
  static ScheduleStatus? _parseScheduleStatus(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return ScheduleStatus.values.firstWhere(
      (e) => e.toString().split('.').last == str,
      orElse: () => ScheduleStatus.pending,
    );
  }

  /// SchedulePriority enum을 문자열로 변환
  static String _schedulePriorityToString(SchedulePriority priority) {
    return priority.toString().split('.').last;
  }

  /// 문자열을 SchedulePriority enum으로 변환
  static SchedulePriority? _parseSchedulePriority(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return SchedulePriority.values.firstWhere(
      (e) => e.toString().split('.').last == str,
      orElse: () => SchedulePriority.normal,
    );
  }

  /// 안전한 bool 파싱 (int 1/0 또는 bool 처리)
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return null;
  }

  /// 안전한 int 파싱
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// 안전한 double 파싱
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
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
