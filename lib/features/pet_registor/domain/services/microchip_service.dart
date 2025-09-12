/// 마이크로칩 관련 서비스 인터페이스
abstract class MicrochipService {
  /// 마이크로칩 등록 사이트 열기
  Future<void> openRegistrationSite();
  
  /// 마이크로칩 번호 유효성 확인
  Future<bool> validateMicrochipNumber(String number);
}