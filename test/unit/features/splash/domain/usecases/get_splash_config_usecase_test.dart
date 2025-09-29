import 'package:aipet_frontend/features/splash/domain/entities/splash_entity.dart';
import 'package:aipet_frontend/features/splash/domain/repositories/splash_repository.dart';
import 'package:aipet_frontend/features/splash/domain/usecases/get_splash_config_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_splash_config_usecase_test.mocks.dart';

@GenerateMocks([SplashRepository])
void main() {
  late GetSplashConfigUseCase useCase;
  late MockSplashRepository mockRepository;

  setUp(() {
    mockRepository = MockSplashRepository();
    useCase = GetSplashConfigUseCase(mockRepository);
  });

  group('GetSplashConfigUseCase', () {
    test(
      'should return splash config when repository call is successful',
      () async {
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

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<Result<SplashEntity>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(expectedConfig));
        expect(result.message, equals('スプラッシュ設定を取得しました'));
        verify(mockRepository.getSplashConfig()).called(1);
      },
    );

    test('should return failure when repository call fails', () async {
      // Arrange
      when(
        mockRepository.getSplashConfig(),
      ).thenAnswer((_) async => Result.failure('設定の取得に失敗しました'));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Result<SplashEntity>>());
      expect(result.isSuccess, isFalse);
      expect(result.message, equals('設定の取得に失敗しました'));
      verify(mockRepository.getSplashConfig()).called(1);
    });
  });
}
