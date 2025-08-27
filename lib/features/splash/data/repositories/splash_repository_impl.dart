import '../../domain/entities/splash_entity.dart';
import '../../domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  @override
  Future<SplashEntity> getSplashConfig() async {
    // 실제로는 API나 로컬 저장소에서 설정을 가져올 수 있음
    await Future.delayed(const Duration(milliseconds: 300)); // 시뮬레이션

    return const SplashEntity(
      logoPath: 'assets/icons/aipet_logo.png',
      animationDuration: Duration(milliseconds: 2000),
      displayDuration: Duration(milliseconds: 1000),
      nextRoute: '/home',
    );
  }

  @override
  Future<void> initializeApp() async {
    // 앱 초기화 로직 (예: 설정 로드, 캐시 정리 등)
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
