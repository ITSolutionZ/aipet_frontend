import 'package:aipet_frontend/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:aipet_frontend/features/splash/domain/entities/splash_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SplashRepositoryImpl repository;

  setUp(() {
    repository = SplashRepositoryImpl();
  });

  group('SplashRepositoryImpl', () {
    test(
      'should return splash config when getSplashConfig is called',
      () async {
        // Act
        final result = await repository.getSplashConfig();

        // Assert
        expect(result, isA<Result<SplashEntity>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isA<SplashEntity>());
        expect(result.data!.logoPath, equals('assets/icons/aipet_logo.png'));
        expect(
          result.data!.animationDuration,
          equals(const Duration(milliseconds: 2000)),
        );
        expect(
          result.data!.displayDuration,
          equals(const Duration(milliseconds: 1000)),
        );
        expect(result.data!.nextRoute, equals('/home'));
        expect(result.message, equals('スプラッシュ設定を取得しました'));
      },
    );

    test('should return success when initializeApp is called', () async {
      // Act
      final result = await repository.initializeApp();

      // Assert
      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isTrue);
      expect(result.message, equals('アプリ初期化が完了しました'));
    });
  });
}
