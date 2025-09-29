import 'package:aipet_frontend/shared/shared.dart';

/// 스플래시 관련 Repository 인터페이스
abstract class SplashRepository {
  /// 스플래시 설정 가져오기
  Future<Result<SplashEntity>> getSplashConfig();

  /// 앱 초기화
  Future<Result<void>> initializeApp();

  /// 스플래시 시퀀스 실행
  Stream<Result<SplashState>> executeSplashSequence();

  /// 다음 화면 경로 결정
  Future<Result<String>> determineNextRoute();
}
