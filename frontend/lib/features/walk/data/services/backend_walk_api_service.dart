import 'package:dio/dio.dart';


import '../../../../shared/shared.dart';
import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';


/// 백엔드 Walk API 서비스
///
/// BackendApiClient를 사용하여 산책 기록 CRUD를 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
class BackendWalkApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 산책 기록 생성
  ///
  /// POST /api/walks
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<Map<String, dynamic>>> createWalk({
    required String petId,
    required String startTime,
    String? endTime,
    int? duration,
    double? distance,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post('/walks', data: {
        'pet_id': petId,
        'start_time': startTime,
        if (endTime != null) 'end_time': endTime,
        if (duration != null) 'duration': duration,
        if (distance != null) 'distance': distance,
        if (notes != null) 'notes': notes,
      });

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

  /// 특정 산책 기록 조회
  ///
  /// GET /api/walks/:walkId
  static Future<Result<Map<String, dynamic>?>> getWalkById(String walkId) async {
    try {
      final response = await _apiClient.get('/walks/$walkId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final walk = data['data'] ?? data;
          return Result.success('散歩記録を取得しました', walk);
        }
      } else if (response.statusCode == 404) {
        return Result.success('散歩記録が見つかりません', null);
      }
      return Result.failure('散歩記録の取得に失敗しました');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.success('散歩記録が見つかりません', null);
      }
      return _handleDioError('산책 기록 조회', e);
    } catch (e) {
      return Result.failure('散歩記録の取得に失敗しました');
    }
  }

  /// 펫의 산책 기록 목록 조회
  ///
  /// GET /api/pets/:petId/walks
  static Future<Result<List<Map<String, dynamic>>>> getPetWalks(
    String petId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/pets/$petId/walks',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
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

        return Result.success('散歩記録リストを取得しました', walks);
      }
      return Result.failure('散歩記録リストの取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('펫 산책 기록 조회', e);
    } catch (e) {
      return Result.failure('散歩記録リストの取得に失敗しました');
    }
  }

  /// 사용자의 모든 산책 기록 조회
  ///
  /// GET /api/walks
  static Future<Result<List<Map<String, dynamic>>>> getUserWalks({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/walks',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
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

        return Result.success('散歩記録リストを取得しました', walks);
      }
      return Result.failure('散歩記録リストの取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('사용자 산책 기록 조회', e);
    } catch (e) {
      return Result.failure('散歩記録リストの取得に失敗しました');
    }
  }

  /// 산책 기록 업데이트
  ///
  /// PUT /api/walks/:walkId
  static Future<Result<Map<String, dynamic>>> updateWalk(
    String walkId, {
    String? endTime,
    int? duration,
    double? distance,
    String? status,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.put('/walks/$walkId', data: {
        if (endTime != null) 'end_time': endTime,
        if (duration != null) 'duration': duration,
        if (distance != null) 'distance': distance,
        if (status != null) 'status': status,
        if (notes != null) 'notes': notes,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final walk = data['data'] ?? data;
          return Result.success('散歩記録を更新しました', walk);
        }
      }
      return Result.failure('散歩記録の更新に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('산책 기록 업데이트', e);
    } catch (e) {
      return Result.failure('散歩記録の更新に失敗しました');
    }
  }

  /// 산책 기록 삭제
  ///
  /// DELETE /api/walks/:walkId
  static Future<Result<void>> deleteWalk(String walkId) async {
    try {
      final response = await _apiClient.delete('/walks/$walkId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success('散歩記録を削除しました', null);
      }
      return Result.failure('散歩記録の削除に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('산책 기록 삭제', e);
    } catch (e) {
      return Result.failure('散歩記録の削除に失敗しました');
    }
  }

  /// 펫의 산책 통계 조회
  ///
  /// GET /api/pets/:petId/walks/statistics
  static Future<Result<Map<String, dynamic>>> getPetWalkStatistics(
    String petId,
  ) async {
    try {
      final response = await _apiClient.get('/pets/$petId/walks/statistics');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final stats = data['data'] ?? data;
          return Result.success('散歩統計を取得しました', stats);
        }
      }
      return Result.failure('散歩統計の取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('펫 산책 통계 조회', e);
    } catch (e) {
      return Result.failure('散歩統計の取得に失敗しました');
    }
  }

  /// 사용자의 산책 통계 조회
  ///
  /// GET /api/walks/statistics/user
  static Future<Result<Map<String, dynamic>>> getUserWalkStatistics() async {
    try {
      final response = await _apiClient.get('/walks/statistics/user');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final stats = data['data'] ?? data;
          return Result.success('散歩統計を取得しました', stats);
        }
      }
      return Result.failure('散歩統計の取得に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('사용자 산책 통계 조회', e);
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
