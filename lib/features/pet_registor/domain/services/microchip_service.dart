import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 마이크로칩 서비스 인터페이스
abstract class MicrochipService {
  /// 마이크로칩 번호 검증
  Future<Result<bool>> validateMicrochipNumber(String microchipNumber);

  /// 마이크로칩 번호로 펫 정보 조회
  Future<Result<Map<String, dynamic>?>> getPetInfoByMicrochip(String microchipNumber);

  /// 마이크로칩 번호 등록
  Future<Result<void>> registerMicrochipNumber(String petId, String microchipNumber);

  /// 마이크로칩 등록 사이트 열기
  Future<void> openRegistrationSite();
}
