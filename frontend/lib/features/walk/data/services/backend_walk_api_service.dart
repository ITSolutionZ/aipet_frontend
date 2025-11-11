import 'package:dio/dio.dart';

import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/shared.dart';

/// 백엔드 Walk API 서비스
///
/// BackendApiClient를 사용하여 산책 기록 CRUD를 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
///
/// 백엔드 API: /api/v1/activity/pets/:petId/walks
class BackendWalkApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  // =========================================================================
  // 산책 기록 (Walks)
  // =========================================================================

  /// 산책 기록 조회
  ///
  /// GET /activity/pets/:petId/walks
  static Future<Result<List<Map<String, dynamic>>>> getWalks({
    required String petId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _apiClient.get(
        '/activity/pets/$petId/walks',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> walks = [];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              walks.add(item);
            }
          }
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              walks.add(item);
            }
          }
        }

        return Result.success('散歩記録を取得しました', walks);
      } else {
        return Result.failure('散歩記録の取得に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('산책 기록 조회', e);
    } catch (e) {
      return Result.failure('散歩記録の取得に失敗しました');
    }
  }

  /// 산책 기록 생성
  ///
  /// POST /activity/pets/:petId/walks
  static Future<Result<Map<String, dynamic>>> createWalk({
    required String petId,
    required DateTime startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? distanceMeters,
    List<Map<String, dynamic>>? routeData,
    double? temperature,
    String? weather,
    int? poopCount,
    int? peeCount,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/activity/pets/$petId/walks',
        data: {
          'startTime': startTime.toIso8601String(),
          if (endTime != null) 'endTime': endTime.toIso8601String(),
          if (durationMinutes != null) 'durationMinutes': durationMinutes,
          if (distanceMeters != null) 'distanceMeters': distanceMeters,
          if (routeData != null) 'routeData': routeData,
          if (temperature != null) 'temperature': temperature,
          if (weather != null) 'weather': weather,
          if (poopCount != null) 'poopCount': poopCount,
          if (peeCount != null) 'peeCount': peeCount,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final walk = data['data'] ?? data;
          return Result.success('散歩記録を作成しました', walk);
        }
      }
      return Result.failure('散歩記録の作成に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('산책 기록 생성', e);
    } catch (e) {
      return Result.failure('散歩記録の作成に失敗しました');
    }
  }

  /// 산책 기록 수정
  ///
  /// PUT /activity/pets/:petId/walks/:walkId
  static Future<Result<Map<String, dynamic>>> updateWalk({
    required String petId,
    required String walkId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? distanceMeters,
    List<Map<String, dynamic>>? routeData,
    double? temperature,
    String? weather,
    int? poopCount,
    int? peeCount,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.put(
        '/activity/pets/$petId/walks/$walkId',
        data: {
          if (startTime != null) 'startTime': startTime.toIso8601String(),
          if (endTime != null) 'endTime': endTime.toIso8601String(),
          if (durationMinutes != null) 'durationMinutes': durationMinutes,
          if (distanceMeters != null) 'distanceMeters': distanceMeters,
          if (routeData != null) 'routeData': routeData,
          if (temperature != null) 'temperature': temperature,
          if (weather != null) 'weather': weather,
          if (poopCount != null) 'poopCount': poopCount,
          if (peeCount != null) 'peeCount': peeCount,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final walk = data['data'] ?? data;
          return Result.success('散歩記録を更新しました', walk);
        }
      }
      return Result.failure('散歩記録の更新に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('산책 기록 수정', e);
    } catch (e) {
      return Result.failure('散歩記録の更新に失敗しました');
    }
  }

  /// 산책 기록 삭제
  ///
  /// DELETE /activity/pets/:petId/walks/:walkId
  static Future<Result<void>> deleteWalk({
    required String petId,
    required String walkId,
  }) async {
    try {
      final response = await _apiClient.delete(
        '/activity/pets/$petId/walks/$walkId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success('散歩記録を削除しました', null);
      } else {
        return Result.failure('散歩記録の削除に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('산책 기록 삭제', e);
    } catch (e) {
      return Result.failure('散歩記録の削除に失敗しました');
    }
  }

  /// 산책 통계 조회
  ///
  /// GET /activity/pets/:petId/walks/stats
  static Future<Result<Map<String, dynamic>>> getWalkStats({
    required String petId,
    int? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (period != null) {
        queryParams['period'] = period;
      }

      final response = await _apiClient.get(
        '/activity/pets/$petId/walks/stats',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final stats = data['data'] ?? data;
          return Result.success('散歩統計を取得しました', stats);
        }
      }
      return Result.failure('散歩統計の取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('산책 통계 조회', e);
    } catch (e) {
      return Result.failure('散歩統計の取得に失敗しました');
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
