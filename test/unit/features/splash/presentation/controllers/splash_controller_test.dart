import 'package:aipet_frontend/features/splash/domain/entities/splash_entity.dart';
import 'package:aipet_frontend/features/splash/domain/entities/splash_state.dart';
import 'package:aipet_frontend/features/splash/domain/repositories/splash_repository.dart';
import 'package:aipet_frontend/features/splash/domain/usecases/get_splash_config_usecase.dart';
import 'package:aipet_frontend/features/splash/domain/usecases/manage_splash_sequence_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'splash_controller_test.mocks.dart';

@GenerateMocks([SplashRepository])
void main() {
  late MockSplashRepository mockRepository;

  setUp(() {
    mockRepository = MockSplashRepository();
  });

  group('Splash UseCases Integration', () {
    test('should execute splash sequence successfully', () async {
      // Arrange
      when(
        mockRepository.initializeApp(),
      ).thenAnswer((_) async => Result.success('アプリ初期化が完了しました'));

      final useCase = ManageSplashSequenceUseCase(mockRepository);

      // Act
      final results = <Result<SplashState>>[];
      await for (final result in useCase.execute()) {
        results.add(result);
        if (results.length >= 2) break; // Limit to first 2 results for testing
      }

      // Assert
      expect(results.length, greaterThan(0));
      expect(results.every((r) => r.isSuccess), isTrue);
    });

    test('should determine next route successfully', () async {
      // Arrange
      final useCase = ManageSplashSequenceUseCase(mockRepository);

      // Act
      final result = await useCase.determineNextRoute();

      // Assert
      expect(result, isA<Result<String>>());
      expect(result.isSuccess, isTrue);
      expect(result.data, equals('/onboarding'));
    });

    test('should load splash config successfully', () async {
      // Arrange
      const expectedConfig = SplashEntity(
        logoPath: 'assets/icons/aipet_logo.png',
        animationDuration: Duration(milliseconds: 2000),
        displayDuration: Duration(milliseconds: 1000),
        nextRoute: '/home',
      );

      when(mockRepository.getSplashConfig()).thenAnswer(
        (_) async => Result.success('スプラッシュ設定を取得しました', expectedConfig),
      );

      final useCase = GetSplashConfigUseCase(mockRepository);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Result<SplashEntity>>());
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(expectedConfig));
      verify(mockRepository.getSplashConfig()).called(1);
    });

    test('should handle errors in loadSplashConfig', () async {
      // Arrange
      when(
        mockRepository.getSplashConfig(),
      ).thenAnswer((_) async => Result.failure('設定の取得に失敗しました'));

      final useCase = GetSplashConfigUseCase(mockRepository);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Result<SplashEntity>>());
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('設定の取得に失敗しました'));
    });
  });
}
