import 'package:url_launcher/url_launcher.dart';
import '../../domain/services/microchip_service.dart';

/// 마이크로칩 서비스 구현체
/// External Service 호출을 Data Layer에서 처리
class MicrochipServiceImpl implements MicrochipService {
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

  @override
  Future<bool> validateMicrochipNumber(String number) async {
    // 실제 구현에서는 API 호출을 통해 유효성 검증
    // 현재는 로컬 검증만 수행
    if (number.isEmpty || number.length != 15) {
      return false;
    }
    
    // 숫자만 포함하는지 확인
    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(number);
    if (!isNumeric) {
      return false;
    }
    
    // TODO: 실제 마이크로칩 데이터베이스와 연동하여 검증
    // 현재는 항상 true 반환 (기본 검증만 수행)
    return true;
  }
}