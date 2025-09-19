import '../../../../shared/shared.dart';
import '../../domain/entities/splash_entity.dart';
import '../../domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  @override
  Future<Result<SplashEntity>> getSplashConfig() async {
    try {
      // 실제로는 API나 로컬 저장소에서 설정을 가져올 수 있음
      await Future.delayed(const Duration(milliseconds: 300)); // 시뮬레이션

      const config = SplashEntity(
        logoPath: 'assets/icons/aipet_logo.png',
        animationDuration: Duration(milliseconds: 2000),
        displayDuration: Duration(milliseconds: 1000),
        nextRoute: '/home',
      );

      return Result.success('スプラッシュ設定を取得しました', config);
    } catch (error) {
      return Result.failure('スプラッシュ設定の取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> initializeApp() async {
    try {
      // 앱 초기화 로직 (예: 설정 로드, 캐시 정리 등)
      await Future.delayed(const Duration(milliseconds: 200));
      return Result.success('アプリ初期化が完了しました');
    } catch (error) {
      return Result.failure('アプリ初期化に失敗しました: ${error.toString()}');
    }
  }
}
