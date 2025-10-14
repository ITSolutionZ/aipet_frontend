import 'package:aipet_frontend/shared/core/domain/result.dart';

/// Settings Feature 전용 Repository 인터페이스
abstract class SettingsRepository {
  /// 사용자 프로필 가져오기
  Future<Result<Map<String, dynamic>>> getUserProfile();

  /// 사용자 프로필 업데이트
  Future<Result<Map<String, dynamic>>> updateUserProfile(
    Map<String, dynamic> profile,
  );

  /// 비밀번호 변경
  Future<Result<void>> changePassword(Map<String, dynamic> request);

  /// 계정 삭제
  Future<Result<void>> deleteAccount();

  /// 앱 설정 가져오기
  Future<Result<Map<String, dynamic>>> getAppSettings();

  /// 앱 설정 저장
  Future<Result<Map<String, dynamic>>> saveAppSettings(
    Map<String, dynamic> settings,
  );

  /// 앱 데이터 내보내기
  Future<Result<Result>> exportAppData();

  /// 앱 데이터 가져오기
  Future<Result<void>> importAppData(String filePath);

  /// 앱 캐시 정리
  Future<Result<void>> clearAppCache();

  /// 캐시 크기 가져오기
  Future<Result<int>> getCacheSize();

  /// 사용자 위치 정보 저장
  Future<Result<void>> saveUserLocation({
    required String postalCode,
    required String address,
    String? detailAddress,
  });

  /// 사용자 위치 정보 가져오기
  Future<Result<Map<String, dynamic>>> getUserLocation();
}
