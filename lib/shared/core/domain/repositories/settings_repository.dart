import 'package:aipet_frontend/shared/core/domain/result.dart';

/// ⚙️ 설정 리포지토리 인터페이스
///
/// 앱 설정 관련 데이터 접근을 위한 추상 인터페이스
abstract class SettingsRepository {
  /// 사용자 설정 로드
  Future<Result<Map<String, dynamic>>> loadUserSettings(String userId);

  /// 사용자 설정 저장
  Future<Result<void>> saveUserSettings(String userId, Map<String, dynamic> settings);

  /// 앱 설정 로드
  Future<Result<Map<String, dynamic>>> loadAppSettings();

  /// 앱 설정 저장
  Future<Result<void>> saveAppSettings(Map<String, dynamic> settings);

  /// 설정 초기화
  Future<Result<void>> resetSettings(String userId);
}