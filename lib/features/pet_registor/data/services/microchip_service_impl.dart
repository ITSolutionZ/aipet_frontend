import 'package:aipet_frontend/features/pet_registor/domain/services/microchip_service.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:url_launcher/url_launcher.dart';

/// 마이크로칩 서비스 구현체
/// External Service 호출을 Data Layer에서 처리
class MicrochipServiceImpl implements MicrochipService {
  @override
  Future<Result<bool>> validateMicrochipNumber(String microchipNumber) async {
    try {
      // 실제 구현에서는 API 호출을 통해 유효성 검증
      // 현재는 로컬 검증만 수행
      if (microchipNumber.isEmpty || microchipNumber.length != 15) {
        return const Failure('마이크로칩 번호는 15자리여야 합니다');
      }

      // 숫자만 포함하는지 확인
      final isNumeric = RegExp(r'^[0-9]+$').hasMatch(microchipNumber);
      if (!isNumeric) {
        return const Failure('마이크로칩 번호는 숫자만 포함해야 합니다');
      }

      // TODO: 실제 마이크로칩 데이터베이스와 연동하여 검증
      // 현재는 항상 true 반환 (기본 검증만 수행)
      return const Success(true);
    } catch (error) {
      return Result.failure('마이크로칩 번호 검증 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getPetInfoByMicrochip(
    String microchipNumber,
  ) async {
    try {
      // TODO: 실제 마이크로칩 데이터베이스에서 펫 정보 조회
      // 현재는 Mock 데이터 반환
      return Success({
        'microchipNumber': microchipNumber,
        'petName': 'Unknown Pet',
        'ownerName': 'Unknown Owner',
        'registrationDate': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      return Result.failure('마이크로칩으로 펫 정보 조회 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> registerMicrochipNumber(
    String petId,
    String microchipNumber,
  ) async {
    try {
      // TODO: 실제 마이크로칩 등록 API 호출
      return const Success(null, '마이크로칩 번호가 성공적으로 등록되었습니다');
    } catch (error) {
      return Result.failure('마이크로칩 번호 등록 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  @override
  Future<void> openRegistrationSite() async {
    const url = 'https://reg.mc.env.go.jp/owner/top_user';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch microchip registration site');
    }
  }
}
