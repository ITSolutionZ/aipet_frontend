import 'package:aipet_frontend/features/scheduling/data/services/feeding_local_storage_service.dart';
import 'package:aipet_frontend/features/scheduling/domain/repositories/feeding_repository.dart';
import 'package:aipet_frontend/shared/core/services/firestore_feeding_service.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// Firestore를 사용하는 급식 관리 Repository 구현체
///
/// 급식 기록은 Firestore에 저장하고, 정적 데이터는 로컬에서 관리합니다.
class FirestoreFeedingRepository implements FeedingRepository {
  @override
  Future<Result<Map<String, dynamic>>> getPetSizeFeedingInfo() async {
    try {
      // 정적 데이터는 로컬에서 관리
      await Future.delayed(const Duration(milliseconds: 200));
      final data = FeedingLocalStorageService.getPetSizeFeedingInfo();
      return Result.success('ペットサイズ給餌量情報を取得しました', data);
    } catch (error) {
      return Result.failure('ペットサイズ給餌量情報の取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getPetSizeFeedingGuide() async {
    try {
      // 정적 데이터는 로컬에서 관리
      await Future.delayed(const Duration(milliseconds: 150));
      final guide = FeedingLocalStorageService.getPetSizeFeedingGuide();
      return Result.success('ペットサイズ給餌ガイドを取得しました', guide);
    } catch (error) {
      return Result.failure('ペットサイズ給餌ガイドの取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> addFeedingRecord(Map<String, dynamic> record) async {
    try {
      LoggerService.debug(
        '📡 FirestoreFeedingRepository.addFeedingRecord() 호출',
      );

      final petId = record['petId'] as String?;
      if (petId == null) {
        return Result.failure('ペットIDが必要です');
      }

      final result = await FirestoreFeedingService.addFeedingRecord(
        petId,
        record,
      );

      if (result.isSuccess) {
        LoggerService.debug('✅ addFeedingRecord 성공');
        return Result.success('給餌記録を追加しました', null);
      } else {
        LoggerService.debug('❌ addFeedingRecord 실패: ${result.error}');
        return Result.failure('給餌記録の追加に失敗しました: ${result.error}');
      }
    } catch (error) {
      LoggerService.debug('❌ addFeedingRecord 예외: $error');
      return Result.failure('給餌記録の追加に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<List<String>>> getPetStatusOptions() async {
    try {
      // 정적 데이터는 로컬에서 관리
      await Future.delayed(const Duration(milliseconds: 100));
      final options = FeedingLocalStorageService.getPetStatusOptions();
      return Result.success('ペット状態オプションを取得しました', options);
    } catch (error) {
      return Result.failure('ペット状態オプションの取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getPetInfo(String petId) async {
    try {
      // 정적 데이터는 로컬에서 관리 (Mock 데이터)
      await Future.delayed(const Duration(milliseconds: 200));
      final petsInfo = FeedingLocalStorageService.getPetSizeFeedingInfo();
      final pet = petsInfo[petId];

      if (pet != null) {
        return Result.success('ペット情報を取得しました', pet);
      } else {
        return Result.success('ペットが見つかりません', null);
      }
    } catch (error) {
      return Result.failure('ペット情報の取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getFeedingRecords({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      LoggerService.debug(
        '📡 FirestoreFeedingRepository.getFeedingRecords() 호출',
      );
      LoggerService.debug('   petId: $petId');

      if (petId == null) {
        return Result.failure('ペットIDが必要です');
      }

      List<Map<String, dynamic>> records;

      // 날짜 범위가 지정된 경우
      if (startDate != null && endDate != null) {
        // 특정 날짜의 기록만 조회 (하루 단위)
        final result = await FirestoreFeedingService.getFeedingRecordsByDate(
          petId,
          startDate,
        );

        if (result.isSuccess) {
          records = result.dataOrNull ?? [];
        } else {
          LoggerService.debug('❌ getFeedingRecords 실패: ${result.error}');
          return Result.failure('給餌記録の取得に失敗しました: ${result.error}');
        }
      } else {
        // 전체 기록 조회
        final result = await FirestoreFeedingService.getFeedingRecords(petId);

        if (result.isSuccess) {
          records = result.dataOrNull ?? [];
        } else {
          LoggerService.debug('❌ getFeedingRecords 실패: ${result.error}');
          return Result.failure('給餌記録の取得に失敗しました: ${result.error}');
        }
      }

      LoggerService.debug('✅ getFeedingRecords 성공: ${records.length}개');
      return Result.success('給餌記録を取得しました', records);
    } catch (error) {
      LoggerService.debug('❌ getFeedingRecords 예외: $error');
      return Result.failure('給餌記録の取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getFeedingAnalysisData({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      LoggerService.debug(
        '📡 FirestoreFeedingRepository.getFeedingAnalysisData() 호출',
      );

      if (petId == null) {
        return Result.failure('ペットIDが必要です');
      }

      // Firestore에서 급식 기록 가져오기
      final recordsResult = await getFeedingRecords(
        petId: petId,
        startDate: startDate,
        endDate: endDate,
      );

      if (!recordsResult.isSuccess) {
        return Result.failure('分析データの取得に失敗しました: ${recordsResult.error}');
      }

      final records = recordsResult.dataOrNull ?? [];

      // 분석 데이터 계산
      final totalFeedings = records.length;
      final totalAmount = records.fold<double>(
        0.0,
        (sum, record) => sum + ((record['amount'] as num?)?.toDouble() ?? 0.0),
      );

      final analysisData = {
        'totalFeedings': totalFeedings,
        'totalAmount': totalAmount,
        'averageAmount': totalFeedings > 0 ? totalAmount / totalFeedings : 0.0,
        'records': records,
      };

      LoggerService.debug('✅ getFeedingAnalysisData 성공');
      return Result.success('分析データを取得しました', analysisData);
    } catch (error) {
      LoggerService.debug('❌ getFeedingAnalysisData 예외: $error');
      return Result.failure('分析データの取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> updateFeedingSchedule({
    required String petId,
    required String mealType,
    required String time,
    required String amount,
  }) async {
    try {
      LoggerService.debug(
        '📡 FirestoreFeedingRepository.updateFeedingSchedule() 호출',
      );

      final schedule = {'mealType': mealType, 'time': time, 'amount': amount};

      final result = await FirestoreFeedingService.updateFeedingSchedule(
        petId,
        schedule,
      );

      if (result.isSuccess) {
        LoggerService.debug('✅ updateFeedingSchedule 성공');
        return Result.success('給餌スケジュールを更新しました', null);
      } else {
        LoggerService.debug('❌ updateFeedingSchedule 실패: ${result.error}');
        return Result.failure('給餌スケジュールの更新に失敗しました: ${result.error}');
      }
    } catch (error) {
      LoggerService.debug('❌ updateFeedingSchedule 예외: $error');
      return Result.failure('給餌スケジュールの更新に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getFeedingSchedule(String petId) async {
    try {
      LoggerService.debug(
        '📡 FirestoreFeedingRepository.getFeedingSchedule() 호출',
      );

      final result = await FirestoreFeedingService.getFeedingSchedule(petId);

      if (result.isSuccess) {
        LoggerService.debug('✅ getFeedingSchedule 성공');
        return Result.success('給餌スケジュールを取得しました', result.dataOrNull ?? {});
      } else {
        LoggerService.debug('❌ getFeedingSchedule 실패: ${result.error}');
        return Result.failure('給餌スケジュールの取得に失敗しました: ${result.error}');
      }
    } catch (error) {
      LoggerService.debug('❌ getFeedingSchedule 예외: $error');
      return Result.failure('給餌スケジュールの取得に失敗しました: ${error.toString()}');
    }
  }
}
