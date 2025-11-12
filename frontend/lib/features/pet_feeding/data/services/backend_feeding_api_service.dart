import 'package:dio/dio.dart';

import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/feeding_record_entity.dart';

/// 백엔드 Feeding API 서비스
///
/// BackendApiClient를 사용하여 급식 관리 CRUD를 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
class BackendFeedingApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 급식 기록 목록 조회
  ///
  /// GET /activity/pets/:petId/feedings
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<List<FeedingRecordEntity>>> getFeedings({
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
        '/activity/pets/$petId/feedings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<FeedingRecordEntity> feedings = [];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              feedings.add(_mapToFeedingEntity(item, petId));
            }
          }
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              feedings.add(_mapToFeedingEntity(item, petId));
            }
          }
        }

        return Result.success('給餌記録を取得しました', feedings);
      } else {
        return Result.failure('給餌記録の取得に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('급식 기록 조회', e);
    } catch (e) {
      return Result.failure('給餌記録の取得に失敗しました');
    }
  }

  /// 급식 기록 생성
  ///
  /// POST /activity/pets/:petId/feedings
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<FeedingRecordEntity>> createFeeding({
    required String petId,
    required FeedingRecordEntity feeding,
  }) async {
    try {
      final feedingData = _feedingEntityToMap(feeding);
      final response = await _apiClient.post(
        '/activity/pets/$petId/feedings',
        data: feedingData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final createdFeeding = _mapToFeedingEntity(
            data['data'] ?? data,
            petId,
          );
          return Result.success('給餌記録を作成しました', createdFeeding);
        }

        return Result.failure('給餌記録の作成に失敗しました');
      } else {
        return Result.failure('給餌記録の作成に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('급식 기록 생성', e);
    } catch (e) {
      return Result.failure('給餌記録の作成に失敗しました');
    }
  }

  /// 급식 기록 수정
  ///
  /// PUT /activity/pets/:petId/feedings/:feedingId
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<FeedingRecordEntity>> updateFeeding({
    required String petId,
    required FeedingRecordEntity feeding,
  }) async {
    try {
      final feedingData = _feedingEntityToMap(feeding);
      final response = await _apiClient.put(
        '/activity/pets/$petId/feedings/${feeding.id}',
        data: feedingData,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final updatedFeeding = _mapToFeedingEntity(
            data['data'] ?? data,
            petId,
          );
          return Result.success('給餌記録を更新しました', updatedFeeding);
        }

        return Result.failure('給餌記録の更新に失敗しました');
      } else {
        return Result.failure('給餌記録の更新に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('급식 기록 수정', e);
    } catch (e) {
      return Result.failure('給餌記録の更新に失敗しました');
    }
  }

  /// 급식 기록 삭제
  ///
  /// DELETE /activity/pets/:petId/feedings/:feedingId
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<void>> deleteFeeding({
    required String petId,
    required String feedingId,
  }) async {
    try {
      final response = await _apiClient.delete(
        '/activity/pets/$petId/feedings/$feedingId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success('給餌記録を削除しました', null);
      } else {
        return Result.failure('給餌記録の削除に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('급식 기록 삭제', e);
    } catch (e) {
      return Result.failure('給餌記録の削除に失敗しました');
    }
  }

  /// 급식 통계 조회
  ///
  /// GET /activity/pets/:petId/feedings/stats
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<FeedingStatistics>> getFeedingStats({
    required String petId,
    int? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (period != null) {
        queryParams['period'] = period;
      }

      final response = await _apiClient.get(
        '/activity/pets/$petId/feedings/stats',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final statsData = data['data'] ?? data;
          final stats = _mapToFeedingStatistics(statsData);
          return Result.success('給餌統計を取得しました', stats);
        }

        return Result.failure('給餌統計の取得に失敗しました');
      } else {
        return Result.failure('給餌統計の取得に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('급식 통계 조회', e);
    } catch (e) {
      return Result.failure('給餌統計の取得に失敗しました');
    }
  }

  /// 백엔드 응답 데이터를 FeedingRecordEntity로 변환
  static FeedingRecordEntity _mapToFeedingEntity(
    Map<String, dynamic> json,
    String petId,
  ) {
    // 백엔드 feeding_time → 프론트엔드 fedTime
    final feedingTime = json['feeding_time'] ?? json['feedingTime'];
    final fedTime = feedingTime != null
        ? DateTime.tryParse(feedingTime) ?? DateTime.now()
        : DateTime.now();

    // amount_grams → amount
    final amountGrams = json['amount_grams'] ?? json['amountGrams'] ?? 0.0;
    final amount = (amountGrams as num).toDouble();

    // 상태는 백엔드에 없으므로 기본값 completed
    // meal_type이 있으면 notes에 추가
    final mealType = json['meal_type'] ?? json['mealType'];
    final notes = json['notes'] as String?;
    final combinedNotes = mealType != null
        ? '${notes ?? ''}\nMeal Type: $mealType'.trim()
        : notes;

    return FeedingRecordEntity(
      id: json['id']?.toString() ?? '',
      petId: petId,
      petName: json['pet_name'] ?? json['petName'] ?? '',
      fedTime: fedTime,
      amount: amount,
      foodType: json['food_type'] ?? json['foodType'] ?? '',
      foodBrand: json['food_brand'] ?? json['foodBrand'] ?? '',
      status: FeedingStatus.completed,
      notes: combinedNotes,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// FeedingRecordEntity를 백엔드 요청 데이터로 변환
  static Map<String, dynamic> _feedingEntityToMap(FeedingRecordEntity feeding) {
    // meal_type 추출 (notes에서)
    String? mealType;
    if (feeding.notes != null && feeding.notes!.contains('Meal Type:')) {
      final match = RegExp(r'Meal Type: (\w+)').firstMatch(feeding.notes!);
      if (match != null) {
        mealType = match.group(1);
      }
    }

    return {
      'feedingTime': feeding.fedTime.toIso8601String(),
      'foodType': feeding.foodType,
      'foodBrand': feeding.foodBrand,
      'amountGrams': feeding.amount,
      'mealType': mealType,
      'notes': feeding.notes?.replaceAll(RegExp(r'\nMeal Type: \w+'), ''),
    };
  }

  /// 백엔드 통계 데이터를 FeedingStatistics로 변환
  static FeedingStatistics _mapToFeedingStatistics(Map<String, dynamic> json) {
    return FeedingStatistics(
      totalFeedings: json['totalFeedings'] ?? json['total_feedings'] ?? 0,
      completedFeedings:
          json['completedFeedings'] ?? json['completed_feedings'] ?? 0,
      skippedFeedings: json['skippedFeedings'] ?? json['skipped_feedings'] ?? 0,
      totalAmount: ((json['totalAmount'] ?? json['total_amount'] ?? 0.0) as num)
          .toDouble(),
      averageAmount:
          ((json['averageAmount'] ?? json['average_amount'] ?? 0.0) as num)
              .toDouble(),
      completionRate:
          ((json['completionRate'] ?? json['completion_rate'] ?? 0.0) as num)
              .toDouble(),
      feedingsByHour: (json['feedingsByHour'] ?? json['feedings_by_hour'] ?? {})
          .map<String, int>(
            (key, value) => MapEntry(key.toString(), (value as num).toInt()),
          ),
    );
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
