import '../../domain/entities/logo_entity.dart';
import '../../domain/repositories/logo_repository.dart';

class LogoRepositoryImpl implements LogoRepository {
  @override
  Future<LogoEntity> getLogoConfig() async {
    // 시뮬레이션된 로고 설정
    await Future.delayed(const Duration(milliseconds: 100));

    return const LogoEntity(
      imagePath: 'assets/icons/itz.png',
      displayDuration: Duration(seconds: 2),
      nextRoute: '/splash',
    );
  }

  @override
  Future<void> initializeApp() async {
    // 앱 초기화는 bootstrap에서 처리하므로 여기서는 아무것도 하지 않음
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
