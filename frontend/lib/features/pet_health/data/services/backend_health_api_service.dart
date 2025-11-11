import 'package:dio/dio.dart';

import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/shared.dart';

/// 백엔드 Health API 서비스
///
/// BackendApiClient를 사용하여 건강 기록 CRUD를 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
///
/// 백엔드 API: /api/v1/health/pets/:petId/...
class BackendHealthApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  // =========================================================================
  // 예방접종 (Vaccinations)
  // =========================================================================

  /// 예방접종 기록 조회
  ///
  /// GET /health/pets/:petId/vaccinations
  static Future<Result<List<Map<String, dynamic>>>> getVaccinations({
    required String petId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/health/pets/$petId/vaccinations',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> vaccinations = [];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              vaccinations.add(item);
            }
          }
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              vaccinations.add(item);
            }
          }
        }

        return Result.success('予防接種記録を取得しました', vaccinations);
      } else {
        return Result.failure('予防接種記録の取得に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('예방접종 조회', e);
    } catch (e) {
      return Result.failure('予防接種記録の取得に失敗しました');
    }
  }

  /// 예방접종 기록 생성
  ///
  /// POST /health/pets/:petId/vaccinations
  static Future<Result<Map<String, dynamic>>> createVaccination({
    required String petId,
    required String vaccineName,
    String? vaccineType,
    required DateTime vaccinationDate,
    DateTime? nextDueDate,
    String? veterinarianName,
    String? clinicName,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/health/pets/$petId/vaccinations',
        data: {
          'vaccineName': vaccineName,
          if (vaccineType != null) 'vaccineType': vaccineType,
          'vaccinationDate': vaccinationDate.toIso8601String(),
          if (nextDueDate != null)
            'nextDueDate': nextDueDate.toIso8601String(),
          if (veterinarianName != null) 'veterinarianName': veterinarianName,
          if (clinicName != null) 'clinicName': clinicName,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final vaccination = data['data'] ?? data;
          return Result.success('予防接種記録を作成しました', vaccination);
        }
      }
      return Result.failure('予防接種記録の作成に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('예방접종 생성', e);
    } catch (e) {
      return Result.failure('予防接種記録の作成に失敗しました');
    }
  }

  /// 예방접종 기록 수정
  ///
  /// PUT /health/pets/:petId/vaccinations/:vaccinationId
  static Future<Result<Map<String, dynamic>>> updateVaccination({
    required String petId,
    required String vaccinationId,
    String? vaccineName,
    String? vaccineType,
    DateTime? vaccinationDate,
    DateTime? nextDueDate,
    String? veterinarianName,
    String? clinicName,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.put(
        '/health/pets/$petId/vaccinations/$vaccinationId',
        data: {
          if (vaccineName != null) 'vaccineName': vaccineName,
          if (vaccineType != null) 'vaccineType': vaccineType,
          if (vaccinationDate != null)
            'vaccinationDate': vaccinationDate.toIso8601String(),
          if (nextDueDate != null)
            'nextDueDate': nextDueDate.toIso8601String(),
          if (veterinarianName != null) 'veterinarianName': veterinarianName,
          if (clinicName != null) 'clinicName': clinicName,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final vaccination = data['data'] ?? data;
          return Result.success('予防接種記録を更新しました', vaccination);
        }
      }
      return Result.failure('予防接種記録の更新に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('예방접종 수정', e);
    } catch (e) {
      return Result.failure('予防接種記録の更新に失敗しました');
    }
  }

  /// 예방접종 기록 삭제
  ///
  /// DELETE /health/pets/:petId/vaccinations/:vaccinationId
  static Future<Result<void>> deleteVaccination({
    required String petId,
    required String vaccinationId,
  }) async {
    try {
      final response = await _apiClient.delete(
        '/health/pets/$petId/vaccinations/$vaccinationId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success('予防接種記録を削除しました', null);
      } else {
        return Result.failure('予防接種記録の削除に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('예방접종 삭제', e);
    } catch (e) {
      return Result.failure('予防接種記録の削除に失敗しました');
    }
  }

  // =========================================================================
  // 의료 기록 (Medical Records)
  // =========================================================================

  /// 의료 기록 조회
  ///
  /// GET /health/pets/:petId/medical-records
  static Future<Result<List<Map<String, dynamic>>>> getMedicalRecords({
    required String petId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/health/pets/$petId/medical-records',
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

        return Result.success('医療記録を取得しました', records);
      } else {
        return Result.failure('医療記録の取得に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('의료 기록 조회', e);
    } catch (e) {
      return Result.failure('医療記録の取得に失敗しました');
    }
  }

  /// 의료 기록 생성
  ///
  /// POST /health/pets/:petId/medical-records
  static Future<Result<Map<String, dynamic>>> createMedicalRecord({
    required String petId,
    required DateTime visitDate,
    String? visitType,
    String? diagnosis,
    String? treatment,
    String? prescription,
    String? veterinarianName,
    String? clinicName,
    double? cost,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/health/pets/$petId/medical-records',
        data: {
          'visitDate': visitDate.toIso8601String(),
          if (visitType != null) 'visitType': visitType,
          if (diagnosis != null) 'diagnosis': diagnosis,
          if (treatment != null) 'treatment': treatment,
          if (prescription != null) 'prescription': prescription,
          if (veterinarianName != null) 'veterinarianName': veterinarianName,
          if (clinicName != null) 'clinicName': clinicName,
          if (cost != null) 'cost': cost,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final record = data['data'] ?? data;
          return Result.success('医療記録を作成しました', record);
        }
      }
      return Result.failure('医療記録の作成に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('의료 기록 생성', e);
    } catch (e) {
      return Result.failure('医療記録の作成に失敗しました');
    }
  }

  /// 의료 기록 수정
  ///
  /// PUT /health/pets/:petId/medical-records/:recordId
  static Future<Result<Map<String, dynamic>>> updateMedicalRecord({
    required String petId,
    required String recordId,
    DateTime? visitDate,
    String? visitType,
    String? diagnosis,
    String? treatment,
    String? prescription,
    String? veterinarianName,
    String? clinicName,
    double? cost,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.put(
        '/health/pets/$petId/medical-records/$recordId',
        data: {
          if (visitDate != null) 'visitDate': visitDate.toIso8601String(),
          if (visitType != null) 'visitType': visitType,
          if (diagnosis != null) 'diagnosis': diagnosis,
          if (treatment != null) 'treatment': treatment,
          if (prescription != null) 'prescription': prescription,
          if (veterinarianName != null) 'veterinarianName': veterinarianName,
          if (clinicName != null) 'clinicName': clinicName,
          if (cost != null) 'cost': cost,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final record = data['data'] ?? data;
          return Result.success('医療記録を更新しました', record);
        }
      }
      return Result.failure('医療記録の更新に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('의료 기록 수정', e);
    } catch (e) {
      return Result.failure('医療記録の更新に失敗しました');
    }
  }

  /// 의료 기록 삭제
  ///
  /// DELETE /health/pets/:petId/medical-records/:recordId
  static Future<Result<void>> deleteMedicalRecord({
    required String petId,
    required String recordId,
  }) async {
    try {
      final response = await _apiClient.delete(
        '/health/pets/$petId/medical-records/$recordId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success('医療記録を削除しました', null);
      } else {
        return Result.failure('医療記録の削除に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('의료 기록 삭제', e);
    } catch (e) {
      return Result.failure('医療記録の削除に失敗しました');
    }
  }

  // =========================================================================
  // 체중 기록 (Weight History)
  // =========================================================================

  /// 체중 기록 조회
  ///
  /// GET /health/pets/:petId/weight-history
  static Future<Result<List<Map<String, dynamic>>>> getWeightHistory({
    required String petId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/health/pets/$petId/weight-history',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> weights = [];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              weights.add(item);
            }
          }
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              weights.add(item);
            }
          }
        }

        return Result.success('体重記録を取得しました', weights);
      } else {
        return Result.failure('体重記録の取得に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('체중 기록 조회', e);
    } catch (e) {
      return Result.failure('体重記録の取得に失敗しました');
    }
  }

  /// 체중 기록 생성
  ///
  /// POST /health/pets/:petId/weight-history
  static Future<Result<Map<String, dynamic>>> createWeightRecord({
    required String petId,
    required double weight,
    DateTime? measuredAt,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/health/pets/$petId/weight-history',
        data: {
          'weight': weight,
          if (measuredAt != null) 'measuredAt': measuredAt.toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final weightRecord = data['data'] ?? data;
          return Result.success('体重記録を作成しました', weightRecord);
        }
      }
      return Result.failure('体重記録の作成に失敗しました');
    } on DioException catch (e) {
      return _handleDioError('체중 기록 생성', e);
    } catch (e) {
      return Result.failure('体重記録の作成に失敗しました');
    }
  }

  // =========================================================================
  // 에러 처리
  // =========================================================================

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
