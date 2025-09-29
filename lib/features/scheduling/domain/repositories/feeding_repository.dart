import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 급여 기록 관련 데이터 추상화 인터페이스
abstract class FeedingRepository {
  /// 펫 사이즈 및 급여량 정보 가져오기
  Future<Result<Map<String, dynamic>>> getPetSizeFeedingInfo();

  /// 펫 사이즈 급여량 가이드 가져오기
  Future<Result<Map<String, dynamic>>> getPetSizeFeedingGuide();

  /// 급여 기록 추가
  Future<Result<void>> addFeedingRecord(Map<String, dynamic> record);

  /// 펫 상태 옵션 가져오기
  Future<Result<List<String>>> getPetStatusOptions();

  /// 펫 정보 가져오기
  Future<Result<Map<String, dynamic>?>> getPetInfo(String petId);

  /// 급여 기록 목록 가져오기
  Future<Result<List<Map<String, dynamic>>>> getFeedingRecords({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 급여 분석 데이터 가져오기
  Future<Result<Map<String, dynamic>>> getFeedingAnalysisData({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
