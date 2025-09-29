import 'package:aipet_frontend/features/splash/domain/entities/splash_state.dart';
import 'package:aipet_frontend/features/splash/domain/repositories/splash_repository.dart';
import 'package:aipet_frontend/features/splash/domain/usecases/manage_splash_sequence_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'manage_splash_sequence_usecase_test.mocks.dart';

@GenerateMocks([SplashRepository])
void main() {
  late ManageSplashSequenceUseCase useCase;
  late MockSplashRepository mockRepository;

  setUp(() {
    mockRepository = MockSplashRepository();
    useCase = ManageSplashSequenceUseCase(mockRepository);
  });

  group('ManageSplashSequenceUseCase', () {
    test('should execute splash sequence successfully', () async {
      // Arrange
      when(
        mockRepository.initializeApp(),
      ).thenAnswer((_) async => Result.success('アプリ初期化が完了しました'));

      // Act
      final results = <Result<SplashState>>[];
      await for (final result in useCase.execute()) {
        results.add(result);
      }

      // Assert
      expect(results.length, greaterThan(0));
      expect(results.every((r) => r.isSuccess), isTrue);

      // Check that we have the expected states
      final states = results
          .map((r) => r.data)
          .whereType<SplashState>()
          .toList();
      expect(states.any((s) => s.isInitializing), isTrue);
      expect(states.any((s) => s.isLoading), isTrue);
      expect(states.any((s) => s.isCompanyLogo), isTrue);
      expect(states.any((s) => s.isAppLogo), isTrue);
      expect(states.any((s) => s.isCompleted), isTrue);

      verify(mockRepository.initializeApp()).called(1);
    });

    test('should handle repository errors gracefully', () async {
      // Arrange
      when(
        mockRepository.initializeApp(),
      ).thenAnswer((_) async => Result.failure('初期化に失敗しました'));

      // Act
      final results = <Result<SplashState>>[];
      await for (final result in useCase.execute()) {
        results.add(result);
      }

      // Assert
      expect(results.length, greaterThan(0));
      expect(results.every((r) => r.isSuccess), isTrue);

      // Even with errors, the sequence should complete
      final states = results
          .map((r) => r.data)
          .whereType<SplashState>()
          .toList();
      expect(states.any((s) => s.isCompleted), isTrue);

      verify(mockRepository.initializeApp()).called(1);
    });

    test('should determine next route correctly', () async {
      // Act
      final result = await useCase.determineNextRoute();

      // Assert
      expect(result, isA<Result<String>>());
      expect(result.isSuccess, isTrue);
      expect(result.data, equals('/onboarding'));
      expect(result.message, equals('オンボーディング画面へ移動'));
    });
  });
}
