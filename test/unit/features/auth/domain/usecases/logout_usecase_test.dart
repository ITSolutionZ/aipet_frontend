import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'logout_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  group('LogoutUseCase', () {
    test('should return success when logout is successful', () async {
      // Arrange
      when(mockRepository.signOut()).thenAnswer((_) async {});

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isTrue);
      expect(result.message, equals('ログアウトしました'));
      verify(mockRepository.signOut()).called(1);
    });

    test('should return failure when logout fails', () async {
      // Arrange
      when(mockRepository.signOut()).thenThrow(Exception('Logout failed'));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('ログアウトに失敗しました'));
      verify(mockRepository.signOut()).called(1);
    });
  });
}
